import express from 'express';
import sampleData from '../data/sampleData';

const router = express.Router();

router.post('/predict-resale', (req, res) => {
  const { vehicleId } = req.body;
  const insight =
    sampleData.aiInsights.find(ai => ai.vehicleId === vehicleId) ||
    sampleData.aiInsights[0] || { resaleValue: 0, confidence: 0, fairValue: 0, message: '' };
  res.json(insight);
});

router.get('/recommendations', (_req, res) => {
  const recommendations = sampleData.vehicles.slice(0, 3).map(vehicle => ({
    id: vehicle.id,
    name: vehicle.name,
    reason: 'High resale value and low running cost',
    score: Math.round((vehicle.rating || 4) * 18)
  }));
  res.json(recommendations);
});

router.get('/dashboard', (_req, res) => {
  res.json({
    ownershipCost: [
      { year: 'Year 1', cost: 1.8 },
      { year: 'Year 2', cost: 2.1 },
      { year: 'Year 3', cost: 2.4 },
      { year: 'Year 4', cost: 2.65 },
      { year: 'Year 5', cost: 2.95 }
    ],
    depreciation: [
      { segment: 'Hatchback', vehicle: 18, segmentAvg: 22 },
      { segment: 'Sedan', vehicle: 20, segmentAvg: 25 },
      { segment: 'SUV', vehicle: 16, segmentAvg: 21 },
      { segment: 'EV', vehicle: 14, segmentAvg: 19 }
    ],
    maintenanceConfidence: 0.82
  });
});

export default router;
