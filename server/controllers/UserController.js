import { User } from "../models/User";

export class UserController {

    static async getUserById(req, res) {
        const user = await User.getById(req.params.id).catch(err => {
            res.status(500).send({ error: err.message });
        });
        if (user) {
            res.status(200).json(user);
        } else {
            res.status(404).send({ error: 'User not found' });
        }
    }

    static async getAllUsers(req, res) {
        res.status(200).json(await User.getAll().catch(err => {
            res.status(500).send({ error: err.message });
        }));
    }

    static async createUser(req, res) {
        res.status(201).json(await new User(req.body.name).save().catch(err => {
            res.status(500).send({ error: err.message });
        }));
    }

    static async updateUser(req, res) {
        await User.getById(req.params.id).then(user => {
            if (user) {
                user.name = req.body.name || user.name;
                // TODO : 필요한 다른 필드들도 여기에 추가
                res.status(200).json(user);
            } else {
                res.status(404).send({ error: 'User not found' });
            }
        }).catch(err => {
            res.status(500).send({ error: err.message });
        });

    }

    static async deleteUser(req, res) {
        await User.getById(req.params.id).then(async user => {
            if (user) {
                await user.delete().then(() => {
                    res.sendStatus(204);
                }).catch(err => {
                    res.status(500).send({ error: err.message });
                });
            } else {
                res.status(404).send({ error: 'User not found' });
            }
        }).catch(err => {
            res.status(500).send({ error: err.message });
        });
    }



}