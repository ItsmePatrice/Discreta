# Discreta

A personal safety system for professionals who work alone. A discreet physical device, a mobile app, and a cloud backend let a user silently trigger an emergency alert and share their live location with trusted contacts.

**Product:** https://discreta.ca
**Website repo:** https://github.com/ItsmePatrice/panic-necklace

---

## What I Built

End-to-end: mobile app, backend, cloud infrastructure, and deployment pipeline.

**Application**
- Flutter/Dart mobile app with Bluetooth integration (Flic button trigger)
- Background and foreground location tracking
- Authentication, Firebase push notifications

**Backend**
- Node.js, Express, TypeScript REST API
- PostgreSQL, real-time location handling, emergency alert workflows
- Authentication middleware and protected routes

**Cloud & Infrastructure**
- AWS infrastructure provisioned entirely with Terraform (EC2, ECR, IAM, S3, CloudFront, ACM)
- Self-managed Kubernetes cluster on EC2, Docker containers, NGINX reverse proxy
- Multi-environment setup (prod/staging) with isolated state

**CI/CD**
- GitHub Actions pipeline: build - containerize - push to ECR - deploy
- AWS authentication via GitHub OIDC - no long-lived credentials stored in GitHub

---

## Tech Stack

| Layer | Tools |
|---|---|
| Mobile | Flutter, Dart, Firebase, Bluetooth |
| Backend | Node.js, Express, TypeScript, PostgreSQL |
| Cloud | AWS EC2, ECR, IAM, S3, CloudFront, ACM |
| Infrastructure | Terraform, Docker, Kubernetes, NGINX |
| CI/CD | GitHub Actions, GitHub OIDC |

---

## Architecture

```text
Discreet Device (Flic) - Mobile App (Flutter) - Backend (Node.js/Express) - EC2 / Kubernetes
                                                        |
                                            ------------+------------
                                     Emergency Notifications   Real-time Location
```

**Deployment flow:**

```text
GitHub - GitHub Actions - OIDC - ECR (image) - EC2 / Kubernetes pods - NGINX - Internet
```

Infrastructure is fully version-controlled and provisioned through Terraform rather than the AWS console - reproducible and consistent across environments.

---

## Security

- GitHub Actions authenticates to AWS via **OIDC**, exchanging a short-lived token for temporary credentials instead of storing static AWS keys
- IAM permissions scoped per workflow
- API routes protected by authentication middleware; credentials kept out of source control

---

## Roadmap

Planned next steps as the project scales beyond its current stage:

1. Move Terraform state to a centralized S3 backend with state locking
2. Introduce an Application Load Balancer and Auto Scaling Group
3. Evaluate Amazon EKS if operational needs outgrow self-managed Kubernetes

---

## Local Development

```bash
git clone https://github.com/ItsmePatrice/Discreta.git
cd Discreta
```

Each component (mobile, backend) has its own dependencies and setup instructions in its respective directory. Environment variables and production credentials are not included in this repository.
