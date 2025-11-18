```text
Vehicle (id PK, owner FK, make, model, year, vin, fuel_type, mileage, vehicle_type, registration_doc, created_at)
 └─ has many MaintenanceLog (id PK, vehicle FK, description, cost, date, next_due_date, created_at)
Fleet (id PK, name, manager FK)
 └─ m2m Fleet.vehicles → Vehicle
Product (id PK, name, category, description, price, seller FK, image, created_at)
Notification (id PK, user FK, message, read, created_at)
PaymentTransaction (id PK, user FK, amount, currency, status, stripe_session_id, created_at)
ApiUsageLog (id PK, user FK nullable, path, method, status_code, ip_address, created_at)
FeatureUsageLog (id PK, user FK nullable, feature_name, metadata JSON, created_at)
VehicleCountSnapshot (id PK, user FK, count, recorded_at)
User (django auth user) ← referenced by Vehicle, Fleet.manager, Product.seller, Notification.user, PaymentTransaction.user, ApiUsageLog.user, FeatureUsageLog.user, VehicleCountSnapshot.user
```
