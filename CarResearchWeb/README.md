# CarResearchWeb (moved under `autopredator/`)

This folder was reorganized into a clean, Graphify-friendly layout under:

- `autopredator/README.md`
- `autopredator/docs/GRAPHIFY.md`

The original PHP app entrypoints and configs now live in `autopredator/backend/`.

To update graphifyy (and the graphify CLI) on Windows:

# Show current version
python -m pip show graphifyy

# Update
python -m pip install --upgrade graphifyy

# Verify CLI still works
graphify --help
If you installed it via pipx instead:

pipx upgrade graphifyy
graphify --help
If you want to refresh your repo graph after updating:

cd .\autopredator
graphify update .