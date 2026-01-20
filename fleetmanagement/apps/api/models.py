from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Text, Boolean, DECIMAL, UUID, Enum, JSON, BigInteger, TIMESTAMP, func, CheckConstraint, UniqueConstraint, Index
from sqlalchemy.dialects.postgresql import UUID as PGUUID, TIMESTAMP as PG_TIMESTAMP
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.ext.declarative import declarative_base
import enum
from datetime import datetime

Base = declarative_base()

# Enums
class UserRoleEnum(enum.Enum):
    ADMIN = "admin"
    MANAGER = "manager"
    OPERATOR = "operator"
    DRIVER = "driver"
    ACCOUNTANT = "accountant"
    VIEWER = "viewer"

class VehicleType(enum.Enum):
    TRUCK = "truck"
    BUS = "bus"
    CAR = "car"
    MOTORCYCLE = "motorcycle"
    TRACTOR = "tractor"
    CONSTRUCTION_EQUIPMENT = "construction_equipment"
    OTHER = "other"

class FuelType(enum.Enum):
    DIESEL = "diesel"
    PETROL = "petrol"
    CNG = "cng"
    ELECTRIC = "electric"
    HYBRID = "hybrid"

class VehicleStatus(enum.Enum):
    ACTIVE = "active"
    MAINTENANCE = "maintenance"
    INACTIVE = "inactive"
    SOLD = "sold"

class DriverStatus(enum.Enum):
    ACTIVE = "active"
    SUSPENDED = "suspended"
    TERMINATED = "terminated"

class TripStatus(enum.Enum):
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    DELAYED = "delayed"

class MaintenanceType(enum.Enum):
    SCHEDULED_SERVICE = "scheduled_service"
    REPAIR = "repair"
    EMERGENCY_REPAIR = "emergency_repair"
    INSPECTION = "inspection"
    TYRE_CHANGE = "tyre_change"
    BATTERY_REPLACEMENT = "battery_replacement"

class MaintenanceStatus(enum.Enum):
    SCHEDULED = "scheduled"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class DocumentType(enum.Enum):
    INSURANCE = "insurance"
    PERMIT = "permit"
    PUC_CERTIFICATE = "puc_certificate"
    FITNESS_CERTIFICATE = "fitness_certificate"
    TAX_RECEIPT = "tax_receipt"
    DRIVER_LICENSE = "driver_license"
    VEHICLE_REGISTRATION = "vehicle_registration"
    MAINTENANCE_RECORD = "maintenance_record"

class AlertType(enum.Enum):
    COMPLIANCE_EXPIRY = "compliance_expiry"
    MAINTENANCE_DUE = "maintenance_due"
    FUEL_ANOMALY = "fuel_anomaly"
    TRIP_DEVIATION = "trip_deviation"
    DOCUMENT_MISSING = "document_missing"

class AlertSeverity(enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class LocationType(enum.Enum):
    DEPOT = "depot"
    BRANCH = "branch"
    WAREHOUSE = "warehouse"
    OTHER = "other"

class NotificationType(enum.Enum):
    EMAIL = "email"
    IN_APP = "in_app"

class ImportJobStatus(enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"

# Tenants (Organizations)
class Tenant(Base):
    __tablename__ = "tenants"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    name = Column(String(255), nullable=False)
    domain = Column(String(255), unique=True, nullable=False)
    address = Column(Text)
    phone = Column(String(20))
    email = Column(String(255))
    gst_number = Column(String(15))
    subscription_plan = Column(String(50), default="basic")
    is_active = Column(Boolean, default=True)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())

    # Relationships
    users = relationship("User", back_populates="tenant")
    vehicles = relationship("Vehicle", back_populates="tenant")
    drivers = relationship("Driver", back_populates="tenant")
    trips = relationship("Trip", back_populates="tenant")
    fuel_logs = relationship("FuelLog", back_populates="tenant")
    service_records = relationship("ServiceRecord", back_populates="tenant")
    documents = relationship("Document", back_populates="tenant")
    vendors = relationship("Vendor", back_populates="tenant")
    expenses = relationship("Expense", back_populates="tenant")
    files = relationship("File", back_populates="tenant")
    audit_logs = relationship("AuditLog", back_populates="tenant")
    notification_outbox = relationship("NotificationOutbox", back_populates="tenant")
    import_jobs = relationship("ImportJob", back_populates="tenant")

# Roles and Permissions
class Role(Base):
    __tablename__ = "roles"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())

    # Relationships
    user_roles = relationship("UserRole", back_populates="role")
    role_permissions = relationship("RolePermission", back_populates="role")

    __table_args__ = (
        UniqueConstraint('tenant_id', 'name', name='uq_tenant_role_name'),
        Index('ix_roles_tenant_id', 'tenant_id'),
    )

