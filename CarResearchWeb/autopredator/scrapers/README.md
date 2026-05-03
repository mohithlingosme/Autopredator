# Autopredator Scrapers

Production scrapers for Indian automotive data tiers.

## Structure
- `tier1_gov/`: VAHAN, SIAM, Parivahan
- `tier2_oem/`: 22 OEM catalogs
- `tier3_marketplace/`: CarDekho, CarWale, ZigWheels
- `tier4_plus/`: Dealers, insurance (Phase 2)

## Run
```bash
cd autopredator/scrapers
python tier1_gov/vahan_selenium.py
python tier3_marketplace/general_scraper.py
```

Output: JSONL to `../scrape_output/`

