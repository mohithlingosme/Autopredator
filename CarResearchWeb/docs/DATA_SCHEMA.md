# Data Schema

All JSON lives under `data/` and is loaded via `src/Data/JsonLoader`. Files are UTF-8 encoded.

## new_carset.json (primary)
Array of models:
- `id` (number) — optional source id.
- `make` (string) — manufacturer name.
- `model` (string) — model family name.
- `segment` (string) — body/segment label (e.g., "SUV").
- `launch_year` (number) — year; optional.
- `variants` (array):
  - `id` (number)
  - `name` (string)
  - `price` (string) — display value.
  - `fuel_type` (string)
  - `transmission` (string)
  - `engine_size` (string, optional)
  - `horsepower` (string, optional)

## data.json (legacy)
Array of simplified rows:
- `s_no` (string/number)
- `make` (string)
- `model` (string)
- `price` (string)
- `power_bhp` (string)
- `range_mileage` (string)
- `fuel_type` (string)
- `notes` (string, optional)

Legacy rows are converted into single-variant models by the repository to keep the interface consistent.

## details_index.json
Object map of `slug -> file` for detailed spec sheets. Slugs must match `/^[a-z0-9]+(?:-[a-z0-9]+)*$/`. Files must live under `data/` and contain any shape you choose; they are served verbatim via `api/details.php`.

## Notes
- Prices are parsed with support for Indian notation: `L` (lakhs) and `Cr` (crores).
- Invalid or unreadable files are logged via `App\Support\Logger` and treated as empty to keep pages responsive.
