<<<<<<< HEAD
# Autopredator (PHP Build)

Plain PHP, HTML, CSS, and vanilla JS implementation of the Autopredator vehicle platform. React/Next.js and Node tooling have been removed; the stack now runs entirely on PHP with MySQL/MariaDB.

## What’s inside
- `legacy/php_app/`: primary UI (dashboards, listings, calculators, auth pages).
- `legacy/static/`: shared CSS/images for the PHP UI.
- `127_0_0_1 (6).sql`: phpMyAdmin export with the `autopredator`, `autopredator_unified`, `blogs`, `cars`, and `mindflow_db` schemas.
- `docs/`, `prototype/`, `legacy/` assets for reference.

## Run locally (XAMPP/LAMP/WAMP)
1. Clone/copy this repo into your web root (e.g., `C:\xampp\htdocs\Autopredator`).
2. In phpMyAdmin, import `127_0_0_1 (6).sql` to create/populate the databases.
3. Serve the app:  
   - Either set the Apache/Nginx document root to `legacy/php_app`, **or**  
   - Open `http://localhost/Autopredator/` and follow the redirect to `legacy/php_app/`.
4. Ensure `legacy/php_app/uploads/` (and `uploads/content/` if using the upload form) is writable by the web server.
5. Update DB credentials in `legacy/php_app/config.php` (and related config files) to match your local MySQL settings.

## Stack
- PHP 8+, MySQL/MariaDB
- HTML, CSS (Tailwind CDN + `legacy/static` styles), vanilla JavaScript
- No Node/React build tools are required.

## Notes
- The root `index.php` simply redirects traffic into the PHP app.
- The gitignore is trimmed for a PHP-first workflow; uploads remain untracked.
=======
# Autopredator

Autopredator pairs a React/Next.js control panel with a Django REST backend so fleets can manage vehicles, predictive maintenance, analytics, notifications, and monetisation flows from one stack.

## Architecture at a glance
- **Frontend**: Next.js 16 with the app router, Tailwind-inspired UI, and `axios`-backed API client that attaches JWT tokens stored in `localStorage`. PostHog is wired via `posthog-js` for feature analytics.
- **Backend**: Django 5 REST API with JWT auth, analytics logging middleware, feature/vehicle snapshot models, email notification jobs, and a linear regression prediction pipeline exported via `joblib`.
- **ML & AI**: A lightweight `backend/scripts/train_model.py` script generates `model.pkl` from synthetic data; the `/api/predict/` endpoint loads it to estimate the next service window and logs usage.
- **Notifications**: `core/management/commands/notify_due.py` scans vehicles for service and document due dates, dispatches SMTP/SendGrid emails (configurable via `.env`), and records `Notification` entries.

## Features
1. JWT login with `auto` redirect on 401/403 and global Axios headers.
2. Dashboard that aggregates vehicles, reminders, cost analytics, predictions, marketplace items, and fleet insights.
3. Fleet panel showing vehicle status, mileage, and CSV exports.
4. Marketplace, blog, community, and compare pages repurposed to work against the Django APIs or static data.
5. Background analytics models tracking API usage, feature adoption, and vehicle counts for each user.
6. Open API, ERD, and Postman artifacts under `docs/`.

## Environment configuration
### Backend
Copy `backend/.env.example` to `backend/.env` and update:
```
DEBUG=False
SECRET_KEY=your-production-key
ALLOWED_HOSTS=api.autopredator.com,localhost,127.0.0.1
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=apikey
EMAIL_HOST_PASSWORD=your-sendgrid-api-key
DEFAULT_FROM_EMAIL=noreply@autopredator.com
```
Additional database settings (DB Engine/User/Auth) follow existing keys.

### Frontend
Copy `frontend/.env.example` to `frontend/.env` for local work:
```
NEXT_PUBLIC_API_URL=http://localhost:8000/api
REACT_APP_API_URL=http://localhost:8000/api
NEXT_PUBLIC_POSTHOG_API_KEY=your-posthog-key
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
```
`NEXT_PUBLIC_POSTHOG_*` values point to PostHog or another compatible analytics collector.

## Getting started
### Backend
1. `python -m venv .venv && source .venv/bin/activate` (or equivalent on Windows)
2. `pip install -r requirements.txt`
3. `python manage.py migrate`
4. `python manage.py createsuperuser`
5. `python manage.py train_model` *(optional — regenerates `model.pkl` for predictions)*
6. `python manage.py runserver`

### Frontend
1. `cd frontend`
2. `npm install` (or `npm install --legacy-peer-deps` where needed)
3. `npm run dev`

## Docker & Compose
1. `docker-compose up --build`
   - Backend on port `8000`, frontend on port `3000`
   - Environment arises from each service’s Dockerfile plus `.env` files.
2. Apply migrations inside the backend container: `docker-compose exec backend python manage.py migrate`

## Testing & QA
- Backend: `python manage.py test`
- Frontend: `npm run test` (uses Vitest with `jsdom`, React Testing Library, and three sanity tests covering login, fleet panel, and prediction card).

## Deployment guidance
- **Frontend**: Push `frontend/.next` build to Netlify, Vercel, or S3+CloudFront. Point `NEXT_PUBLIC_API_URL` to the hosted backend.
- **Backend**: Deploy Django to Render, Railway, or EC2; connect to Postgres via ElephantSQL, Supabase, or Railway-managed database.
- **HTTPS**: Always serve both tiers over HTTPS behind valid domains (e.g., `app.autopredator.com`, `api.autopredator.com`). Use CORS settings to allow approved origins.
- **Email**: Configure SMTP/SendGrid credentials in `.env` and ensure `DEFAULT_FROM_EMAIL` matches your sending domain.
- **Analytics**: PostHog events flow from the frontend and Django logs into the `ApiUsageLog`/`FeatureUsageLog` models. Export analytics as needed.
- **Payment/Plans**: The backend exposes `/api/payment/create-checkout-session/` to initiate Stripe sessions. Add UI around `Free`, `Pro`, and `Fleet Enterprise` plans as desired.

## Documentation & Assets
- ERD: `docs/ERD.md`
- Swagger/OpenAPI: `docs/openapi.yaml`
- Postman collection: `docs/postman_collection.json`

## Additional scripts
- `backend/scripts/train_model.py`: regenerates `model.pkl` using mileage, vehicle type, and service interval samples.
- `core/management/commands/notify_due.py`: send upcoming service/document notifications (run via cron or scheduler).

## Notes
- Clear auth tokens via the login page or on API 401/403 responses to enforce reauthentication.
- Keep `model.pkl` in sync with training data before deploying new models; the API gracefully falls back to heuristics if loading fails.
>>>>>>> de5be4d3c077d718cb1340a58c78882f0f3ec30d
