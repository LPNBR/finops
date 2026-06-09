# GitHub Actions Automation

O projeto possui automações FinOps utilizando GitHub Actions para gerenciamento operacional da PoC AWS.

## Workflows disponíveis

### FinOps - Pause AWS POC

Workflow responsável pela hibernação completa da estrutura AWS.

Funções:

* Stop EC2
* Stop RDS
* Disable EventBridge
* Lambda concurrency = 0
* Disable CloudWatch alarm actions
* Validação final do ambiente

Arquivo:

```text
.github/workflows/finops-pause-poc.yml
```

---

### FinOps - Start AWS POC

Workflow responsável pela reativação da estrutura AWS.

Funções:

* Start EC2
* Start RDS
* Enable EventBridge
* Restore Lambda concurrency
* Enable CloudWatch alarm actions
* Validação final do ambiente

Arquivo:

```text
.github/workflows/finops-start-poc.yml
```

---

### FinOps - Stop RDS POC

Workflow responsável por validar diariamente o status do Amazon RDS.

Caso o banco esteja ligado (`available`), o workflow executa automaticamente o stop da instância para evitar custos desnecessários.

Arquivo:

```text
.github/workflows/finops-rds-stop.yml
```

---

# Secrets necessários

Configure os seguintes secrets no GitHub:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

Local:

```text
Repository → Settings → Secrets and variables → Actions
```

---

# Estratégia FinOps aplicada

O ambiente foi otimizado utilizando:

* Hibernação controlada
* Automação operacional
* Start/Stop sob demanda
* Redução automática de custos
* Governança AWS
* GitHub Actions integrado com AWS CLI

---

# Execução manual

Acesse:

```text
Actions → Workflow → Run workflow
```

---

# Objetivo do projeto

Demonstrar estratégias reais de:

* FinOps
* Governança Cloud
* Automação AWS
* Infraestrutura como Código
* Operações Cloud
* AIOps
* Observabilidade
