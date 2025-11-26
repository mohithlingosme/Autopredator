-- Seed data for blog_posts table
-- Expected schema: id (auto), title, slug, excerpt, content, featured_image, created_at
INSERT INTO blog_posts (title, slug, excerpt, content, featured_image, created_at) VALUES
('Why reactive maintenance is costing you', 'reactive-maintenance-costs', 'How to quantify downtime and fuel waste from delayed alerts.', 'Delaying maintenance until failure leads to compounding downtime. Use telemetry to trigger proactive work orders and reduce roadside events.', '', NOW()),
('Designing driver-first safety programs', 'driver-first-safety', 'Coaching and compliance without adding operational friction.', 'Safety programs work when they are driver-first: clear feedback, fair scoring, and coaching that respects time on the road.', '', NOW()),
('From alerts to automation', 'alerts-to-automation', 'Routing tasks to the right teams without spreadsheets.', 'Move from noisy alerts to automation by defining ownership, routing rules, and closed-loop workflows that show ROI.', '', NOW());
