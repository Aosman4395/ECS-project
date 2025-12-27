# Project Overview

This project demonstrates a production-style containerised application deployed on AWS using ECS, Terraform, and CI/CD.  

The primary focus is **infrastructure, automation, and deployment**, not application development.

For the application layer, an existing lightweight open-source app is used as a deployable artifact.

---

## Application Choice

**App:** Memos  

**Reason for choice:**  

Memos is a simple, self-hosted application with minimal configuration and predictable HTTP behaviour, making it well-suited for an infrastructure-focused project.

The application is distributed as a Docker image, which aligns well with container-first deployment workflows.

---

## Phase 1 – Local Application Verification

**Goal:** Verify that the application runs locally and is accessible before any infrastructure or automation work.

### Local Setup

The application was run locally using the official Docker image:

```bash
docker run -d \
  --name memos \
  -p 5230:5230 \
  -v ~/.memos:/var/opt/memos \
  neosmemo/memos:stable

 ```

### Verification

The application was accessed successfully via a web browser at:

http://localhost:5230

An HTTP request was also made to a non-specific path to confirm the server responds when running:

curl http://localhost:5230/health

Although `/health` is not a dedicated health endpoint, the request returned a successful HTTP response, confirming that the application server is running and responding to requests.

### Result

- Application starts successfully in a Docker container
- HTTP server responds consistently when the app is running
- App accessible locally on port **5230**

**Confirms:**

- Docker is the required runtime
- The application exposes an HTTP interface
- The app can be validated via HTTP responses

## Phase 2 – Dockerisation & Local Validation

The application was successfully containerised and validated locally using Docker.

### Docker Image Build

The Docker image was built from the repository root using the following command:

```bash
docker build -t memos-local .
```
### Verification

The container was verified to be running successfully using the following command:

```bash
docker ps
```

![container-running](screenshots/container-running.png)

## Phase 3 – Container Image Stored in Amazon ECR

In this phase, the application Docker image was pushed to Amazon Elastic Container Registry (ECR), making it available for deployment using AWS ECS.

### Amazon ECR Overview

Amazon ECR is used as a private container registry to securely store Docker images within AWS.  

Storing the image in ECR allows ECS to pull and run the application independently of the local development environment.

### Image Tag Used

The image was pushed using the **`latest`** tag.

This tag represents the **current stable version** of the application for this project and will be referenced in the ECS task definition in the next phase.

### Verification (AWS Console)

The successful image push was verified using the AWS Management Console.

![ecr-push](screenshots/ecr-push.png)

## Phase 4 – Manual AWS Deployment (ClickOps)

In this phase, the containerised application was manually deployed to AWS using the AWS Management Console (ClickOps).  
This phase focuses on understanding how all AWS components integrate together without Infrastructure as Code.

---

### Tasks Completed

- **Created an Amazon ECR repository**
  - Used to store the production Docker image.
  - The ECS service pulls the image directly from ECR at runtime.

- **Created an Amazon ECS Cluster (Fargate)**
  - Chose **AWS Fargate** to run containers serverlessly without managing EC2 instances.
  - Provides automatic scaling and infrastructure abstraction.

- **Created an ECS Task Definition**
  - Defined container settings including:
    - Image from Amazon ECR
    - Container port `5230`
    - CPU and memory allocation
    - CloudWatch logging
  - This acts as the blueprint for running the container.

- **Set up an Application Load Balancer (ALB)**
  - Internet-facing ALB created to route external traffic to ECS tasks.
  - Listener configured for HTTP and HTTPS.
  - Target group created to forward traffic to the container on port `5230`.

- **Configured Security Groups**
  - Inbound rules allow:
    - HTTP (80)
    - HTTPS (443)
  - Ensures public access while maintaining controlled network boundaries.

- **Configured DNS using Namecheap (instead of Route 53)**
  - An existing domain was already managed via **Namecheap**.
  - A **CNAME record** (`tm.<domain>`) was created pointing to the ALB DNS name.
  - This replaces the need for Route 53 while achieving the same result.

- **Attached an ACM Certificate for HTTPS**
  - AWS Certificate Manager (ACM) used to provision a TLS certificate.
  - Certificate attached to the ALB HTTPS listener.
  - Enables secure HTTPS access to the application.

---

### Verification

- ECS task is running and healthy.
- Target group shows healthy targets.
- Application is accessible via the custom domain.
- HTTPS is enabled and secured using ACM.

---
Application running via custom domain

![domain](screenshots/domain.png)

Application running securely over HTTPS (ACM enabled)

![acm](screenshots/acm.png)



