# Architecture Overview

## High-Level Architecture

AutoPredator FleetCommand follows a modern, scalable architecture designed for multi-tenant SaaS applications.

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Next.js Web   │    │   FastAPI API   │    │   RQ Worker     │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Background)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   (Database)    │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │     Redis       │
                    │  (Cache/Queue)  │
                    └─────────────────┘
```

## Components

### Frontend (apps/web)
- **Framework**: Next.js with TypeScript
- **Styling**: Tailwind CSS
- **State Management**: React Query + Context
- **Routing**: Next.js App Router
- **Authentication**: JWT tokens stored securely

### Backend (apps/api)
- **Framework**: FastAPI with Python
- **Database**: SQLAlchemy ORM with PostgreSQL
- **Authentication**: JWT with bcrypt hashing
- **Validation**: Pydantic models
- **Documentation**: Auto-generated OpenAPI/Swagger

### Worker (apps/worker)
- **Framework**: RQ (Redis Queue) with Python
- **Jobs**: Email notifications, expiry checks, report generation
- **Scheduling**: APScheduler for recurring tasks

### Database
- **Primary**: PostgreSQL with PostGIS (future GPS support)
- **Schema**: Multi-tenant with separate schemas per organization
- **Migrations**: Alembic

### Infrastructure
- **Containerization**: Docker + Docker Compose
- **Reverse Proxy**: Nginx
- **SSL**: Let's Encrypt
- **Monitoring**: Health checks, structured logging

## Data Flow

### User Request Flow
1. User logs in via web app
2. JWT token issued and stored
3. API requests include tenant context
4. Backend validates tenant access
5. Database queries filtered by tenant
6. Response returned with tenant-scoped data

### Background Job Flow
1. Scheduled job triggers (e.g., daily expiry check)
2. Worker queries database for expiring documents
3. Notifications queued in Redis
4. Email service sends notifications
5. Audit logs created for all actions

## Multi-Tenant Enforcement

### Database-Level Isolation
- Each organization has separate PostgreSQL schema
- Schema names: `org_{org_id}`
- Cross-schema queries prohibited
- Row-level security policies enforced

### Application-Level Guards
- All API endpoints require tenant context
- Middleware validates user belongs to tenant
- Database sessions scoped to tenant schema
- File storage organized by tenant

### Security Measures
- Tenant ID in JWT payload
- API keys scoped to tenant
- Audit logs include tenant context
- Data export restricted to tenant data

### Query Enforcement
```python
# Example: All queries filtered by tenant
def get_vehicles(db: Session, tenant_id: int):
    return db.query(Vehicle).filter(Vehicle.tenant_id == tenant_id).all()
```

### Data Partitioning Rules
- Organizations cannot access other orgs' data
- Users can only see data from their organization
- Admin users have elevated permissions within their org
- System admins can manage multiple orgs

This architecture ensures strict data privacy while maintaining performance and scalability for growing fleets.
