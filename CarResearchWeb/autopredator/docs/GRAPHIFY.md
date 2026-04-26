# Graphify in Autopredator

This repo uses Graphify to generate a navigable dependency/architecture graph of the codebase.

## Clean reset (repo-local artifacts)

Run these from `CarResearchWeb/` (this folder):

```powershell
# Remove Graphify outputs (safe: only removes Graphify artifacts)
Remove-Item -Recurse -Force -LiteralPath .\autopredator\graphify-out -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force -LiteralPath .\autopredator\.graphify    -ErrorAction SilentlyContinue
Remove-Item -Force           -LiteralPath .\autopredator\graph.json  -ErrorAction SilentlyContinue
Remove-Item -Force           -LiteralPath .\autopredator\graph.html  -ErrorAction SilentlyContinue
```

To also remove *global* caches/config (optional), search first:

```powershell
# Inspect possible global artifacts (do not delete blindly)
Get-ChildItem -Force "$env:USERPROFILE" -Filter ".graphify*" -ErrorAction SilentlyContinue
Get-ChildItem -Force "$env:LOCALAPPDATA" -Filter "*graphify*" -ErrorAction SilentlyContinue
Get-ChildItem -Force "$env:APPDATA" -Filter "*graphify*" -ErrorAction SilentlyContinue
```

## Installation (production-grade options)

Graphify is installed from the `graphifyy` package.

### Option A: `pipx` (recommended: isolated + global CLI)

```powershell
python -m pip install --user pipx
python -m pipx ensurepath
pip install graphifyy
graphify --help
graphify install --platform codex
```

### Option B: `pip --user` (global-ish CLI, but shares site-packages)

```powershell
python -m pip install --upgrade pip
python -m pip install --user --upgrade graphifyy
graphify --help
graphify install --platform codex
```

If `graphify` is not found after `--user` install, add your Python Scripts directory to PATH:

```powershell
python -c "import site; print(site.getuserbase())"
# Add the printed path + '\\Scripts' to PATH, then open a new terminal.
```

### Option C: project venv (repeatable per-repo, not global)

```powershell
cd .\autopredator
python -m venv .venv
.\.venv\Scripts\python -m pip install --upgrade pip
.\.venv\Scripts\python -m pip install --upgrade graphifyy
.\.venv\Scripts\graphify --help
.\.venv\Scripts\graphify install --platform codex
```

## Initialize + first build

Run from `CarResearchWeb/autopredator`:

```powershell
cd .\autopredator

# Wire Graphify into Codex (writes ./AGENTS.md + ./.codex/hooks.json)
graphify codex install

# First build (Graphify will honor .graphifyignore)
graphify update .
```

Common useful commands:

```powershell
graphify --help
graphify update .
graphify watch .
graphify query "extract_specs"
graphify explain "extract_specs()"
graphify path "A" "B"
```

## What Graphify generates

Typical outputs (exact names can vary by version/config):

- `graphify-out/graph.json`: machine-readable graph (nodes + edges + metadata).
- `graphify-out/graph.html`: interactive report/visualization (open in browser).
- `graphify-out/cache/`: cached analysis results for faster incremental updates.
- `graphify-out/manifest.json`: file hashes/timestamps used for incremental rebuilds.

These are build artifacts: keep them out of git.

## Team workflow (continuous usage)

### After code changes

```powershell
cd .\autopredator
graphify update .
```

### During debugging

Use `graphify query` (if supported) to answer questions like:

```powershell
graphify query "entrypoints in backend"
graphify query "who calls extract_specs"
```

### Watch mode

```powershell
cd .\autopredator
graphify watch .
```

## Git hook integration

Graphify can install hooks for you:

```powershell
cd .\autopredator
graphify hook status
graphify hook install
```

Hooks keep the graph fresh on `post-commit` and `post-checkout`. Keep it fast by relying on cache + `.graphifyignore` (never scan `backend/vendor/`).

## Autopredator-specific graphing targets

Focus Graphify on the real flow:

1. `scraper/` ingestion + normalization (`scraper/scripts/*`)
2. `backend/` request handlers + DB access (`backend/api/*`, `backend/includes/*`)
3. `ml/` extraction/ranking/risk logic (`ml/ai_service/*`)

If Graphify supports query filters/scopes, prefer scoping queries to these folders for speed and signal.

### Flow recipes (copy/paste)

Scraper → normalized dataset:

```powershell
cd .\autopredator
graphify query "convert_data_to_json"
graphify query "normalize"
```

Backend API → repository → data:

```powershell
cd .\autopredator
graphify query "SearchController"
graphify explain "JsonCarRepository"
graphify query "JsonCarRepository"
```

ML service entrypoints:

```powershell
cd .\autopredator
graphify query "ml\\ai_service\\agent.py"
graphify explain "extract_specs()"
```

### Large codebase performance

- Keep `.graphifyignore` strict (especially `backend/vendor/`).
- Prefer `graphify update .` for incremental updates (uses `graphify-out/cache/`).
- If you only need fresh visualization after edits, `graphify cluster-only .` is usually cheaper than a full re-extract.
- If you vendor large datasets/binaries, keep them under `data/` and add explicit ignore patterns.

## Common mistakes (avoid)

- Committing `graphify-out/` (treat it like build output).
- Letting Graphify scan `backend/vendor/` (massive noise + slow).
- Running Graphify from the wrong directory (always `cd autopredator` first so `.graphifyignore` applies as intended).
- Expecting `graphify query` to be “smart” without a fresh graph; run `graphify update .` after major refactors.
- Installing multiple conflicting `graphify` executables (prefer `pipx` or a single Python install).

## MCP server (advanced)

Graphify can expose your graph over an MCP stdio server (useful for agentic tooling).

1) Install the dependency:

```powershell
python -m pip install mcp
```

2) Start the MCP server (stdio transport):

```powershell
cd .\autopredator
python -m graphify.serve .\graphify-out\graph.json
```

This exposes tools like `query_graph`, `get_node`, `get_neighbors`, `shortest_path`, etc. (exact tool names depend on the client + Graphify version).
