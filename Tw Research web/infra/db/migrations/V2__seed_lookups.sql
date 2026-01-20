-- Seed lookup data for catalog and pricing reference tables
INSERT INTO catalog.fuel_types (name)
VALUES ('petrol'), ('diesel'), ('cng'), ('electric'), ('hybrid')
ON CONFLICT (name) DO NOTHING;

INSERT INTO catalog.transmission_types (name)
VALUES ('manual'), ('automatic'), ('cvt'), ('dct')
ON CONFLICT (name) DO NOTHING;

INSERT INTO catalog.body_types (name)
VALUES ('hatchback'), ('sedan'), ('suv'), ('muv'), ('coupe'), ('cruiser'), ('scooter')
ON CONFLICT (name) DO NOTHING;

INSERT INTO catalog.features (category, name)
VALUES
  ('safety', 'ABS'),
  ('safety', 'Traction Control'),
  ('comfort', 'Keyless Start'),
  ('comfort', 'Cruise Control'),
  ('connectivity', 'Apple CarPlay'),
  ('connectivity', 'Android Auto')
ON CONFLICT (category, name) DO NOTHING;

INSERT INTO pricing.cities (name, state)
VALUES
  ('Mumbai', 'Maharashtra'),
  ('Delhi', 'Delhi'),
  ('Bengaluru', 'Karnataka'),
  ('Hyderabad', 'Telangana'),
  ('Pune', 'Maharashtra')
ON CONFLICT (name, state) DO NOTHING;
