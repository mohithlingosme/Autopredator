# Notifications System

This document outlines the notification system for AutoPredator FleetCommand, focusing on email notifications in the MVP.

## Notification Types

### Expiry Alerts
Automated alerts for document expirations.

#### Insurance Expiry
- **Trigger**: 30, 15, 7, 1 days before expiry
- **Recipients**: Fleet managers, vehicle operators
- **Priority**: High
- **Template**: `insurance_expiry_alert.html`

#### Permit Expiry
- **Trigger**: 30, 15, 7, 1 days before expiry
- **Recipients**: Fleet managers, compliance officers
- **Priority**: High
- **Template**: `permit_expiry_alert.html`

#### Fitness Certificate Expiry
- **Trigger**: 30, 15, 7, 1 days before expiry
- **Recipients**: Fleet managers, vehicle operators
- **Priority**: High
- **Template**: `fitness_expiry_alert.html`

#### PUC Expiry
- **Trigger**: 30, 15, 7, 1 days before expiry
- **Recipients**: Fleet managers, vehicle operators
- **Priority**: Medium
- **Template**: `puc_expiry_alert.html`

#### Driver License Expiry
- **Trigger**: 30, 15, 7, 1 days before expiry
- **Recipients**: Fleet managers, HR
- **Priority**: High
- **Template**: `license_expiry_alert.html`

### Maintenance Reminders
Scheduled maintenance notifications.

#### Service Due (Odometer)
- **Trigger**: 1000 km before due service
- **Recipients**: Fleet managers, mechanics
- **Priority**: Medium
- **Template**: `maintenance_due_alert.html`

#### Service Due (Date)
- **Trigger**: 30, 15, 7 days before due service
- **Recipients**: Fleet managers, mechanics
- **Priority**: Medium
- **Template**: `maintenance_due_alert.html`

### System Notifications
Administrative and system alerts.

#### User Account Created
- **Trigger**: New user registration
- **Recipients**: New user, admin
- **Priority**: Low
- **Template**: `user_welcome.html`

#### Password Reset
- **Trigger**: Password reset request
- **Recipients**: User
- **Priority**: High
- **Template**: `password_reset.html`

#### Failed Login Attempts
- **Trigger**: 5+ failed logins in 15 minutes
- **Recipients**: User, admin
- **Priority**: High
- **Template**: `security_alert.html`

## Email Templates

### Base Template Structure
All emails use a consistent HTML template with:
- Company branding (AutoPredator FleetCommand)
- Responsive design
- Clear call-to-action buttons
- Footer with contact information
- Unsubscribe link (for marketing emails)

### Template Variables
Common variables available in all templates:
- `{{user_name}}` - Recipient's full name
- `{{organization_name}}` - Company name
- `{{current_date}}` - Current date/time
- `{{login_url}}` - Application login URL
- `{{support_email}}` - Support contact

### Sample Templates

#### Insurance Expiry Alert
```html
<h2>Vehicle Insurance Expiry Alert</h2>
<p>Dear {{user_name}},</p>
<p>The insurance for vehicle <strong>{{vehicle_registration}}</strong> is expiring on <strong>{{expiry_date}}</strong>.</p>
<p>Please ensure renewal is completed before the expiry date to avoid penalties.</p>
<a href="{{vehicle_details_url}}" class="btn-primary">View Vehicle Details</a>
```

#### Maintenance Due Alert
```html
<h2>Vehicle Maintenance Due</h2>
<p>Dear {{user_name}},</p>
<p>Vehicle <strong>{{vehicle_registration}}</strong> is due for maintenance.</p>
<ul>
  <li>Current odometer: {{current_odometer}} km</li>
  <li>Next service due: {{next_service_due}} km</li>
  <li>Recommended service date: {{recommended_date}}</li>
</ul>
<a href="{{schedule_maintenance_url}}" class="btn-primary">Schedule Maintenance</a>
```

## Notification Channels

### MVP: Email Only
- **Provider**: SMTP (Gmail, SendGrid, or custom SMTP)
- **Delivery**: Immediate for critical alerts, batched for routine
- **Tracking**: Delivery status, open rates (if provider supports)

### Phase 2: SMS/WhatsApp
- **SMS**: Twilio or Indian SMS gateway
- **WhatsApp**: WhatsApp Business API
- **Use Cases**: Critical alerts, driver notifications

## Delivery Rules

### Frequency Limits
- **Per User**: Maximum 10 emails per day
- **Per Organization**: Maximum 100 emails per day
- **Burst Control**: Anti-spam measures

### Scheduling
- **Critical Alerts**: Immediate delivery
- **Routine Alerts**: Business hours (9 AM - 6 PM IST)
- **Batch Notifications**: Daily digest option

### Preferences
- **User Settings**: Email frequency preferences
- **Organization Settings**: Default notification rules
- **Opt-out**: Ability to unsubscribe from non-critical alerts

## Queue System

### Background Processing
- **Queue**: Redis-based job queue (RQ)
- **Workers**: Dedicated worker processes for email sending
- **Retry Logic**: 3 retry attempts with exponential backoff
- **Dead Letter Queue**: Failed emails moved to DLQ for manual review

### Monitoring
- **Queue Health**: Queue length, processing rate
- **Delivery Stats**: Success rate, bounce rate, complaint rate
- **Performance**: Average send time, throughput

## Integration Points

### Database Triggers
- **Expiry Checks**: Daily job scans for upcoming expiries
- **Event Hooks**: Database triggers for immediate alerts
- **Audit Trail**: All notifications logged in audit_logs table

### API Endpoints
- **Manual Send**: Admin ability to send custom notifications
- **Bulk Send**: Send to multiple users/organizations
- **Template Management**: CRUD operations for email templates

### User Interface
- **Notification Center**: In-app notification display
- **Email History**: View sent emails and delivery status
- **Settings**: User notification preferences

## Compliance Considerations

### Indian Regulations
- **Data Protection**: User consent for email communications
- **Spam Laws**: Compliance with TRAI regulations
- **Content**: Clear identification as transactional emails

### Privacy
- **Data Minimization**: Only necessary user data in emails
- **Encryption**: Email content encrypted in transit
- **Retention**: Email logs retained for 3 years

### Accessibility
- **Alt Text**: Images include descriptive alt text
- **Plain Text**: Plain text version available
- **High Contrast**: Sufficient color contrast ratios

This notification system provides timely, relevant communications while respecting user preferences and regulatory requirements.
