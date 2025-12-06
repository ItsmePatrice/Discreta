import express from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";

dotenv.config();

const app = express();

app.use(express.json());
app.use(cors());
app.use(helmet());

// Test route
app.get("/api/health", (_, res) => {
  res.json({ status: "ok", server: "Discreta API" });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Discreta server running on port ${PORT}`);
});
