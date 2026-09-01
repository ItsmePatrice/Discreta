# Discreta

**Discreta is a personal safety system designed for professionals who work alone.**

The system combines a discreet physical device, a mobile application, and a cloud backend to allow a user to silently trigger an emergency alert while sharing their live location with trusted contacts.

This repository contains the **core Discreta application and backend infrastructure**.

The product presentation and sales landing page are maintained in a separate repository:

**[Discreta Website](https://github.com/ItsmePatrice/panic-necklace)**

🌐 **Product website:** https://discreta.ca

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
                    │      (Flic)          │
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
* Added protections around sensitive API routes
* Designed backend services to support multiple running instances

### Cloud & Infrastructure

* Designed and provisioned AWS infrastructure using **Terraform**
* Deployed the backend on **Amazon EC2**
* Containerized services using **Docker**
* Created an **Amazon ECR** repository for application images
* Configured **NGINX** as a reverse proxy
* Configured TLS certificates using **AWS Certificate Manager**
* Built and managed a Kubernetes cluster on EC2
* Deployed backend workloads using Kubernetes Deployments and Services
* Configured multiple backend replicas for improved availability

### CI/CD & DevOps

* Built CI/CD pipelines using **GitHub Actions**
* Automated Node.js builds and testing
* Automated Docker image creation
* Automated image publishing to Amazon ECR
* Implemented GitHub Actions authentication to AWS using **OIDC**
* Avoided storing long-lived AWS access keys in GitHub
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

### AWS authentication

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

### Application security

The backend uses protected API routes and authentication middleware to prevent unauthorized access to application resources.

Sensitive configuration such as API credentials and database credentials is kept outside of the source code.

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

## 🧱 Technology Stack

### Mobile

* **Flutter**
* **Dart**
* Bluetooth / Flic SDK
* Background location services
* Firebase

### Backend

* **Node.js**
* **Express**
* **TypeScript**
* **PostgreSQL**
* Socket.IO
* Firebase
* Stripe

### Cloud

* **Amazon EC2**
* **Amazon ECR**
* **AWS IAM**
* **AWS ACM**
* **Amazon S3**
* **Amazon CloudFront**

### Infrastructure & DevOps

* **Terraform**
* **Docker**
* **Kubernetes**
* **NGINX**
* **GitHub Actions**
* GitHub OIDC

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

The project gave me practical experience designing and operating a system across the entire software delivery lifecycle - from a physical hardware interaction all the way to a production cloud environment.

---

## 👨‍💻 Project

**Discreta**

A personal safety system designed to help professionals working alone stay connected to their emergency contacts when it matters most.

**Product:** https://discreta.ca
**Website repository:** https://github.com/ItsmePatrice/panic-necklace
