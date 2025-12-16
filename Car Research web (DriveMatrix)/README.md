# DriveMatrix 🚘

> **The Trust Layer for the Indian Automotive Market.**
> *Data Integrity | User Privacy | AI-Driven Valuation*

![Status](https://img.shields.io/badge/Status-Pre--Alpha-red)
![Stack](https://img.shields.io/badge/Stack-MERN_%2B_Python-blue)
![Infrastructure](https://img.shields.io/badge/Cloud-Azure-0078D4)

## 📋 Executive Summary
DriveMatrix is a high-fidelity decision-enablement engine tailored specifically for the Indian automotive market. Unlike incumbents that prioritize aggressive lead generation, DriveMatrix disrupts the status quo by prioritizing **data integrity** and **user privacy**.

We bridge the gap between market psychological needs and rigorous engineering execution, serving both new car buyers and the rapidly expanding used car demographic.

## 🚀 Key Value Propositions
* **Privacy-First Architecture:** We guarantee "No Phone Number Required" for initial price reveals. Contact details are shared only upon high-intent actions (e.g., booking a test drive).
* **AI-Verified Health Report:** Computer vision analyzes listing photos for panel gaps and structural anomalies.
* **Hyper-Local Tax Calculator:** Real-time on-road price breakdowns based on specific RTO fee structures and local fuel prices.
* **Regulatory Risk Score:** Alerts users to potential obsolescence (e.g., 10-year diesel bans in NCR).
* **Total Cost of Ownership (TCO) Engine:** Forecasts 5-year maintenance, fuel, and depreciation costs.

## 🛠 Tech Stack & Architecture

DriveMatrix utilizes a **Microservices-ready Modular Monolith** architecture to ensure agility for MVP iteration while remaining robust enough to scale.


### **Frontend (Client)**
* **Framework:** Next.js (v18+) with React.js (SSR for SEO optimization).
* **State Management:** Redux Toolkit.
* **Hosting:** Azure App Service.

### **Backend (API Gateway / BFF)**
* **Runtime:** Node.js with Express.js.
* **Role:** Authentication (JWT), rate limiting, request validation, and data aggregation.
* **Database:** MongoDB Atlas (Flexible schema for varied vehicle specs).
* **Caching:** Azure Cache for Redis.

### **AI Microservices Layer**
* **Language:** Python (FastAPI/Flask).
* **Hosting:** Azure Functions (Serverless Consumption Plan).
* **Services:**
    * **Valuation Engine:** Random Forest/XGBoost models for price prediction.
    * **Computer Vision:** OpenCV/PyTorch for damage detection.

### **Infrastructure**
* **Storage:** Azure Blob Storage (Hot Tier with Lifecycle Management).
* **CDN:** Azure Front Door / CDN for edge delivery of images.
* **DevOps:** Azure DevOps (Boards, Repos, Pipelines).

## 📂 Repository Structure (Polyrepo)

We follow a **Polyrepo** approach to decouple deployment pipelines:

* `drivematrix-frontend`: Next.js application.
* `drivematrix-backend-api`: Node.js/Express core services.
* `drivematrix-ai-service`: Python serverless functions.

## ⚡ Getting Started

### Prerequisites
* Node.js v18.x
* Python 3.10
* MongoDB Atlas Account
* Azure CLI

### 1. Clone Repositories
```bash
git clone [https://github.com/your-org/drivematrix-frontend.git](https://github.com/your-org/drivematrix-frontend.git)
git clone [https://github.com/your-org/drivematrix-backend-api.git](https://github.com/your-org/drivematrix-backend-api.git)
git clone [https://github.com/your-org/drivematrix-ai-service.git](https://github.com/your-org/drivematrix-ai-service.git)
2. Backend Setup (Node.js)
Bash

cd drivematrix-backend-api
npm install
# Create .env file with MONGODB_URI and JWT_SECRET
npm run dev
3. AI Service Setup (Python)
Bash

cd drivematrix-ai-service
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
func start # Run Azure Functions locally
4. Frontend Setup (Next.js)
Bash

cd drivematrix-frontend
npm install
npm run dev
🔐 Environment Variables
Create a .env file in the respective root directories.

Backend (.env):

Code snippet

PORT=5000
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/drivematrix
JWT_SECRET=your_jwt_secret
VAHAN_API_KEY=your_vendor_key
AZURE_STORAGE_CONNECTION_STRING=your_azure_connection_string
AI Service (local.settings.json):

JSON

{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python"
  }
}
🧪 Testing
Backend: npm test (Jest)

Frontend: npm run test (Jest/React Testing Library)

AI Service: pytest

🤝 Contributing
Checkout develop branch.

Create a feature branch: git checkout -b feature/amazing-feature.

Commit changes.

Push to the branch.

Open a Pull Request to develop.

📜 License
Proprietary software. All rights reserved.