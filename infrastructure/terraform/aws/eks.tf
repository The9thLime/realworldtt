resource "aws_eks_cluster" "app-cluster" {
  name     = "realworld"
  role_arn = aws_iam_role.eks-role.arn
  depends_on = [
    aws_iam_role_policy_attachment.eks-role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-role-AmazonEKSVPCResourceController,
  ]
  vpc_config {
    subnet_ids = [for subnet in aws_subnet.subnets : subnet.id]
  }
}