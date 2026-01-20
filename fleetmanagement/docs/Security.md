# Security & Privacy

This document outlines the security measures and privacy controls implemented in AutoPredator FleetCommand.

## Tenant Isolation

### Database-Level Isolation
- **Schema Separation**: Each organization has dedicated PostgreSQL schema (`org_{org_id}`)
- **Query Scoping**: All queries automatically filtered by tenant context
- **Cross-Tenant Prevention**: Database roles prevent schema access across tenants
- **Backup Isolation**: Tenant-specific backup and restore operations

### Application-Level Controls
- **Tenant Context**: JWT tokens include tenant_id, validated on every request
- **Middleware Enforcement**: Automatic tenant injection in all API calls
- **File Storage**: Documents stored in tenant-specific directories
- **Cache Isolation**: Redis keys prefixed with tenant_id

### Network Isolation
- **VPC**: All services within private network
- **Firewall Rules**: Strict ingress/egress policies
- **API Gateway**: Rate limiting and request validation

## Authentication & Authorization

### Authentication
- **JWT Tokens**: Access tokens (15min) + refresh tokens (7 days)
- **Password Hashing**: bcrypt with salt rounds >= 12
- **Multi-Factor**: Optional TOTP for admin accounts
- **Session Management**: Secure cookie storage, automatic logout on suspicious activity

### Authorization (RBAC)
- **Role-Based Access**: 6 predefined roles with granular permissions
- **Permission Matrix**: Enforced server-side on all endpoints
- **Context-Aware**: Permissions checked per tenant and resource
- **Admin Override**: System admins can manage multiple tenants

### API Security
- **Input Validation**: Pydantic models with strict type checking
- **Rate Limiting**: 100 requests/minute per user, 1000/hour per tenant
- **CORS Policy**: Restricted to allowed domains
- **HTTPS Only**: All traffic encrypted in transit

## Audit Logs

### Audit Trail
- **Comprehensive Logging**: All CRUD operations logged
- **Immutable Records**: Audit logs cannot be modified
- **Tenant Context**: Every log entry includes tenant_id
- **User Tracking**: Who, when, what, where for all changes

### Audit Schema
```sql
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    user_id INTEGER,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50),
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Compliance Features
- **Retention**: 7 years for financial data, 3 years for operational
- **Export**: Audit reports for compliance audits
- **Search**: Full-text search across audit logs
- **Alerts**: Suspicious activity detection

## Secrets Management

### Environment Variables
- **No Hardcoded Secrets**: All secrets loaded from environment
- **Validation**: Required secrets validated on startup
- **Encryption**: Sensitive env vars encrypted at rest

### Key Management
- **JWT Secrets**: Rotated quarterly, stored in secure vault
- **Database Credentials**: Managed through connection strings
- **API Keys**: Scoped to specific services and tenants

### Secure Storage
- **Vault Integration**: HashiCorp Vault for production secrets
- **Local Development**: .env files with gitignore
- **CI/CD**: Secrets injected via GitHub Secrets

## Encryption

### Data at Rest
- **Database**: PostgreSQL encryption with pgcrypto
- **Files**: AES-256 encryption for uploaded documents
- **Backups**: Encrypted before storage

### Data in Transit
- **TLS 1.3**: All external communications
- **Internal**: mTLS between services
- **API**: JWT tokens encrypted

### Key Rotation
- **Automatic**: Database encryption keys rotated monthly
- **Manual**: Emergency rotation procedures documented
- **Backup**: Old keys retained for decryption during transition

## Backups & Recovery

### Backup Strategy
- **Database**: Daily full backups + hourly WAL archives
- **Files**: Incremental backups of document storage
- **Configuration**: Infrastructure as code backed up
- **Encryption**: All backups encrypted

### Recovery Procedures
- **RTO**: 4 hours for critical data, 24 hours for full recovery
- **RPO**: 1 hour data loss tolerance
- **Testing**: Monthly backup restoration tests
- **Multi-Region**: Backups stored in secondary location

### Disaster Recovery
- **Failover**: Automated failover to backup region
- **Data Integrity**: Checksums and validation on restore
- **Communication**: Incident response plan documented

## Threat Model

### Attack Vectors Considered
- **Tenant Data Leakage**: Schema isolation prevents cross-tenant access
- **Unauthorized Access**: RBAC + JWT validation
- **Data Tampering**: Audit logs + immutable records
- **DDoS**: Rate limiting + CDN protection
- **Injection Attacks**: Input validation + parameterized queries
- **Insider Threats**: Least privilege + audit monitoring

### Security Controls
- **Defense in Depth**: Multiple layers of protection
- **Zero Trust**: Every request validated
- **Fail Safe**: Deny by default policies
- **Monitoring**: Real-time threat detection

### Compliance Frameworks
- **ISO 27001**: Information security management
- **SOC 2**: Trust services criteria
- **PDP Bill 2023**: Indian data protection regulations
- **GDPR Alignment**: Privacy by design principles

### Regular Assessments
- **Penetration Testing**: Quarterly external audits
- **Code Reviews**: Security-focused PR reviews
- **Dependency Scanning**: Automated vulnerability checks
- **Incident Response**: 24/7 monitoring and response

This security model ensures enterprise-grade protection while maintaining usability for fleet management operations.
