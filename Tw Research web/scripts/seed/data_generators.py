"""
Utility generators for synthetic but realistic automotive data.
All randomness is controlled by the provided random.Random instance.
"""

import calendar
import random
from datetime import date, timedelta
from typing import Dict, Iterable, List, Tuple

INDIAN_FIRST_NAMES = [
    "Aarav",
    "Vivaan",
    "Aditya",
    "Kabir",
    "Ishaan",
    "Rohan",
    "Neha",
    "Priya",
    "Aanya",
    "Diya",
    "Isha",
    "Saanvi",
    "Navya",
    "Ananya",
    "Kavya",
]

INDIAN_LAST_NAMES = [
    "Sharma",
    "Verma",
    "Reddy",
    "Nair",
    "Patel",
    "Singh",
    "Gupta",
    "Mehta",
    "Iyer",
    "Chopra",
    "Kulkarni",
    "Pillai",
    "Yadav",
    "Khan",
    "Das",
]

FEATURES_BY_CATEGORY: Dict[str, List[str]] = {
    "Safety": [
        "ABS",
        "EBD",
        "Brake Assist",
        "Traction Control",
        "Electronic Stability Program",
        "Hill Hold Control",
        "Hill Descent Control",
        "Tyre Pressure Monitoring",
        "Rear Parking Sensors",
        "Front Parking Sensors",
        "360 Camera",
        "Rear View Camera",
        "Airbags Driver",
        "Airbags Passenger",
        "Side Airbags",
        "Curtain Airbags",
        "ISOFIX Child Seat Mounts",
        "Engine Immobilizer",
        "Speed Alert",
        "Seatbelt Reminder",
        "Roll Over Mitigation",
        "Cornering Lights",
        "Auto Dimming IRVM",
        "Rain Sensing Wipers",
        "Adaptive Cruise Control",
        "Lane Keep Assist",
        "Blind Spot Monitoring",
        "Rear Cross Traffic Alert",
        "Driver Attention Warning",
        "Tyre Repair Kit",
    ],
    "Comfort": [
        "Auto AC",
        "Rear AC Vents",
        "Heated Seats",
        "Ventilated Seats",
        "Electric Adjust Seats",
        "Lumbar Support",
        "Leather Upholstery",
        "Height Adjustable Driver Seat",
        "Push Button Start",
        "Keyless Entry",
        "Remote Start",
        "Power Windows",
        "One Touch Up",
        "One Touch Down",
        "Sunroof",
        "Panoramic Sunroof",
        "Ambient Lighting",
        "Power Tailgate",
        "Rear Armrest",
        "Front Armrest",
        "Adjustable Steering",
        "Cruise Control",
        "Auto Headlamps",
        "Auto Wipers",
        "Cooled Glovebox",
        "Wireless Charger",
        "Air Purifier",
        "Head Up Display",
        "Heated ORVM",
        "Puddle Lamps",
    ],
    "Infotainment": [
        "Apple CarPlay",
        "Android Auto",
        "Wireless CarPlay",
        "Wireless Android Auto",
        "Touchscreen 7 inch",
        "Touchscreen 8 inch",
        "Touchscreen 10 inch",
        "Touchscreen 12 inch",
        "Navigation",
        "Connected Car Tech",
        "Voice Commands",
        "Steering Controls",
        "Bluetooth Audio",
        "USB Ports",
        "Type C Ports",
        "AM FM Radio",
        "OTA Updates",
        "Inbuilt SIM",
        "Premium Sound 6 Speaker",
        "Premium Sound 8 Speaker",
        "Subwoofer",
        "Equalizer",
        "Rear Screens",
        "Wireless Headphones",
        "12V Socket",
        "SD Card Slot",
        "Digital Keys",
        "Alexa Integration",
        "Android Automotive",
        "Gesture Control",
    ],
    "Exterior": [
        "Alloy Wheels",
        "Diamond Cut Alloys",
        "Steel Wheels",
        "LED Headlamps",
        "Projector Headlamps",
        "LED DRL",
        "LED Tail Lamps",
        "Fog Lamps Front",
        "Fog Lamps Rear",
        "Roof Rails",
        "Shark Fin Antenna",
        "Split Tailgate",
        "Body Cladding",
        "Skid Plates",
        "Chrome Grille",
        "Blackout Package",
        "Dual Tone Paint",
        "ORVM Indicators",
        "Auto Folding ORVM",
        "Cornering Lamps",
        "Wide Tyres",
        "Rear Spoiler",
        "Side Steps",
        "Tow Hook",
        "All Terrain Tyres",
        "Heated Windshield",
        "Rain Visors",
        "Rear Wiper",
        "Defogger",
        "Sun Film",
    ],
    "Tech": [
        "Digital Instrument Cluster",
        "Semi Digital Cluster",
        "Analog Cluster",
        "TPMS Display",
        "ADAS Level 2",
        "ADAS Level 1",
        "Drive Modes",
        "Terrain Modes",
        "Auto Hold",
        "Electronic Parking Brake",
        "360 Proximity Sensors",
        "Telematics",
        "Find My Car",
        "Remote Lock Unlock",
        "Geo Fencing",
        "Valet Mode",
        "Speed Limiter",
        "Wireless Updates",
        "Driver Profiles",
        "Heated Steering",
        "Rear Disc Brakes",
        "Front Ventilated Disc",
        "Start Stop System",
        "Battery Management System",
        "Fast Charging DC",
        "Vehicle To Load",
        "Regenerative Braking",
        "Cornering Stability",
        "Roll Stability Control",
    ],
}

