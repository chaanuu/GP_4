import bcrypt from 'bcrypt';
import { db } from '../db.js';
import { User } from '../models/User.js';

const saltRounds = 10;

export class UserService {

    static async registerUser(username, password) {
        const hashedPassword = await bcrypt.hash(password, saltRounds);
        const result = await new User(username, hashedPassword).save();
        return { id: result.insertId, username };
    }


    static async hashPassword(password) {
        const saltRounds = 10;
        return await bcrypt.hash(password, saltRounds);
    }

    static async comparePassword(password, hashedPassword) {
        return await bcrypt.compare(password, hashedPassword);
    }
}