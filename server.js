// server.js

const express = require('express');   // Import Express (a framework to create web servers)
const app = express();                // Create an Express app
const port = process.env.PORT || 5000; // Set the port, Railway will set the PORT automatically when deployed

// Create a route for /api/cars
app.get('/api/cars', (req, res) => {
    // This sends back a list of cars in JSON format
    res.json([
        { id: 1, make: 'Toyota', model: 'Camry', year: 2021 },
        { id: 2, make: 'Honda', model: 'Civic', year: 2020 },
        { id: 3, make: 'Tesla', model: 'Model S', year: 2022 }
    ]);
});

// Start the server and listen on the specified port
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
