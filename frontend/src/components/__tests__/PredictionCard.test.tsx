import { render, screen } from '@testing-library/react';

import PredictionCard, { PredictionResult } from '@/components/PredictionCard';
import { Vehicle } from '@/types';

const sampleVehicle: Vehicle = {
  id: 1,
  make: 'Mahindra',
  model: 'Bolero',
  mileage: 42000,
  status: 'active'
};

const prediction: PredictionResult = {
  next_service_date: new Date().toISOString(),
  confidence: 0.72,
  message: 'Regular maintenance suggested',
  vehicle_id: 1,
  source: 'ml'
};

describe('PredictionCard', () => {
  it('renders a fallback message when there is no prediction', () => {
    render(<PredictionCard prediction={null} vehicle={null} />);
    expect(screen.getByText(/Predictive maintenance insights/)).toBeInTheDocument();
  });

  it('shows prediction details when the API responds', () => {
    render(<PredictionCard prediction={prediction} vehicle={sampleVehicle} />);
    expect(screen.getByText(/Mahindra Bolero/)).toBeInTheDocument();
    expect(screen.getByText(prediction.message)).toBeInTheDocument();
    expect(screen.getByText(/Next service/)).toBeInTheDocument();
  });
});
