import mysql2 from 'mysql2/promise';

const dbConfig = {
    host: 1,
    user: 'root',
    password: 'password',
    database: 'healthcare',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

/**
 * MySQL 데이터베이스 관리를 위한 클래스.
 * 커넥션 풀을 사용하여 다수의 동시 요청을 효율적으로 처리합니다.
 * async/await를 통해 동기적인 코드 스타일로 비동기 DB 작업을 수행할 수 있습니다.
 */
class DB {
    /**
     * DB 클래스의 생성자.
     * @param {object} config - 데이터베이스 연결 설정 객체.
     * 예: { host, user, password, database, waitForConnections, connectionLimit, queueLimit }
     */
    constructor(config) {
        if (!config) {
            throw new Error("데이터베이스 설정 객체가 필요합니다.");
        }
        // 설정 객체를 기반으로 커넥션 풀을 생성합니다.
        this.pool = mysql2.createPool(config);


    }

    /**
     * 데이터베이스에 쿼리를 실행합니다.
     * @param {string} sql - 실행할 SQL 쿼리 문자열 (플레이스홀더 '?' 사용 가능).
     * @param {Array} params - SQL 쿼리의 플레이스홀더에 바인딩될 파라미터 배열.
     * @returns {Promise<Array>} 쿼리 결과 배열을 반환하는 프로미스.
     */
    async query(sql, params) {
        let conn;
        try {
            // 커넥션 풀에서 커넥션을 가져옵니다.
            conn = await this.pool.getConnection();
            // SQL 쿼리와 파라미터를 사용하여 쿼리를 실행합니다.
            // execute는 SQL Injection 공격을 방지하기 위해 Prepared Statements를 사용합니다.
            const [rows] = await conn.execute(sql, params);
            return rows;
        } catch (error) {
            // 에러 발생 시 콘솔에 로그를 남기고 에러를 다시 던집니다.
            console.error(`[Database Error] ${error.message}`);
            throw error;
        } finally {
            // 쿼리 실행 후에는 반드시 커넥션을 풀에 반환합니다.
            if (conn) {
                conn.release();
            }
        }
    }

    /**
     * 커넥션 풀에서 커넥션을 직접 가져옵니다.
     * 트랜잭션이 필요한 경우에 사용합니다.
     * @returns {Promise<Connection>} MySQL 커넥션 객체를 반환하는 프로미스.
     */
    async getConnection() {
        return this.pool.getConnection();
    }

    /**
     * 테이블에 새로운 데이터를 삽입합니다. (Create)
     * @param {string} table - 데이터를 삽입할 테이블 이름.
     * @param {object} data - 삽입할 데이터 객체 (key: column, value: value).
     * @returns {Promise<object>} 쿼리 실행 결과 (e.g., insertId).
     */
    async create(table, data) {
        const sql = `INSERT INTO ?? SET ?`;
        const params = [table, data];
        return this.query(sql, params);
    }

    /**
     * 테이블에서 데이터를 조회합니다. (Read)
     * @param {string} table - 조회할 테이블 이름.
     * @param {object} [where={}] - 조회 조건 객체. 비어있으면 모든 데이터를 조회합니다.
     * @param {string|Array<string>} [columns='*'] - 조회할 컬럼.
     * @returns {Promise<Array>} 조회된 데이터 배열.
     */
    async read(table, where = {}, columns = '*') {
        const whereClauses = Object.keys(where).map(key => `${key} = ?`).join(' AND ');
        const params = Object.values(where);
        const sql = `SELECT ${Array.isArray(columns) ? columns.join(', ') : columns} FROM ?? ${whereClauses ? `WHERE ${whereClauses}` : ''}`;

        // 테이블 이름을 params의 맨 앞에 추가합니다.
        params.unshift(table);

        // SQL에서 테이블 이름 플레이스홀더를 ??로 변경해야 합니다.
        const finalSql = sql.replace('FROM ??', 'FROM ??');

        return this.query(finalSql, params);
    }

    /**
     * 테이블의 데이터를 수정합니다. (Update)
     * @param {string} table - 수정할 테이블 이름.
     * @param {object} data - 수정할 데이터 객체.
     * @param {object} where - 수정할 레코드를 식별하는 조건 객체.
     * @returns {Promise<object>} 쿼리 실행 결과 (e.g., affectedRows).
     */
    async update(table, data, where) {
        const whereClauses = Object.keys(where).map(key => `${key} = ?`).join(' AND ');
        if (!whereClauses) {
            throw new Error("UPDATE 쿼리에는 WHERE 절이 반드시 필요합니다.");
        }
        const sql = `UPDATE ?? SET ? WHERE ${whereClauses}`;
        const params = [table, data, ...Object.values(where)];
        return this.query(sql, params);
    }

    /**
     * 테이블의 데이터를 삭제합니다. (Delete)
     * @param {string} table - 삭제할 테이블 이름.
     * @param {object} where - 삭제할 레코드를 식별하는 조건 객체.
     * @returns {Promise<object>} 쿼리 실행 결과 (e.g., affectedRows).
     */
    async delete(table, where) {
        const whereClauses = Object.keys(where).map(key => `${key} = ?`).join(' AND ');
        if (!whereClauses) {
            throw new Error("DELETE 쿼리에는 WHERE 절이 반드시 필요합니다.");
        }
        const sql = `DELETE FROM ?? WHERE ${whereClauses}`;
        const params = [table, ...Object.values(where)];
        return this.query(sql, params);
    }

    async tableExists(table) {
        const sql = `SELECT COUNT(*) FROM information_schema.TABLES
                    WHERE TABLE_SCHEMA = ${dbConfig.database} 
                    AND TABLE_NAME = '${table}'`;
        const ret = await this.query(sql, []);
        return ret;
    }

    /**
     * 커넥션 풀의 모든 커넥션을 종료합니다.
     * 애플리케이션 종료 시 호출해야 합니다.
     */
    async close() {
        await this.pool.end();
        console.log('데이터베이스 커넥션 풀이 종료되었습니다.');
    }
}

export const db = new DB();
// TODO : 테이블 초기화 (없으면 초기파일 불러오기) 코드 작성
db.getConnection().tableExists('users').then(res => console.log(res)).catch(err => console.error(err));
db.getConnection().tableExists('foods').then(res => console.log(res)).catch(err => console.error(err));
