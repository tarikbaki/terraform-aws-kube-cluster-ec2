variable "worker-count" {
  default = 1
}
variable "vpc_cidr_range" {
  default = "10.0.0.0/16"
}
variable "vpc_private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "vpc_public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "key_name" {
  default = "id_rsa"
}