class Permission(Base):
    __tablename__ = "permissions"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text)
    resource = Column(String(100), nullable=False)
    action = Column(String(100), nullable=False)

    # Relationships
    role_permissions = relationship("RolePermission", back_populates="permission")

class UserRole(Base):
    __tablename__ = "user_roles"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    role_id = Column(PGUUID(as_uuid=True), ForeignKey("roles.id"), nullable=False)
    assigned_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())

    # Relationships
    user = relationship("User", back_populates="user_roles")
    role = relationship("Role", back_populates="user_roles")

    __table_args__ = (
        UniqueConstraint('user_id', 'role_id', name='uq_user_role'),
        Index('ix_user_roles_user_id', 'user_id'),
        Index('ix_user_roles_role_id', 'role_id'),
    )

class RolePermission(Base):
    __tablename__ = "role_permissions"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    role_id = Column(PGUUID(as_uuid=True), ForeignKey("roles.id"), nullable=False)
    permission_id = Column(PGUUID(as_uuid=True), ForeignKey("permissions.id"), nullable=False)

    # Relationships
    role = relationship("Role", back_populates="role_permissions")
    permission = relationship("Permission", back_populates="role_permissions")

    __table_args__ = (
        UniqueConstraint('role_id', 'permission_id', name='uq_role_permission'),
        Index('ix_role_permissions_role_id', 'role_id'),
        Index('ix_role_permissions_permission_id', 'permission_id'),
    )

