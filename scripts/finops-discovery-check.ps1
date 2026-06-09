Write-Host "===== FINOPS DISCOVERY CHECK - AWS =====" -ForegroundColor Cyan

$Region = "us-east-1"

Write-Host "`n[EC2 INSTANCES]" -ForegroundColor Yellow
aws ec2 describe-instances `
  --region $Region `
  --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value}" `
  --output table

Write-Host "`n[EBS VOLUMES]" -ForegroundColor Yellow
aws ec2 describe-volumes `
  --region $Region `
  --query "Volumes[].{VolumeId:VolumeId,Size:Size,Type:VolumeType,State:State,AttachedInstance:Attachments[0].InstanceId}" `
  --output table

Write-Host "`n[EBS SNAPSHOTS - OWNED BY ME]" -ForegroundColor Yellow
aws ec2 describe-snapshots `
  --owner-ids self `
  --region $Region `
  --query "Snapshots[].{SnapshotId:SnapshotId,Size:VolumeSize,State:State,StartTime:StartTime}" `
  --output table

Write-Host "`n[ELASTIC IP]" -ForegroundColor Yellow
aws ec2 describe-addresses `
  --region $Region `
  --query "Addresses[].{PublicIp:PublicIp,AllocationId:AllocationId,AssociationId:AssociationId,InstanceId:InstanceId,NetworkInterfaceId:NetworkInterfaceId}" `
  --output table

Write-Host "`n[NAT GATEWAYS]" -ForegroundColor Yellow
aws ec2 describe-nat-gateways `
  --region $Region `
  --query "NatGateways[].{NatGatewayId:NatGatewayId,State:State,VpcId:VpcId,SubnetId:SubnetId}" `
  --output table

Write-Host "`n[LOAD BALANCERS - ALB/NLB]" -ForegroundColor Yellow
aws elbv2 describe-load-balancers `
  --region $Region `
  --query "LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code,Scheme:Scheme,DNS:DNSName}" `
  --output table

Write-Host "`n[TARGET GROUPS]" -ForegroundColor Yellow
aws elbv2 describe-target-groups `
  --region $Region `
  --query "TargetGroups[].{Name:TargetGroupName,Protocol:Protocol,Port:Port,VpcId:VpcId}" `
  --output table

Write-Host "`n[RDS INSTANCES]" -ForegroundColor Yellow
aws rds describe-db-instances `
  --region $Region `
  --query "DBInstances[].{DB:DBInstanceIdentifier,Status:DBInstanceStatus,Class:DBInstanceClass,Engine:Engine,MultiAZ:MultiAZ,Storage:AllocatedStorage}" `
  --output table

Write-Host "`n[EKS CLUSTERS]" -ForegroundColor Yellow
aws eks list-clusters `
  --region $Region `
  --output table

Write-Host "`n[ECS CLUSTERS]" -ForegroundColor Yellow
aws ecs list-clusters `
  --region $Region `
  --output table

Write-Host "`n[LAMBDA FUNCTIONS]" -ForegroundColor Yellow
aws lambda list-functions `
  --region $Region `
  --query "Functions[].{FunctionName:FunctionName,Runtime:Runtime,LastModified:LastModified}" `
  --output table

Write-Host "`n[LAMBDA CONCURRENCY]" -ForegroundColor Yellow
$functions = aws lambda list-functions --region $Region --query "Functions[].FunctionName" --output text

foreach ($function in $functions) {
    Write-Host "`nFunction: $function" -ForegroundColor Cyan
    aws lambda get-function-concurrency `
      --function-name $function `
      --region $Region
}

Write-Host "`n[EVENTBRIDGE RULES]" -ForegroundColor Yellow
aws events list-rules `
  --region $Region `
  --query "Rules[].{Name:Name,State:State,Schedule:ScheduleExpression,EventPattern:EventPattern}" `
  --output table

Write-Host "`n[CLOUDWATCH ALARMS]" -ForegroundColor Yellow
aws cloudwatch describe-alarms `
  --region $Region `
  --query "MetricAlarms[].{Alarm:AlarmName,State:StateValue,ActionsEnabled:ActionsEnabled,Metric:MetricName,Namespace:Namespace}" `
  --output table

Write-Host "`n[CLOUDWATCH LOG GROUPS]" -ForegroundColor Yellow
aws logs describe-log-groups `
  --region $Region `
  --query "logGroups[].{LogGroup:logGroupName,Retention:retentionInDays,StoredBytes:storedBytes}" `
  --output table

Write-Host "`n[S3 BUCKETS]" -ForegroundColor Yellow
aws s3api list-buckets `
  --query "Buckets[].{Name:Name,Created:CreationDate}" `
  --output table

Write-Host "`n[DYNAMODB TABLES]" -ForegroundColor Yellow
aws dynamodb list-tables `
  --region $Region `
  --output table

Write-Host "`n[SNS TOPICS]" -ForegroundColor Yellow
aws sns list-topics `
  --region $Region `
  --output table

Write-Host "`n[SECRETS MANAGER]" -ForegroundColor Yellow
aws secretsmanager list-secrets `
  --region $Region `
  --query "SecretList[].{Name:Name,CreatedDate:CreatedDate,LastChangedDate:LastChangedDate}" `
  --output table

Write-Host "`n[KMS KEYS]" -ForegroundColor Yellow
aws kms list-keys `
  --region $Region `
  --output table

Write-Host "`n===== CHECK FINALIZADO =====" -ForegroundColor Green