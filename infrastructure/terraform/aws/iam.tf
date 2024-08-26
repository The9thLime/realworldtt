data "aws_iam_policy_document" "eks-cluster-assume-role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "eks-node-assume-role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "eks-role" {
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-assume-role.json
  name               = "eks-cluster-role"
}

resource "aws_iam_role" "eks-node-role" {
  assume_role_policy = data.aws_iam_policy_document.eks-node-assume-role.json
  name               = "eks-node-role"
}

resource "aws_iam_role_policy_attachment" "eks-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role_policy_attachment" "eks-role-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role_policy_attachment" "node-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-role.name
}


resource "aws_iam_role_policy_attachment" "node-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "node-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-role.name
}
