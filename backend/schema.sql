-- Autopredator Database Schema

CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  name VARCHAR(100) DEFAULT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) DEFAULT NULL,
  phone_number VARCHAR(15) DEFAULT NULL,
  address TEXT DEFAULT NULL,
  user_type VARCHAR(20) CHECK (user_type IN ('Buyer','Seller','Dealer')) DEFAULT NULL,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE vehicle_kind AS ENUM ('new', 'used');

CREATE TABLE vehicles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  brand VARCHAR(120) NOT NULL,
  segment VARCHAR(120),
  type vehicle_kind NOT NULL DEFAULT 'new',
  fuel_type VARCHAR(60),
  body_type VARCHAR(60),
  transmission VARCHAR(60),
  seating_capacity INT,
  price_min NUMERIC(12, 2),
  price_max NUMERIC(12, 2),
  currency VARCHAR(8) DEFAULT 'INR',
  rating NUMERIC(3, 2) DEFAULT 4.5,
  image_url TEXT,
  thumbnail_url TEXT,
  specs JSONB DEFAULT '{}',
  features JSONB DEFAULT '{}',
  performance JSONB DEFAULT '{}',
  dimensions JSONB DEFAULT '{}',
  safety_rating NUMERIC(2, 1) DEFAULT 4.0,
  categories TEXT[] DEFAULT '{}',
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE vehicle_listings (
  id SERIAL PRIMARY KEY,
  vehicle_id INT REFERENCES vehicles(id) ON DELETE CASCADE,
  seller_id INT REFERENCES users(user_id),
  km_driven INT,
  year INT,
  asking_price NUMERIC(12, 2),
  condition VARCHAR(50),
  city VARCHAR(255),
  owner_type VARCHAR(120),
  verified BOOLEAN DEFAULT FALSE,
  documents JSONB DEFAULT '[]',
  service_score NUMERIC(3, 2) DEFAULT 4.0,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE service_history (
  id SERIAL PRIMARY KEY,
  vehicle_listing_id INT REFERENCES vehicle_listings(id) ON DELETE CASCADE,
  service_date DATE,
  description TEXT,
  mileage INT,
  cost NUMERIC(10, 2)
);

CREATE TABLE vehicle_documents (
  id SERIAL PRIMARY KEY,
  vehicle_listing_id INT REFERENCES vehicle_listings(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  status VARCHAR(60) DEFAULT 'available',
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_saved_vehicles (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
  vehicle_id INT REFERENCES vehicles(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, vehicle_id)
);

CREATE TABLE user_bookings (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
  vehicle_id INT REFERENCES vehicles(id),
  booking_type VARCHAR(60),
  preferred_date DATE,
  status VARCHAR(60) DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE forum_posts (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(user_id),
  category VARCHAR(80) NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  views INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE forum_replies (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(user_id),
  post_id INT REFERENCES forum_posts(id) ON DELETE CASCADE,
  parent_reply_id INT REFERENCES forum_replies(id),
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE blog_posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  summary TEXT NOT NULL,
  content TEXT NOT NULL,
  author VARCHAR(120),
  hero_image TEXT,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE ai_insights (
  id SERIAL PRIMARY KEY,
  vehicle_id INT REFERENCES vehicles(id),
  resale_value NUMERIC(12, 2),
  confidence NUMERIC(3, 2),
  fair_value NUMERIC(12, 2),
  explanation TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
