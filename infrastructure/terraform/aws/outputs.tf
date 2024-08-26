output "vpc_id" {
  value       = aws_vpc.realworld-vpc.id
  description = "realworld-vpc ID"
}

output "nat_ip" {
  value       = aws_eip.this.public_ip
  description = "IP address for the NAT gateway"
}

output "cluster-endpoint" {
  value = aws_eks_cluster.app-cluster.endpoint
}
