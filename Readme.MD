# Terraform Kube Cluster EC2

## Deploy the infrastructure

1. Deploy the infrastructure using Terraform

    ```bash
    terraform init

    terraform plan

    terraform apply
    ```

2. Destroy infrastructure

    ```bash
    terraform destroy
    ```

<br/>

## Prepare the requirements of the python app

1. Prepare the requirements and run the app using the `docker-compose` on the local ;
    ``` bash
    cd app

    pip install pipreqs

    pipreqs . #

    docker-compose up
    ```

2. Go to the browser and open the `http://localhost:3000/`

3. Destroy the docker containers;
    ``` bash
    docker-compose down
    ```

<br/>

## Build the app and push docker image into the ECR

``` bash
cd app

aws ecr get-login-password \
    --region eu-central-1 \
    --profile myAccount \
    | docker login \
        --username AWS \
        --password-stdin 927869708525.dkr.ecr.eu-central-1.amazonaws.com

docker build -t 927869708525.dkr.ecr.eu-central-1.amazonaws.com/demo:0.1 .

docker push 927869708525.dkr.ecr.eu-central-1.amazonaws.com/demo:0.1
```






##########



> Terraform code to create a kube cluster using ec2.
> To be used with kubeadm 


## Prerequisites

- Terraform >= 1.0 # This can be updated in `provider.tf` using `required_version` key

## Resources Setup

- 1 VPC  (Uses AWS VPC [module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest))
  - 3 private subnets and 3 public subnets (*Configurable*)
  - Single NAT GW

- 1 Master Node
  - t2.micro

- 1 Worker node - Can be configured using `worker-count` key in `variables.tf`
  - t2.micro  

- 3 Security groups
  - Configured using kubernetes [documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports)
  
  - Only the user/system from which the `terraform apply` is run, can connect to the instances created. 


### NOTE

> The worker nodes do not have public IPs default (*Can be changed*).  
> In order to connect to them, use *ssh forwarding concept*

## Usage

- Update the `key_name` key under `variables.tf` or pass the value at run time, to make use of an already existing ssh to connect to the instances.


- To initialise
    ```shell
        terraform init
    ```

- To run a plan
    ```shell
        terraform plan
    ```

- To deploy infrastructure 
    ```shell
        terraform apply
    ```

- To destroy infrastructure 
    ```shell
        terraform destroy
    ```

*If automating, pass `--auto-approve` flag to apply and destroy commands*

### Optional



****
```helm install
```ubuntu@ip-10-0-103-105:~$ ./get_helm.sh 
Downloading https://get.helm.sh/helm-v2.17.0-linux-amd64.tar.gz
Preparing to install helm and tiller into /usr/local/bin
helm installed into /usr/local/bin/helm
tiller installed into /usr/local/bin/tiller
```Run 'helm init' to configure helm.


ubuntu@ip-10-0-103-105:~$ wget https://git.io/get_helm.sh

get_helm.sh         100%[===================>]   6.51K  --.-KB/s    in 0s      

```ubuntu@ip-10-0-103-105:~$ chmod 700 get_helm.sh 
ubuntu@ip-10-0-103-105:~$ ./get_helm.sh

