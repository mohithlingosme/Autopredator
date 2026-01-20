# Autopredator — India-Only Vehicle Research Platform

> A fast, SEO-first research website where Indian buyers can **discover → filter → compare → calculate TCO/EMI → shortlist → request quotes** for **Commercial Vehicles (LCV/ICV/MHCV/Buses)**, **Farm Vehicles (tractors + implements)**, and **Construction Equipment (earthmovers, loaders, cranes, etc.)**.

Autopredator is India's premier decision platform for vehicles used in work and earnings, not just lifestyle. We help users answer critical questions like: Which vehicle fits my load/route/terrain/daily km/usage hours? What's the real cost (fuel + maintenance + tyres + insurance + depreciation)? What's the best variant/config and value option? Where can I get quotes/dealers/finance quickly?

## MVP Scope

The MVP focuses on the core research journey:
- **Search & Discovery**: Category browsing (CV/Farm/Construction) with powerful filters (price, fuel, GVW, HP, etc.)
- **Model & Variant Pages**: Detailed specs, features, pricing, and comparisons
- **Compare Tool**: Side-by-side comparisons with "best value" highlights
- **Calculators**: EMI, TCO, fuel cost, and operating cost tools
- **Shortlist & Quotes**: Save vehicles and request dealer quotes
- **Content Hub**: Guides, reviews, and issue reports for informed decisions

Out-of-scope for MVP: User accounts, dealer directory, crowdsourced reviews, advanced AI recommendations.

## Tech Stack

- **Web App**: Next.js (React) with TypeScript for SEO-optimized pages
- **API**: FastAPI (Python) for backend services and data APIs
- **Database**: PostgreSQL for catalog, pricing, and user data
- **Search**: PostgreSQL full-text search (upgrade to Elasticsearch later)
- **Cache**: Redis for hot pages and compare results
- **Storage**: S3-compatible for media, docs, and backups
- **Deployment**: Docker + Docker Compose for local; Kubernetes for prod
- **CI/CD**: GitHub Actions for build/test/deploy

## Local Setup

### Prerequisites
- Docker + Docker Compose
- Node.js 20+ (for web development)
- Python 3.11+ (for API development)
- Git

### Steps
1. **Clone the repo**:
   ```bash
   git clone https://github.com/your-org/autopredator.git
   cd autopredator
   ```

2. **Set up environment**:
   ```bash
   cp .env.example .env  # Edit with your local settings
   ```

3. **Run with Docker**:
   ```bash
   docker-compose up -d
   ```

4. **Access the app**:
   - Web: http://localhost:3000
   - API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

### Development Commands
- `make dev-up` - Start all services in dev mode
- `make dev-down` - Stop all services
- `make test` - Run all tests
- `make seed` - Seed database with sample data
- `make reindex` - Reindex search data

## Contributing

### Branch Naming
- `feature/`: New features (e.g., `feature/add-emi-calculator`)
- `bugfix/`: Bug fixes (e.g., `bugfix/fix-filter-reset`)
- `hotfix/`: Urgent production fixes
- `docs/`: Documentation updates

### PR Rules
- PRs must be reviewed by at least one maintainer
- All tests must pass
- Include screenshots for UI changes
- Update docs if needed
- Squash commits on merge

## Folder Structure

```
autopredator/
├── apps/
│   ├── web/          # Next.js frontend app
│   └── api/          # FastAPI backend app
├── infra/            # Docker, deployment, and infra configs
├── data/             # Seeds, imports, and data validators
├── docs/             # Documentation and guides
├── .github/          # GitHub templates and workflows
└── README.md
```

- `apps/web/`: Contains the Next.js application for the user-facing website
- `apps/api/`: Contains the FastAPI application for APIs and data processing
- `infra/`: Infrastructure as code, Dockerfiles, and deployment scripts
- `data/`: Database seeds, data import scripts, and validation rules
- `docs/`: All documentation, including this README, coding standards, and roadmaps
