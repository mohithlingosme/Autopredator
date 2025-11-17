import express from 'express';
import sampleData from '../data/sampleData';
import {
  getServiceHistoryForListing,
  getVehicleById,
  getVehicleListings,
  getVehicles
} from '../services/dataService';
import { AiInsight } from '../types';

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const { type, fuel, body, priceMin, priceMax, sort, limit } = req.query;
    const vehicles = await getVehicles({ type: type as string | undefined, limit: limit ? Number(limit) : undefined });

    const filtered = vehicles
      .filter(vehicle => {
        const matchesFuel = fuel ? vehicle.fuel_type?.toLowerCase() === String(fuel).toLowerCase() : true;
        const matchesBody = body ? vehicle.body_type?.toLowerCase() === String(body).toLowerCase() : true;
        const min = priceMin ? Number(priceMin) : null;
        const max = priceMax ? Number(priceMax) : null;
        const price = vehicle.price_min || 0;
        const matchesPrice = (!min || price >= min) && (!max || (vehicle.price_max || price) <= max);
        return matchesFuel && matchesBody && matchesPrice;
      })
      .sort((a, b) => {
        switch (sort) {
          case 'price-high':
            return (b.price_max || 0) - (a.price_max || 0);
          case 'price-low':
            return (a.price_min || 0) - (b.price_min || 0);
          case 'rating':
            return (b.rating || 0) - (a.rating || 0);
          default:
            return (b.is_featured ? 1 : 0) - (a.is_featured ? 1 : 0);
        }
      });

    res.json(filtered);
  } catch (error) {
    console.error('Failed to fetch vehicles', error);
    res.status(500).json({ error: 'Failed to fetch vehicles' });
  }
});

router.get('/used', async (req, res) => {
  try {
    const { city, verified, owner_type, listing_type } = req.query;
    const vehicles = await getVehicles({ type: 'used' });
    const listings = await getVehicleListings();

    const data = listings
      .filter(listing => {
        const matchesCity = city ? listing.city?.toLowerCase() === String(city).toLowerCase() : true;
        const matchesVerified = verified ? listing.verified === (verified === 'true') : true;
        const ownerFilter = owner_type
          ? listing.owner_type?.toLowerCase().includes(String(owner_type).toLowerCase())
          : true;
        const listingTypeFilter = listing_type
          ? listing.owner_type?.toLowerCase().includes(String(listing_type).toLowerCase())
          : true;
        return matchesCity && matchesVerified && ownerFilter && listingTypeFilter;
      })
      .map(listing => {
        const vehicle = vehicles.find(v => v.id === listing.vehicle_id);
        return {
          listing,
          vehicle
        };
      })
      .filter(item => Boolean(item.vehicle));

    res.json(data);
  } catch (error) {
    console.error('Failed to fetch used vehicles', error);
    res.status(500).json({ error: 'Failed to fetch used vehicles' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const vehicle = await getVehicleById(id);
    if (!vehicle) {
      return res.status(404).json({ error: 'Vehicle not found' });
    }
    const listings = await getVehicleListings(id);
    const serviceHistory = await Promise.all(
      listings.map(async listing => ({
        listingId: listing.id,
        records: await getServiceHistoryForListing(listing.id)
      }))
    );
    const related = (await getVehicles({ type: vehicle.type })).filter(v => v.id !== vehicle.id).slice(0, 3);
    const aiInsight = sampleData.aiInsights.find((insight: AiInsight) => insight.vehicleId === id);

    res.json({
      vehicle,
      listings,
      serviceHistory,
      related,
      aiInsight
    });
  } catch (error) {
    console.error('Failed to fetch vehicle', error);
    res.status(500).json({ error: 'Failed to fetch vehicle' });
  }
});

router.get('/:id/listings', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const listings = await getVehicleListings(id);
    res.json(listings);
  } catch (error) {
    console.error('Failed to fetch listings', error);
    res.status(500).json({ error: 'Failed to fetch listings' });
  }
});

router.get('/:id/service-history', async (req, res) => {
  try {
    const listingId = Number(req.params.id);
    const history = await getServiceHistoryForListing(listingId);
    res.json(history);
  } catch (error) {
    console.error('Failed to fetch service history', error);
    res.status(500).json({ error: 'Failed to fetch service history' });
  }
});

router.post('/compare', async (req, res) => {
  try {
    const { vehicleIds } = req.body as { vehicleIds: number[] };
    if (!vehicleIds?.length) {
      return res.status(400).json({ error: 'vehicleIds is required' });
    }
    const vehicles = await Promise.all(vehicleIds.map(id => getVehicleById(id)));
    res.json(vehicles.filter(Boolean));
  } catch (error) {
    console.error('Failed to compare vehicles', error);
    res.status(500).json({ error: 'Failed to compare vehicles' });
  }
});

export default router;
