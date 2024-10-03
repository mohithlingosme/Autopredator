const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Database connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'yourpassword',
    database: 'car_research'
});

db.connect(err => {
    if (err) {
        console.error('Error connecting to database:', err);
    } else {
        console.log('Connected to the database');
    }
});

// Sample API to get cars
app.get('/api/cars', (req, res) => {
    const sql = 'SELECT * FROM cars';
    db.query(sql, (err, result) => {
        if (err) {
            return res.status(500).send(err);
        }
        res.json(result);
    });
});

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
