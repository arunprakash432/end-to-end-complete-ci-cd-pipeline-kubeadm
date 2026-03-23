# 🚀 End-to-End Complete CI/CD Pipeline with Kubeadm

<div align="center">

![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Kubeadm-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![SonarQube](https://img.shields.io/badge/Quality-SonarQube-4E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Visualization-Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)

<br/>

> **A production-grade, fully automated CI/CD pipeline** built on a self-managed Kubernetes cluster (Kubeadm), with integrated code quality analysis, artifact management, container orchestration, and real-time monitoring — all deployed on AWS.

</div>

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Prerequisites](#-prerequisites)
- [Phase 1 — Infrastructure & Kubernetes Cluster Setup](#phase-1--infrastructure--kubernetes-cluster-setup)
  - [Step 1: Launch Master / Jenkins EC2 Instance](#step-1-launch-master--jenkins-ec2-instance)
  - [Step 2: Security Group Configuration](#step-2-security-group-configuration)
  - [Step 3: Clone the Repository & Install Tools on Master Node](#step-3-clone-the-repository--install-tools-on-master-node)
  - [Step 4: Provision Worker Nodes & Monitoring Server via Terraform](#step-4-provision-worker-nodes--monitoring-server-via-terraform)
  - [Step 5: SSH into All Instances](#step-5-ssh-into-all-instances)
  - [Step 6: Install Kubernetes Components on All Nodes](#step-6-install-kubernetes-components-on-all-nodes)
  - [Step 7: Initialize the Kubernetes Cluster (Master Only)](#step-7-initialize-the-kubernetes-cluster-master-only)
  - [Step 8: Install Pod Network — Calico (Master Only)](#step-8-install-pod-network--calico-master-only)
  - [Step 9: Join Worker Nodes to the Cluster](#step-9-join-worker-nodes-to-the-cluster)
- [Phase 2 — Jenkins CI/CD Pipeline](#phase-2--jenkins-cicd-pipeline)
  - [Step 1: Jenkins Initial Setup & Login](#step-1-jenkins-initial-setup--login)
  - [Step 2: Install Jenkins Plugins](#step-2-install-jenkins-plugins)
  - [Step 3: Upgrade EC2 Instance Type (If Needed)](#step-3-upgrade-ec2-instance-type-if-needed)
  - [Step 4: Configure Tools in Jenkins](#step-4-configure-tools-in-jenkins)
  - [Step 5: SonarQube Setup & Jenkins Integration](#step-5-sonarqube-setup--jenkins-integration)
  - [Step 6: Email Notification Setup](#step-6-email-notification-setup)
  - [Step 7: Docker Hub Integration](#step-7-docker-hub-integration)
  - [Step 8: Grant Jenkins Access to Docker & Kubernetes](#step-8-grant-jenkins-access-to-docker--kubernetes)
  - [Step 9: GitHub Token & Webhook Configuration](#step-9-github-token--webhook-configuration)
  - [Step 10: Nexus Repository Configuration](#step-10-nexus-repository-configuration)
  - [Step 11: Create & Run the Jenkins Pipeline Job](#step-11-create--run-the-jenkins-pipeline-job)
- [Phase 3 — Monitoring & Observability](#phase-3--monitoring--observability)
  - [Step 1: Install Monitoring Tools on the Monitoring Server](#step-1-install-monitoring-tools-on-the-monitoring-server)
  - [Step 2: Configure Prometheus & Blackbox Exporter](#step-2-configure-prometheus--blackbox-exporter)
  - [Step 3: Grafana Setup & Dashboard](#step-3-grafana-setup--dashboard)
- [Screenshots Index](#-screenshots-index)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌐 Project Overview

This project demonstrates a **complete, production-ready DevOps pipeline** for a Java application, covering:

- ✅ Infrastructure provisioning using **Terraform on AWS**
- ✅ Self-managed **Kubernetes cluster** using **Kubeadm** (1 Master + 2 Worker Nodes)
- ✅ Automated **CI/CD pipeline** using **Jenkins**
- ✅ Code quality analysis with **SonarQube**
- ✅ Artifact management via **Nexus Repository**
- ✅ Container image builds, security scans (via **Trivy**), and pushes to **Docker Hub**
- ✅ Kubernetes deployments with **LoadBalancer** and **NodePort** services
- ✅ Full-stack monitoring with **Prometheus**, **Grafana**, and **Blackbox Exporter**
- ✅ Email notifications for pipeline events via **Gmail SMTP**

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud (EC2 Instances)                      │
│                                                                          │
│  ┌────────────────────────┐          ┌────────────────────────────────┐  │
│  │  Master / Jenkins Node  │          │        Worker Node 1           │  │
│  │      (t3.large)         │◄────────►│        (t3.medium)             │  │
│  │                         │          └────────────────────────────────┘  │
│  │  ● Jenkins (8080)       │                                              │
│  │  ● SonarQube (9000)     │          ┌────────────────────────────────┐  │
│  │  ● Nexus (8081)         │◄────────►│        Worker Node 2           │  │
│  │  ● Trivy                │          │        (t3.medium)             │  │
│  │  ● kubeadm master       │          └────────────────────────────────┘  │
│  │  ● containerd / docker  │                                              │
│  └────────────────────────┘                                              │
│                                                                          │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                      Monitoring Server                             │  │
│  │      Prometheus (9090)  |  Grafana (3000)  |  Blackbox (9115)     │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────┘

CI/CD Pipeline Flow:
─────────────────────────────────────────────────────────────
  GitHub Push
      │
      ▼
  GitHub Webhook
      │
      ▼
  Jenkins Pipeline
      ├── Maven Build & Test
      ├── SonarQube Code Quality Analysis
      ├── Nexus Artifact Upload
      ├── Trivy Docker Image Security Scan
      ├── Docker Build & Push to Docker Hub
      └── Deploy to Kubernetes Cluster
              │
              ├── kubectl apply (Pods + Service)
              └── Email Notification (Success / Failure)
```

---

## 🧰 Technology Stack

| Category | Tool / Service |
|---|---|
| **Cloud Provider** | AWS EC2 |
| **Infrastructure as Code** | Terraform |
| **Operating System** | Ubuntu (Latest LTS) |
| **Container Runtime** | Containerd |
| **Container Engine** | Docker |
| **Orchestration** | Kubernetes (Kubeadm) |
| **CNI / Pod Network** | Calico |
| **CI/CD** | Jenkins |
| **Build Tool** | Apache Maven |
| **Code Quality** | SonarQube |
| **Artifact Repository** | Nexus Repository Manager |
| **Security Scanner** | Trivy |
| **Container Registry** | Docker Hub |
| **Monitoring** | Prometheus + Blackbox Exporter |
| **Visualization / Dashboards** | Grafana |
| **Version Control** | GitHub |
| **Notification** | Gmail SMTP (App Password) |

---

## ✅ Prerequisites

Before you begin, ensure you have the following:

- An **AWS account** with an IAM user that has programmatic access (Access Key ID + Secret Access Key)
- A **GitHub account** — fork or clone this repository
- A **Docker Hub account** — to push and pull container images
- A **Gmail account** — for pipeline email notifications (using App Password, not your Gmail password)
- An **SSH key pair** — created in AWS for EC2 access
- Basic understanding of Linux CLI, Kubernetes concepts, and Jenkins

---

## Phase 1 — Infrastructure & Kubernetes Cluster Setup

### Step 1: Launch Master / Jenkins EC2 Instance

Manually launch the first EC2 instance from the AWS console. This will serve as both the **Kubernetes Master Node** and the **Jenkins / tooling server**.

| Parameter | Value |
|---|---|
| **AMI** | Ubuntu (Latest LTS) |
| **Instance Type** | `t3.medium` (to be upgraded to `t3.large` in Phase 2) |
| **Storage** | 30 GB |
| **Key Pair** | Assign an existing key pair or create a new one |
| **Security Group** | Create a new group — see Step 2 below |

> 📸 **Screenshot:** ![01-launch-an-instance-master-node.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/01-launch-an-instance-master-node.png)

---

### Step 2: Security Group Configuration

Configure the security group for the **Master / Jenkins node** to allow the following inbound ports:

| Port / Range | Protocol | Purpose |
|---|---|---|
| `22` | TCP | SSH access |
| `80` | TCP | HTTP |
| `443` | TCP | HTTPS |
| `6443` | TCP | Kubernetes API Server |
| `2379–2380` | TCP | etcd server (Kubernetes internal) |
| `10250` | TCP | Kubelet API |
| `10257` | TCP | Kube Controller Manager |
| `10259` | TCP | Kube Scheduler |
| `30000–32767` | TCP | NodePort Services (Kubernetes) |
| `8080` | TCP | Jenkins web UI |
| `8081` | TCP | Nexus Repository Manager |
| `9000` | TCP | SonarQube |
| `465` | TCP | SMTPS — Extended Email (Jenkins) |
| `587` | TCP | SMTP/TLS — Basic Email (Jenkins) |

> 📸 **Screenshots:**
> ![02-security-group-master-node.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/02-security-group-master-node.png)
> ![03-security-group-master-node.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/03-security-group-master-node.png)

> 💡 **Note for Monitoring Server:** The Monitoring Server provisioned by Terraform should also have ports `9090` (Prometheus), `3000` (Grafana), and `9115` (Blackbox Exporter) open in its security group.

---

### Step 3: Clone the Repository & Install Tools on Master Node

SSH into the master/Jenkins instance:

```bash
ssh -i your-key.pem ubuntu@<MASTER_PUBLIC_IP>
```

**Clone the project repository first:**

```bash
git clone https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm.git
cd end-to-end-complete-ci-cd-pipeline-kubeadm
```

**Install all required tools** using the scripts in the `scripts/` folder or by following the official documentation:

```bash
# The following tools must be installed on the master/Jenkins node:
# Jenkins, Terraform, AWS CLI, SonarQube, Nexus Repository Manager,
# Trivy, Containerd, Docker, Kubeadm, Kubelet, Kubectl

# Use the provided installation scripts:
bash scripts/install-tools.sh
```

**Configure AWS CLI** with your IAM credentials to allow Terraform to provision resources:

```bash
aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (e.g., us-east-1)
# Enter: Default output format (press Enter for default)
```

---

### Step 4: Provision Worker Nodes & Monitoring Server via Terraform

Navigate to the `infra/` directory and use Terraform to provision the remaining EC2 instances:

```bash
cd infra/

# Initialize Terraform (downloads providers)
terraform init

# Preview what will be created
terraform plan

# Apply and create the infrastructure
terraform apply
```

Terraform will create **3 EC2 Ubuntu instances**:
- `kube-ec2-1` → Worker Node 1
- `kube-ec2-2` → Worker Node 2
- `kube-ec2-3` → Monitoring Server

> 🏷️ **Rename `kube-ec2-3` to `monitoring-server`** in the AWS Console for clarity:
> AWS Console → EC2 → Instances → Click the instance name → Edit → Save

> 📸 **Screenshots:**
> ![04-terraform-creation-of-worker-nodes-and-monitoring-server.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/04-terraform-creation-of-worker-nodes-and-monitoring-server.png)
> ![05-resources-created.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/05-resources-created.png)
> ![06-after-resources-created-rename.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/06-after-resources-created-rename.png)

---

### Step 5: SSH into All Instances

Open separate terminal sessions and SSH into all 3 newly created instances (Worker Node 1, Worker Node 2, and Monitoring Server) using your key pair:

```bash
ssh -i your-key.pem ubuntu@<WORKER_NODE_1_PUBLIC_IP>
ssh -i your-key.pem ubuntu@<WORKER_NODE_2_PUBLIC_IP>
ssh -i your-key.pem ubuntu@<MONITORING_SERVER_PUBLIC_IP>
```

> 📸 **Screenshot:** ![07-login-into-all-machines.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/07-login-into-all-machines.png)

---

### Step 6: Install Kubernetes Components on All Nodes

> ⚠️ **Run these steps on ALL 3 nodes: Master, Worker Node 1, and Worker Node 2.**

Install `containerd`, `kubeadm`, `kubelet`, and `kubectl` using the scripts in the repository or by following the [official Kubernetes documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/).

```bash
# Run the kubernetes installation script on each node
bash scripts/install-kubernetes.sh
```

**Enable the CRI plugin in Containerd** (required for Kubernetes — run on ALL nodes):

```bash
# Option A — Edit existing config to remove "cri" from disabled plugins:
sudo vi /etc/containerd/config.toml
# Find the line:   disabled_plugins = ["cri"]
# Change it to:   disabled_plugins = []
# Save and exit (:wq)
sudo systemctl restart containerd

# Option B — Regenerate a clean default config (recommended):
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

# Verify containerd is running correctly:
sudo systemctl status containerd
```

---

### Step 7: Initialize the Kubernetes Cluster (Master Only)

> ⚠️ **Run this section on the Master Node only.**

```bash
# Fetch the master node's private IP from AWS instance metadata
MASTER_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Verify the IP is correct before proceeding
echo "Master IP: $MASTER_IP"

# Initialize the Kubernetes cluster
sudo kubeadm init \
  --apiserver-advertise-address=$MASTER_IP \
  --pod-network-cidr=192.168.0.0/16 \
  --cri-socket unix:///run/containerd/containerd.sock
```

> ⚠️ **Critical:** Copy and save the entire `kubeadm join ...` command printed at the end of the output. You will need this to join worker nodes in Step 9.

**Set up `kubectl` access for the current user (ubuntu):**

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify kubectl works on the master
kubectl get nodes
```

---

### Step 8: Install Pod Network — Calico (Master Only)

A CNI (Container Network Interface) plugin is required for pod communication. Install Calico:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
```

**Wait for all system pods to reach `Running` state:**

```bash
# Watch the pods come up (Ctrl+C to exit once all are Running)
watch kubectl get pods -n kube-system

# You should see all pods showing STATUS: Running before proceeding
kubectl get pods -n kube-system
```

> ⏳ This may take 1–3 minutes. Do not proceed to join worker nodes until all `kube-system` pods are `Running`.

---

### Step 9: Join Worker Nodes to the Cluster

> ⚠️ **Run the `kubeadm join` command on each Worker Node separately.**

Use the join command saved from Step 7:

```bash
# Run this on Worker Node 1 AND Worker Node 2:
sudo kubeadm join <MASTER_PRIVATE_IP>:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --cri-socket unix:///run/containerd/containerd.sock
```

> 💡 If the token has expired (tokens expire after 24 hours), generate a new one on the master:
> ```bash
> kubeadm token create --print-join-command
> ```

**Verify from the Master Node that all nodes have joined successfully:**

```bash
kubectl get nodes
# Expected output: All 3 nodes (1 master + 2 workers) with STATUS: Ready
```

> 📸 **Screenshots:**
> ![08-kubeadm-join-command.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/08-kubeadm-join-command.png)
> ![09-worker-node1-kubeadm-join-command.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/09-worker-node1-kubeadm-join-command.png)
> ![10-worker-node-2-kubeadm-join-command.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/10-worker-node-2-kubeadm-join-command.png)
> ![11-after-joining-master-node-kubectl-get-nodes.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/11-after-joining-master-node-kubectl-get-nodes.png)

---

## Phase 2 — Jenkins CI/CD Pipeline

### Step 1: Jenkins Initial Setup & Login

Access the Jenkins web UI at `http://<MASTER_PUBLIC_IP>:8080`.

Retrieve the initial admin password from the master node terminal:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password, paste it into the Jenkins unlock screen, and complete the setup wizard (install suggested plugins, create an admin user).

> 📸 **Screenshot:** ![12-login-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/12-login-jenkins.png)

---

### Step 2: Install Jenkins Plugins

Navigate to **Manage Jenkins → Plugins → Available Plugins** and search for and install the following plugins:

| Plugin Name | Purpose |
|---|---|
| **Pipeline: Stage View** | Visual pipeline stage UI |
| **Eclipse Temurin Installer** | JDK auto-installation |
| **Pipeline Maven Integration** | Maven support in pipelines |
| **Config File Provider** | Manage config files (e.g., `settings.xml`) |
| **SonarQube Scanner** | SonarQube analysis integration |
| **Kubernetes CLI** | `kubectl` in pipeline steps |
| **Kubernetes** | Kubernetes cloud agents |
| **Docker** | Docker build/run support |
| **Docker Pipeline Step** | Docker steps in Declarative Pipeline |

Click **Install** and restart Jenkins once installation completes.

> 📸 **Screenshot:** ![13-install-jenkins-plugins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/13-install-jenkins-plugins.png)

---

### Step 3: Upgrade EC2 Instance Type (If Needed)

> 💡 If your `t3.medium` instance becomes unstable or crashes under the combined load of Jenkins + SonarQube + Nexus, upgrade it to `t3.large`:

1. AWS Console → **EC2 → Instances** → Select the master instance
2. **Instance State → Stop** (wait for it to stop fully)
3. **Actions → Instance Settings → Change Instance Type**
4. Select `t3.large` → Apply
5. **Start** the instance again
6. Reconnect via SSH and verify Jenkins, SonarQube, and Nexus are running

> 📸 **Screenshots:**
> ![14-change-instance-type.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/14-change-instance-type.png)
> ![15-new-instance-type.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/15-new-instance-type.png)
> ![16-new-instance-type-changes.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/16-new-instance-type-changes.png)
> ![17-new-instance-type-changed-successfully.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/17-new-instance-type-changed-successfully.png)

---

### Step 4: Configure Tools in Jenkins

Go to **Manage Jenkins → Tools** and configure the following:

| Tool | Configuration Name | Details |
|---|---|---|
| **JDK** | `jdk17` | Install automatically via Eclipse Temurin |
| **Maven** | `maven3` | Install automatically (latest Maven 3.x) |
| **SonarQube Scanner** | `sonar-scanner` | Install automatically |
| **Docker** | `docker` | Install automatically |

Click **Apply and Save**.

> 📸 **Screenshots:**
> ![20-install-jdk-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/20-install-jdk-in-jenkins.png)
> ![21-install-sonar-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/21-install-sonar-in-jenkins.png)
> ![22-install-maven3-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/22-install-maven3-in-jenkins.png)
> ![23-install-docker-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/23-install-docker-in-jenkins.png)

---

### Step 5: SonarQube Setup & Jenkins Integration

#### 5a — Configure SonarQube

Access SonarQube at `http://<MASTER_PUBLIC_IP>:9000`.

1. Log in with default credentials: **Username:** `admin` / **Password:** `admin`
2. You will be prompted to change the default password — set a new secure password.
3. Generate an authentication token:
   - Navigate to **Administration → Security → Users → Tokens**
   - Click **Generate Token**, give it a name (e.g., `jenkins-sonar-token`), and copy the token value.

> 📸 **Screenshots:**
> ![18-sonarqube-after-login.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/18-sonarqube-after-login.png)
> ![19-sonarqube-token-created.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/19-sonarqube-token-created.png)

#### 5b — Add SonarQube to Jenkins

1. Go to **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**:
   - **Kind:** Secret text
   - **Secret:** Paste the SonarQube token
   - **ID:** `sonar-token`
   - Click **Create**

2. Go to **Manage Jenkins → System → SonarQube Installations**:
   - Click **Add SonarQube**
   - **Name:** `sonar-server`
   - **Server URL:** `http://<MASTER_PRIVATE_IP>:9000`
   - **Server Authentication Token:** Select the `sonar-token` credential
   - Click **Apply and Save**

> 📸 **Screenshot:** ![24-configure-sonar-url-and-credentials.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/24-configure-sonar-url-and-credentials.png)

---

### Step 6: Email Notification Setup

#### 6a — Create a Gmail App Password

> ⚠️ **Never use your actual Gmail account password.** Jenkins requires a Gmail App Password.

1. Go to your **Google Account** → Click your profile → **Manage your Google account**
2. In the search bar, type **"App Passwords"** and open it
3. Select **App:** `Mail` and **Device:** `Other (custom name)` → Enter `jenkins`
4. Click **Generate** and copy the 16-character App Password

#### 6b — Configure Basic Email (E-mail Notification)

Go to **Manage Jenkins → System → E-mail Notification**:

| Field | Value |
|---|---|
| **SMTP Server** | `smtp.gmail.com` |
| **Default Email Suffix** | `@gmail.com` |
| **Use SMTP Authentication** | ✅ Checked |
| **Username** | Your full Gmail address |
| **Password** | Your Gmail **App Password** |
| **Use TLS** | ✅ Checked |
| **SMTP Port** | `587` |
| **Reply-To Address** | Your full Gmail address |

Click **Test Configuration** to verify, then **Apply and Save**.

#### 6c — Configure Extended Email Notification

Go to **Manage Jenkins → System → Extended E-mail Notification**:

| Field | Value |
|---|---|
| **SMTP Server** | `smtp.gmail.com` |
| **SMTPS Port** | `465` |
| **Default Email Suffix** | `@gmail.com` |
| **Use TLS** | ✅ Checked |
| **Credentials** | Add → Username with Password |
| **Username** | Your full Gmail address |
| **Password** | Your Gmail **App Password** |
| **Credential ID** | `starbucks-gmail` |

Click **Apply and Save**.

---

### Step 7: Docker Hub Integration

**Generate a Docker Hub Access Token:**

1. Log in to [hub.docker.com](https://hub.docker.com)
2. Go to **Account Settings → Security → New Access Token**
3. Give it a name (e.g., `jenkins-token`) and set permissions to **Read, Write, Delete**
4. Copy the generated token

**Add Docker Hub credentials to Jenkins:**

1. Go to **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**
   - **Kind:** Username with password
   - **Username:** Your Docker Hub username
   - **Password:** The Docker Hub access token (NOT your Docker Hub password)
   - **ID:** `docker-cred`
   - Click **Create**

> 📸 **Screenshot:** ![25-dockerhub-token-generation.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/25-dockerhub-token-generation.png)

---

### Step 8: Grant Jenkins Access to Docker & Kubernetes

#### 8a — Add Jenkins to the Docker Group

```bash
# Add the jenkins user to the docker group
sudo usermod -aG docker jenkins

# Restart Jenkins to apply group membership
sudo systemctl restart jenkins
```

#### 8b — Grant Jenkins kubectl Access

Jenkins runs as the `jenkins` user. You must copy the kubeconfig so Jenkins can communicate with the Kubernetes cluster.

```bash
# Verify which user Jenkins runs as (should be 'jenkins')
ps aux | grep jenkins

# Create the .kube directory for the jenkins user
sudo mkdir -p /var/lib/jenkins/.kube

# Copy the admin kubeconfig to the jenkins user's directory
sudo cp /etc/kubernetes/admin.conf /var/lib/jenkins/.kube/config

# Set correct ownership so jenkins user can read it
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

# Verify Jenkins can now reach the cluster
sudo -u jenkins kubectl get nodes
# Expected: All nodes listed with STATUS: Ready
```

> 📸 **Screenshot:** ![26-test-jenkins-kubernetes-configuration.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/26-test-jenkins-kubernetes-configuration.png)

---

### Step 9: GitHub Token & Webhook Configuration

#### 9a — Create a GitHub Personal Access Token

1. GitHub → **Settings** (top-right profile menu) → **Developer Settings**
2. **Personal Access Tokens → Tokens (Classic) → Generate new token (classic)**
3. Give it a name, set expiration, and select scopes: `repo`, `admin:repo_hook`
4. Click **Generate token** and copy it

**Add the GitHub token to Jenkins:**

1. Go to **Manage Jenkins → Credentials → System → Global credentials → Add Credentials**
   - **Kind:** Username with password
   - **Username:** Your GitHub username
   - **Password:** The GitHub personal access token
   - **ID:** `github-token`
   - Click **Create**

#### 9b — Create a GitHub Webhook

In your GitHub repository:

1. **Settings → Webhooks → Add webhook**
2. Fill in the details:
   - **Payload URL:** `http://<MASTER_PUBLIC_IP>:8080/github-webhook/`
   - **Content type:** `application/json`
   - **Which events:** Select `Just the push event`
3. Ensure **Active** is checked → Click **Add webhook**

> 📸 **Screenshots:**
> ![27-create-github-webhook.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/27-create-github-webhook.png)
> ![28-github-webhook-created.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/28-github-webhook-created.png)

---

### Step 10: Nexus Repository Configuration

#### 10a — Update pom.xml with Your Nexus IP

In the application source code (`app/pom.xml`), replace the placeholder IP and port with your actual Nexus server's IP and port:

```xml
<!-- Update the distributionManagement section in app/pom.xml -->
<distributionManagement>
  <repository>
    <id>maven-releases</id>
    <url>http://<NEXUS_PUBLIC_OR_PRIVATE_IP>:8081/repository/maven-releases/</url>
  </repository>
  <snapshotRepository>
    <id>maven-snapshots</id>
    <url>http://<NEXUS_PUBLIC_OR_PRIVATE_IP>:8081/repository/maven-snapshots/</url>
  </snapshotRepository>
</distributionManagement>
```

Commit and push this change to your GitHub repository.

#### 10b — Configure Maven settings.xml in Jenkins

Go to **Manage Jenkins → Managed Files → Add a new Config**:

1. Select type: **Maven settings.xml**
2. **ID:** `maven-settings`
3. In the **Content** section, add your Nexus credentials inside the `<servers>` block:

```xml
<settings>
  <servers>
    <server>
      <id>maven-releases</id>
      <username>admin</username>
      <password>your-nexus-password</password>
    </server>
    <server>
      <id>maven-snapshots</id>
      <username>admin</username>
      <password>your-nexus-password</password>
    </server>
  </servers>
</settings>
```

4. Click **Submit / Save**

> 📸 **Screenshots:**
> ![29-config-file-provider-configuration.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/29-config-file-provider-configuration.png)
> ![30-nexus-jenkins-configuration.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/30-nexus-jenkins-configuration.png)
> ![31-nexus-jenkins-configured-successfully.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/31-nexus-jenkins-configured-successfully.png)

---

### Step 11: Create & Run the Jenkins Pipeline Job

**Create the Jenkins Pipeline job:**

1. Jenkins Dashboard → **New Item**
2. **Item name:** `java-application`
3. Select **Pipeline** → Click **OK**
4. Under **Build Triggers**, enable: ✅ **GitHub hook trigger for GITScm polling**
5. Under **Pipeline**, select:
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** `https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm.git`
   - **Credentials:** Select `github-token`
   - **Branch:** `*/main`
   - **Script Path:** `Jenkinsfile`
6. Click **Apply and Save**

**Trigger the first build:**

Click **Build Now** to run the pipeline manually for the first time.

**Verify the deployment on the master node:**

```bash
# Check that application pods are running
kubectl get pods

# Check that the service was created (NodePort / LoadBalancer)
kubectl get svc

# Check all resources in the default namespace
kubectl get all
```

> 📸 **Screenshots:**
> ![32-jenkins-pipeline-successfully.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/32-jenkins-pipeline-successfully.png)
> ![33-jenkins-pipeline-successfully-1.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/33-jenkins-pipeline-successfully-1.png)
> ![34-browser-output-of-java-application.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/34-browser-output-of-java-application.png)
> ![35-loadbalancer.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/35-loadbalancer.png)
> ![36-browser-output-different-port-numbers.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/36-browser-output-different-port-numbers.png)
> ![37-browser-output-different-port-numbers.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/37-browser-output-different-port-numbers.png)

---

## Phase 3 — Monitoring & Observability

### Step 1: Install Monitoring Tools on the Monitoring Server

SSH into the **Monitoring Server** (the renamed `kube-ec2-3` instance):

```bash
ssh -i your-key.pem ubuntu@<MONITORING_SERVER_PUBLIC_IP>
```

Clone the repository and run the installation scripts:

```bash
git clone https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm.git
cd end-to-end-complete-ci-cd-pipeline-kubeadm/scripts

# Install Prometheus
bash install-prometheus.sh

# Install Grafana
bash install-grafana.sh

# Install Blackbox Exporter
bash install-blackbox-exporter.sh
```

Verify all three services are active:

```bash
sudo systemctl status prometheus
sudo systemctl status grafana-server
sudo systemctl status blackbox_exporter
```

---

### Step 2: Configure Prometheus & Blackbox Exporter

**Edit the Prometheus configuration** to add scrape targets for your application and the Blackbox Exporter:

```bash
sudo vi /etc/prometheus/prometheus.yml
```

Add the following scrape configurations (adjust IPs and URLs to match your setup):

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - http://<MASTER_PUBLIC_IP>:8080       # Jenkins
          - http://<MASTER_PUBLIC_IP>:9000       # SonarQube
          - http://<MASTER_PUBLIC_IP>:<APP_PORT> # Java Application
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9115

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

**Edit the Blackbox Exporter configuration:**

```bash
sudo vi /etc/blackbox.yml
```

Ensure the HTTP probe module is defined:

```yaml
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
      valid_status_codes: []
      method: GET
```

**Restart both services to apply changes:**

```bash
sudo systemctl restart prometheus
sudo systemctl restart blackbox_exporter

# Verify they are running
sudo systemctl status prometheus
sudo systemctl status blackbox_exporter
```

> 📸 **Screenshots:**
> ![38-prometheus-web-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/38-prometheus-web-page.png)
> ![40-blackbox-exporter-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/40-blackbox-exporter-page.png)
> ![41-prometheus-output.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/41-prometheus-output.png)
> ![42-blackbox-exporter-output-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/42-blackbox-exporter-output-page.png)

---

### Step 3: Grafana Setup & Dashboard

**Access Grafana** at `http://<MONITORING_SERVER_PUBLIC_IP>:3000`

> 📸 **Screenshot:** ![39-grafana-login-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/39-grafana-login-page.png)

1. Log in with default credentials: **Username:** `admin` / **Password:** `admin`
2. Set a new secure password when prompted.

**Add Prometheus as a Data Source:**

1. Go to **Configuration (⚙️) → Data Sources → Add data source**
2. Select **Prometheus**
3. Fill in:
   - **URL:** `http://localhost:9090` (or `http://<MONITORING_SERVER_PRIVATE_IP>:9090`)
4. Scroll down → Click **Save & Test**
5. You should see a green **"Data source is working"** confirmation.

> 📸 **Screenshots:**
> ![43-grafana-prometheus-configuration-data-source.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/43-grafana-prometheus-configuration-data-source.png)
> ![44-grafana-prometheus-configuration-data-source.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/44-grafana-prometheus-configuration-data-source.png)

**Create Dashboards:**

Manually create dashboards or import pre-built ones to visualize:
- Application uptime and HTTP response codes (via Blackbox Exporter)
- Kubernetes cluster node metrics (CPU, Memory, Disk)
- Jenkins build metrics

> 📸 **Screenshots:**
> ![45-grafana-dashboard-output.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/45-grafana-dashboard-output.png)
> ![46-grafana-dashboard-ouput.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/46-grafana-dashboard-ouput.png)

---

## 📸 Screenshots Index

All screenshots are stored in [`https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/`](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/). Click any filename to view it.

<details>
<summary>📁 View full index of all 46 screenshots</summary>

| # | File | Description | Phase |
|---|---|---|---|
| 01 | ![01-launch-an-instance-master-node.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/01-launch-an-instance-master-node.png) | Launching the Master/Jenkins EC2 instance | Phase 1 |
| 02 | ![02-security-group-master-node.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/02-security-group-master-node.png) | Security group inbound rules (part 1) | Phase 1 |
| 03 | ![03-security-group-master-node.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/03-security-group-master-node.png) | Security group inbound rules (part 2) | Phase 1 |
| 04 | ![04-terraform-creation-of-worker-nodes-and-monitoring-server.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/04-terraform-creation-of-worker-nodes-and-monitoring-server.png) | `terraform apply` creating EC2 instances | Phase 1 |
| 05 | ![05-resources-created.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/05-resources-created.png) | All Terraform resources created successfully | Phase 1 |
| 06 | ![06-after-resources-created-rename.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/06-after-resources-created-rename.png) | Renaming kube-ec2-3 to monitoring-server | Phase 1 |
| 07 | ![07-login-into-all-machines.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/07-login-into-all-machines.png) | SSH login into all EC2 instances | Phase 1 |
| 08 | ![08-kubeadm-join-command.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/08-kubeadm-join-command.png) | kubeadm join command output after cluster init | Phase 1 |
| 09 | ![09-worker-node1-kubeadm-join-command.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/09-worker-node1-kubeadm-join-command.png) | Worker Node 1 successfully joined the cluster | Phase 1 |
| 10 | ![10-worker-node-2-kubeadm-join-command.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/10-worker-node-2-kubeadm-join-command.png) | Worker Node 2 successfully joined the cluster | Phase 1 |
| 11 | ![11-after-joining-master-node-kubectl-get-nodes.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/11-after-joining-master-node-kubectl-get-nodes.png) | `kubectl get nodes` — all nodes STATUS: Ready | Phase 1 |
| 12 | ![12-login-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/12-login-jenkins.png) | Jenkins initial unlock / login page | Phase 2 |
| 13 | ![13-install-jenkins-plugins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/13-install-jenkins-plugins.png) | Installing required Jenkins plugins | Phase 2 |
| 14 | ![14-change-instance-type.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/14-change-instance-type.png) | Stopping instance to change the type | Phase 2 |
| 15 | ![15-new-instance-type.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/15-new-instance-type.png) | Selecting t3.large instance type | Phase 2 |
| 16 | ![16-new-instance-type-changes.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/16-new-instance-type-changes.png) | Confirming the instance type change | Phase 2 |
| 17 | ![17-new-instance-type-changed-successfully.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/17-new-instance-type-changed-successfully.png) | Instance successfully upgraded to t3.large | Phase 2 |
| 18 | ![18-sonarqube-after-login.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/18-sonarqube-after-login.png) | SonarQube dashboard after first login | Phase 2 |
| 19 | ![19-sonarqube-token-created.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/19-sonarqube-token-created.png) | SonarQube authentication token generated | Phase 2 |
| 20 | ![20-install-jdk-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/20-install-jdk-in-jenkins.png) | JDK (Eclipse Temurin) configured in Jenkins Tools | Phase 2 |
| 21 | ![21-install-sonar-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/21-install-sonar-in-jenkins.png) | SonarQube Scanner configured in Jenkins Tools | Phase 2 |
| 22 | ![22-install-maven3-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/22-install-maven3-in-jenkins.png) | Maven 3 configured in Jenkins Tools | Phase 2 |
| 23 | ![23-install-docker-in-jenkins.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/23-install-docker-in-jenkins.png) | Docker configured in Jenkins Tools | Phase 2 |
| 24 | ![24-configure-sonar-url-and-credentials.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/24-configure-sonar-url-and-credentials.png) | SonarQube server URL and token added in Jenkins System | Phase 2 |
| 25 | ![25-dockerhub-token-generation.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/25-dockerhub-token-generation.png) | Docker Hub personal access token created | Phase 2 |
| 26 | ![26-test-jenkins-kubernetes-configuration.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/26-test-jenkins-kubernetes-configuration.png) | Jenkins user verified to access Kubernetes cluster | Phase 2 |
| 27 | ![27-create-github-webhook.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/27-create-github-webhook.png) | Creating GitHub webhook pointing to Jenkins | Phase 2 |
| 28 | ![28-github-webhook-created.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/28-github-webhook-created.png) | GitHub webhook active and delivering | Phase 2 |
| 29 | ![29-config-file-provider-configuration.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/29-config-file-provider-configuration.png) | Maven settings.xml created in Jenkins Managed Files | Phase 2 |
| 30 | ![30-nexus-jenkins-configuration.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/30-nexus-jenkins-configuration.png) | Nexus credentials and URL configured in settings.xml | Phase 2 |
| 31 | ![31-nexus-jenkins-configured-successfully.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/31-nexus-jenkins-configured-successfully.png) | Nexus configuration saved successfully | Phase 2 |
| 32 | ![32-jenkins-pipeline-successfully.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/32-jenkins-pipeline-successfully.png) | Jenkins pipeline — all stages passed (view 1) | Phase 2 |
| 33 | ![33-jenkins-pipeline-successfully-1.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/33-jenkins-pipeline-successfully-1.png) | Jenkins pipeline — all stages passed (view 2) | Phase 2 |
| 34 | ![34-browser-output-of-java-application.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/34-browser-output-of-java-application.png) | Java application running and accessible in browser | Phase 2 |
| 35 | ![35-loadbalancer.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/35-loadbalancer.png) | Kubernetes LoadBalancer service for the application | Phase 2 |
| 36 | ![36-browser-output-different-port-numbers.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/36-browser-output-different-port-numbers.png) | Application accessible via NodePort (view 1) | Phase 2 |
| 37 | ![37-browser-output-different-port-numbers.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/37-browser-output-different-port-numbers.png) | Application accessible via NodePort (view 2) | Phase 2 |
| 38 | ![38-prometheus-web-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/38-prometheus-web-page.png) | Prometheus web UI and targets page | Phase 3 |
| 39 | ![39-grafana-login-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/39-grafana-login-page.png) | Grafana initial login page | Phase 3 |
| 40 | ![40-blackbox-exporter-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/40-blackbox-exporter-page.png) | Blackbox Exporter running at port 9115 | Phase 3 |
| 41 | ![41-prometheus-output.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/41-prometheus-output.png) | Prometheus metrics query output | Phase 3 |
| 42 | ![42-blackbox-exporter-output-page.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/42-blackbox-exporter-output-page.png) | Blackbox Exporter probe metrics output | Phase 3 |
| 43 | ![43-grafana-prometheus-configuration-data-source.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/43-grafana-prometheus-configuration-data-source.png) | Adding Prometheus as Grafana data source | Phase 3 |
| 44 | ![44-grafana-prometheus-configuration-data-source.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/44-grafana-prometheus-configuration-data-source.png) | Grafana data source — Save & Test confirmed | Phase 3 |
| 45 | ![45-grafana-dashboard-output.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/45-grafana-dashboard-output.png) | Grafana dashboard showing application metrics | Phase 3 |
| 46 | ![46-grafana-dashboard-ouput.png](https://github.com/arunprakash432/end-to-end-complete-ci-cd-pipeline-kubeadm/raw/main/assets/screenshots/46-grafana-dashboard-ouput.png) | Grafana dashboard — full panel view | Phase 3 |

</details>

---

## 🛠️ Troubleshooting

| Issue | Likely Cause | Fix |
|---|---|---|
| `kubectl get nodes` shows `NotReady` | Calico not fully started or CNI issue | Run `kubectl get pods -n kube-system` and wait for all pods to reach `Running` |
| Containerd CRI socket error on `kubeadm init` | CRI plugin disabled in config | Ensure `disabled_plugins = []` in `/etc/containerd/config.toml`, then `sudo systemctl restart containerd` |
| `kubeadm join` token expired | Join tokens expire after 24 hours | Run `kubeadm token create --print-join-command` on the master to get a new join command |
| Jenkins pipeline fails at Docker build step | Jenkins not in docker group | Run `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins` |
| `sudo -u jenkins kubectl get nodes` fails | Jenkins user doesn't have kubeconfig | Re-run the kubeconfig copy steps in Phase 2, Step 8b |
| EC2 instance crashes or OOM under load | t3.medium underpowered | Upgrade to `t3.large` (see Phase 2, Step 3) |
| SonarQube analysis fails in pipeline | Token expired or wrong credential ID | Regenerate token in SonarQube Admin, update the `sonar-token` credential in Jenkins |
| Nexus artifact upload fails | Wrong IP/port in pom.xml or bad credentials | Verify `<NEXUS_IP>:8081` in `pom.xml` and Nexus credentials in Jenkins Managed Files |
| GitHub webhook shows delivery failures | Jenkins URL unreachable from GitHub | Ensure port `8080` is open in the security group and Jenkins is running |
| Prometheus targets show `DOWN` | Wrong IP/port in `prometheus.yml` | Update scrape targets with correct IPs and restart Prometheus |
| Grafana shows "No data" | Wrong Prometheus URL in data source | Verify Prometheus is running and the URL in Grafana data source is reachable |

---

## 🤝 Contributing

Contributions, improvements, and bug fixes are welcome!

1. Fork this repository
2. Create a new branch: `git checkout -b feature/your-feature-name`
3. Make your changes and commit: `git commit -m 'Add: description of your change'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request describing your changes

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

<div align="center">

**Built with ❤️ by [Arunprakash K ](https://github.com/arunprakash432)**

⭐ **If this project helped you, please give it a star!** ⭐

</div>
