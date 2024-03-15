package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func cleanupS3Bucket(t *testing.T, awsRegion string, bucketName string) {
	aws.EmptyS3Bucket(t, awsRegion, bucketName)
	aws.DeleteS3Bucket(t, awsRegion, bucketName)
}

func TestTerraformStack(t *testing.T) {
	randId := strings.ToLower(random.UniqueId())
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	expectedProjectName := "cm-terratest-" + randId
	expectedPort := int64(3306)
	expectedVpcCidr := "172.16.0.0/16"

	//configure S3 bucket for temporary backend
	defer cleanupS3Bucket(t, awsRegion, expectedProjectName)
	aws.CreateS3Bucket(t, awsRegion, expectedProjectName)

	key := fmt.Sprintf("%s/terraform.tfstate", randId)
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../",
		Reconfigure:  true,
		Vars: map[string]interface{}{
			"project":              expectedProjectName,
			"vpc_cidr":             expectedVpcCidr,
			"db_allocated_storage": 5,
			"region":               awsRegion,
		},
		BackendConfig: map[string]interface{}{
			"bucket": expectedProjectName,
			"key":    key,
			"region": awsRegion,
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	dbInstanceID := terraform.Output(t, terraformOptions, "db_instance_id")

	// Look up the endpoint address and port of the RDS instance
	address := aws.GetAddressOfRdsInstance(t, dbInstanceID, awsRegion)
	port := aws.GetPortOfRdsInstance(t, dbInstanceID, awsRegion)

	// Verify that the address is not null
	assert.NotNil(t, address)
	// Verify that the DB instance is listening on the port mentioned
	assert.Equal(t, expectedPort, port)
	// Verify that the table/schema requested for creation is actually present in the database

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedVpcCidr, vpcCidr)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.0.0/24", "172.16.1.0/24"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.2.0/24", "172.16.3.0/24"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	eksClusterId := terraform.Output(t, terraformOptions, "cluster_id")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedProjectName+"-cluster", eksClusterId)

	// Run `terraform output` to get the value of an output variable
	eksNodeGroupId := terraform.Output(t, terraformOptions, "node_group_id")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedProjectName+"-cluster:"+expectedProjectName, eksNodeGroupId)

	// Run `terraform output` to get the value of an output variable
	eksNodeGroupRoleName := terraform.Output(t, terraformOptions, "node_group_role_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedProjectName+"-Node-Role", eksNodeGroupRoleName)

	// Run `terraform output` to get the value of an output variable
	eksNodeGroupStatus := terraform.Output(t, terraformOptions, "node_group_status")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "ACTIVE", eksNodeGroupStatus)

}
