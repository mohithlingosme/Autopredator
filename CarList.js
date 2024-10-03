import React, { useState, useEffect } from 'react';
import axios from 'axios';

const CarList = () => {
    const [cars, setCars] = useState([]);

    useEffect(() => {
        axios.get('http://localhost:5000/api/cars')
            .then(response => {
                setCars(response.data);
            })
            .catch(error => {
                console.error('There was an error fetching the cars!', error);
            });
    }, []);

    return (
        <div>
            <h1>Car List</h1>
            <ul>
                {cars.map(car => (
                    <li key={car.car_id}>
                        {car.make} {car.model} ({car.year}) - ${car.price}
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default CarList;
