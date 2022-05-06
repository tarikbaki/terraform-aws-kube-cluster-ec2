# Terraform Kube Cluster EC2

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

1. Download the latest version of Helm using the following command:

```wget https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz
```
The terminal prints out a confirmation message when the download completes.

Downloading Helm from Terminal.
2. Next, unpack the Helm file using the Linux tar command:

```tar xvf helm-v3.4.1-linux-amd64.tar.gz
```
The output displays four unpacked files.

3. Move the linux-amd64/helm file to the /usr/local/bin directory:

sudo mv linux-amd64/helm /usr/local/bin

There will be no output if the command was executed correctly.

Unpacking Helm.

4. Remove the downloaded file using the command:

```rm helm-v3.4.1-linux-amd64.tar.gz
```
5. Remove the linux-amd64 directory to clean up space by running:

```rm -rf linux-amd64
```
There is no output if the process completes successfully.

Removing files that are not necessary. 

6. Finally, verify you have successfully installed Helm by checking the version of the software:

```helm version```