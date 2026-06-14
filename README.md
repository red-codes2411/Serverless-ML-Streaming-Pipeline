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

## Outputs
<img width="642" height="662" alt="Screenshot 2026-06-15 030445" src="https://github.com/user-attachments/assets/301f3f43-1bad-43af-ac37-cfb0cb6cddc0" />
<img width="592" height="667" alt="Screenshot 2026-06-15 030716" src="https://github.com/user-attachments/assets/ee5883b7-837a-4575-bdaa-cbd286882398" />
<img width="677" height="677" alt="Screenshot 2026-06-15 030732" src="https://github.com/user-attachments/assets/d3481a31-9731-4df0-b662-59d1bb2cf469" />


## 🚀 How to Run Locally

### 1. Provision the AWS Infrastructure
Navigate to the Terraform directory and deploy the resources to your AWS account (requires AWS CLI configured with appropriate credentials).
```bash
cd terraform-dhanu
terraform init
terraform apply
