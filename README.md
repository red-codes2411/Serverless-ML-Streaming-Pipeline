# Serverless Real-Time ML Feature Pipeline

An event-driven, infrastructure-as-code (IaC) project that streams mock transactional data from a local containerized frontend into a cloud-native Machine Learning Feature Store.

## 🏗️ Architecture

1. **Local Producer:** A Python/Streamlit frontend containerized with Docker generates mock transaction events.
2. **Streaming Buffer:** Events are published in real-time to an **Amazon Kinesis Data Stream**.
3. **Serverless Transformation:** **AWS Lambda** consumes the Kinesis stream, decodes the payload, and performs necessary data transformations.
4. **ML Feature Store:** Lambda injects the processed features into an **Amazon SageMaker Online Feature Store**, making them available for sub-millisecond ML inference.
5. **Infrastructure as Code:** All AWS resources, IAM roles, and event mappings are provisioned dynamically using **Terraform**.

## 🛠️ Tech Stack
* **Cloud:** AWS (Kinesis, Lambda, SageMaker, IAM, CloudWatch)
* **Infrastructure as Code:** Terraform
* **Local Environment:** Docker, Kubernetes (Local testing)
* **Frontend/Producer:** Python, Streamlit, Boto3

## 🚀 How to Run Locally

### 1. Provision the AWS Infrastructure
Navigate to the Terraform directory and deploy the resources to your AWS account (requires AWS CLI configured with appropriate credentials).
```bash
cd terraform-dhanu
terraform init
terraform apply
