# Discreta

**Discreta is a personal safety system designed for professionals who work alone.**

The system combines a discreet physical device, a mobile application, and a cloud backend to allow a user to silently trigger an emergency alert while sharing their live location with trusted contacts.

This repository contains the **core Discreta application and backend infrastructure**.

The product presentation page is maintained in a separate repository:

**[Discreta Website](https://github.com/ItsmePatrice/panic-necklace)**

🌐 **Product website:** https://discreta.ca

---

## 🛠️ Tech Stack

**Mobile:** Flutter · Dart · Firebase · Bluetooth

**Backend:** Node.js · Express · TypeScript · PostgreSQL ·

**Cloud:** AWS EC2 · ECR · IAM · S3 · CloudFront · ACM

**Infrastructure:** Terraform · Docker · Kubernetes · NGINX

**CI/CD:** GitHub Actions · GitHub OIDC

---

## 🎯 The Problem

Professionals who work alone can find themselves in situations where reaching for a phone or making a visible emergency call is not practical.

Discreta provides a discreet alternative.

A user can trigger an alert using a small physical device. The system then notifies designated emergency contacts and continuously provides the user's location until the situation is resolved.

---

## 🏗️ System Architecture

Discreta is built as a distributed system combining hardware, mobile software, backend services, and cloud infrastructure.

```text
                    ┌─────────────────────┐
                    │   Discreet Device   │
                    │      (Flic)         │
                    └──────────┬──────────┘
                               │
                               │ Bluetooth
                               ▼
                    ┌─────────────────────┐
                    │    Mobile App       │
                    │      Flutter        │
                    └──────────┬──────────┘
                               │
                               │ HTTPS / API
                               ▼
                    ┌─────────────────────┐
                    │    AWS / Backend    │
                    │                     │
                    │  Node.js + Express  │
                    │  PostgreSQL         │
                    │  Firebase           │
                    └──────────┬──────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
        ┌─────────────────┐        ┌─────────────────┐
        │ Emergency       │        │ Real-time       │
        │ Notifications   │        │ Location        │
        └─────────────────┘        └─────────────────┘
```

The architecture is designed around a simple flow:

**Physical trigger → Mobile application → Cloud backend → Emergency contacts**

---

## 🚀 What I Built

I worked across the application, backend, cloud infrastructure, and deployment pipeline.

### Application

* Developed the mobile application using **Flutter and Dart**
* Integrated the application with the **Flic Bluetooth button**
* Implemented background location tracking
* Implemented foreground services for reliable location updates
* Integrated authentication and user management
* Implemented communication between the mobile application and backend API
* Integrated Firebase services and push notifications
* Integrated Stripe for subscription payments

### Backend

* Developed the backend using **Node.js, Express, and TypeScript**
* Built REST API endpoints for the application
* Implemented authentication and authorization
* Integrated **PostgreSQL**
* Implemented emergency alert workflows
* Implemented real-time location handling
* Implemented notification services
* Added authentication middleware and protected API routes
* Structured backend services to support multiple application instances

### Cloud & Infrastructure

* Designed and provisioned AWS infrastructure using **Terraform**
* Deployed the backend on **Amazon EC2**
* Containerized services using **Docker**
* Created an **Amazon ECR** repository for application images
* Configured **NGINX** as a reverse proxy
* Configured TLS certificates using **AWS Certificate Manager**
* Built and managed a Kubernetes cluster directly on EC2
* Deployed backend workloads using Kubernetes Deployments and Services
* Configured multiple Kubernetes replicas for the backend

### CI/CD & DevOps

* Built CI/CD pipelines using **GitHub Actions**
* Automated application builds
* Automated Docker image creation
* Automated image publishing to Amazon ECR
* Implemented GitHub Actions authentication to AWS using **OIDC**
* Avoided storing long-lived AWS credentials in GitHub
* Automated deployment of containerized backend workloads
* Separated development, staging, and production infrastructure
* Managed infrastructure as code using Terraform

---

## ☁️ AWS Architecture

The backend infrastructure is primarily hosted on AWS.

```text
                         GitHub
                            │
                            │ GitHub Actions
                            ▼
                    ┌─────────────────┐
                    │   AWS IAM       │
                    │   GitHub OIDC   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Amazon ECR    │
                    │ Docker Images   │
                    └────────┬────────┘
                             │
                             │ Pull Image
                             ▼
                    ┌─────────────────┐
                    │   EC2 Instance  │
                    │                 │
                    │   Kubernetes    │
                    │   ┌────┐ ┌────┐│
                    │   │Pod │ │Pod ││
                    │   └────┘ └────┘│
                    └────────┬────────┘
                             │
                             │
                          NGINX
                             │
                             ▼
                        Internet/API
```

Infrastructure is provisioned through Terraform rather than manually configured in the AWS console.

This allows the infrastructure to be version controlled, reproducible, and consistently deployed across environments.

---

## 🔐 Security

Security is an important part of the architecture because the application handles authentication, emergency alerts, and location data.

### AWS Authentication

GitHub Actions authenticates with AWS using **OpenID Connect (OIDC)**.

Instead of storing permanent AWS credentials in GitHub, the workflow receives a short-lived identity token and assumes a dedicated IAM role.

```text
GitHub Actions
      │
      │ OIDC token
      ▼
AWS IAM
      │
      │ AssumeRoleWithWebIdentity
      ▼
Temporary AWS credentials
```

IAM permissions are scoped according to the resources required by each workflow.

### Application Security

The backend uses authentication middleware and protected API routes to prevent unauthorized access to application resources.

Sensitive configuration such as API credentials and database credentials is kept outside the source code.

---

## 🔄 CI/CD

The project uses GitHub Actions to automate the software delivery process.

A simplified backend deployment flow is:

```text
Developer
    │
    ▼
GitHub
    │
    ▼
GitHub Actions
    │
    ├── Install dependencies
    ├── Build application
    ├── Build Docker image
    ├── Authenticate with AWS using OIDC
    ├── Push image to Amazon ECR
    │
    ▼
Deployment
    │
    ▼
Kubernetes
    │
    ├── Pod
    └── Pod
```

This removes the need to manually build and deploy backend releases.

---

## 📱 Product Flow

A typical emergency workflow looks like this:

```text
1. User presses the discreet physical button
                 │
                 ▼
2. Mobile application detects the trigger
                 │
                 ▼
3. Emergency alert is sent to the backend
                 │
                 ▼
4. Emergency contacts are notified
                 │
                 ▼
5. User's location is continuously updated
                 │
                 ▼
6. Contacts can monitor the situation
                 │
                 ▼
7. User confirms that they are safe
```

The objective is to make the process **fast, discreet, and difficult to interrupt accidentally**.

---

## 🌐 Product Website

The public-facing product presentation is maintained separately from the application repository.

The website is built with **Next.js** and deployed as a static application using:

**Next.js → GitHub Actions → Amazon S3 → CloudFront → discreta.ca**

You can find the website repository here:

**[Discreta Website Repository](https://github.com/ItsmePatrice/panic-necklace)**

It contains the landing page used to present the product, its features, and the overall safety system.

---

## 🚧 Open Items - Documented, Not Hidden

Discreta is an evolving production project. Some infrastructure decisions are intentionally kept simple while the project is still at its current scale.

Being transparent about these tradeoffs is part of documenting the engineering decisions behind the system.

Current known limitations and areas for improvement:

* **Terraform state is currently stored locally per environment.** A remote backend using Amazon S3 with state locking would be the next step for safer collaboration and centralized state management.

* **The backend currently runs on a Kubernetes cluster hosted directly on EC2 rather than Amazon EKS.** This keeps infrastructure costs and operational complexity lower while providing hands-on experience managing Kubernetes directly.

* **The EC2/Kubernetes layer is not yet backed by an Application Load Balancer or Auto Scaling Group.** The current architecture is sufficient for the project's present scale. Introducing these components would make sense as traffic and availability requirements increase.

* **Observability is still an area for improvement.** Centralized logging, metrics, dashboards, and alerting would be added as the system moves toward higher production usage.

* **The CI/CD pipeline can be expanded with additional deployment safeguards.** The current pipelines automate builds, container image publishing, and deployments, while automated testing and stronger deployment gates can be added as the project grows.

### Scaling Path - Not Built, Deliberately Deferred

If usage and availability requirements increase, the infrastructure can evolve without fundamentally changing the application architecture.

1. Introduce an **Application Load Balancer** in front of the Kubernetes workloads.
2. Add an **Auto Scaling Group** to provide additional EC2 capacity.
3. Move Terraform state to a centralized **Amazon S3 backend with state locking**.
4. Expand automated testing and add deployment gates to the CI/CD pipeline.
5. Introduce centralized logging and monitoring using services such as **Amazon CloudWatch**, Prometheus, and Grafana.
6. Evaluate **Amazon EKS** if the operational benefits justify moving Kubernetes management to AWS.
7. Add additional redundancy and multi-instance infrastructure as availability requirements increase.

The goal is to scale the infrastructure when the product requires it, rather than introducing operational complexity before it provides meaningful value.

---

## 🛠️ Local Development

Clone the repository:

```bash
git clone https://github.com/ItsmePatrice/Discreta.git
cd Discreta
```

The backend and application components have their own dependencies and configuration.

Refer to the relevant project directory for installation and environment configuration instructions.

> Environment variables and production credentials are intentionally not included in the repository.

---

## 📈 Engineering Focus

Discreta has been an end-to-end engineering project rather than only an application development project.

It involved working across:

* Application development
* Backend engineering
* Database design
* API development
* Authentication and authorization
* Real-time communication
* Bluetooth hardware integration
* Cloud infrastructure
* Infrastructure as Code
* Containerization
* Kubernetes
* CI/CD
* AWS security and IAM
* Production deployment

The project provided practical experience designing and operating a system across the entire software delivery lifecycle - from a physical hardware interaction all the way to a production cloud environment.

---

## 👨‍💻 Project

**Discreta**

A personal safety system designed to help professionals working alone stay connected to their emergency contacts when it matters most.

**Product:** https://discreta.ca
**Website repository:** https://github.com/ItsmePatrice/panic-necklace
