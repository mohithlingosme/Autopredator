# Tenancy and Data Privacy Guidelines

## Tenant Isolation Rules

### Data Scoping
- **Every record** must include an `org_id` (tenant_id) field unless the data is truly global (e.g., system configuration)
- **API queries** must always include org_id filtering - no cross-org data access allowed
- **Database constraints** should enforce org_id presence on all tenant-scoped tables

### Security Principles
- **Strict server-side RBAC** - frontend hiding is not sufficient security
- **Audit logging** for all sensitive operations (user access, data exports, configuration changes)
- **No shared data** between organizations under any circumstances

### Data Export Permissions
- Users can only export data from their own organization
- Export requests must be logged with user and org context
- Sensitive data (financial, personal) requires additional approval for export

## Data Privacy Guarantees

### User Data Protection
- Personal information (driver details, contact info) is strictly isolated per organization
- No data sharing between tenants without explicit consent
- Data retention policies applied per organization

### Compliance Requirements
- GDPR/CCPA equivalent protections for Indian regulations
- Right to data portability within organization scope
- Data deletion requests honored per organization

## Threat Model Basics

### Potential Threats
- Cross-tenant data leakage through API vulnerabilities
- Unauthorized access via compromised user accounts
- Data exfiltration through export features

### Mitigation Strategies
- Multi-layer authentication and authorization
- Input validation and sanitization
- Regular security audits and penetration testing
- Encrypted data storage and transmission

## Future Enhancements
- **Postgres Row Level Security (RLS)** can be implemented for additional database-level isolation
- **Data masking** for sensitive fields in logs and exports
- **Zero-trust architecture** with micro-segmentation
