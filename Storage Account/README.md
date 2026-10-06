Azure Storage – Production & Non-Production
📌 Project Overview

Hands-on Azure Storage project for CloudX, demonstrating how to manage Production and Non-Production storage environments under a single Azure subscription.

Region: Central India
Focus: Azure Storage, Blob Storage, Security, Data Protection & Networking

🏗️ Architecture
Azure Subscription
│
├── CloudX-Prod-RG
│   └── Production Storage Account
│       └── cloudx-production-data
│
└── CloudX-NonProd-RG
    └── Non-Production Storage Account
        └── nonprod-temp-data

🔧 Implementation

Created separate Prod and Non-Prod Resource Groups.

Created Storage Accounts and Blob Containers.

Uploaded images and text files.

Generated SAS URL for controlled Blob access.

Enabled Blob Versioning and tested recovery of previous file versions.

Configured Lifecycle Management:

Non-Prod → Delete after 90 days

Prod → Delete after 180 days

Created a Private Endpoint for secure private connectivity.

Disabled public network access and tested private access.

Used nslookup to test Storage endpoint/DNS resolution.

Tested public vs private access behavior.

🔐 Key Azure Concepts

Azure Storage Accounts

Blob Storage

SAS

Blob Versioning

Lifecycle Management

Private Endpoint

Virtual Network

DNS

Storage Security

🎯 Objective

To gain practical AZ-104 Azure Administrator experience in storage management, data protection, lifecycle policies, access control, networking, and troubleshooting.

🚀 Future Improvements

Azure RBAC

Microsoft Entra ID authentication

Azure Monitor & Log Analytics

Private DNS Zone

Azure CLI / PowerShell

Bicep automation

Storage alerts and cost optimization
