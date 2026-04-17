# cleaner.py

import pandas as pd
import re

# -----------------------------
# LOAD FILE
# -----------------------------
FILE_PATH = "Autopredator DB rough.xlsx"

df = pd.read_excel(FILE_PATH)

# -----------------------------
# BASIC CLEANING
# -----------------------------

# Remove fully empty rows
df = df.dropna(how="all")

# Normalize column names
df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")

# Forward fill model & variant (important for your structure)
for col in ["model_name", "variant", "sub_variant"]:
    if col in df.columns:
        df[col] = df[col].fillna(method="ffill")

# Remove duplicates
df = df.drop_duplicates()

# -----------------------------
# CLEAN FUNCTIONS
# -----------------------------

def clean_price(x):
    if pd.isna(x):
        return None
    x = str(x)
    x = x.replace("₹", "").replace(",", "").strip()

    if "L" in x:
        return float(x.replace("L", "").strip()) * 100000
    return None


def clean_engine(x):
    if pd.isna(x):
        return None
    x = str(x)

    if "cc" in x:
        return float(re.sub(r"[^\d.]", "", x))
    if "L" in x:
        return float(re.sub(r"[^\d.]", "", x)) * 1000

    return None


def clean_mileage(x):
    if pd.isna(x):
        return None
    x = str(x)
    x = x.replace("kmpl", "").replace("km/kg", "").replace("~", "")
    try:
        return float(re.findall(r"\d+\.?\d*", x)[0])
    except:
        return None


def clean_power(x):
    if pd.isna(x):
        return None
    x = str(x)
    try:
        return float(re.findall(r"\d+\.?\d*", x)[0])
    except:
        return None


def clean_torque(x):
    if pd.isna(x):
        return None
    x = str(x)
    try:
        return float(re.findall(r"\d+\.?\d*", x)[0])
    except:
        return None


# -----------------------------
# APPLY CLEANING
# -----------------------------

if "price" in df.columns:
    df["price"] = df["price"].apply(clean_price)

if "engine" in df.columns:
    df["engine_cc"] = df["engine"].apply(clean_engine)

if "mileage" in df.columns:
    df["mileage"] = df["mileage"].apply(clean_mileage)

if "power" in df.columns:
    df["power_bhp"] = df["power"].apply(clean_power)

if "torque" in df.columns:
    df["torque_nm"] = df["torque"].apply(clean_torque)

# -----------------------------
# STANDARDIZE TEXT
# -----------------------------

def normalize_transmission(x):
    if pd.isna(x):
        return None
    x = str(x).lower()

    if "amt" in x:
        return "AMT"
    if "manual" in x or "mt" in x:
        return "Manual"
    if "cvt" in x:
        return "CVT"
    if "at" in x or "automatic" in x:
        return "Automatic"

    return x


def normalize_fuel(x):
    if pd.isna(x):
        return None
    x = str(x).lower()

    if "cng" in x:
        return "CNG"
    if "electric" in x:
        return "Electric"
    if "hybrid" in x:
        return "Hybrid"
    if "petrol" in x:
        return "Petrol"

    return x


df["transmission"] = df.get("transmission", "").apply(normalize_transmission)
df["fuel"] = df.get("fuel_type", "").apply(normalize_fuel)

# -----------------------------
# SPLIT MULTIPLE FUELS
# -----------------------------

df = df.assign(fuel=df["fuel"].astype(str).str.split("/")).explode("fuel")

# -----------------------------
# FINAL STRUCTURE
# -----------------------------

final_df = df[[
    "model_name",
    "variant",
    "sub_variant",
    "fuel",
    "transmission",
    "drivetrain",
    "engine_cc",
    "power_bhp",
    "torque_nm",
    "mileage",
    "price"
]].rename(columns={
    "model_name": "model"
})

# Drop empty essential rows
final_df = final_df.dropna(subset=["model", "variant"])

# -----------------------------
# SORT DATA
# -----------------------------

final_df = final_df.sort_values(by=["model", "price"])

# -----------------------------
# SAVE OUTPUT
# -----------------------------

final_df.to_csv("cleaned_cars.csv", index=False)
final_df.to_json("cleaned_cars.json", orient="records", indent=4)

print("✅ Cleaning complete!")
print(f"Total rows: {len(final_df)}")s