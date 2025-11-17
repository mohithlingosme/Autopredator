import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import authRoutes from './routes/auth';
import vehicleRoutes from './routes/vehicles';
import forumRoutes from './routes/forum';
import blogRoutes from './routes/blogs';
import aiRoutes from './routes/ai';
import userRoutes from './routes/users';
import { pool } from './db';

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/users', userRoutes);
app.use('/api/forum', forumRoutes);
app.use('/api/blogs', blogRoutes);
app.use('/api/ai', aiRoutes);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

export { pool };
