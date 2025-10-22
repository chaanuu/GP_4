import { db } from '../modules/utils/DB.js';

// { name, id, {inbodys}, nutrition }
export class User {
    constructor(name, email = null) {
        this.name = name;
        this.email = email;
        this.id = null; // DB에 저장되면 설정됨
        this.inbodys = []; // Inbody 객체 데이터 (미정)
        this.nutrition = {}; // {kcal, carb, protein, fat} TODO : 인자 수정 필요
    }


    /**
     * 
     * @returns {Promise<User>} 저장된 User 객체 반환
     */
    async save() {
        try {
            await db.create('users', {
                name: this.name,
                email: this.email,
                inbodys: JSON.stringify(this.inbodys),
                nutrition: JSON.stringify(this.nutrition)
            }).then((result) => { this.id = result.insertId; });
        } catch (error) {
            console.error('Error saving user on DB :', error);
            throw error;
        }
        return this;

    }

    /**
     * 
     * @returns {Promise<Array<User>>} 모든 User 객체 배열 반환
     */
    static async getAll() {
        try {
            let rows = db.read('users', {});
            return rows.map(row => new User(row));
        } catch (error) {
            console.error('Error getting all users from DB :', error);
            throw error;
        }

    }


    /**
     * 
     * @param {number} id 
     * @returns {Promise<User|null>} id에 해당하는 User 객체 반환, 없으면 null 반환
     */
    static async getById(id) {
        try {
            return db.read('users', { id: id });
        } catch (error) {
            console.error('Error getting user by ID from DB :', error);
            throw error;
        }
    }


    /**
     * 
     * @param {string} query 
     * @returns  {Promise<Array<User>>} 이름에 query가 포함된 User 객체 배열 반환
     */
    static async getByQuery(query) {
        try {
            return db.query('users', [query]);
        } catch (error) {
            console.error('Error getting users by query from DB :', error);
            throw error;
        }

    }

    /**
     * 
     * @param {number} id
     * @param {User} updatedUser
     * @returns  {Promise<boolean>} 수정 성공 여부 반환
     */
    static async update(id, updatedUser) {
        try {
            return db.update('users', {
                name: updatedUser.name,
                inbodys: updatedUser.inbodys,
                nutrition: updatedUser.nutrition,
                id: id
            });
        } catch (error) {
            console.error('Error getting user by ID from DB :', error);
            throw error;
        }

    }


    /**
     * 
     * @param {number} id
     * @returns {Promise<boolean>} 삭제 성공 여부 반환
     */
    static async delete(id) {
        try {
            return db.delete('users', { id: id });
        } catch (error) {
            console.error('Error getting user by ID from DB :', error);
            throw error;
        }

    }
}