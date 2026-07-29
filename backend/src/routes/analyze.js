import express from "express";
import { requireFirebaseAuth } from "../middleware/firebaseAuth.js";
import { analyzeController } from "../controllers/analyzeController.js";

const router = express.Router();

router.post("/", requireFirebaseAuth, analyzeController);

export default router;