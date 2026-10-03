# Cloud-X Org | Azure Enterprise VM Environment

> A hands-on Microsoft Azure infrastructure project demonstrating enterprise-style networking, Linux and Windows workloads, web services, security controls, and public load balancing.

---

## 📌 Project Overview

This project demonstrates the design and deployment of a multi-tier virtual machine environment on **Microsoft Azure**.

The environment was designed to separate workloads into dedicated network segments while providing controlled Internet access to web applications hosted on both **Rocky Linux** and **Windows Server** virtual machines.

### Key Components

- Azure Resource Group
- Azure Virtual Network (VNet)
- Dedicated WEB and APP subnets
- Rocky Linux Web Server
- Apache HTTP Server (`httpd`)
- Windows Server
- Internet Information Services (IIS)
- Network Security Groups (NSGs)
- Public IP addresses
- Azure Public Load Balancer
- Backend Pool
- HTTP traffic on TCP/80

---

# 🏗️ Architecture

```text
                              INTERNET
                                  │
                                  │
                         ┌────────▼────────┐
                         │  Azure Public   │
                         │   Load Balancer │
                         └────────┬────────┘
                                  │
                         Backend Pool
                         ┌────────┴────────┐
                         │                 │
                         ▼                 ▼
                ┌────────────────┐  ┌────────────────┐
                │  Rocky Linux   │  │ Windows Server │
                │    Web VM      │  │     APP VM     │
                │                │  │                │
                │ Apache httpd   │  │      IIS       │
                │    TCP/80      │  │    TCP/80      │
                └───────┬────────┘  └───────┬────────┘
                        │                   │
                        ▼                   ▼
                 ┌─────────────┐     ┌─────────────┐
                 │ Subnet-WEB  │     │ Subnet-APP  │
                 │ 10.0.0.0/24 │     │ 10.0.1.0/24 │
                 └──────┬──────┘     └──────┬──────┘
                        │                   │
                        └─────────┬─────────┘
                                  │
                         ┌────────▼────────┐
                         │  Cloud-X-VNET   │
                         │  10.0.0.0/21    │
                         └─────────────────┘
