import bcrypt from 'bcrypt';
import { User } from '../../models/User/User.js';

import { NotFoundError } from '../../utils/errors.js';

const saltRounds = 10;

export class UserService {

    static async getUserById(id) {
        const user = await User.getById(id);
        if (!user) {
            throw new NotFoundError('User not found');
        }
        return user;
    }

    static async getUserByEmail(email) {
        const user = await User.getByEmail(email);
        if (!user) {
            throw new NotFoundError('User not found by email');
        }
        return user;
    }


    // create 
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

    static async updateUser(id, updateData) {
        const user = await this.getUserById(id);

        // 비밀번호 업데이트 시 해싱 처리
        if (updateData.password) {
            updateData.password = await this.hashPassword(updateData.password);
        }

        Object.assign(user, updateData);
        return await user.save();
    }

    static async deleteUserByEmail(email) {
        const user = await User.getByEmail(email);
        if (!user) {
            throw new NotFoundError('User not found');
        }
        await user.delete();
    }

    static async deleteUserById(id) {
        const user = await this.getUserById(id);
        if (!user) {
            throw new NotFoundError('User not found');
        }
        await user.delete();
    }


    static async getAllUsers() {
        return await User.getAll();
    }

}