# Users
class User(Base):
    __tablename__ = "users"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    email = Column(String(255), nullable=False)
    password_hash = Column(String(255), nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    role = Column(Enum(UserRoleEnum), nullable=False)
    is_active = Column(Boolean, default=True)
    last_login = Column(PG_TIMESTAMP(timezone=True))
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="users")
    user_roles = relationship("UserRole", back_populates="user")
    vehicles_created = relationship("Vehicle", foreign_keys="Vehicle.created_by", back_populates="creator")
    vehicles_updated = relationship("Vehicle", foreign_keys="Vehicle.updated_by", back_populates="updater")
    drivers_created = relationship("Driver", foreign_keys="Driver.created_by", back_populates="creator")
    drivers_updated = relationship("Driver", foreign_keys="Driver.updated_by", back_populates="updater")
    trips_created = relationship("Trip", foreign_keys="Trip.created_by", back_populates="creator")
    trips_updated = relationship("Trip", foreign_keys="Trip.updated_by", back_populates="updater")
    fuel_logs_created = relationship("FuelLog", foreign_keys="FuelLog.created_by", back_populates="creator")
    service_records_created = relationship("ServiceRecord", foreign_keys="ServiceRecord.created_by", back_populates="creator")
    documents_uploaded = relationship("Document", foreign_keys="Document.uploaded_by", back_populates="uploader")
    expenses_created = relationship("Expense", foreign_keys="Expense.created_by", back_populates="creator")
    files_uploaded = relationship("File", foreign_keys="File.uploaded_by", back_populates="uploader")
    audit_logs = relationship("AuditLog", back_populates="user")

    __table_args__ = (
        UniqueConstraint('tenant_id', 'email', name='uq_tenant_user_email'),
        Index('ix_users_tenant_id', 'tenant_id'),
        Index('ix_users_email', 'email'),
        Index('ix_users_role', 'role'),
        Index('ix_users_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Locations
class Location(Base):
    __tablename__ = "locations"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    name = Column(String(255), nullable=False)
    address = Column(Text, nullable=False)
    latitude = Column(DECIMAL(10, 8))
    longitude = Column(DECIMAL(11, 8))
    type = Column(Enum(LocationType), default=LocationType.DEPOT)
    is_active = Column(Boolean, default=True)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="locations")
    vehicles = relationship("Vehicle", back_populates="location")
    trips_start = relationship("Trip", foreign_keys="Trip.start_location_id", back_populates="start_location")
    trips_end = relationship("Trip", foreign_keys="Trip.end_location_id", back_populates="end_location")

    __table_args__ = (
        Index('ix_locations_tenant_id', 'tenant_id'),
        Index('ix_locations_type', 'type'),
        Index('ix_locations_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Vehicles
class Vehicle(Base):
    __tablename__ = "vehicles"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    registration_number = Column(String(20), nullable=False)
    chassis_number = Column(String(50))
    engine_number = Column(String(50))
    vehicle_type = Column(Enum(VehicleType), nullable=False)
    make = Column(String(100))
    model = Column(String(100))
    year = Column(Integer)
    fuel_type = Column(Enum(FuelType), default=FuelType.DIESEL)
    capacity = Column(DECIMAL(10, 2))
    location_id = Column(PGUUID(as_uuid=True), ForeignKey("locations.id"))
    insurance_expiry = Column(Date)
    permit_expiry = Column(Date)
    fitness_expiry = Column(Date)
    puc_expiry = Column(Date)
    fastag_id = Column(String(20))
    odometer_reading = Column(DECIMAL(10, 2), default=0)
    status = Column(Enum(VehicleStatus), default=VehicleStatus.ACTIVE)
    is_active = Column(Boolean, default=True)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    updated_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="vehicles")
    location = relationship("Location", back_populates="vehicles")
    creator = relationship("User", foreign_keys=[created_by], back_populates="vehicles_created")
    updater = relationship("User", foreign_keys=[updated_by], back_populates="vehicles_updated")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="vehicles_deleted")
    trips = relationship("Trip", back_populates="vehicle")
    fuel_logs = relationship("FuelLog", back_populates="vehicle")
    service_records = relationship("ServiceRecord", back_populates="vehicle")
    documents = relationship("Document", foreign_keys="Document.vehicle_id", back_populates="vehicle")
    files = relationship("File", foreign_keys="File.vehicle_id", back_populates="vehicle")

    __table_args__ = (
        UniqueConstraint('tenant_id', 'registration_number', name='uq_tenant_vehicle_registration'),
        CheckConstraint('odometer_reading >= 0', name='ck_vehicle_odometer_positive'),
        CheckConstraint('capacity > 0', name='ck_vehicle_capacity_positive'),
        Index('ix_vehicles_tenant_id', 'tenant_id'),
        Index('ix_vehicles_registration_number', 'registration_number'),
        Index('ix_vehicles_status', 'status'),
        Index('ix_vehicles_location_id', 'location_id'),
        Index('ix_vehicles_tenant_id_created_at', 'tenant_id', 'created_at'),
        Index('ix_vehicles_tenant_id_vehicle_type', 'tenant_id', 'vehicle_type'),
    )

# Drivers
class Driver(Base):
    __tablename__ = "drivers"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    license_number = Column(String(20), nullable=False)
    license_expiry = Column(Date, nullable=False)
    phone = Column(String(15))
    address = Column(Text)
    date_of_birth = Column(Date)
    emergency_contact = Column(String(15))
    status = Column(Enum(DriverStatus), default=DriverStatus.ACTIVE)
    is_active = Column(Boolean, default=True)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    updated_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="drivers")
    creator = relationship("User", foreign_keys=[created_by], back_populates="drivers_created")
    updater = relationship("User", foreign_keys=[updated_by], back_populates="drivers_updated")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="drivers_deleted")
    trips = relationship("Trip", back_populates="driver")
    documents = relationship("Document", foreign_keys="Document.driver_id", back_populates="driver")
    files = relationship("File", foreign_keys="File.driver_id", back_populates="driver")

    __table_args__ = (
        UniqueConstraint('tenant_id', 'license_number', name='uq_tenant_driver_license'),
        Index('ix_drivers_tenant_id', 'tenant_id'),
        Index('ix_drivers_license_number', 'license_number'),
        Index('ix_drivers_status', 'status'),
        Index('ix_drivers_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Trips
class Trip(Base):
    __tablename__ = "trips"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    vehicle_id = Column(PGUUID(as_uuid=True), ForeignKey("vehicles.id"), nullable=False)
    driver_id = Column(PGUUID(as_uuid=True), ForeignKey("drivers.id"), nullable=False)
    trip_number = Column(String(20), nullable=False)
    start_location_id = Column(PGUUID(as_uuid=True), ForeignKey("locations.id"))
    end_location_id = Column(PGUUID(as_uuid=True), ForeignKey("locations.id"))
    start_time = Column(PG_TIMESTAMP(timezone=True))
    end_time = Column(PG_TIMESTAMP(timezone=True))
    start_odometer = Column(DECIMAL(10, 2))
    end_odometer = Column(DECIMAL(10, 2))
    distance = Column(DECIMAL(10, 2))
    cargo_type = Column(String(100))
    cargo_weight = Column(DECIMAL(10, 2))
    status = Column(Enum(TripStatus), default=TripStatus.PLANNED)
    notes = Column(Text)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    updated_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="trips")
    vehicle = relationship("Vehicle", back_populates="trips")
    driver = relationship("Driver", back_populates="trips")
    start_location = relationship("Location", foreign_keys=[start_location_id], back_populates="trips_start")
    end_location = relationship("Location", foreign_keys=[end_location_id], back_populates="trips_end")
    creator = relationship("User", foreign_keys=[created_by], back_populates="trips_created")
    updater = relationship("User", foreign_keys=[updated_by], back_populates="trips_updated")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="trips_deleted")
    fuel_logs = relationship("FuelLog", back_populates="trip")

    __table_args__ = (
        UniqueConstraint('tenant_id', 'trip_number', name='uq_tenant_trip_number'),
        CheckConstraint('start_odometer >= 0', name='ck_trip_start_odometer_positive'),
        CheckConstraint('end_odometer >= 0', name='ck_trip_end_odometer_positive'),
        CheckConstraint('distance >= 0', name='ck_trip_distance_positive'),
        CheckConstraint('cargo_weight >= 0', name='ck_trip_cargo_weight_positive'),
        Index('ix_trips_tenant_id', 'tenant_id'),
        Index('ix_trips_vehicle_id', 'vehicle_id'),
        Index('ix_trips_driver_id', 'driver_id'),
        Index('ix_trips_status', 'status'),
        Index('ix_trips_start_time', 'start_time'),
        Index('ix_trips_tenant_id_created_at', 'tenant_id', 'created_at'),
        Index('ix_trips_tenant_id_vehicle_id_date', 'tenant_id', 'vehicle_id', func.date('start_time')),
        Index('ix_trips_tenant_id_driver_id_date', 'tenant_id', 'driver_id', func.date('start_time')),
    )

