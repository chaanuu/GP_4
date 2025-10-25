import { db } from '../../utils/DB.js';

import { DuplicateEntryError, NotFoundError } from '../../utils/errors.js';

export class User {
    constructor(email, password_hash) {
        this.id = null; // DB에 저장되면 설정됨
        this.email = email;
        this.password_hash = password_hash;
        this.inbodys = [];
        this.nutrition = {};
    }


    static #fromDB(row) {
        if (!row) return null;

        const user = new User(row.email, row.password_hash);
        user.id = row.id;
        // JSON으로 저장된 문자열을 객체로 파싱
        // user.inbodys = row.inbodys ? JSON.parse(row.inbodys) : [];
        // user.nutrition = row.nutrition ? JSON.parse(row.nutrition) : {};
        return user;
    }

    /**
     * 
     * @returns {Promise<User>} 저장된 User 객체 반환
     */
    async save() {
        const data = {
            email: this.email,
            password_hash: this.password_hash,
            inbodys: JSON.stringify(this.inbodys),
            nutrition: JSON.stringify(this.nutrition)
        };

        try {
            if (this.id) {
                // ID가 있으면 UPDATE
                const result = await db.update('users', data, { id: this.id });
                if (result.affectedRows === 0) {
                    // 업데이트할 대상이 없음 (존재하지 않는 ID)
                    throw new NotFoundError('User not found during update');
                }
            } else {
                // ID가 없으면 INSERT
                const result = await db.create('users', data);
                this.id = result.insertId;
            }
            return this;

        } catch (error) {
            // DB 에러가 "중복 키" 에러일 경우, 애플리케이션 에러로 변환
            if (error.code === 'ER_DUP_ENTRY') {
                throw new DuplicateEntryError('This email is already registered.');
            }
            // 그 외 DB 에러는 그대로 상위로 전파
            throw error;
        }
    }

    /**
     * 
     * @returns {Promise<Array<User>>} 모든 User 객체 배열 반환
     */
    static async getAll() {
        const rows = await db.read('users', {});
        return rows.map(row => User.#fromDB(row));
    }

    /**
     * @param {number} id 
     * @returns {Promise<User|null>} id에 해당하는 User 객체 반환, 없으면 null 반환
     */
    static async getById(id) {
        const rows = await db.read('users', { id: id });

        if (rows.length === 0) {
            // "못 찾음"은 에러가 아니므로, null을 반환합니다.
            // 서비스 계층이 이 null을 보고 NotFoundError를 throw할 것입니다.
            return null;
        }

        return User.#fromDB(rows[0]);
    }


    /**
     * 
     *  * @param {string} email
     *  * @returns {Promise<User|null>} email에 해당하는 User 객체 반환, 없으면 null 반환
     */

    static async getByEmail(email) {
        const rows = await db.read('users', { email: email });

        if (rows.length === 0) {
            // "못 찾음"은 에러가 아니므로, null을 반환합니다.
            // 서비스 계층이 이 null을 보고 NotFoundError를 throw할 것입니다.
            return null;
        }

        return User.#fromDB(rows[0]);
    }

    /**
     * 
     * @param {string} query 
     * @returns {Promise<Array<User>>}
     */
    static async getByQuery(query) {
        const rows = await db.query('users', [query]);
        return rows.map(row => User.#fromDB(row));
    }


    /**
     * @param {number} id
     * @returns {Promise<boolean>} 삭제 성공 여부 반환
     */
    static async delete(id) {
        const result = await db.delete('users', { id: id });

        if (result.affectedRows === 0) {
            // 삭제할 대상이 없음 (존재하지 않는 ID)
            throw new NotFoundError('User not found, delete failed.');
        }

        return true;
    }
}