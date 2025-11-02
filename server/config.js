import 'dotenv/config';

const config = {

    port: process.env.PORT || 3000,

    jwt: {
        accessSecret: process.env.JWT_ACCESS_SECRET,
        refreshSecret: process.env.JWT_REFRESH_SECRET,
        accessTTL: 60 * 60, // 1시간
        refreshTTL: 30 * 24 * 60 * 60, // 30일
    },

    redis: {
        host: process.env.REDIS_HOST,
        port: process.env.REDIS_PORT,
        password: process.env.REDIS_PASSWORD,
        dbCache: 0
    },

    db: {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        waitForConnections: true,
        connectionLimit: 10, // 동시에 허용할 최대 연결 수
        queueLimit: 0        // 큐 대기열 무제한
    }
};

export default config;


