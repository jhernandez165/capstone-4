# initial password
resource "random_password" "db_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# jwt key
resource "random_password" "jwt_key" {
  length           = 74
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# encrypt key
resource "random_password" "encrypt_key" {
  length           = 24
  special          = true
  min_special      = 1
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

resource "random_id" "id" {
  byte_length = 4
}

# the secret
resource "aws_secretsmanager_secret" "aline_secret" {
  name = "aline-secret-${random_id.id.hex}"
}

resource "aws_iam_policy" "secret_policy" {
  name        = "aline-secret-${random_id.id.hex}-policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.aline_secret.arn
      },
    ]
  })
}

# initial version
resource "aws_secretsmanager_secret_version" "secret_val" {
  secret_id = aws_secretsmanager_secret.aline_secret.id
	# encode in the required format
  secret_string = jsonencode(
    {
      username     = aws_db_instance.default.username
      password     = aws_db_instance.default.password
      dbname     = aws_db_instance.default.db_name
      engine      = "mysql"
      host     = aws_db_instance.default.address
      jwt_key     = random_password.jwt_key.result
      encrypt_key = random_password.encrypt_key.result
    }
  )
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
	# deploy in the first subnet
  subnet_ids          = [aws_subnet.private[0].id]
	# attach the security group
  security_group_ids  = [aws_security_group.data_plane_sg.id]
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.project}-db-subnet"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "${var.project}-db-subnet"
  }
}

# find the details by id
data "aws_serverlessapplicationrepository_application" "rotator" {
  application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSMySQLRotationSingleUser"
}

data "aws_partition" "current" {}
data "aws_region" "current" {}

# deploy the cloudformation stack
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotate-stack" {
  name             = "Rotate-${var.project}"
  application_id   = data.aws_serverlessapplicationrepository_application.rotator.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.rotator.semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.rotator.required_capabilities

  parameters = {
		# secrets manager endpoint
    endpoint            = "https://secretsmanager.${data.aws_region.current.name}.${data.aws_partition.current.dns_suffix}"
		# a name for the function
    functionName        = "rotator-${var.project}"
		# deploy in the first subnet
    vpcSubnetIds        = aws_subnet.private[0].id
		# attach the security group so it can communicate with the other componets
    vpcSecurityGroupIds = aws_security_group.data_plane_sg.id
  }
}

resource "aws_secretsmanager_secret_rotation" "rotation" {
	# secret_id through the secret_version so that it is deployed before setting up rotation
  secret_id           = aws_secretsmanager_secret_version.secret_val.secret_id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rotate-stack.outputs.RotationLambdaARN

  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = var.db_allocated_storage
  db_name                = "aline"
  engine                 = "mysql"
  instance_class         = var.db_instance_class
  username               = "admin"
  password               = random_password.db_master_pass.result
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.data_plane_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name 
}
