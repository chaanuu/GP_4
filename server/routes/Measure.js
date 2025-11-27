import { MeasureController } from "../controllers/MeasureController";
import express from 'express';
import { upload } from '../middlewares/uploadMiddleware.js';
const router = express.Router();

router.get('/circumference', upload.array('photos', 2), MeasureController.measureCircumference);

