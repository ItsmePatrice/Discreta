# Discreta

**A production AWS infrastructure built with a FinOps + cloud security lens.**

Discreta started as a GPS safety-tracking app for real estate agents. After field validation showed the pain wasn't urgent enough to sustain a business, the product decision was to shelve the app — but keep the infrastructure work alive as what it had actually become: a real, live, cost-conscious cloud environment built the way a junior DevOps/Cloud engineer would build one on a bank or fintech team, not the way a tutorial would.

Everything in this repo is running infrastructure, not a demo. Every architectural choice below is one I made deliberately and can defend in an interview — including the ones I haven't fixed yet.

---

## Why this project exists

Most junior DevOps portfolios are a pile of shallow, disconnected tutorials: a Docker container here, a Terraform "hello world" there. Discreta is the opposite bet — **one project, taken deep enough** that CI/CD, IaC, container orchestration, IAM, and networking all have to work together and hold up under scrutiny.

The guiding constraint throughout has been **FinOps**: every decision is sized to the actual scale of the workload, with an explicit, documented path to scale up if traffic ever justified it. Nothing here is over-engineered to look impressive — over-engineering an app with near-zero traffic is itself a red flag in a cost-conscious interview.

---

## Architecture

```
                        ┌─────────────────────┐
                        │   GitHub Actions     │
                        │   (CI/CD Pipeline)   │
                        └──────────┬───────────┘
                                   │ OIDC federation (no static AWS creds)
                                   ▼
                        ┌─────────────────────┐
                        │   Amazon ECR         │
                        │  (Docker images)     │
                        └──────────┬───────────┘
                                   │ pulled via IAM instance profile
                                   ▼
        ┌──────────────────────────────────────────────────┐
        │                  EC2 (Amazon Linux 2023)          │
        │  ┌──────────────────────────────────────────┐    │
        │  │              k3s (containerd)              │   │
        │  │        lightweight Kubernetes cluster       │  │
        │  └──────────────────────────────────────────┘    │
        └──────────────────────────────────────────────────┘
                                   │
                         Elastic IP (per environment)
                                   │
                                   ▼
                     Porkbun DNS → prod.discreta.ca
                                 → staging.discreta.ca
```

Two fully isolated environments — **staging** and **prod** — each with their own EC2 instance, Elastic IP, and Terraform state.

---

## Tech stack

| Layer | Technology |
|---|---|
| Cloud provider | AWS (`ca-central-1`) |
| Compute | EC2, Amazon Linux 2023 |
| Container orchestration | k3s (lightweight Kubernetes) on containerd |
| Container registry | Amazon ECR |
| IaC | Terraform (modular, multi-environment) |
| CI/CD | GitHub Actions |
| Identity | IAM (OIDC federation, instance profiles — zero long-lived credentials) |
| Networking | VPC, Security Groups, Elastic IPs |
| DNS | Porkbun |
| TLS | NGINX + Certbot (Let's Encrypt) |

---

## CI/CD pipeline

On every push, GitHub Actions:

1. Builds the Docker image in CI.
2. Pushes it to **ECR**, tagged `staging-<git-sha>` for staging or the git tag (e.g. `v1.2.0`) for production releases — so every running image is traceable back to an exact commit.
3. SSHes into the target EC2 instance (`appleboy/ssh-action`) and pulls/redeploys the new image on the k3s cluster.

**Authentication is credential-free end to end:**
- GitHub Actions authenticates to AWS via **OIDC federation** — no long-lived AWS access keys stored as secrets.
- EC2 pulls images from ECR using an **IAM instance profile** — no credentials stored on the instance at all.

The one deliberate exception: deployment secrets are currently injected via GitHub Actions `envs` passed through the SSH action, rather than pulled from AWS SSM Parameter Store at deploy time. This was a conscious simplicity-over-audit-trail tradeoff for a project at this stage — SSM is the documented next step.

---

## Infrastructure as Code

Terraform is organized to mirror how a real platform team separates concerns:

```
terraform/
├── network/                 # shared VPC, security groups (own state)
├── modules/
│   ├── ec2-app/              # reusable EC2 + k3s module
│   └── ecr/                  # reusable ECR repository module
└── environments/
    ├── staging/               # staging root — consumes network state
    └── prod/                  # prod root — consumes network state
```

- **Three isolated state files** (`network`, `staging`, `prod`) so a mistake in one environment can't touch another.
- The shared security group lives in the `network` module and is consumed by both environments via `terraform_remote_state` — one source of truth for shared networking rules.
- **Remote state migration to S3 is in progress** (currently local state) — required before CI/CD can safely apply infrastructure changes without risking state corruption from concurrent runs.

---

## Key engineering decisions (and the tradeoffs behind them)

| Decision | Why |
|---|---|
| **Single-node k3s instead of EKS** | Cost-proportionate to a portfolio-scale, near-zero-traffic app. k3s demonstrates real Kubernetes fluency without paying for control-plane costs an app this size would never justify in production. The scaling path (multi-node, ALB + Auto Scaling Group) is documented, not built — because building it here would be the over-engineering FinOps is supposed to catch. |
| **IAM instance profiles over stored credentials** | EC2 never holds an AWS access key. Pull permissions are scoped to the specific ECR repository ARN; only `GetAuthorizationToken` requires `Resource: "*"`, since that's an account-level token action. |
| **OIDC federation for GitHub Actions** | Eliminates long-lived AWS credentials in GitHub Secrets entirely — the pipeline authenticates per-run with a short-lived token. |
| **Elastic IPs per environment** | Decouples the public IP from instance lifecycle. If an instance is replaced (e.g. after a `user_data` change forces recreation), DNS and deployment secrets tied to that IP stay valid — no cascade of updates needed. |
| **SSH open on port 22 (temporary)** | A conscious, documented tradeoff, not an oversight. SSM Session Manager is the planned replacement to remove the open inbound rule entirely. |
| **DNS at Porkbun, not Route 53** | Avoids an unnecessary AWS-managed DNS cost for a project that doesn't need Route 53's automation — a small but deliberate FinOps call. |

---

## Roadmap

- [ ] Migrate Terraform state to S3 (network → staging → prod)
- [ ] Move SSH access to AWS SSM Session Manager, close port 22
- [ ] Move deploy-time secrets from GitHub Actions env injection to SSM Parameter Store
- [ ] CloudFront + S3 static sales page at the apex domain (`discreta.ca`), private bucket behind Origin Access Control
- [ ] Full architecture documentation with explicit scaling path (ALB/ASG) for review alongside job applications
- [ ] Standalone Prometheus/Grafana observability demo (kept separate from Discreta's prod infra, since justifying full monitoring stack on a zero-traffic app isn't a defensible FinOps call)

---

## What this project demonstrates

- Designing and running real multi-environment cloud infrastructure, not a single "it works on my machine" deployment
- Container orchestration with Kubernetes (k3s) — the skill that shows up in nearly every junior DevOps posting
- Secure-by-default identity: OIDC federation and IAM instance profiles, zero long-lived credentials
- Modular, stateful Infrastructure as Code with environment isolation
- Making — and being able to defend — cost/complexity tradeoffs instead of defaulting to the "biggest" tool available

---

## About

Built by **Patrice**, final-year Software Engineering student at Polytechnique Montréal, targeting junior DevOps / Cloud / SRE roles with a FinOps and cloud security focus.

- LinkedIn: [add your link]
- Email: [add your email]
