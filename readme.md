# 🚀 Task Tracker API – DevOps Project

A containerized FastAPI service deployed on AWS EC2 using Terraform. It includes CI/CD with GitHub Actions, Dockerized deployment, and monitoring via Prometheus Node Exporter.

---

## 🏗 Architecture Diagram

![Architecture Diagram](in form of flowchart)

---

## 📦 Project Structure

```bash
.
├── app/
│ ├── main.py
│ └── requirements.txt
├── terraform/
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
├── .github/
│ └── workflows/
│ └── deploy.yml
├── Dockerfile
├── architecture.png
└── README.md
```
---

## ⚙️ Setup Instructions

### 1️⃣ Prerequisites

- AWS account & access keys configured
- Existing EC2 Key Pair (for SSH)
- Docker Hub account
- GitHub repo with the code

---

### 2️⃣ Infrastructure Provisioning (Terraform)

```bash
cd terraform

terraform init

terraform apply \
  -var="key_name=<your-ec2-key-name>" \
  -var="bucket_name=<your-unique-bucket-name>"
```  
This will:
1. Create an EC2 instance (Ubuntu 22.04)
2. Open ports 80 (app) and 9100 (metrics)
3. Create an optional S3 bucket
4. Install Docker, deploy your container, and start Prometheus Node Exporter
5. After deployment, note the EC2 public IP from Terraform output.


3️⃣  CI/CD with GitHub Actions

➕ Secrets to Add in GitHub:
Name	Description
DOCKER_USERNAME	Docker Hub username
DOCKER_PASSWORD	Docker Hub password
EC2_HOST	EC2 public IP
EC2_SSH_KEY	SSH private key (no .pem needed)
EC2_USER	EC2 username (usually ubuntu)

What It Does:
On push to main:

Builds Docker image
Pushes image to Docker Hub
SSH into EC2 and redeploys the container

4️⃣ API Usage
➕ Create Task
```bash
curl -X POST http://<EC2_PUBLIC_IP>/tasks \
-H "Content-Type: application/json" \
-d '{"title":"Deploy", "description":"Via CI/CD"}'
```

📋 List Tasks
```bash
curl http://<EC2_PUBLIC_IP>/tasks
```

📈 App Metrics
```bash
curl http://<EC2_PUBLIC_IP>/metrics
```

📊 Node Exporter Metrics (System)
``` bash
curl http://<EC2_PUBLIC_IP>:9100/metrics
```

🛡 Monitoring
App Metrics: via prometheus_client at /metrics
System Metrics: Node Exporter on port 9100


