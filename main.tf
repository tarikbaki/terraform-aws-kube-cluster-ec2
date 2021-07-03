data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "azs" {}

locals {
    control_plane_sg_rules = {
        rule1 = {
            cidr_blocks = [ var.vpc_cidr_range ]
            description = "etcd server API"
            from_port = 2379
            ipv6_cidr_blocks = [ module.kube-vpc.vpc_ipv6_cidr_block ]
            protocol = "tcp"
            self = true
            to_port = 2380
        },
        rule2 = {
            cidr_blocks = [var.vpc_cidr_range]
            description = "kubelet API"
            from_port = 10250
            ipv6_cidr_blocks = [ module.kube-vpc.vpc_ipv6_cidr_block  ]
            protocol = "tcp"
            self = true
            to_port = 10250
        },
        rule3 = {
            cidr_blocks = [var.vpc_cidr_range]
            description = "kube scheduler"
            from_port = 10251
            ipv6_cidr_blocks = [ module.kube-vpc.vpc_ipv6_cidr_block  ]
            protocol = "tcp"
            self = true
            to_port = 10251
        },
        rule5 = {
            cidr_blocks = [var.vpc_cidr_range]
            description = "kube controller manager"
            from_port = 10252
            ipv6_cidr_blocks = [ module.kube-vpc.vpc_ipv6_cidr_block  ]
            protocol = "tcp"
            self = true
            to_port = 10252
        }
    }
}

module "kube-vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "3.2.0"

    name = "kube-cluster-vpc"
    cidr = var.vpc_cidr_range

    azs             = data.aws_availability_zones.azs.zone_ids
    private_subnets = var.vpc_private_subnets
    public_subnets  = var.vpc_public_subnets

    enable_ipv6 = true
    enable_nat_gateway = true
    single_nat_gateway = true

    public_subnet_tags = {
        Public = "true"
    }
    private_subnet_tags = {
        Private = "true"
    }

    tags = {
        Name        = "kube-cluster-vpc"
        Environment = "kube"
        Application = "kube-cluster"
    }

    vpc_tags = {
        Name = "kube-cluster-vpc"
    }
}

resource "random_shuffle" "private_subnet" {
    input = module.kube-vpc.private_subnets
    result_count = 1
}

resource "random_shuffle" "public_subnet" {
    input = module.kube-vpc.public_subnets
    result_count = 1
}

resource "aws_security_group" "ssh_sg" {
    name = "ssh_sg_kube"
    description = "Allow SSH to nodes"
    vpc_id = module.kube-vpc.vpc_id
    ingress {
        cidr_blocks = [ "${chomp(data.http.myip.body)}/32",var.vpc_cidr_range ]
        description = "SSH"
        from_port = 22
        protocol = "tcp"
        self = true
        to_port = 22
    }
}

resource "aws_security_group" "kube_control_plane" {
    name = "kube_control_plane_sg"
    vpc_id = module.kube-vpc.vpc_id
    description = "Allow access to control plane nodes"
}

resource "aws_security_group_rule" "control_plane_rules" {
    for_each = local.control_plane_sg_rules
    type = "ingress"
    cidr_blocks = each.value.cidr_blocks
    description = each.value.description
    from_port = each.value.from_port
    # ipv6_cidr_blocks = each.value.ipv6_cidr_blocks
    protocol = each.value.protocol
    # self = each.value.self
    to_port = each.value.to_port
    security_group_id = aws_security_group.kube_control_plane.id
}

resource "aws_security_group_rule" "control_plane_rule" {
    cidr_blocks = concat(module.kube-vpc.nat_public_ips,[ "${chomp(data.http.myip.body)}/32", var.vpc_cidr_range ])
    type = "ingress"
    description = "All in bound kube API server"
    from_port = 6443
    protocol = "tcp"
    to_port = 6443
    security_group_id = aws_security_group.kube_control_plane.id
}

resource "aws_security_group" "outbound" {
    name = "outbound_to_igw"
    description = "outbound to all"
    vpc_id = module.kube-vpc.vpc_id
    egress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Out bound"
        from_port = 0
        ipv6_cidr_blocks = [ "::/0" ]
        protocol = "-1"
        self = false
        to_port = 0
    } 
}

resource "aws_security_group" "kube_worker_nodes" {
    name = "kube_worker_nodes_sg"
    description = "Allow access to worker nodes"
    vpc_id = module.kube-vpc.vpc_id
}

resource "aws_security_group_rule" "worker_node_sg_1" {
    description = "Kubelet API"
    type = "ingress"
    from_port = 10250
    protocol = "tcp"
    source_security_group_id = aws_security_group.kube_control_plane.id
    to_port = 10250
    security_group_id = aws_security_group.kube_worker_nodes.id
}

resource "aws_security_group_rule" "worker_node_sg_2" {
    cidr_blocks = ["0.0.0.0/0"]
    type = "ingress"
    description = "Node ports"
    from_port = 30000
    ipv6_cidr_blocks = ["::/0"]
    protocol = "tcp"
    to_port = 32767
    security_group_id = aws_security_group.kube_worker_nodes.id
}

resource "aws_security_group_rule" "worker_node_sg_3" {
    description = "Back to control plane"
    type = "egress"
    from_port = 10250
    to_port = 10250
    protocol = "tcp"
    source_security_group_id = aws_security_group.kube_control_plane.id
    security_group_id = aws_security_group.kube_worker_nodes.id
}

resource "aws_instance" "master" {
    ami = data.aws_ami.ubuntu.id
    key_name = var.key_name
    subnet_id = random_shuffle.public_subnet.result[0]
    associate_public_ip_address = true
    instance_type = "t2.medium"
    vpc_security_group_ids  = [ aws_security_group.ssh_sg.id, aws_security_group.kube_control_plane.id, aws_security_group.outbound.id ]
    tags = {
        Name = "kube-master",
        Application = "kube-cluster"
    }
}

resource "aws_instance" "worker" {
    count = var.worker-count
    ami = data.aws_ami.ubuntu.id
    subnet_id = random_shuffle.private_subnet.result[0]
    key_name = var.key_name
    instance_type = "t2.micro"
    vpc_security_group_ids  = [ aws_security_group.ssh_sg.id, aws_security_group.kube_worker_nodes.id, aws_security_group.outbound.id ]
    tags = {
        Name = "kube-worker-${count.index}",
        Application = "kube-cluster"
    }
}