# Fuel Logs
class FuelLog(Base):
    __tablename__ = "fuel_logs"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    vehicle_id = Column(PGUUID(as_uuid=True), ForeignKey("vehicles.id"), nullable=False)
    trip_id = Column(PGUUID(as_uuid=True), ForeignKey("trips.id"))
    odometer_reading = Column(DECIMAL(10, 2), nullable=False)
    fuel_quantity = Column(DECIMAL(10, 2), nullable=False)
    fuel_price = Column(DECIMAL(10, 2), nullable=False)
    total_cost = Column(DECIMAL(10, 2), nullable=False)
    fuel_station = Column(String(255))
    filled_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    notes = Column(Text)
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="fuel_logs")
    vehicle = relationship("Vehicle", back_populates="fuel_logs")
    trip = relationship("Trip", back_populates="fuel_logs")
    creator = relationship("User", foreign_keys=[created_by], back_populates="fuel_logs_created")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="fuel_logs_deleted")

    __table_args__ = (
        CheckConstraint('odometer_reading >= 0', name='ck_fuel_log_odometer_positive'),
        CheckConstraint('fuel_quantity > 0', name='ck_fuel_log_quantity_positive'),
        CheckConstraint('fuel_price >= 0', name='ck_fuel_log_price_positive'),
        CheckConstraint('total_cost >= 0', name='ck_fuel_log_cost_positive'),
        Index('ix_fuel_logs_tenant_id', 'tenant_id'),
        Index('ix_fuel_logs_vehicle_id', 'vehicle_id'),
        Index('ix_fuel_logs_filled_at', 'filled_at'),
        Index('ix_fuel_logs_tenant_id_created_at', 'tenant_id', 'filled_at'),
        Index('ix_fuel_logs_tenant_id_vehicle_id_date', 'tenant_id', 'vehicle_id', func.date('filled_at')),
    )

