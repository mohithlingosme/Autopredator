import asyncio
import json
import re
from playwright.async_api import async_playwright

URL = "https://www.carwale.com/find-car/results/?carMakeIds=10%2C16%2C9%2C8%2C17%2C70%2C15%2C1%2C49%2C18%2C22%2C111%2C74%2C33%2C50%2C7%2C61%2C44%2C43%2C30%2C23%2C34%2C123%2C36%2C77%2C11%2C72%2C51%2C21%2C19%2C45%2C25%2C73%2C155%2C20%2C37"

# -------------------------
# CLEAN TEXT
# -------------------------
def clean(text):
    if not text:
        return ""
    return re.sub(r"\s+", " ", text).strip()

# -------------------------
# EXTRACT DATA FROM CARD
# -------------------------
def parse_card(text):
    text = clean(text)

    # PRICE
    price = ""
    m = re.search(r"Rs\.\s?[\d.,]+\s?(Lakh|Crore)", text)
    if m:
        price = m.group(0)

    # ENGINE
    engine = ""
    m = re.search(r"\d{3,4}\s?cc", text)
    if m:
        engine = m.group(0)

    # POWER
    power = ""
    m = re.search(r"\d+\s?bhp", text)
    if m:
        power = m.group(0)

    # FUEL
    fuel = ""
    if "Petrol" in text:
        fuel = "Petrol"
    elif "Diesel" in text:
        fuel = "Diesel"
    elif "Electric" in text:
        fuel = "Electric"
    elif "Hybrid" in text:
        fuel = "Hybrid"

    # TRANSMISSION
    transmission = ""
    if "Manual" in text:
        transmission = "Manual"
    elif "Automatic" in text:
        transmission = "Automatic"

    return {
        "price": price,
        "engine": engine,
        "power": power,
        "fuel": fuel,
        "transmission": transmission
    }

# -------------------------
# MAIN SCRAPER
# -------------------------
async def scrape():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()

        await page.goto(URL, wait_until="domcontentloaded", timeout=60000)

        # scroll to load all cars
        for _ in range(10):
            await page.mouse.wheel(0, 5000)
            await page.wait_for_timeout(1000)

        cards = await page.query_selector_all("div[data-testid='car-card']")

        print(f"Cars found: {len(cards)}")

        results = []

        for c in cards:
            text = clean(await c.inner_text())

            if not text:
                continue

            lines = text.split("\n")

            # BASIC EXTRACTION
            brand_model = lines[0] if len(lines) > 0 else ""
            variant = lines[1] if len(lines) > 1 else ""

            parsed = parse_card(text)

            results.append({
                "brand_model": brand_model,
                "variant": variant,
                "fuel_type": parsed["fuel"],
                "transmission": parsed["transmission"],
                "engine_cc": parsed["engine"],
                "power": parsed["power"],
                "torque": "",
                "dual_tone": "",
                "price_ex_showroom": parsed["price"]
            })

        await browser.close()
        return results

# -------------------------
# RUN
# -------------------------
if __name__ == "__main__":
    data = asyncio.run(scrape())

    with open("cars_clean.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ DONE: {len(data)} cars")