import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, Tenant, User, Vehicle, Driver, Trip
import datetime
from passlib.hash import bcrypt

# Database URL from env
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://autopredator:devpassword@localhost:5432/autopredator_dev')

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def seed_database():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # Create demo tenant
        tenant = Tenant(name="Demo Company")
        db.add(tenant)
        db.commit()

        # Create users
        users_data = [
            {"email": "admin@autopredator.dev", "password": "admin123", "role": "admin"},
            {"email": "manager@autopredator.dev", "password": "manager123", "role": "manager"},
            {"email": "driver@autopredator.dev", "password": "driver123", "role": "driver"},
        ]

        users = []
        for user_data in users_data:
            user = User(
                email=user_data["email"],
                password_hash=bcrypt.hash(user_data["password"]),
                role=user_data["role"],
                tenant_id=tenant.id
            )
            db.add(user)
            users.append(user)
        db.commit()

        # Create vehicle
        vehicle = Vehicle(
            license_plate="KA01AB1234",
            model="Toyota Innova",
            tenant_id=tenant.id
        )
        db.add(vehicle)
        db.commit()

        # Create driver profile
        driver_user = next(u for u in users if u.role == "driver")
        driver = Driver(
            user_id=driver_user.id,
            license_number="DL123456789",
            phone="+91-9876543210"
        )
        db.add(driver)
        db.commit()

        # Create sample trip
        trip = Trip(
            vehicle_id=vehicle.id,
            driver_id=driver.id,
            start_location="Bangalore",
            end_location="Mysore",
            start_time=datetime.datetime.utcnow(),
            end_time=datetime.datetime.utcnow() + datetime.timedelta(hours=4),
            status="completed"
        )
        db.add(trip)
        db.commit()

        print("✅ Database seeded successfully!")

    except Exception as e:
        db.rollback()
        print(f"❌ Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
