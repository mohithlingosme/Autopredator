<?php include 'config_insurancePremiumcalsi.php'; $cars = fetchAllCarData(); ?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Insurance Premium Calculator</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #f7f9fc;
      padding: 40px;
      margin: 0;
    }
    .container {
      max-width: 700px;
      margin: auto;
      background: white;
      padding: 30px 40px;
      border-radius: 12px;
      box-shadow: 0 0 20px rgba(0,0,0,0.1);
    }
    h1 {
      text-align: center;
      color: #333;
      margin-bottom: 30px;
    }
    form {
      display: flex;
      flex-direction: column;
      gap: 15px;
    }
    select, input {
      padding: 12px;
      font-size: 16px;
      border: 1px solid #ccc;
      border-radius: 8px;
    }
    label {
      font-weight: 600;
      color: #555;
    }
    button {
      background: #007bff;
      color: white;
      padding: 14px;
      font-size: 16px;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      margin-top: 10px;
    }
    button:hover {
      background: #0056b3;
    }
    #result {
      margin-top: 30px;
      background: #e7f7ed;
      padding: 20px;
      border-left: 6px solid #28a745;
      border-radius: 8px;
    }
  </style>
</head>
<body>
<div class="container">
  <h1>Insurance Premium Calculator</h1>

  <form id="insuranceForm">
    <label for="make">Make</label>
    <select id="make" onchange="loadModels()" required>
      <option value="">Select Make</option>
    </select>

    <label for="model">Model</label>
    <select id="model" onchange="loadVariants()" required>
      <option value="">Select Model</option>
    </select>

    <label for="variant">Variant</label>
    <select id="variant" onchange="prefillDetails()" required>
      <option value="">Select Variant</option>
    </select>

    <label>Ex-Showroom Price (₹)</label>
    <input type="text" id="price" readonly />

    <label>IDV (₹)</label>
    <input type="number" id="idv" readonly />

    <label>Policy Type</label>
    <select id="policyType">
      <option value="comprehensive">Comprehensive</option>
      <option value="third-party">Third-Party</option>
    </select>

    <label>No Claim Bonus (NCB %)</label>
    <input type="number" id="ncb" value="0" min="0" max="50" />

    <label><input type="checkbox" name="addons" value="zeroDep" /> Zero Depreciation</label>
    <label><input type="checkbox" name="addons" value="rsa" /> Roadside Assistance</label>

    <button type="button" onclick="calculatePremium()">Calculate Premium</button>
  </form>

  <div id="result"></div>
</div>

<script>
  const rawCars = <?= json_encode($cars); ?>;
  let structuredData = {};

  function buildNestedData() {
    rawCars.forEach(car => {
      const make = car.Make;
      const model = car.Model;
      const variant = car.Variant;
      const price = parseInt(car.Ex_Showroom_Price);

      if (!structuredData[make]) structuredData[make] = {};
      if (!structuredData[make][model]) structuredData[make][model] = {};
      structuredData[make][model][variant] = {
        price: price,
        idv: Math.floor(price * 0.95)
      };
    });

    const makeSelect = document.getElementById("make");
    Object.keys(structuredData).forEach(make => {
      makeSelect.innerHTML += `<option value="${make}">${make}</option>`;
    });
  }

  function loadModels() {
    const make = document.getElementById("make").value;
    const modelSelect = document.getElementById("model");
    const variantSelect = document.getElementById("variant");
    modelSelect.innerHTML = `<option value="">Select Model</option>`;
    variantSelect.innerHTML = `<option value="">Select Variant</option>`;

    if (structuredData[make]) {
      Object.keys(structuredData[make]).forEach(model => {
        modelSelect.innerHTML += `<option value="${model}">${model}</option>`;
      });
    }
  }

  function loadVariants() {
    const make = document.getElementById("make").value;
    const model = document.getElementById("model").value;
    const variantSelect = document.getElementById("variant");
    variantSelect.innerHTML = `<option value="">Select Variant</option>`;

    if (structuredData[make]?.[model]) {
      Object.keys(structuredData[make][model]).forEach(variant => {
        variantSelect.innerHTML += `<option value="${variant}">${variant}</option>`;
      });
    }
  }

  function prefillDetails() {
    const make = document.getElementById("make").value;
    const model = document.getElementById("model").value;
    const variant = document.getElementById("variant").value;

    if (structuredData[make]?.[model]?.[variant]) {
      const details = structuredData[make][model][variant];
      document.getElementById("price").value = `₹${details.price.toLocaleString("en-IN")}`;
      document.getElementById("idv").value = details.idv;
    }
  }

  function getThirdPartyPremium() {
    return 5000; // Fixed
  }

  function calculatePremium() {
    const idv = parseFloat(document.getElementById("idv").value);
    const ncb = parseFloat(document.getElementById("ncb").value) || 0;
    const policyType = document.getElementById("policyType").value;
    const addons = document.querySelectorAll("input[name='addons']:checked");
    const addonCost = addons.length * 500;

    const baseRate = 0.03;
    const depreciation = 0.2;
    const odPremium = idv * baseRate * (1 - depreciation);
    const ncbDiscount = odPremium * (ncb / 100);
    const netOD = odPremium - ncbDiscount;
    const tpPremium = getThirdPartyPremium();

    const total = policyType === "third-party" ? tpPremium : tpPremium + netOD + addonCost;

    document.getElementById("result").innerHTML = `
      <h3>Premium Estimate:</h3>
      <p><strong>Own Damage Premium:</strong> ₹${netOD.toFixed(2)}</p>
      <p><strong>Third-Party Premium:</strong> ₹${tpPremium}</p>
      <p><strong>Add-on Cost:</strong> ₹${addonCost}</p>
      <hr />
      <p><strong>Total Premium:</strong> ₹${total.toFixed(2)}</p>
    `;
  }

  buildNestedData();
</script>
</body>
</html>
