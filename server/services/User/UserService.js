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


    /**
     * 
     * 사용자 등록(로컬, Google, Apple 등)
     * 
     * @returns {Promise<{id: number, email: string, name: string}>}
     * @param {string} email 
     * @param {string} password
     * @param {string} name
     * @param {string} provider
     * @param {string|null} provider_id
     * 
     */
    static async registerUser(email, password, name, provider = 'local', provider_id = null) {
        const hashedPassword = await this.hashPassword(password);
        const result = await new User(email, hashedPassword, name, provider, provider_id).save();
        return { id: result.insertId, email, name };
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


    static async getUserByProviderId(provider, providerId) {
        const user = await User.getByProviderId(provider, providerId);
        if (!user) {
            throw new NotFoundError(`User not found by ${provider} ID`);
        }
        return user;
    }

    static async deleteUserByProviderId(provider, providerId) {
        const user = await this.getUserByProviderId(provider, providerId);
        if (!user) {
            throw new NotFoundError(`User not found by ${provider} ID`);
        }
        await user.delete();
    }
}