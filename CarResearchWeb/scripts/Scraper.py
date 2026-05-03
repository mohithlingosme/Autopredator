import os
import json
import time
import random
import logging
import requests
from datetime import datetime
from urllib.parse import urljoin

from bs4 import BeautifulSoup
from tqdm import tqdm
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager


# =====================================================
# CONFIG
# =====================================================
BASE_PORTAL = "https://parivahan.gov.in/"
VAHAN_DASHBOARD = "https://vahan.parivahan.gov.in/vahan4dashboard/vahan/view/reportview.xhtml"
ANALYTICS_PORTAL = "https://analytics.parivahan.gov.in/"
HOMOLOGATION_URL = "https://parivahan.gov.in/parivahan//en/content/homologation"
PUCC_URL = "https://analytics.parivahan.gov.in/analytics/publicview/#/pucdashboard"
ATS_URL = "https://analytics.parivahan.gov.in/analytics/atsdashboard"

OUTPUT_DIR = "output"
LOG_DIR = "logs"

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(LOG_DIR, exist_ok=True)

logging.basicConfig(
    filename=os.path.join(LOG_DIR, "public_scraper.log"),
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)


# =====================================================
# MAIN SCRAPER
# =====================================================
class PublicParivahanScraper:
    def __init__(self, headless=False):
        options = webdriver.ChromeOptions()

        if headless:
            options.add_argument("--headless=new")

        options.add_argument("--start-maximized")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")

        self.driver = webdriver.Chrome(
            service=Service(ChromeDriverManager().install()),
            options=options
        )

        self.wait = WebDriverWait(self.driver, 60)

        self.session = requests.Session()

        self.master = {
            "metadata": {
                "project": "Autopredator",
                "dataset_type": "Public Only Parivahan",
                "created_at": datetime.now().isoformat(),
                "legal_mode": True
            },
            "vahan_dashboard": [],
            "analytics_dashboard": [],
            "homologation": [],
            "pucc": [],
            "fitness_ats": [],
            "trade_certificates": [],
            "recalls": [],
            "scrappage": [],
            "policies": [],
            "public_forms": [],
            "state_links": [],
            "supporting_services": []
        }

    # =================================================
    # GENERIC HTML FETCH
    # =================================================
    def fetch_html(self, url):
        try:
            response = self.session.get(
                url,
                timeout=30,
                headers={
                    "User-Agent": (
                        "Mozilla/5.0"
                    )
                }
            )

            if response.status_code == 200:
                return response.text

        except Exception as e:
            logging.error(f"{url} failed: {e}")

        return None

    # =================================================
    # MAIN PORTAL
    # =================================================
    def scrape_main_portal(self):
        html = self.fetch_html(BASE_PORTAL)

        if not html:
            return

        soup = BeautifulSoup(html, "html.parser")

        links = soup.find_all("a", href=True)

        for link in links:
            text = link.get_text(" ", strip=True)
            href = link["href"]

            if not text:
                continue

            full_url = urljoin(BASE_PORTAL, href)

            if any(
                restricted in text.lower()
                for restricted in [
                    "login",
                    "otp",
                    "know your vehicle",
                    "know your license",
                    "nr services"
                ]
            ):
                continue

            record = {
                "name": text,
                "url": full_url,
                "scraped_at": datetime.now().isoformat()
            }

            if "policy" in text.lower():
                self.master["policies"].append(record)

            elif "form" in text.lower():
                self.master["public_forms"].append(record)

            elif "recall" in text.lower():
                self.master["recalls"].append(record)

            elif "scrapp" in text.lower():
                self.master["scrappage"].append(record)

            elif "trade" in text.lower():
                self.master["trade_certificates"].append(record)

            else:
                self.master["supporting_services"].append(record)

    # =================================================
    # ANALYTICS DASHBOARD
    # =================================================
    def scrape_analytics_dashboard(self):
        html = self.fetch_html(ANALYTICS_PORTAL)

        if not html:
            return

        soup = BeautifulSoup(html, "html.parser")

        texts = soup.get_text("\n", strip=True)

        self.master["analytics_dashboard"].append({
            "content": texts[:50000],
            "source": ANALYTICS_PORTAL,
            "scraped_at": datetime.now().isoformat()
        })

    # =================================================
    # HOMOLOGATION
    # =================================================
    def scrape_homologation(self):
        html = self.fetch_html(HOMOLOGATION_URL)

        if html:
            soup = BeautifulSoup(html, "html.parser")

            self.master["homologation"].append({
                "content": soup.get_text(
                    "\n",
                    strip=True
                )[:50000],
                "source": HOMOLOGATION_URL,
                "scraped_at": datetime.now().isoformat()
            })

    # =================================================
    # PUCC
    # =================================================
    def scrape_pucc(self):
        html = self.fetch_html(PUCC_URL)

        if html:
            self.master["pucc"].append({
                "content": html[:50000],
                "source": PUCC_URL,
                "scraped_at": datetime.now().isoformat()
            })

    # =================================================
    # FITNESS ATS
    # =================================================
    def scrape_ats(self):
        html = self.fetch_html(ATS_URL)

        if html:
            self.master["fitness_ats"].append({
                "content": html[:50000],
                "source": ATS_URL,
                "scraped_at": datetime.now().isoformat()
            })

    # =================================================
    # VAHAN DASHBOARD
    # =================================================
    def load_vahan_dashboard(self):
        self.driver.get(VAHAN_DASHBOARD)

        self.wait.until(
            lambda d: d.execute_script(
                "return document.readyState"
            ) == "complete"
        )

        time.sleep(8)

    def get_states(self):
        return self.driver.execute_script("""
            let dropdown = document.getElementById('j_idt40_input');
            let states = [];

            if (!dropdown) return [];

            for (let i = 0; i < dropdown.options.length; i++) {
                let opt = dropdown.options[i];

                if (
                    opt.value &&
                    opt.value !== '-1' &&
                    opt.text.trim()
                ) {
                    states.push([
                        opt.value,
                        opt.text.trim()
                    ]);
                }
            }

            return states;
        """)

    def scrape_vahan_dashboard(self):
        self.load_vahan_dashboard()

        states = self.get_states()

        y_axes = [
            "Vehicle Class",
            "Vehicle Category",
            "Maker",
            "Fuel",
            "Norms",
            "State"
        ]

        for state_code, state_name in tqdm(
            states,
            desc="Public VAHAN"
        ):
            for y_axis in y_axes:
                try:
                    # Select state
                    self.driver.execute_script(f"""
                        let state = document.getElementById('j_idt40_input');

                        if (state) {{
                            state.value = '{state_code}';

                            if (typeof PrimeFaces !== 'undefined') {{
                                PrimeFaces.ab({{
                                    s:'j_idt40',
                                    e:'change',
                                    f:'masterLayout_formlogin',
                                    p:'j_idt40',
                                    u:'selectedRto yaxisVar xaxisVar selectedYear'
                                }});
                            }}
                        }}
                    """)

                    time.sleep(4)

                    # Set Y axis
                    self.driver.execute_script(f"""
                        let y = document.getElementById('yaxisVar_input');

                        if (y) {{
                            for (
                                let i = 0;
                                i < y.options.length;
                                i++
                            ) {{
                                if (
                                    y.options[i].text.includes('{y_axis}')
                                ) {{
                                    y.value = y.options[i].value;
                                    break;
                                }}
                            }}
                        }}
                    """)

                    time.sleep(3)

                    # Refresh
                    self.driver.execute_script("""
                        if (typeof PrimeFaces !== 'undefined') {
                            PrimeFaces.ab({
                                s:'j_idt71',
                                f:'masterLayout_formlogin',
                                p:'masterLayout_formlogin',
                                u:'combTablePnl groupingTable'
                            });
                        }
                    """)

                    time.sleep(8)

                    rows = self.driver.execute_script("""
                        let panel = document.getElementById(
                            'combTablePnl'
                        );

                        if (!panel) return [];

                        let tables = panel.getElementsByTagName(
                            'table'
                        );

                        let data = [];

                        for (let table of tables) {
                            let trs = table.getElementsByTagName(
                                'tr'
                            );

                            for (let tr of trs) {
                                let cells = tr.querySelectorAll(
                                    'th, td'
                                );

                                let row = [];

                                for (let cell of cells) {
                                    let txt = cell.innerText.trim();

                                    if (txt) row.push(txt);
                                }

                                if (row.length > 1) {
                                    data.push(row);
                                }
                            }
                        }

                        return data;
                    """)

                    for row in rows:
                        self.master["vahan_dashboard"].append({
                            "state": state_name,
                            "state_code": state_code,
                            "dimension": y_axis,
                            "row": row,
                            "scraped_at": datetime.now().isoformat()
                        })

                except Exception as e:
                    logging.error(
                        f"{state_name} | {y_axis}: {e}"
                    )

            time.sleep(
                random.uniform(2, 5)
            )

    # =================================================
    # STATE PUBLIC LINKS
    # =================================================
    def add_state_links(self):
        portals = [
            "https://transport.telangana.gov.in/",
            "https://www.aptransport.org/",
            "https://odishatransport.gov.in/"
        ]

        for portal in portals:
            self.master["state_links"].append({
                "portal": portal,
                "scraped_at": datetime.now().isoformat()
            })

    # =================================================
    # SAVE
    # =================================================
    def save_output(self):
        with open(
            os.path.join(
                OUTPUT_DIR,
                "autopredator_public_master.json"
            ),
            "w",
            encoding="utf-8"
        ) as f:
            json.dump(
                self.master,
                f,
                indent=2,
                ensure_ascii=False
            )

    # =================================================
    # RUN
    # =================================================
    def run(self):
        logging.info("Starting public-only scrape...")

        self.scrape_main_portal()
        self.scrape_analytics_dashboard()
        self.scrape_homologation()
        self.scrape_pucc()
        self.scrape_ats()
        self.scrape_vahan_dashboard()
        self.add_state_links()

        self.save_output()

        logging.info("Completed.")

    # =================================================
    # CLOSE
    # =================================================
    def close(self):
        self.driver.quit()


# =====================================================
# EXECUTION
# =====================================================
if __name__ == "__main__":
    scraper = PublicParivahanScraper(headless=False)

    try:
        scraper.run()
    finally:
        scraper.close()
