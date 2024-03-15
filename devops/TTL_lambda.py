import boto3


def put_cpu_alarm(instance_id):
    cloudWatch   = boto3.client('cloudwatch')
    cloudWatch.put_metric_alarm(
        AlarmName          = f'CPU_ALARM_{instance_id}',
        AlarmDescription   = 'Alarm when EC2 CPU does not exceed 10%',
        AlarmActions       = ['arn:aws:automate:us-west-1:ec2:stop'],
        MetricName         = 'CPUUtilization',
        Namespace          = 'AWS/EC2' ,
        Statistic          = 'Average',
        Dimensions         = [{'Name': 'InstanceId', 'Value': instance_id}],
        Period             = 3600,
        EvaluationPeriods  = 3,
        Threshold          = 10,
        ComparisonOperator = 'LessThanOrEqualToThreshold',
        TreatMissingData   = 'notBreaching'
    )


def lambda_handler(event, context):
    instance_id = event['detail']['instance-id']
    ec2 = boto3.resource('ec2')
    instance = ec2.Instance(instance_id)
    put_cpu_alarm(instance_id)