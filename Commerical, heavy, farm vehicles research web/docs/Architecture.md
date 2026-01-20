# Architecture - AutoPredator FleetCommand

## System Overview

FleetCommand is a multi-tenant fleet management platform designed for commercial vehicle operations. The system ensures strict data isolation between organizations while providing scalable, secure, and performant fleet management capabilities.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   Web Browser   │  │   Mobile App    │  │   API       │  │
│  │   (Next.js)     │  │   (Future)      │  │   Clients   │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Load Balancer │
                    │   (Nginx/ALB)   │
                    └─────────────────┘
                                 │
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │     Web App     │  │      API        │  │     Worker      │  │
│  │   (Next.js)     │  │   (FastAPI)     │  │   (Python)      │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Message Bus   │
                    │     (Redis)     │
                    └─────────────────┘
                                 │
┌─────────────────────────────────────────────────────────────────┐
│                    Data Layer                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   PostgreSQL    │  │     Redis       │  │   File Storage  │  │
│  │   (Primary DB)  │  │   (Cache)       │  │   (S3/MinIO)    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Service Components

### Web Application (Next.js)

- **Purpose**: User interface for fleet management operations
- **Technology**: Next.js 14 with TypeScript, React
- **Responsibilities**:
  - Authentication flows (login/logout)
  - Dashboard and fleet views
  - Form handling for fleet operations
  - Real-time updates via WebSocket/SSE
- **Deployment**: Static site served by CDN/API Gateway

### API Service (FastAPI)

- **Purpose**: RESTful API for business logic and data access
- **Technology**: FastAPI with Pydantic, SQLAlchemy
- **Responsibilities**:
  - Authentication and authorization
  - CRUD operations for fleet entities
  - Business logic validation
  - Integration with external services
- **Features**:
  - JWT-based authentication
  - Role-based access control (RBAC)
  - Multi-tenant data isolation
  - Request/response validation
  - Structured logging

### Worker Service (Python)

- **Purpose**: Background job processing
- **Technology**: Python with Celery/RQ, Redis
- **Responsibilities**:
  - Long-running tasks (reports, imports)
  - Scheduled maintenance jobs
  - Email notifications
  - Data synchronization
- **Queue Management**: Redis-backed job queues with priority levels

## Data Architecture

### Database Schema

#### Core Tables

```sql
-- Organizations (multi-tenant root)
CREATE TABLE orgs (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Users with org membership
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- User-organization relationships with roles
CREATE TABLE user_org_memberships (
    user_id UUID REFERENCES users(id),
    org_id UUID REFERENCES orgs(id),
    role VARCHAR(50) NOT NULL, -- Admin, Manager, Operator, Driver, Accountant, Viewer
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, org_id)
);

-- Audit trail for compliance
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY,
    org_id UUID NOT NULL REFERENCES orgs(id),
    actor_user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    meta_json JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Key Design Principles

1. **Multi-Tenant Isolation**:
   - Every table includes `org_id` column
   - All queries filtered by organization context
   - Row-level security enforced at application level

2. **Soft Deletes**:
   - `deleted_at` timestamp for logical deletion
   - Maintains data integrity and audit trails

3. **Audit Logging**:
   - All data changes logged with actor and metadata
   - Compliance with regulatory requirements

### Caching Strategy

- **Redis** for:
  - Session storage
  - API response caching
  - Rate limiting counters
  - Job queue management

## Security Architecture

### Authentication

- **JWT Tokens**: Access + refresh token pattern
- **Password Security**: bcrypt/argon2 hashing
- **Session Management**: Secure cookie handling

### Authorization

- **RBAC**: Role-based permissions (Admin, Manager, Operator, Driver, Accountant, Viewer)
- **Org Context**: All operations scoped to user's organization
- **API Permissions**: Endpoint-level access control

### Security Controls

- **Input Validation**: Pydantic schemas for all inputs
- **Rate Limiting**: Redis-backed rate limiting on auth endpoints
- **CORS**: Configured origins for cross-origin requests
- **HTTPS**: TLS 1.3 for all communications
- **Security Headers**: CSP, HSTS, X-Frame-Options

## Deployment Architecture

### Local Development

```yaml
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: fleetcommand
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password

  redis:
    image: redis:7-alpine

  api:
    build: ./apps/api
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres/fleetcommand
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  web:
    build: ./apps/web
    environment:
      - API_URL=http://api:8000
    depends_on:
      - api
```

### Production Deployment

- **Container Orchestration**: Kubernetes/Docker Swarm
- **Load Balancing**: Application Load Balancer
- **Database**: Managed PostgreSQL (RDS/Aurora)
- **Cache**: Managed Redis (ElastiCache)
- **Storage**: S3-compatible object storage
- **CDN**: CloudFront/Cloudflare for static assets

## Monitoring & Observability

### Logging

- **Structured Logging**: JSON format with correlation IDs
- **Log Levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Centralized**: ELK stack or CloudWatch

### Metrics

- **Application Metrics**: Response times, error rates, throughput
- **System Metrics**: CPU, memory, disk usage
- **Business Metrics**: User activity, feature usage

### Alerting

- **Threshold Alerts**: Performance degradation, error spikes
- **Health Checks**: Service availability monitoring
- **Incident Response**: Automated escalation procedures

## Scalability Considerations

### Horizontal Scaling

- **API Services**: Stateless, can scale horizontally
- **Worker Services**: Queue-based, can add more workers
- **Database**: Read replicas for query scaling
- **Cache**: Redis cluster for high availability

### Performance Optimization

- **Database Indexing**: Optimized queries with proper indexes
- **Caching**: Multi-layer caching strategy
- **CDN**: Static asset delivery
- **Compression**: Response compression

## Disaster Recovery

### Backup Strategy

- **Database**: Daily backups with point-in-time recovery
- **Application Data**: Regular snapshots
- **Configuration**: Version-controlled infrastructure

### Recovery Procedures

- **RTO**: 4 hours for critical services
- **RPO**: 1 hour data loss tolerance
- **Failover**: Automated failover for critical components

This architecture provides a solid foundation for a scalable, secure, and maintainable fleet management platform.
