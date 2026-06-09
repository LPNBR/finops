$Region = "us-east-1"

$Ec2Name = "poc-ai-monitoring-app-ec2"
$RdsId = "poc-ai-monitoring-mysql"
$LambdaName = "poc-ai-monitoring-agent"
$EventRule = "poc-ai-monitoring-alarm-state-change"

Write-Host "===== INICIANDO AMBIENTE POC =====" -ForegroundColor Cyan

Write-Host "`n[1/5] Localizando EC2 por tag Name..."

$InstanceId = aws ec2 describe-instances `
  --region $Region `
  --filters "Name=tag:Name,Values=$Ec2Name" "Name=instance-state-name,Values=stopped,running,pending,stopping" `
  --query "Reservations[*].Instances[*].InstanceId" `
  --output text

if ([string]::IsNullOrWhiteSpace($InstanceId)) {
  Write-Host "Nenhuma EC2 encontrada com Name=$Ec2Name" -ForegroundColor Red
} else {
  Write-Host "EC2 encontrada: $InstanceId"

  $InstanceState = aws ec2 describe-instances `
    --region $Region `
    --instance-ids $InstanceId `
    --query "Reservations[0].Instances[0].State.Name" `
    --output text

  Write-Host "Status atual da EC2: $InstanceState"

  if ($InstanceState -eq "running") {
    Write-Host "EC2 já está ligada." -ForegroundColor Yellow
  } elseif ($InstanceState -eq "pending") {
    Write-Host "EC2 já está iniciando." -ForegroundColor Yellow
  } elseif ($InstanceState -eq "stopping") {
    Write-Host "EC2 está parando. Aguarde finalizar para iniciar novamente." -ForegroundColor Yellow
  } else {
    Write-Host "Iniciando EC2..."
    aws ec2 start-instances `
      --region $Region `
      --instance-ids $InstanceId
  }
}

Write-Host "`n[2/5] Verificando RDS..."

$RdsStatus = aws rds describe-db-instances `
  --region $Region `
  --db-instance-identifier $RdsId `
  --query "DBInstances[0].DBInstanceStatus" `
  --output text

if ($RdsStatus -eq "stopped") {
  Write-Host "Iniciando RDS..."
  aws rds start-db-instance `
    --region $Region `
    --db-instance-identifier $RdsId
} else {
  Write-Host "RDS não está parado. Status atual: $RdsStatus" -ForegroundColor Yellow
}

Write-Host "`n[3/5] Liberando execução da Lambda..."

aws lambda delete-function-concurrency `
  --region $Region `
  --function-name $LambdaName

Write-Host "`n[4/5] Habilitando EventBridge..."

aws events enable-rule `
  --region $Region `
  --name $EventRule

Write-Host "`n[5/5] Habilitando ações dos alarmes..."

$alarms = @(
  "poc-ai-monitoring-ec2-cpu-high",
  "poc-ai-monitoring-ec2-status-check-failed",
  "poc-ai-monitoring-rds-cpu-high",
  "poc-ai-monitoring-nginx-down"
)

foreach ($alarm in $alarms) {
  Write-Host "Habilitando alarme: $alarm"

  aws cloudwatch enable-alarm-actions `
    --region $Region `
    --alarm-names $alarm
}

Write-Host "`n===== AMBIENTE INICIADO =====" -ForegroundColor Green
Write-Host "EC2 localizada por tag Name: $Ec2Name"
Write-Host "Região utilizada: $Region"
Write-Host ""
Write-Host "Após a EC2 iniciar, valide o SSM com:"
Write-Host "aws ssm describe-instance-information --region $Region --output table"
Write-Host ""
Write-Host "Atenção: o ALB foi removido via Terraform. Para recriar o ALB, rode terraform apply na pasta environments\poc."