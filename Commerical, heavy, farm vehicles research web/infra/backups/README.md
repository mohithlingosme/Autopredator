# Backup Strategy for AutoPredator FleetCommand

## Overview

This directory contains backup and disaster recovery procedures for the AutoPredator FleetCommand infrastructure.

## Backup Strategy

### Database Backups

- **Frequency**: Daily full backups at 2 AM UTC
- **Retention**:
  - Daily: 7 days
  - Weekly: 4 weeks (Sundays)
  - Monthly: 12 months (1st of month)
- **Storage**: Local server + offsite (S3/GCS recommended)
- **Compression**: gzip
- **Encryption**: File system level (server responsibility)

### Recovery Objectives

- **RTO (Recovery Time Objective)**: 4 hours
- **RPO (Recovery Point Objective)**: 24 hours (daily backups)

## Automated Backup Process

### Daily Backups

Run via cron job on the server:

```bash
# Add to crontab (crontab -e)
0 2 * * * cd /opt/fleetcommand/configs && ./infra/scripts/backup_postgres.sh production
```

### Manual Backups

```bash
# Staging
./infra/scripts/backup_postgres.sh staging

# Production
./infra/scripts/backup_postgres.sh production
```

## Restore Procedures

### Database Restore

1. **Stop services** (to prevent data corruption):
   ```bash
   docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.production.yml stop api worker web
   ```

2. **Restore from backup**:
   ```bash
   ./infra/scripts/restore_postgres.sh production /opt/fleetcommand/backups/fleetcommand_production_20231201_020000.sql.gz
   ```

3. **Start services**:
   ```bash
   docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.production.yml start api worker web
   ```

4. **Run health checks**:
   ```bash
   ./infra/scripts/healthcheck.sh production
   ```

### Full Infrastructure Restore

1. **Provision new server** using `infra/scripts/provision_vps.sh`
2. **Copy configs** and restore `.env` file
3. **Restore database** using procedure above
4. **Deploy latest version** using `infra/scripts/deploy.sh`

## Offsite Backup (Recommended)

### AWS S3 Setup

1. **Install AWS CLI**:
   ```bash
   apt install awscli
   aws configure  # Use IAM user with S3 permissions
   ```

2. **Modify backup script** to upload to S3:
   ```bash
   # Add to infra/scripts/backup_postgres.sh
   aws s3 cp "$BACKUP_FILE" "s3://your-backup-bucket/fleetcommand/$ENV/"
   ```

3. **Restore from S3**:
   ```bash
   aws s3 cp "s3://your-backup-bucket/fleetcommand/production/fleetcommand_production_20231201_020000.sql.gz" .
   ./infra/scripts/restore_postgres.sh production fleetcommand_production_20231201_020000.sql.gz
   ```

### Google Cloud Storage

Similar setup using `gsutil` instead of `awscli`.

## Backup Verification

### Automated Verification

- Check backup file exists and is not empty
- Verify backup can be decompressed
- Test restore to staging environment monthly

### Manual Verification

```bash
# Check backup integrity
gunzip -c backup.sql.gz | head -n 10

# Test restore to staging
./infra/scripts/restore_postgres.sh staging backup.sql.gz
```

## Monitoring & Alerts

### Backup Monitoring

- Check cron job logs: `grep CRON /var/log/syslog`
- Monitor backup directory size
- Alert if backup fails (integrate with monitoring system)

### Storage Monitoring

- Monitor backup directory disk usage
- Alert when >80% full
- Clean up old backups automatically

## Security Considerations

- Backups contain sensitive data
- Encrypt backups at rest and in transit
- Restrict access to backup files (chmod 600)
- Use separate credentials for backup storage
- Regularly rotate backup encryption keys

## Testing Disaster Recovery

### Quarterly DR Drills

1. Restore backup to isolated environment
2. Verify data integrity
3. Test application functionality
4. Document any issues found
5. Update procedures based on findings

### Contact Information

- **Primary Contact**: DevOps Team
- **Emergency Contact**: On-call Engineer
- **Documentation**: This README and infra/README.md

## Backup Inventory

Keep track of backup locations and credentials in a secure location (not in this repo):

- [ ] Server backup directory: `/opt/fleetcommand/backups/`
- [ ] Offsite storage: `s3://your-backup-bucket/fleetcommand/`
- [ ] Encryption keys location
- [ ] Access credentials for backup storage
