from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager
import pandas as pd
import time
import random
import json


class VahanUltimateScraper:
    URL = "https://vahan.parivahan.gov.in/vahan4dashboard/vahan/view/reportview.xhtml"

    def __init__(self, headless=False):
        options = webdriver.ChromeOptions()

        if headless:
            options.add_argument("--headless=new")

        options.add_argument("--start-maximized")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")

        options.add_experimental_option(
            "excludeSwitches",
            ["enable-automation"]
        )

        options.add_experimental_option(
            "useAutomationExtension",
            False
        )

        self.driver = webdriver.Chrome(
            service=Service(ChromeDriverManager().install()),
            options=options
        )

        self.wait = WebDriverWait(self.driver, 60)

    # ===============================
    # DASHBOARD LOAD
    # ===============================
    def load_dashboard(self):
        self.driver.get(self.URL)

        self.wait.until(
            lambda d: d.execute_script(
                "return document.readyState"
            ) == "complete"
        )

        time.sleep(8)

        print("Dashboard fully loaded.")

    # ===============================
    # GET STATES
    # ===============================
    def get_states(self):
        states = self.driver.execute_script("""
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

        print(f"Loaded {len(states)} states.")
        return states

    # ===============================
    # GENERIC DROPDOWN
    # ===============================
    def set_dropdown_value(self, element_id, value):
        self.driver.execute_script(f"""
            let el = document.getElementById('{element_id}');

            if (el) {{
                el.value = '{value}';

                el.dispatchEvent(
                    new Event(
                        'change',
                        {{ bubbles: true }}
                    )
                );
            }}
        """)

    # ===============================
    # STATE SELECTION
    # ===============================
    def select_state(self, state_code):
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

        time.sleep(6)

    # ===============================
    # DASHBOARD CONFIG
    # ===============================
    def configure_dashboard(self, state_code):
        # Actual values
        self.set_dropdown_value("j_idt30_input", "A")

        # State
        self.select_state(state_code)

        # All RTO
        self.set_dropdown_value("selectedRto_input", "-1")

        # Calendar Year
        self.set_dropdown_value("selectedYearType_input", "C")

        # Latest year
        self.driver.execute_script("""
            let year = document.getElementById('selectedYear_input');

            if (year) {
                let preferred = ['2026', '2025', 'Till Today'];

                for (let p of preferred) {
                    for (let i = 0; i < year.options.length; i++) {
                        if (
                            year.options[i].text.trim() === p
                        ) {
                            year.value = year.options[i].value;
                            return;
                        }
                    }
                }
            }
        """)

        # Y Axis
        self.driver.execute_script("""
            let y = document.getElementById('yaxisVar_input');

            if (y) {
                for (let i = 0; i < y.options.length; i++) {
                    if (
                        y.options[i].text.includes(
                            'Vehicle Class'
                        )
                    ) {
                        y.value = y.options[i].value;
                        break;
                    }
                }
            }
        """)

        # X Axis
        self.driver.execute_script("""
            let x = document.getElementById('xaxisVar_input');

            if (x) {
                for (let i = 0; i < x.options.length; i++) {
                    if (
                        x.options[i].text.includes(
                            'Vehicle Category Group'
                        )
                    ) {
                        x.value = x.options[i].value;
                        break;
                    }
                }
            }
        """)

        time.sleep(4)

    # ===============================
    # REFRESH
    # ===============================
    def refresh_dashboard(self):
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

        time.sleep(10)

    # ===============================
    # TABLE EXTRACTION
    # ===============================
    def extract_table(self):
        rows = self.driver.execute_script("""
            let panel = document.getElementById('combTablePnl');

            if (!panel) return [];

            let tables = panel.getElementsByTagName('table');
            let data = [];

            for (let table of tables) {
                let trs = table.getElementsByTagName('tr');

                for (let tr of trs) {
                    let cells = tr.querySelectorAll('th, td');
                    let row = [];

                    for (let cell of cells) {
                        let txt = cell.innerText.trim();

                        if (txt) {
                            row.push(txt);
                        }
                    }

                    if (row.length > 1) {
                        let joined = row.join(" ").toLowerCase();

                        if (
                            joined.startsWith("s no") ||
                            joined.startsWith("4wic") ||
                            joined.includes(
                                "vehicle class vehicle category"
                            )
                        ) {
                            continue;
                        }

                        data.push(row);
                    }
                }
            }

            return data;
        """)

        # Remove duplicates
        cleaned = []
        seen = set()

        for row in rows:
            t = tuple(row)

            if t not in seen:
                seen.add(t)
                cleaned.append(row)

        return cleaned

    # ===============================
    # RETRY
    # ===============================
    def retry_state_if_incomplete(
        self,
        state_code,
        state_name,
        rows
    ):
        if len(rows) >= 3:
            return rows

        print(f"Incomplete data for {state_name}, retrying...")

        self.driver.refresh()

        time.sleep(10)

        self.configure_dashboard(state_code)

        self.refresh_dashboard()

        return self.extract_table()

    # ===============================
    # JSON STRUCTURE
    # ===============================
    def rows_to_json_records(
        self,
        rows,
        state_code,
        state_name
    ):
        records = []

        for row in rows:
            record = {
                "serial_no": row[0] if len(row) > 0 else None,
                "vehicle_class": row[1] if len(row) > 1 else None,
                "vehicle_category_group": {
                    "2WIC": row[2] if len(row) > 2 else None,
                    "LMV": row[3] if len(row) > 3 else None,
                    "MMV": row[4] if len(row) > 4 else None,
                    "HMV": row[5] if len(row) > 5 else None,
                    "TOTAL": row[6] if len(row) > 6 else None
                },
                "state_metadata": {
                    "state_code": state_code,
                    "state_name": state_name
                },
                "scrape_metadata": {
                    "scraped_at": pd.Timestamp.now().isoformat(),
                    "source": self.URL
                }
            }

            records.append(record)

        return records

    # ===============================
    # STATE SCRAPE
    # ===============================
    def scrape_state(self, state_code, state_name):
        print(f"Scraping {state_name}...")

        try:
            self.configure_dashboard(state_code)

            self.refresh_dashboard()

            rows = self.extract_table()

            rows = self.retry_state_if_incomplete(
                state_code,
                state_name,
                rows
            )

            if not rows:
                print(f"No data for {state_name}")
                return []

            records = self.rows_to_json_records(
                rows,
                state_code,
                state_name
            )

            print(
                f"Collected {len(records)} rows for {state_name}"
            )

            return records

        except Exception as e:
            print(f"Failed {state_name}: {e}")
            return []

    # ===============================
    # SAVE LIVE
    # ===============================
    def save_live_json(self, all_data):
        with open(
            "vahan_vehicle_registration_live.json",
            "w",
            encoding="utf-8"
        ) as f:
            json.dump(
                {
                    "metadata": {
                        "source": self.URL,
                        "record_count": len(all_data),
                        "last_updated": pd.Timestamp.now().isoformat()
                    },
                    "data": all_data
                },
                f,
                indent=4,
                ensure_ascii=False
            )

    # ===============================
    # SAVE FINAL
    # ===============================
    def save_final_json(self, all_data):
        with open(
            "vahan_vehicle_registration_final.json",
            "w",
            encoding="utf-8"
        ) as f:
            json.dump(
                {
                    "metadata": {
                        "project": "Autopredator",
                        "dataset": "VAHAN National Vehicle Registration",
                        "source": self.URL,
                        "total_records": len(all_data),
                        "generated_at": pd.Timestamp.now().isoformat(),
                        "format_version": "1.0"
                    },
                    "data": all_data
                },
                f,
                indent=4,
                ensure_ascii=False
            )

    # ===============================
    # MAIN LOOP
    # ===============================
    def scrape_all_states(self):
        self.load_dashboard()

        states = self.get_states()

        all_data = []

        for idx, (code, name) in enumerate(states):
            state_data = self.scrape_state(code, name)

            if state_data:
                all_data.extend(state_data)

                self.save_live_json(all_data)

            # Periodic refresh
            if idx > 0 and idx % 5 == 0:
                self.driver.refresh()
                time.sleep(10)

            time.sleep(
                random.uniform(4, 7)
            )

        if all_data:
            self.save_final_json(all_data)

            print(
                f"SUCCESS: {len(all_data)} structured JSON records collected."
            )

            return all_data

        print("No data collected.")
        return []

    # ===============================
    # CLOSE
    # ===============================
    def close(self):
        self.driver.quit()


if __name__ == "__main__":
    scraper = VahanUltimateScraper(headless=False)

    try:
        scraper.scrape_all_states()
    finally:
        scraper.close()


