## CI/CD and Automation

This repo ships with GitHub Actions workflows and Dependabot updates to keep builds and deployments healthy.

### Workflows
- `ci.yml`: Runs on pushes to `main` and pull requests. Detects changed areas and runs targeted jobs:
  - Backend (Python/FastAPI): installs `backend/requirements*.txt`, then runs `ruff`, `black`, and `pytest` only if installed.
  - Frontend (Node/Vite/React): installs with `npm ci`, runs `lint`/`test` if defined, and builds when a frontend change is detected.
  - PHP: syntax checks all tracked `*.php` files (also under `CarResearchWeb/` or `php_app/`).
- `security.yml`: Secret scanning via Gitleaks and CodeQL SAST for Python and JavaScript (push, PR, and weekly).
- `docker.yml`: Builds and pushes images to GHCR for backend and frontend when corresponding `Dockerfile`s exist (push to `main` and tags starting with `v`).
- `deploy.yml`: SSH-based deployment to a VPS, pulling and restarting services with `docker-compose.prod.yml` on `main`.

### Required secrets (Settings → Secrets and variables → Actions)
- `SSH_HOST`, `SSH_USER`, `SSH_KEY`, `DEPLOY_PATH` (deploy). Optional: `SSH_PORT` (defaults to 22).
- `GITHUB_TOKEN` is provided automatically for GHCR pushes; no extra configuration needed unless you prefer a PAT for pulling.

### Using GHCR images on a server
```bash
echo "$CR_PAT" | docker login ghcr.io -u <github-username> --password-stdin
docker pull ghcr.io/<github-username>/autopredator-backend:latest
docker pull ghcr.io/<github-username>/autopredator-frontend:latest
```
Replace `<github-username>` with the repository owner (lowercase for GHCR).

### Example docker-compose.prod.yml (server-side)
```yaml
services:
  backend:
    image: ghcr.io/<github-username>/autopredator-backend:latest
    env_file: .env.backend
    restart: unless-stopped

  frontend:
    image: ghcr.io/<github-username>/autopredator-frontend:latest
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped
```
