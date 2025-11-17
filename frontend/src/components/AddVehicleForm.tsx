'use client';

import { AxiosError } from 'axios';
import { FormEvent, useState } from 'react';

import apiClient from '@/lib/api';

const vehicleTypes = ['Car', 'Truck', 'Tractor', 'Bus', 'Utility', 'Other'];
const fuelTypes = ['Petrol', 'Diesel', 'CNG', 'LPG', 'EV', 'Hybrid'];

export default function AddVehicleForm() {
  const [vin, setVin] = useState('');
  const [make, setMake] = useState('');
  const [model, setModel] = useState('');
  const [year, setYear] = useState('');
  const [mileage, setMileage] = useState('');
  const [vehicleType, setVehicleType] = useState(vehicleTypes[0]);
  const [fuelType, setFuelType] = useState(fuelTypes[0]);
  const [documents, setDocuments] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleDocumentChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setDocuments(event.target.files?.[0] ?? null);
  };

  const handleSubmit = async (event: FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);

    const formData = new FormData();
    formData.append('vin', vin);
    formData.append('make', make);
    formData.append('model', model);
    formData.append('year', year);
    formData.append('mileage', mileage);
    formData.append('vehicle_type', vehicleType);
    formData.append('fuel_type', fuelType);
    if (documents) {
      formData.append('registration', documents);
    }

    try {
      await apiClient.post('/vehicles/', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      setMessage('Vehicle added successfully. The fleet will update in a few moments.');
      setVin('');
      setMake('');
      setModel('');
      setYear('');
      setMileage('');
      setDocuments(null);
    } catch (err) {
      const message =
        err instanceof AxiosError && err.response?.data?.detail
          ? err.response.data.detail
          : 'Unable to add vehicle right now.';
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="w-full max-w-2xl bg-white rounded-3xl border border-gray-100 shadow-lg p-8 space-y-6">
      <div>
        <p className="text-xs uppercase tracking-[0.4em] text-gray-400">Fleet onboarding</p>
        <h2 className="text-3xl font-semibold text-charcoal mt-2">Add a new vehicle</h2>
        <p className="text-gray-500 mt-2">
          Provide the basic registration data and upload documents to enroll a vehicle into the platform.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="grid gap-4">
        <div className="grid gap-4 md:grid-cols-2">
          <label className="block text-sm font-medium text-gray-600">
            VIN / Registration
            <input
              type="text"
              value={vin}
              onChange={event => setVin(event.target.value)}
              required
              className="mt-2 w-full rounded-2xl border border-gray-200 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="MH12AB1234"
            />
          </label>
          <label className="block text-sm font-medium text-gray-600">
            Make
            <input
              type="text"
              value={make}
              onChange={event => setMake(event.target.value)}
              required
              className="mt-2 w-full rounded-2xl border border-gray-200 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="Mahindra"
            />
          </label>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <label className="block text-sm font-medium text-gray-600">
            Model
            <input
              type="text"
              value={model}
              onChange={event => setModel(event.target.value)}
              required
              className="mt-2 w-full rounded-2xl border border-gray-200 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="Thar Double Cab"
            />
          </label>
          <label className="block text-sm font-medium text-gray-600">
            Year of manufacture
            <input
              type="number"
              value={year}
              onChange={event => setYear(event.target.value)}
              required
              className="mt-2 w-full rounded-2xl border border-gray-200 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="2024"
              min={1990}
              max={new Date().getFullYear()}
            />
          </label>
        </div>

        <div className="grid gap-4 md:grid-cols-2">
          <label className="block text-sm font-medium text-gray-600">
            Vehicle type
            <select
              value={vehicleType}
              onChange={event => setVehicleType(event.target.value)}
              className="mt-2 w-full rounded-2xl border border-gray-200 px-4 py-3 focus:border-blue focus:outline-none"
            >
              {vehicleTypes.map(type => (
                <option key={type} value={type}>
                  {type}
                </option>
              ))}
            </select>
          </label>
          <label className="block text-sm font-medium text-gray-600">
            Mileage (km)
            <input
              type="number"
              value={mileage}
              onChange={event => setMileage(event.target.value)}
              required
              min={0}
              className="mt-2 w-full rounded-2xl border border-gray-200 px-4 py-3 focus:border-blue focus:outline-none"
              placeholder="43000"
            />
          </label>
        </div>

        <div className="grid gap-4">
          <label className="block text-sm font-medium text-gray-600">
            Fuel type
            <select
              value={fuelType}
              onChange={event => setFuelType(event.target.value)}
              className="mt-2 w-full rounded-2xl border border-gray-200 px-4 py-3 focus:border-blue focus:outline-none"
            >
              {fuelTypes.map(type => (
                <option key={type} value={type}>
                  {type}
                </option>
              ))}
            </select>
          </label>
        </div>

        <label className="block text-sm font-medium text-gray-600">
          Upload registration / RC document
          <input
            type="file"
            accept=".pdf,.jpg,.png"
            onChange={handleDocumentChange}
            className="mt-2 w-full rounded-2xl border border-dashed border-gray-200 px-4 py-3 text-sm text-gray-600 focus:outline-none"
          />
        </label>

        {error && <p className="text-sm text-red-600 font-medium">{error}</p>}
        {message && <p className="text-sm text-green-600 font-medium">{message}</p>}

        <button type="submit" disabled={loading} className="btn-primary px-5 py-3 font-semibold">
          {loading ? 'Adding vehicle…' : 'Submit vehicle'}
        </button>
      </form>
    </div>
  );
}
