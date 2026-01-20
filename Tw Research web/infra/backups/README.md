# Backup Strategy for AutoPredator FleetCommand

## Overview

This document outlines the backup and disaster recovery strategy for AutoPredator FleetCommand deployments.

## Recovery Objectives

- **RTO (Recovery Time Objective)**: 4 hours
  - Time to restore service after incident
- **RPO (Recovery Point Objective)**: 1 hour
  - Maximum acceptable data loss (latest backup)

## Backup Components

### Database Backups
- **Tool**: PostgreSQL `pg_dump` with gzip compression
- **Frequency**: Daily automated backups
- **Retention**:
  - Daily: 7 days
  - Weekly: 4 weeks (Sundays)
  - Monthly: 12 months (1st of month)
- **Location**: `/opt/fleetcommand/backups/`
- **Compression**: gzip (.sql.gz files)

### Configuration Backups
- **What**: `.env` files, docker-compose configs
- **Frequency**: Before each deployment
- **Location**: Git repository + local backups

### Offsite Storage (Optional)
- **Tool**: AWS S3 or compatible storage
- **Frequency**: After successful local backup
- **Retention**: Same as local retention

## Backup Process

### Automated Daily Backup
```bash
# Run via cron daily at 2 AM
0 2 * * * /opt/fleetcommand/configs/infra/scripts/backup_postgres.sh production
```

### Manual Backup
```bash
cd /opt/fleetcommand/configs
./infra/scripts/backup_postgres.sh production
```

## Restore Process

### Database Restore
```bash
# Stop services
cd /opt/fleetcommand/configs/infra/compose
docker-compose -f docker-compose.base.yml -f docker-compose.production.yml down

# Restore database
./infra/scripts/restore_postgres.sh production /path/to/backup.sql.gz

# Start services
docker-compose -f docker-compose.base.yml -f docker-compose.production.yml up -d
```

### Full Environment Restore
1. Provision new VPS using `provision_vps.sh`
2. Copy latest backup files to `/opt/fleetcommand/backups/`
3. Restore database using `restore_postgres.sh`
4. Deploy latest code using `deploy.sh`
5. Update DNS if necessary

## Disaster Recovery Drill

Perform this quarterly to ensure restore procedures work:

### Drill Steps
1. **Preparation** (Week 1):
   - Document current state
   - Test backup integrity: `gunzip -c backup.sql.gz | head -20`

2. **Execution** (Week 2):
   - Provision test environment
   - Run full restore procedure
   - Verify data integrity
   - Test application functionality

3. **Validation** (Week 3):
   - Compare restored data with production
   - Run integration tests
   - Document any issues found

4. **Debrief** (Week 4):
   - Update procedures based on findings
   - Schedule next drill

### Success Criteria
- ✅ Restore completes within 4 hours
- ✅ No data loss beyond RPO
- ✅ All services start successfully
- ✅ Application functions normally
- ✅ Health checks pass

## Monitoring & Alerts

### Backup Monitoring
- Check backup logs: `tail -f /opt/fleetcommand/logs/backup.log`
- Alert if backup fails for 2+ consecutive days
- Monitor backup file sizes for anomalies

### Storage Monitoring
- Alert when disk usage > 80%
- Monitor backup directory size trends
- Ensure sufficient space for 30 days of backups

## Security Considerations

- Backups encrypted at rest (if using S3)
- Access restricted to deploy user
- Backup files not committed to git
- Offsite storage uses separate credentials

## Troubleshooting

### Common Issues
- **Backup fails**: Check database connectivity, disk space
- **Restore fails**: Verify backup file integrity, check permissions
- **Services won't start**: Check environment variables, network connectivity

### Emergency Contacts
- DevOps Team: [contact info]
- Database Admin: [contact info]
- Infrastructure Provider: [contact info]
