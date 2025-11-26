<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Vehicle Documentation</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            margin: 0;
            padding: 0;
        }

        header {
            background-color: #004aad;
            color: white;
            padding: 20px;
            text-align: center;
        }

        .container {
            max-width: 900px;
            margin: 40px auto;
            background: white;
            padding: 30px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        h2 {
            color: #004aad;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }

        .doc-section {
            margin-bottom: 25px;
        }

        label {
            font-weight: bold;
            display: block;
            margin-bottom: 5px;
        }

        input[type="text"], input[type="date"], select, input[type="file"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .submit-btn {
            background: #004aad;
            color: white;
            border: none;
            padding: 12px 25px;
            font-size: 16px;
            cursor: pointer;
            border-radius: 4px;
        }

        .submit-btn:hover {
            background: #00337a;
        }
    </style>
</head>
<body>

<header>
    <h1>Vehicle Documentation</h1>
</header>

<div class="container">
    <h2>Upload Vehicle Documents</h2>
    <form action="/upload" method="post" enctype="multipart/form-data">
        <div class="doc-section">
            <label for="vehicle-number">Vehicle Registration Number</label>
            <input type="text" id="vehicle-number" name="vehicle-number" required>
        </div>

        <div class="doc-section">
            <label for="owner-name">Owner's Name</label>
            <input type="text" id="owner-name" name="owner-name" required>
        </div>

        <div class="doc-section">
            <label for="reg-doc">Registration Certificate (RC)</label>
            <input type="file" id="reg-doc" name="reg-doc" accept=".pdf,.jpg,.png" required>
        </div>

        <div class="doc-section">
            <label for="insurance-doc">Insurance Document</label>
            <input type="file" id="insurance-doc" name="insurance-doc" accept=".pdf,.jpg,.png" required>
        </div>

        <div class="doc-section">
            <label for="pollution-doc">Pollution Certificate</label>
            <input type="file" id="pollution-doc" name="pollution-doc" accept=".pdf,.jpg,.png">
        </div>

        <div class="doc-section">
            <label for="expiry-date">Document Expiry Date</label>
            <input type="date" id="expiry-date" name="expiry-date">
        </div>

        <button type="submit" class="submit-btn">Submit Documents</button>
    </form>
</div>

</body>
</html>
