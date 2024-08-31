resource "aws_eks_cluster" "app-cluster" {
  name     = "realworld"
  role_arn = aws_iam_role.eks-role.arn
  depends_on = [
    aws_iam_role_policy_attachment.eks-role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-role-AmazonEKSVPCResourceController,
  ]
  vpc_config {
    subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]
  }
}

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.app-cluster.name
  node_group_name = "nodegroup-1"
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = [for subnet in aws_subnet.private_subnets : subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2 
  }

  instance_types = ["t2.micro"]
}
