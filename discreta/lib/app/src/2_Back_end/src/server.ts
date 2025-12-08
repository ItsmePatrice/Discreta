import express from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";
import { initDB } from "./Config/database";

dotenv.config();

const app = express();

app.use(express.json());
app.use(cors());
app.use(helmet());

app.get("/", (req, res) => {
  res.json({ message: "Discreta server is running" });
});


initDB().then(() => {
  const PORT = process.env.SERVER_PORT;

  app.listen(PORT, () => {
    console.log(`🚀 Discreta server running on port ${PORT}`);
  });
}).catch((err) => {
  console.error("Failed to initialize database", err);
});