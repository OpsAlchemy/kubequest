# LocalStack (Self-Hosted, Community Edition)

This setup runs **LocalStack** locally using Docker Compose, with **all default services enabled** for the Community edition.
No LocalStack Cloud. No license required.

---

## Prerequisites

* Docker
* Docker Compose (v2)
* AWS CLI

---

## Start LocalStack 
For WSL
```bash
cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/localstack
docker compose up -d
```

Check logs:

```bash
docker compose logs -f localstack
```

Wait until you see:

```
Ready.
```

---

## AWS CLI Configuration (One-Time)

LocalStack accepts fake credentials.

```bash
aws configure
```

Use:

```
AWS Access Key ID: test
AWS Secret Access Key: test
Default region name: us-east-1
Default output format: json
```

---

## Endpoint

All AWS services are exposed via a **single edge endpoint**:

```
http://localhost:4566
```

### Health endpoints

- **Status (JSON):** `http://localhost:4566/_localstack/health`

  Example:

  ```bash
  curl http://localhost:4566/_localstack/health
  ```

  This returns a JSON object listing services and their status as well as `edition` and `version`.

  Example (trimmed):

  ```json
  {
    "services": {
      "acm": "available",
      "apigateway": "available",
      "cloudformation": "available",
      "cloudwatch": "available",
      "config": "available",
      "dynamodb": "available",
      "dynamodbstreams": "available",
      "ec2": "available",
      "es": "available",
      "events": "available",
      "firehose": "available",
      "iam": "available",
      "kinesis": "available",
      "kms": "available",
      "lambda": "available",
      "logs": "available",
      "opensearch": "available",
      "redshift": "available",
      "resource-groups": "available",
      "resourcegroupstaggingapi": "available",
      "route53": "available",
      "route53resolver": "available",
      "s3": "running",
      "s3control": "available",
      "scheduler": "available",
      "secretsmanager": "available",
      "ses": "available",
      "sns": "available",
      "sqs": "available",
      "ssm": "available",
      "stepfunctions": "available",
      "sts": "available",
      "support": "available",
      "swf": "available",
      "transcribe": "available"
    },
    "edition": "community",
    "version": "4.12.1.dev43"
  }
  ```

- **Services (alphabetical):**
  - acm
  - apigateway
  - cloudformation
  - cloudwatch
  - config
  - dynamodb
  - dynamodbstreams
  - ec2
  - es
  - events
  - firehose
  - iam
  - kinesis
  - kms
  - lambda
  - logs
  - opensearch
  - redshift
  - resource-groups
  - resourcegroupstaggingapi
  - route53
  - route53resolver
  - s3
  - s3control
  - scheduler
  - secretsmanager
  - ses
  - sns
  - sqs
  - ssm
  - stepfunctions
  - sts
  - support
  - swf
  - transcribe

- **Note:** `http://localhost:4566/health` (without `/_localstack`) may be interpreted as an S3 bucket request and return an XML error such as `NoSuchBucket` for a bucket named `health`. Use `/_localstack/health` to get the status JSON.

### UI

- There is **no web UI** in the Community edition. If you need a UI (dashboard or pro features), consider upgrading to LocalStack Pro.

---

## Smoke Test Commands

### S3

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://demo-bucket
aws --endpoint-url=http://localhost:4566 s3 ls
```

### SQS

```bash
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name demo-queue
aws --endpoint-url=http://localhost:4566 sqs list-queues
```

### DynamoDB

```bash
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### IAM / STS

```bash
aws --endpoint-url=http://localhost:4566 sts get-caller-identity
aws --endpoint-url=http://localhost:4566 iam list-roles
```

---

## Stop / Reset

Stop services:

```bash
docker compose down
```

Stop and remove all LocalStack data:

```bash
docker compose down -v
```

---

## Notes

* All **Community-edition default services** are enabled automatically.
* Advanced AWS features (e.g. Step Functions, EKS, full IAM evaluation) are **not available** in Community.
* This setup is ideal for **local development, CI testing, Terraform, and Crossplane control-plane validation**.

---
