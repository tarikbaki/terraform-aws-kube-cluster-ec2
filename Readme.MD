# Terraform Kube Cluster EC2

> Terraform code to create a kube cluster using ec2.
> To be used with kubeadm or kubespray


## Prerequisites

- Terraform >= 1.0 # This can be updated in `provider.tf` using `required_version` key

## Resources Setup

- 1 VPC  (Uses AWS VPC [module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest))
  - 3 private subnets and 3 public subnets (*Configurable*)
  - Single NAT GW

- 1 Master Node
  - t3.medium

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

- By default, the backend for storing terraform state is the project directory/local system
- If you want to use S3 as your backend store, add the following to the `terraform` block in `provider.tf`

```tf
    backend "s3" {
        bucket  = <bucket-name>
        key     = <path/to/tf.state>
        region  = <region>
    }
```