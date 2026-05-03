#!/usr/bin/env python3
'''
SIAM Monthly Sales PDF Parser (Tier 1 Government/OEM Data)

Downloads SIAM domestic sales PDFs from siam.in → extracts tables → JSON sales data.

Install:
pip install requests tabula-py pandas pypdf camelot-py[cv]

Sources:
http://www.siam.in/statistics.aspx?mpgid=8&pgidtrail=14
http://www.siam.in/upload/Reports/[month-year].pdf

Output: JSONL to ../../scrape_output/siam_sales.jsonl
'''

import os
import json
import re
import pandas as pd
from datetime import datetime
from typing import List, Dict
import requests
from pathlib import Path
import tabula  # For PDF table extraction
import camelot  # Alternative PDF tables

OUTPUT_DIR = "../../scrape_output"
SIAM_SALES_JSONL = os.path.join(OUTPUT_DIR, "siam_sales.jsonl")

MONTH_NAMES = {
    'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04', 'May': '05', 'Jun': '06',
    'Jul': '07', 'Aug': '08', 'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
}

def ensure_output():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def download_pdf(url: str, filename: str) -> Path:
    """Download SIAM PDF."""
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    path = Path(OUTPUT_DIR) / 'pdfs' / filename
    path.parent.mkdir(exist_ok=True)
    with open(path, 'wb') as f:
        f.write(resp.content)
    print(f"Downloaded: {path}")
    return path

def parse_pdf_tables(pdf_path: Path) -> List[Dict]:
    """Extract sales tables from SIAM PDF."""
    # Try tabula first
    try:
        tables = tabula.read_pdf(str(pdf_path), pages='all', multiple_tables=True)
        records = []
        for table in tables:
            # Clean and normalize columns
            table.columns = table.columns.str.strip()
            if 'OEM' in table.columns.str.upper().tolist() or 'Passenger' in table.columns.str.upper().tolist():
                # Convert to dicts, filter sales numbers
                for _, row in table.iterrows():
                    rec = {
                        'oem': str(row.get('OEM', row.get('Manufacturer', ''))).strip(),
                        'passenger_cars': pd.to_numeric(row.get('Passenger Cars', 0), errors='coerce'),
                        'utility_vehicles': pd.to_numeric(row.get('Utility Vehicles', 0), errors='coerce'),
                        'domestic': pd.to_numeric(row.get('Domestic', 0), errors='coerce'),
                        'exports': pd.to_numeric(row.get('Exports', 0), errors='coerce'),
                        'total': pd.to_numeric(row.get('Total', 0), errors='coerce'),
                        'pdf_source': str(pdf_path),
                        'parsed_at': datetime.now().isoformat()
                    }
                    if rec['oem'] and rec['total'] > 0:
                        records.append(rec)
        return records
    except Exception as e:
        print(f"Tabula failed: {e}. Trying Camelot...")
        # Camelot fallback
        try:
            camelot_tables = camelot.read_pdf(str(pdf_path), pages='all')
            # Similar processing...
            return []
        except:
            return []

def discover_siam_pdfs() -> List[str]:
    """Find latest SIAM PDF links."""
    base = "http://www.siam.in/statistics.aspx?mpgid=8&pgidtrail=14"
    resp = requests.get(base)
    soup = BeautifulSoup(resp.text, 'html.parser')
    
    links = []
    for a in soup.find_all('a', href=True):
        href = a['href']
        if 'upload/Reports' in href and href.endswith('.pdf'):
            url = urljoin(base, href)
            links.append(url)
    return links[-12:]  # Last 12 months

def main():
    ensure_output()
    
    pdf_urls = discover_siam_pdfs()
    print(f"Found {len(pdf_urls)} SIAM PDFs")
    
    all_records = []
    for url in pdf_urls:
        month_year = re.search(r'(\w+[- ]\d{4})', os.path.basename(url))
        filename = f"siam_{month_year.group(1).replace(' ', '_')}.pdf" if month_year else f"siam_{int(time.time())}.pdf"
        
        pdf_path = download_pdf(url, filename)
        records = parse_pdf_tables(pdf_path)
        
        for rec in records:
            rec['pdf_url'] = url
            rec['month'] = month_year.group(1) if month_year else 'unknown'
            json.dump(rec, open(SIAM_SALES_JSONL, 'a'), ensure_ascii=False)
            all_records.append(rec)
        
        time.sleep(2)  # Rate limit
    
    print(f"Parsed {len(all_records)} SIAM sales records")
    print(f"JSONL: {SIAM_SALES_JSONL}")

if __name__ == "__main__":
    main()

