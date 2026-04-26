# Autopredator (module)

Commercial vehicle intelligence: scraping + normalization, backend APIs, and ML-assisted extraction.

## Layout

```
autopredator/
├── backend/   # PHP web app + APIs + assets
├── scraper/   # scraping/ETL scripts
├── ml/        # ML/LLM services (FastAPI, etc.)
├── data/      # datasets, dumps, schemas
├── docs/      # design + ops docs (incl. Graphify)
└── tests/     # unit/e2e tests + mocks
```

## Graphify (architecture graph)

Graphify outputs live in `autopredator/graphify-out/` and are intentionally ignored by git.

### First build

```powershell
cd .\autopredator
graphify update .
```

### Common usage

```powershell
cd .\autopredator
graphify query "extract_specs"
graphify explain "extract_specs()"
graphify watch .
```

See `autopredator/docs/GRAPHIFY.md` for cleanup, install, hooks, and MCP server setup.

