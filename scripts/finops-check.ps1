$Prefix = "poc-ai-monitoring"
$InstanceId = aws ec2 describe-instances `
  --filters "Name=tag:Name,Values=poc-ai-monitoring*" `
  --query "Reservations[].Instances[?State.Name!='terminated'].InstanceId" `
  --output text
$RdsId = "poc-ai-monitoring-mysql"
$LambdaName = "poc-ai-monitoring-agent"
$EventRule = "poc-ai-monitoring-alarm-state-change"

Write-Host "===== FINOPS CHECK - AWS POC =====" -ForegroundColor Cyan

Write-Host "`n[EC2]"
aws ec2 describe-instances `
  --instance-ids $InstanceId `
  --query "Reservations[0].Instances[0].{InstanceId:InstanceId,State:State.Name,Type:InstanceType}"

Write-Host "`n[RDS]"
aws rds describe-db-instances `
  --db-instance-identifier $RdsId `
  --query "DBInstances[0].{DB:DBInstanceIdentifier,Status:DBInstanceStatus,Class:DBInstanceClass,Engine:Engine}"

Write-Host "`n[ALB]"
aws elbv2 describe-load-balancers `
  --query "LoadBalancers[].{Name:LoadBalancerName,State:State.Code,Type:Type}"

Write-Host "`n[LAMBDA CONCURRENCY]"
aws lambda get-function-concurrency `
  --function-name $LambdaName

Write-Host "`n[LAMBDA ENV - IA]"
aws lambda get-function-configuration `
  --function-name $LambdaName `
  --query "Environment.Variables.{ENABLE_AI_ANALYSIS:ENABLE_AI_ANALYSIS,BEDROCK_MODEL_ID:BEDROCK_MODEL_ID}"

Write-Host "`n[EVENTBRIDGE]"
aws events describe-rule `
  --name $EventRule `
  --query "{Name:Name,State:State}"

Write-Host "`n[CLOUDWATCH ALARMS]"
aws cloudwatch describe-alarms `
  --alarm-name-prefix $Prefix `
  --query "MetricAlarms[].{Alarm:AlarmName,ActionsEnabled:ActionsEnabled,State:StateValue}"

Write-Host "`n[EBS VOLUMES]"
aws ec2 describe-volumes `
  --filters Name=attachment.instance-id,Values=$InstanceId `
  --query "Volumes[].{VolumeId:VolumeId,Size:Size,Type:VolumeType,State:State}"

Write-Host "`n[ELASTIC IP]"
aws ec2 describe-addresses `
  --query "Addresses[].{PublicIp:PublicIp,AllocationId:AllocationId,ServiceManaged:ServiceManaged,AssociationId:AssociationId}"

Write-Host "`n[S3 BUCKETS POC]"
aws s3api list-buckets `
  --query "Buckets[?contains(Name, '$Prefix')].Name"

Write-Host "`n[DYNAMODB]"
aws dynamodb describe-table `
  --table-name "poc-ai-monitoring-incidents" `
  --query "Table.{TableName:TableName,BillingMode:BillingModeSummary.BillingMode,Status:TableStatus}"

Write-Host "`n===== CHECK FINALIZADO =====" -ForegroundColor Green