BODY_TYPES = [
    "Hatchback",
    "Sedan",
    "SUV",
    "MUV",
    "Pickup",
    "Truck",
    "Bus",
    "Bike",
    "Scooter",
]

FUEL_TYPES = ["Petrol", "Diesel", "CNG", "Electric", "Hybrid"]

TRANSMISSION_TYPES = ["Manual", "Automatic", "AMT", "CVT", "DCT"]


def random_name(rng: random.Random) -> str:
    return f"{rng.choice(INDIAN_FIRST_NAMES)} {rng.choice(INDIAN_LAST_NAMES)}"


def random_phone(rng: random.Random) -> str:
    start = rng.choice(["9", "8", "7", "6"])
    rest = "".join(str(rng.randint(0, 9)) for _ in range(9))
    return f"+91{start}{rest}"


def random_email(name: str, rng: random.Random) -> str:
    handle = name.lower().replace(" ", ".")
    domain = rng.choice(["example.com", "mailinator.com", "autopredator.dev"])
    return f"{handle}{rng.randint(10,999)}@{domain}"


def base_price_for_body(body_type: str, rng: random.Random) -> int:
    ranges = {
        "Hatchback": (500_000, 900_000),
        "Sedan": (800_000, 1_600_000),
        "SUV": (1_000_000, 2_800_000),
        "MUV": (900_000, 2_000_000),
        "Pickup": (1_200_000, 2_200_000),
        "Truck": (1_800_000, 3_500_000),
        "Bus": (3_000_000, 5_000_000),
        "Bike": (80_000, 250_000),
        "Scooter": (60_000, 120_000),
    }
    low, high = ranges.get(body_type, (700_000, 1_500_000))
    return rng.randint(low, high)


def generate_specs(body_type: str, fuel: str, rng: random.Random) -> Dict[str, object]:
    base_power = {
        "Hatchback": (70, 130),
        "Sedan": (90, 180),
        "SUV": (110, 250),
        "MUV": (100, 180),
        "Pickup": (110, 200),
        "Truck": (140, 260),
        "Bus": (150, 280),
        "Bike": (8, 35),
        "Scooter": (6, 12),
    }
    power_range = base_power.get(body_type, (90, 150))
    power = rng.randint(*power_range)
    torque = int(power * rng.uniform(7.5, 11.5))
    mileage = rng.uniform(12, 22)
    if fuel == "Electric":
        torque = torque * 2
        mileage = rng.uniform(5, 8)  # km/kWh equivalent
    engine_cc = {
        "Bike": rng.randint(110, 450),
        "Scooter": rng.randint(100, 160),
        "Truck": rng.randint(2000, 4500),
        "Bus": rng.randint(2200, 5000),
    }.get(body_type, rng.randint(900, 2000))
    seating = {
        "Hatchback": 5,
        "Sedan": 5,
        "SUV": rng.choice([5, 7]),
        "MUV": rng.choice([6, 7, 8]),
        "Pickup": 5,
        "Truck": rng.choice([2, 3]),
        "Bus": rng.choice([18, 24, 32]),
        "Bike": 2,
        "Scooter": 2,
    }.get(body_type, 5)
    airbags = rng.choice([2, 4, 6]) if body_type not in {"Bike", "Scooter", "Truck", "Bus"} else 0
    dim_map = {
        "Hatchback": (3990, 1740, 1500, 2500),
        "Sedan": (4500, 1750, 1480, 2600),
        "SUV": (4550, 1800, 1690, 2650),
        "MUV": (4600, 1820, 1750, 2700),
        "Pickup": (5200, 1820, 1860, 3100),
        "Truck": (6000, 2200, 2500, 3500),
        "Bus": (7800, 2400, 2900, 4200),
        "Bike": (2100, 780, 1100, 1400),
        "Scooter": (1850, 680, 1150, 1300),
    }
    length_mm, width_mm, height_mm, wheelbase_mm = dim_map.get(body_type, (4400, 1750, 1600, 2600))
    return {
        "engine_cc": engine_cc,
        "power_hp": power,
        "torque_nm": torque,
        "mileage_kmpl": round(mileage, 2),
        "seating": seating,
        "airbags": airbags,
        "length_mm": length_mm,
        "width_mm": width_mm,
        "height_mm": height_mm,
        "wheelbase_mm": wheelbase_mm,
    }


