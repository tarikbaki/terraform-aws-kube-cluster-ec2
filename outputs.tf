output "master-ip" {
  value = aws_instance.master.public_ip
}
output "worker-private-ip" {
  value = {
    for worker in aws_instance.worker : worker.tags["Name"] => worker.private_ip
  }
}

output "worker-public-ip" {
  value = {
    for worker in aws_instance.worker : worker.tags["Name"] => worker.public_ip
  }
}