# Service Records
class ServiceRecord(Base):
    __tablename__ = "service_records"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    vehicle_id = Column(PGUUID(as_uuid=True), ForeignKey("vehicles.id"), nullable=False)
    maintenance_type = Column(Enum(MaintenanceType), nullable=False)
    description = Column(Text, nullable=False)
    cost = Column(DECIMAL(10, 2))
    odometer_at_service = Column(DECIMAL(10, 2))
    next_service_due = Column(Date)
    next_service_odometer = Column(DECIMAL(10, 2))
    performed_by = Column(String(255))
    performed_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    status = Column(Enum(MaintenanceStatus), default=MaintenanceStatus.COMPLETED)
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    notes = Column(Text)
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="service_records")
    vehicle = relationship("Vehicle", back_populates="service_records")
    creator = relationship("User", foreign_keys=[created_by], back_populates="service_records_created")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="service_records_deleted")

    __table_args__ = (
        CheckConstraint('cost >= 0', name='ck_service_record_cost_positive'),
        CheckConstraint('odometer_at_service >= 0', name='ck_service_record_odometer_positive'),
        CheckConstraint('next_service_odometer >= 0', name='ck_service_record_next_odometer_positive'),
        Index('ix_service_records_tenant_id', 'tenant_id'),
        Index('ix_service_records_vehicle_id', 'vehicle_id'),
        Index('ix_service_records_performed_at', 'performed_at'),
        Index('ix_service_records_status', 'status'),
        Index('ix_service_records_tenant_id_created_at', 'tenant_id', 'performed_at'),
        Index('ix_service_records_tenant_id_vehicle_id_date', 'tenant_id', 'vehicle_id', func.date('performed_at')),
    )

# Documents
class Document(Base):
    __tablename__ = "documents"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    vehicle_id = Column(PGUUID(as_uuid=True), ForeignKey("vehicles.id"))
    driver_id = Column(PGUUID(as_uuid=True), ForeignKey("drivers.id"))
    document_type = Column(Enum(DocumentType), nullable=False)
    file_name = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)
    file_size = Column(BigInteger, nullable=False)
    mime_type = Column(String(100), nullable=False)
    expiry_date = Column(Date)
    uploaded_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    uploaded_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    is_active = Column(Boolean, default=True)
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="documents")
    vehicle = relationship("Vehicle", foreign_keys=[vehicle_id], back_populates="documents")
    driver = relationship("Driver", foreign_keys=[driver_id], back_populates="documents")
    uploader = relationship("User", foreign_keys=[uploaded_by], back_populates="documents_uploaded")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="documents_deleted")

    __table_args__ = (
        CheckConstraint('file_size > 0', name='ck_document_file_size_positive'),
        Index('ix_documents_tenant_id', 'tenant_id'),
        Index('ix_documents_vehicle_id', 'vehicle_id'),
        Index('ix_documents_driver_id', 'driver_id'),
        Index('ix_documents_document_type', 'document_type'),
        Index('ix_documents_expiry_date', 'expiry_date'),
        Index('ix_documents_uploaded_at', 'uploaded_at'),
        Index('ix_documents_tenant_id_created_at', 'tenant_id', 'uploaded_at'),
    )

