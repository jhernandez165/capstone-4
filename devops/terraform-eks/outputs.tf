output "cluster_id" {
  value = aws_eks_cluster.eks.id
}

output "region" {
  value = var.region
}

output "project" {
  value = var.project
}

output "node_group_id" {
  value = aws_eks_node_group.nodes.id
}

output node_group_status {
  value = aws_eks_node_group.nodes.status
}

output node_group_role_name {
  value = aws_iam_role.node.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "db_host" {
  value = aws_db_instance.default.address
}

output "db_instance_id" {
  value = aws_db_instance.default.id
}

output "db_instance_class" {
  value = aws_db_instance.default.instance_class
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "private_subnet_cidrs" {
  value = aws_subnet.private[*].cidr_block
}

output "public_subnet_cidrs" {
  value = aws_subnet.public[*].cidr_block
}

output "secret_policy_arn" {
  value = aws_iam_policy.secret_policy.arn
}

output "secret_policy_name" {
  value = aws_iam_policy.secret_policy.name
}

output "secret_name" {
  value = aws_secretsmanager_secret.aline_secret.name
}