def _add_months(base: date, months: int) -> date:
    month_index = base.month - 1 + months
    year = base.year + month_index // 12
    month = month_index % 12 + 1
    last_day = calendar.monthrange(year, month)[1]
    day = min(base.day, last_day)
    return date(year, month, day)


def price_series(base_price: int, months: int, start_month: date, rng: random.Random) -> List[Tuple[date, float, float]]:
    series = []
    ex_price = float(base_price)
    current = start_month
    for i in range(months):
        # Mild month-over-month drift with occasional jumps
        drift = rng.uniform(0.002, 0.007)
        if rng.random() < 0.08:
            jump = rng.uniform(0.015, 0.04)
            ex_price *= 1 + jump
        else:
            ex_price *= 1 + drift
        on_road_multiplier = rng.uniform(1.08, 1.11)
        series.append((current, round(ex_price, 2), round(ex_price * on_road_multiplier, 2)))
        current = _add_months(start_month, i + 1)
    return series


def listing_price(listing_type: str, base_on_road: float, year: int, km: int, rng: random.Random) -> float:
    current_year = date.today().year
    age = max(0, current_year - year)
    if listing_type == "new":
        return round(base_on_road * rng.uniform(0.98, 1.05), 2)
    depreciation = 0.05 * age + (km / 200000)
    depreciation = min(depreciation, 0.75)
    price = base_on_road * max(0.25, 1 - depreciation)
    return round(price * rng.uniform(0.97, 1.05), 2)


def pick_variant_features(features: List[Tuple[int, str, str]], rng: random.Random) -> Tuple[List[int], List[int]]:
    feature_ids = [f[0] for f in features]
    rng.shuffle(feature_ids)
    count = max(4, int(len(feature_ids) * 0.25))
    picked = feature_ids[:count]
    standard_cutoff = int(len(picked) * 0.6)
    standard = picked[:standard_cutoff]
    optional = picked[standard_cutoff:]
    return standard, optional


def select_transmission(rng: random.Random, fuel: str) -> str:
    weights = {
        "Electric": [0.1, 0.6, 0.0, 0.2, 0.1],
        "CNG": [0.7, 0.15, 0.1, 0.05, 0.0],
        "Petrol": [0.4, 0.3, 0.15, 0.1, 0.05],
        "Diesel": [0.5, 0.3, 0.15, 0.05, 0.0],
        "Hybrid": [0.25, 0.45, 0.0, 0.2, 0.1],
    }
    choices = TRANSMISSION_TYPES
    probs = weights.get(fuel, [0.5, 0.3, 0.1, 0.05, 0.05])
    pick = rng.uniform(0, 1)
    cumulative = 0
    for choice, prob in zip(choices, probs):
        cumulative += prob
        if pick <= cumulative:
            return choice
    return choices[-1]


def select_body_type(rng: random.Random) -> str:
    weights = [0.15, 0.12, 0.22, 0.12, 0.05, 0.05, 0.03, 0.13, 0.13]
    pick = rng.uniform(0, 1)
    cumulative = 0
    for body, prob in zip(BODY_TYPES, weights):
        cumulative += prob
        if pick <= cumulative:
            return body
    return BODY_TYPES[-1]


def feature_catalog() -> List[Dict[str, str]]:
    items: List[Dict[str, str]] = []
    for category, names in FEATURES_BY_CATEGORY.items():
        for name in names:
            items.append({"category": category, "name": name})
    return items
