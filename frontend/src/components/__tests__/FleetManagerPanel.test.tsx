import { render, screen } from '@testing-library/react';

import FleetManagerPanel from '@/components/FleetManagerPanel';

const vehicles = [
  { id: 1, name: 'Thar', status: 'active', mileage: 20000, vehicle_type: 'suv', next_service_date: '2025-12-01' },
  { id: 2, name: 'Bolero', status: 'due', mileage: 34000, vehicle_type: 'truck', next_service_date: '2025-11-11' }
];

const analytics = [
  { label: 'Vehicles', value: 2 },
  { label: 'Products', value: 5 },
  { label: 'Fleets', value: 1 }
];

describe('FleetManagerPanel', () => {
  it('displays summary cards and analytics points', () => {
    render(<FleetManagerPanel fleetVehicles={vehicles} analytics={analytics} />);
    expect(screen.getByText('Active vehicles')).toBeInTheDocument();
    expect(screen.getByText('Due soon')).toBeInTheDocument();
    expect(screen.getByText('Insights')).toBeInTheDocument();
  });
});