# Vendors
class Vendor(Base):
    __tablename__ = "vendors"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    name = Column(String(255), nullable=False)
    contact_person = Column(String(255))
    phone = Column(String(15))
    email = Column(String(255))
    address = Column(Text)
    gst_number = Column(String(15))
    vendor_type = Column(String(100))  # fuel_station, service_center, etc.
    is_active = Column(Boolean, default=True)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    updated_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="vendors")
    creator = relationship("User", foreign_keys=[created_by], back_populates="vendors_created")
    updater = relationship("User", foreign_keys=[updated_by], back_populates="vendors_updated")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="vendors_deleted")
    expenses = relationship("Expense", back_populates="vendor")

    __table_args__ = (
        Index('ix_vendors_tenant_id', 'tenant_id'),
        Index('ix_vendors_vendor_type', 'vendor_type'),
        Index('ix_vendors_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Expenses
class Expense(Base):
    __tablename__ = "expenses"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    vendor_id = Column(PGUUID(as_uuid=True), ForeignKey("vendors.id"))
    amount = Column(DECIMAL(12, 2), nullable=False)
    category = Column(String(100), nullable=False)
    description = Column(Text)
    expense_date = Column(Date, nullable=False)
    payment_method = Column(String(50))
    reference_number = Column(String(100))
    vehicle_id = Column(PGUUID(as_uuid=True), ForeignKey("vehicles.id"))
    driver_id = Column(PGUUID(as_uuid=True), ForeignKey("drivers.id"))
    trip_id = Column(PGUUID(as_uuid=True), ForeignKey("trips.id"))
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="expenses")
    vendor = relationship("Vendor", back_populates="expenses")
    vehicle = relationship("Vehicle", foreign_keys=[vehicle_id], back_populates="expenses")
    driver = relationship("Driver", foreign_keys=[driver_id], back_populates="expenses")
    trip = relationship("Trip", foreign_keys=[trip_id], back_populates="expenses")
    creator = relationship("User", foreign_keys=[created_by], back_populates="expenses_created")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="expenses_deleted")

    __table_args__ = (
        CheckConstraint('amount >= 0', name='ck_expense_amount_positive'),
        Index('ix_expenses_tenant_id', 'tenant_id'),
        Index('ix_expenses_vendor_id', 'vendor_id'),
        Index('ix_expenses_category', 'category'),
        Index('ix_expenses_expense_date', 'expense_date'),
        Index('ix_expenses_vehicle_id', 'vehicle_id'),
        Index('ix_expenses_driver_id', 'driver_id'),
        Index('ix_expenses_trip_id', 'trip_id'),
        Index('ix_expenses_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Files
class File(Base):
    __tablename__ = "files"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    entity_type = Column(String(50), nullable=False)  # vehicle, driver, trip, etc.
    entity_id = Column(PGUUID(as_uuid=True), nullable=False)
    vehicle_id = Column(PGUUID(as_uuid=True), ForeignKey("vehicles.id"))
    driver_id = Column(PGUUID(as_uuid=True), ForeignKey("drivers.id"))
    file_name = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)
    file_size = Column(BigInteger, nullable=False)
    mime_type = Column(String(100), nullable=False)
    uploaded_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    uploaded_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    is_active = Column(Boolean, default=True)
    deleted_at = Column(PG_TIMESTAMP(timezone=True))
    deleted_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"))

    # Relationships
    tenant = relationship("Tenant", back_populates="files")
    vehicle = relationship("Vehicle", foreign_keys=[vehicle_id], back_populates="files")
    driver = relationship("Driver", foreign_keys=[driver_id], back_populates="files")
    uploader = relationship("User", foreign_keys=[uploaded_by], back_populates="files_uploaded")
    deleter = relationship("User", foreign_keys=[deleted_by], back_populates="files_deleted")

    __table_args__ = (
        CheckConstraint('file_size > 0', name='ck_file_file_size_positive'),
        Index('ix_files_tenant_id', 'tenant_id'),
        Index('ix_files_entity_type', 'entity_type'),
        Index('ix_files_entity_id', 'entity_id'),
        Index('ix_files_vehicle_id', 'vehicle_id'),
        Index('ix_files_driver_id', 'driver_id'),
        Index('ix_files_uploaded_at', 'uploaded_at'),
        Index('ix_files_tenant_id_created_at', 'tenant_id', 'uploaded_at'),
    )

# Audit Logs
class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    action = Column(String(50), nullable=False)
    table_name = Column(String(50), nullable=False)
    record_id = Column(PGUUID(as_uuid=True), nullable=False)
    old_values = Column(JSON)
    new_values = Column(JSON)
    ip_address = Column(String(45))
    user_agent = Column(Text)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())

    # Relationships
    tenant = relationship("Tenant", back_populates="audit_logs")
    user = relationship("User", back_populates="audit_logs")

    __table_args__ = (
        Index('ix_audit_logs_tenant_id', 'tenant_id'),
        Index('ix_audit_logs_user_id', 'user_id'),
        Index('ix_audit_logs_table_name', 'table_name'),
        Index('ix_audit_logs_created_at', 'created_at'),
        Index('ix_audit_logs_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Notification Outbox
class NotificationOutbox(Base):
    __tablename__ = "notification_outbox"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    type = Column(Enum(NotificationType), nullable=False)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    data = Column(JSON)
    sent_at = Column(PG_TIMESTAMP(timezone=True))
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())

    # Relationships
    tenant = relationship("Tenant", back_populates="notification_outbox")
    user = relationship("User", back_populates="notifications")

    __table_args__ = (
        Index('ix_notification_outbox_tenant_id', 'tenant_id'),
        Index('ix_notification_outbox_user_id', 'user_id'),
        Index('ix_notification_outbox_type', 'type'),
        Index('ix_notification_outbox_sent_at', 'sent_at'),
        Index('ix_notification_outbox_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Import Jobs
class ImportJob(Base):
    __tablename__ = "import_jobs"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(PGUUID(as_uuid=True), ForeignKey("tenants.id"), nullable=False)
    file_path = Column(String(500), nullable=False)
    status = Column(Enum(ImportJobStatus), default=ImportJobStatus.PENDING)
    total_rows = Column(Integer, default=0)
    processed_rows = Column(Integer, default=0)
    error_count = Column(Integer, default=0)
    created_by = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    created_at = Column(PG_TIMESTAMP(timezone=True), default=func.now())
    updated_at = Column(PG_TIMESTAMP(timezone=True), default=func.now(), onupdate=func.now())
    completed_at = Column(PG_TIMESTAMP(timezone=True))

    # Relationships
    tenant = relationship("Tenant", back_populates="import_jobs")
    creator = relationship("User", foreign_keys=[created_by], back_populates="import_jobs_created")
    rows = relationship("ImportJobRow", back_populates="job")

    __table_args__ = (
        Index('ix_import_jobs_tenant_id', 'tenant_id'),
        Index('ix_import_jobs_status', 'status'),
        Index('ix_import_jobs_created_at', 'created_at'),
        Index('ix_import_jobs_tenant_id_created_at', 'tenant_id', 'created_at'),
    )

# Import Job Rows
class ImportJobRow(Base):
    __tablename__ = "import_job_rows"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    job_id = Column(PGUUID(as_uuid=True), ForeignKey("import_jobs.id"), nullable=False)
    row_number = Column(Integer, nullable=False)
    row_data = Column(JSON, nullable=False)
    status = Column(String(20), default="pending")  # pending, processed, error
    error_message = Column(Text)
    created_entity_type = Column(String(50))
    created_entity_id = Column(PGUUID(as_uuid=True))
    processed_at = Column(PG_TIMESTAMP(timezone=True))

    # Relationships
    job = relationship("ImportJob", back_populates="rows")

    __table_args__ = (
        Index('ix_import_job_rows_job_id', 'job_id'),
        Index('ix_import_job_rows_status', 'status'),
        Index('ix_import_job_rows_row_number', 'row_number'),
    )

# Add missing relationships to User model
User.vendors_created = relationship("Vendor", foreign_keys="Vendor.created_by", back_populates="creator")
User.vendors_updated = relationship("Vendor", foreign_keys="Vendor.updated_by", back_populates="updater")
User.vendors_deleted = relationship("Vendor", foreign_keys="Vendor.deleted_by", back_populates="deleter")
User.expenses_created = relationship("Expense", foreign_keys="Expense.created_by", back_populates="creator")
User.expenses_deleted = relationship("Expense", foreign_keys="Expense.deleted_by", back_populates="deleter")
User.files_uploaded = relationship("File", foreign_keys="File.uploaded_by", back_populates="uploader")
User.files_deleted = relationship("File", foreign_keys="File.deleted_by", back_populates="deleter")
User.notifications = relationship("NotificationOutbox", back_populates="user")
User.import_jobs_created = relationship("ImportJob", foreign_keys="ImportJob.created_by", back_populates="creator")

# Add missing relationships to Tenant model
Tenant.locations = relationship("Location", back_populates="tenant")

# Add missing relationships to Vehicle model
Vehicle.expenses = relationship("Expense", foreign_keys="Expense.vehicle_id", back_populates="vehicle")

# Add missing relationships to Driver model
Driver.expenses = relationship("Expense", foreign_keys="Expense.driver_id", back_populates="driver")

# Add missing relationships to Trip model
Trip.expenses = relationship("Expense", foreign_keys="Expense.trip_id", back_populates="trip")
