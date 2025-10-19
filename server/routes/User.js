import express from 'express';
import { UserController } from '../controllers/UserController';

const router = express.Router();

router.get('/:id', UserController.getUserById);

router.get('/', UserController.getAllUsers);

router.post('/', UserController.createUser);

router.put('/:id', UserController.updateUser);

router.delete('/:id', UserController.deleteUser);


export const userRouter = router;