import express from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";
import { initDB } from "./Config/database";
import authRoutes from './Routes/authRoutes';
import userRoutes from './Routes/userRoutes';

dotenv.config();

const app = express();

app.use(express.json());

app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
}));

app.use(helmet());

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/alert-flow', userRoutes);

initDB().then(() => {
  const PORT = process.env.SERVER_PORT;

  app.listen(PORT, () => {
    console.log(`🚀 Discreta server running on port ${PORT}`);
  });
}).catch((err) => {
  console.error("Failed to initialize database", err);
});
