# Locked Decisions for AutoPredator FleetCommand

## Product Identity
- **Product Name:** AutoPredator FleetCommand
- **Tagline:** “Track. Schedule. Control. Profit.”
- **Short Description:** “One command center for vehicles, drivers, fuel, trips, and maintenance. Operations, compliance, and cost—under one dashboard.”

## Target Users & Roles
- **Enabled Roles:** Admin, Manager, Operator, Driver, Accountant, Viewer
- **Role Meanings:**
  - Admin: Full system access, user management, configuration
  - Manager: Operational oversight, approvals, reporting
  - Operator: Daily operations, trip logging, maintenance scheduling
  - Driver: Personal trip logs, document uploads, basic reporting
  - Accountant: Financial data access, cost analysis, invoice management
  - Viewer: Read-only access to reports and dashboards

## Hosting Strategy
- **Approach:** Full production-grade deployment from start using VPS + Docker
- **Implications:** Staging and production environments ready from Day 1, with automated deployments, monitoring, and scaling considerations built-in from the beginning.

## Notifications Plan
- **MVP:** Email + In-app alerts
- **Phase 2:** SMS + WhatsApp integration
- **Scope:** Essential alerts for compliance reminders, maintenance due dates, and critical operational events.

## Data Scope
- **MVP:** Support manual workflows for trip logging, fuel tracking, and maintenance records
- **Architecture Note:** Design must be extensible for GPS/Telematics integration later, with data models that can accommodate real-time sensor data and automated imports.

## Tenancy Model
- **Model:** Multi-company (multi-org) with VERY strict data privacy
- **Principles:** Complete data isolation between organizations, no cross-tenant data sharing, audit trails for all access.

## India Scope
- **Currency:** INR only
- **GST:** Enabled and integrated into financial calculations
- **Compliance Reminders:** Enabled for vehicle permits, insurance, PUC, and other regulatory requirements

## Non-Goals for Now
- No telematics integration in MVP (manual data entry only)
- No SMS/WhatsApp notifications in MVP
- No advanced analytics or AI features in initial release
