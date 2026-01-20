# Observability for AutoPredator FleetCommand

## Overview

This directory contains observability configurations for monitoring, logging, and metrics collection.

## Current Setup

### Health Checks

- API provides `GET /health` (liveness) and `GET /ready` (readiness with DB check)
- Docker health checks configured for all services
- Run `infra/scripts/healthcheck.sh <env>` for comprehensive checks

### Logging

- Structured JSON logging enabled in API and worker
- Caddy logs requests to `/var/log/caddy/`
- Docker logs available via `docker-compose logs`

### Metrics (Future)

- Prometheus configuration scaffold provided
- Grafana dashboard scaffold provided
- Enable when monitoring needs grow

## Logging

### Viewing Logs

```bash
# All services
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.staging.yml logs -f

# Specific service
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.staging.yml logs -f api

# Caddy access logs
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.staging.yml exec caddy tail -f /var/log/caddy/app.log
```

### Log Rotation

Configure log rotation in `/etc/logrotate.d/fleetcommand`:

```
/var/log/caddy/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 caddy caddy
}
```

## Metrics with Prometheus (Optional)

### Setup Prometheus

1. Add Prometheus service to docker-compose:

```yaml
prometheus:
  image: prom/prometheus:latest
  ports:
    - "9090:9090"
  volumes:
    - ./infra/observability/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    - prometheus_data:/prometheus
  networks:
    - internal
```

2. Configure scrape targets in `prometheus.yml`

3. Access Prometheus at `http://your-server:9090`

### Application Metrics

Add metrics endpoints to services:

- API: `/metrics` (Prometheus format)
- Custom business metrics (response times, error rates, etc.)

## Grafana Dashboards (Optional)

### Setup Grafana

1. Add Grafana service to docker-compose:

```yaml
grafana:
  image: grafana/grafana:latest
  ports:
    - "3001:3000"
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=change-this
  volumes:
    - grafana_data:/var/lib/grafana
  networks:
    - internal
```

2. Import dashboard JSON from `infra/observability/grafana/`

3. Access Grafana at `http://your-server:3001`

### Sample Dashboards

- System metrics (CPU, memory, disk)
- Application metrics (requests, errors, latency)
- Database metrics (connections, query performance)
- Docker container metrics

## Alerting (Future)

### Prometheus Alertmanager

Configure alerts for:
- Service down
- High error rates
- Low disk space
- Database connection issues

### Notification Channels

- Email
- Slack
- PagerDuty

## Monitoring Checklist

- [ ] Health checks pass
- [ ] Logs are being written
- [ ] Disk space > 20% free
- [ ] Database connections healthy
- [ ] SSL certificates valid
- [ ] Backup jobs successful

## Troubleshooting

### Common Issues

1. **Logs not appearing**: Check log file permissions
2. **Metrics not collecting**: Verify scrape targets are accessible
3. **High memory usage**: Check for memory leaks in application
4. **Slow queries**: Enable query logging in PostgreSQL

### Debug Commands

```bash
# Check service status
docker-compose ps

# Check resource usage
docker stats

# Inspect container logs
docker-compose logs --tail=100 api

# Check network connectivity
docker-compose exec api curl -f http://postgres:5432
