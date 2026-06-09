$Region = "us-east-1"

$Ec2Name = "poc-ai-monitoring-app-ec2"
$RdsId = "poc-ai-monitoring-mysql"
$LambdaName = "poc-ai-monitoring-agent"
$EventRule = "poc-ai-monitoring-alarm-state-change"

Write-Host "===== PAUSANDO AMBIENTE POC =====" -ForegroundColor Yellow

Write-Host "`n[1/5] Desabilitando EventBridge..."

aws events disable-rule `
  --region $Region `
  --name $EventRule

Write-Host "`n[2/5] Bloqueando execução da Lambda..."

aws lambda put-function-concurrency `
  --region $Region `
  --function-name $LambdaName `
  --reserved-concurrent-executions 0

Write-Host "`n[3/5] Localizando EC2 por tag Name..."

$InstanceId = aws ec2 describe-instances `
  --region $Region `
  --filters "Name=tag:Name,Values=$Ec2Name" "Name=instance-state-name,Values=pending,running,stopping,stopped" `
  --query "Reservations[*].Instances[*].InstanceId" `
  --output text

if ([string]::IsNullOrWhiteSpace($InstanceId)) {
  Write-Host "Nenhuma EC2 encontrada com Name=$Ec2Name" -ForegroundColor Red
} else {
  $InstanceState = aws ec2 describe-instances `
    --region $Region `
    --instance-ids $InstanceId `
    --query "Reservations[0].Instances[0].State.Name" `
    --output text

  Write-Host "EC2 encontrada: $InstanceId | Estado atual: $InstanceState"

  if ($InstanceState -eq "stopped") {
    Write-Host "EC2 já está parada." -ForegroundColor Yellow
  } elseif ($InstanceState -eq "stopping") {
    Write-Host "EC2 já está em processo de parada." -ForegroundColor Yellow
  } else {
    Write-Host "Parando EC2..."
    aws ec2 stop-instances `
      --region $Region `
      --instance-ids $InstanceId
  }
}

Write-Host "`n[4/5] Verificando RDS..."

$RdsStatus = aws rds describe-db-instances `
  --region $Region `
  --db-instance-identifier $RdsId `
  --query "DBInstances[0].DBInstanceStatus" `
  --output text

Write-Host "RDS status atual: $RdsStatus"

if ($RdsStatus -eq "available") {
  Write-Host "Parando RDS..."
  aws rds stop-db-instance `
    --region $Region `
    --db-instance-identifier $RdsId
} elseif ($RdsStatus -eq "stopped") {
  Write-Host "RDS já está parado." -ForegroundColor Yellow
} elseif ($RdsStatus -eq "stopping") {
  Write-Host "RDS já está em processo de parada." -ForegroundColor Yellow
} else {
  Write-Host "RDS não será parado pois está no estado: $RdsStatus" -ForegroundColor Yellow
}

Write-Host "`n[5/5] Desabilitando ações dos alarmes..."

$alarms = @(
  "poc-ai-monitoring-ec2-cpu-high",
  "poc-ai-monitoring-ec2-status-check-failed",
  "poc-ai-monitoring-rds-cpu-high",
  "poc-ai-monitoring-alb-5xx-high"
)

foreach ($alarm in $alarms) {
  Write-Host "Desabilitando alarme: $alarm"

  aws cloudwatch disable-alarm-actions `
    --region $Region `
    --alarm-names $alarm
}

Write-Host "`n===== AMBIENTE PAUSADO =====" -ForegroundColor Green
Write-Host "Valide com: .\finops-check.ps1"