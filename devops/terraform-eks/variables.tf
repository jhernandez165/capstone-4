variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "us-west-1"
}

variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  type = string
  default = "cm-tf-eks"
}

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "Instance type for RDS database instance"
  type = string
  default = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "Storage space allocated for RDS database instance"
  type = number
  default = 20
}

variable "node_instance_types" {
  description = "Instance types for cluster worker nodes"
  type        = list(string)
  default     = ["t2.medium"]
}

variable "node_disk_size" {
  description = "disk size for cluster worker nodes"
  type        = number
  default     = 20
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "CMTerraformEKS"
    "Environment" = "Development"
    "Owner"       = "Chris McKelvy"
  }
}
