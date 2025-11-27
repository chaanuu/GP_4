import express from 'express';
import { ProgramController } from '../controllers/ProgramController.js';

const router = express.Router();

router.post('/', ProgramController.createProgram);
router.get('/user/:uid', ProgramController.getProgramList);
router.get('/:pid', ProgramController.getProgramDetail);
router.delete('/:programId', ProgramController.deleteProgram);

export const programRouter = router;
