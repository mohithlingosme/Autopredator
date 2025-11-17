import express from 'express';
import { pool } from '../db';
import { authenticate, AuthRequest } from '../middleware/authMiddleware';
import { getVehicles } from '../services/dataService';

const router = express.Router();

router.use(authenticate);

router.get('/:id/saved', async (req: AuthRequest, res) => {
  try {
    const userId = Number(req.params.id);
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    const result = await pool.query(
      `
        SELECT v.*
        FROM user_saved_vehicles usv
        JOIN vehicles v ON v.id = usv.vehicle_id
        WHERE usv.user_id = $1
      `,
      [userId]
    );
    if (!result.rows.length) {
      const fallback = (await getVehicles()).slice(0, 3);
      return res.json(fallback);
    }
    res.json(result.rows);
  } catch (error) {
    console.error('Failed to fetch saved vehicles', error);
    const fallback = (await getVehicles()).slice(0, 3);
    res.json(fallback);
  }
});

router.post('/:id/saved', async (req: AuthRequest, res) => {
  try {
    const userId = Number(req.params.id);
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    const { vehicleId } = req.body;
    await pool.query(
      'INSERT INTO user_saved_vehicles (user_id, vehicle_id) VALUES ($1, $2) ON CONFLICT (user_id, vehicle_id) DO NOTHING',
      [userId, vehicleId]
    );
    res.status(201).json({ message: 'Saved' });
  } catch (error) {
    console.error('Failed to save vehicle', error);
    res.status(500).json({ error: 'Failed to save vehicle' });
  }
});

router.delete('/:id/saved/:vehicleId', async (req: AuthRequest, res) => {
  try {
    const userId = Number(req.params.id);
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    await pool.query('DELETE FROM user_saved_vehicles WHERE user_id = $1 AND vehicle_id = $2', [
      userId,
      Number(req.params.vehicleId)
    ]);
    res.json({ message: 'Removed' });
  } catch (error) {
    console.error('Failed to remove vehicle', error);
    res.status(500).json({ error: 'Failed to remove vehicle' });
  }
});

router.get('/:id/bookings', async (req: AuthRequest, res) => {
  try {
    const userId = Number(req.params.id);
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    const result = await pool.query(
      `
        SELECT b.*, v.name AS vehicle_name
        FROM user_bookings b
        LEFT JOIN vehicles v ON v.id = b.vehicle_id
        WHERE b.user_id = $1
      `,
      [userId]
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Failed to fetch bookings', error);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

router.post('/:id/bookings', async (req: AuthRequest, res) => {
  try {
    const userId = Number(req.params.id);
    if (req.userId !== userId) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    const { vehicleId, bookingType, preferredDate, notes } = req.body;
    const result = await pool.query(
      `
        INSERT INTO user_bookings (user_id, vehicle_id, booking_type, preferred_date, notes)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *
      `,
      [userId, vehicleId, bookingType, preferredDate, notes]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Failed to create booking', error);
    res.status(500).json({ error: 'Failed to create booking' });
  }
});

export default router;
