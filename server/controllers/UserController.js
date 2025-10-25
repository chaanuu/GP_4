import { UserService } from '../services/UserService.js';


export class UserController {

    static async getUserById(req, res) {
        const user = await UserService.getUserById(req.params.id);
        res.status(200).json(user);
    }

    static async getAllUsers(req, res) {
        const users = await UserService.getAllUsers();
        res.status(200).json(users);
    }

    // TODO : Service 에서 인증 처리 추가
    static async createUser(req, res) {
        const newUser = await UserService.registerUser(req.body.email, req.body.password);
        res.status(201).json(newUser);
    }

    static async updateUser(req, res) {
        const updatedUser = await UserService.updateUser(req.params.id, req.body);
        res.status(200).json(updatedUser);
    }

    static async deleteUserById(req, res) {
        await UserService.deleteUserById(req.params.email);
        res.sendStatus(204);
    }

}