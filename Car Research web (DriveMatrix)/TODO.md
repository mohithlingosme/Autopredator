🚗 Car Research Platform - Development Roadmap

This project aims to build a modern car research application that ingests unstructured brochure data (PDF/Text) via Google AI Studio, converts it into structured JSON, and serves it via a PostgreSQL (Hybrid SQL/JSON) database.

📌 Phase 1: Project Initialization & Architecture

[ ] Tech Stack Selection

[ ] Frontend: Next.js (React) - Selected for SEO & Server Side Rendering.

[ ] Backend: Node.js (Express) OR Python (FastAPI) - Node.js recommended for native JSON handling.

[ ] Database: PostgreSQL (v14+) - Required for robust JSONB support.

[ ] AI Provider: Google Gemini API (AI Studio).

[ ] Repo Setup

[ ] Initialize Git repository.

[ ] Set up Monorepo structure (optional) or separate /client and /server folders.

[ ] Configure .env files (DB credentials, Gemini API Keys).

🤖 Phase 2: The AI Ingestion Pipeline (The Core)

Goal: Convert raw brochure text into the "Strict Mode" JSON format we designed.

[ ] Prompt Engineering

[ ] Save the "Strict Mode" System Prompt (from our previous chat) into a constant file (prompts/carSpecsPrompt.ts).

[ ] Implement the "Polymorphic Logic" (Detect ICE vs EV first).

[ ] Brochure Processing Script

[ ] Create a script to accept text input (OCR output from PDF).

[ ] Connect to Google Gemini API (gemini-pro model).

[ ] Validation Layer: Write a function to validate the AI's output:

[ ] Check if common_specs exists.

[ ] Ensure variants is an array.

[ ] Verify true/false booleans (reject "Yes"/"No" strings).

[ ] Testing

[ ] Run the pipeline with the Hyundai i20 brochure text.

[ ] Verify handling of null values for missing data.

🗄️ Phase 3: Database Implementation (PostgreSQL)

Goal: Store the JSON efficiently while allowing SQL-speed querying.

[ ] Schema Design

[ ] Create car_models table:

CREATE TABLE car_models (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(50) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    brochure_version VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    specs JSONB NOT NULL -- The massive JSON object goes here
);


[ ] Indexing Strategy

[ ] Create GIN Index for fast JSON searching:
CREATE INDEX idx_car_specs ON car_models USING GIN (specs);

[ ] Seed Data

[ ] Manually insert the cleaned Hyundai i20 JSON as the first record for testing.

🔌 Phase 4: Backend API Development

[ ] Basic Endpoints

[ ] GET /api/cars - List all available cars (Brand + Model).

[ ] GET /api/cars/:id - Fetch the full JSON for a specific car.

[ ] Advanced Filtering (The "Magic" Queries)

[ ] Implement Query: Find cars by Feature (e.g., Sunroof = true).

-- Concept
SELECT * FROM car_models 
WHERE specs @> '{"variants": [{"features": {"sunroof": true}}]}';


[ ] Implement Query: Find cars by Power (e.g., > 100 PS).

[ ] Admin Ingestion Endpoint

[ ] POST /api/admin/ingest - Accepts raw text, calls AI, returns JSON for review.

[ ] POST /api/admin/save - Saves the approved JSON to DB.

💻 Phase 5: Frontend Development (Next.js)

[ ] Components Construction

[ ] VariantSelector: A tab or dropdown component to switch between "Sportz", "Asta", etc.

[ ] SpecTable: A component that takes common_specs + variant.features and renders a clean table.

[ ] FeatureBadge: Visual pills for key features (e.g., "Sunroof", "6 Airbags").

[ ] Pages

[ ] Home: Search bar + Brand grid.

[ ] Model Details:

[ ] Header (Car Name, Price Range).

[ ] "Common Specs" Section (Dimensions, Engine).

[ ] Interactive Variant comparison section (The Logic: mergedData = { ...common, ...selectedVariant }).

[ ] Comparison Tool (Side-by-Side):

[ ] Select Car A -> Select Variant.

[ ] Select Car B -> Select Variant.

[ ] Render two columns comparing keys.

🛠️ Phase 6: Internal Tools (Admin Dashboard)

Goal: Speed up adding new cars.

[ ] Build a simple "Paste & Convert" page.

[ ] Text Area: Paste copied text from PDF.

[ ] Button: "Generate Specs".

[ ] JSON Editor: View the AI output, fix any hallucinations manually.

[ ] Save Button: Push to PostgreSQL.

🚀 Phase 7: Polish & Launch

[ ] Data Sanitization: Ensure null values display as "-" or "N/A" on the UI, not empty space.

[ ] Unit Conversion: Helper function to convert mm to ft or PS to BHP if needed on the frontend.

[ ] SEO: Generate dynamic meta tags based on model_info.

[ ] Deployment: Vercel (Frontend) + Supabase/Render 