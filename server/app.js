import express from 'express';
import { RedisClient } from './utils/Redis.js';

// routes
import { userRouter } from './routes/User.js';
import { exerciseRouter } from './routes/Exercise.js';
import { foodRouter } from './routes/Food.js';


const app = express();
const router = express.Router();
// router.use('/physique', physiqueChangeRouter);
router.use('/user', userRouter);
router.use('/exercise', exerciseRouter);
router.use('/food', foodRouter);



const server = app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});



const redisConfig = {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    password: process.env.REDIS_PASSWORD,
    db: 0,
};

// 싱글톤 Redis 클라이언트 초기화
RedisClient.getCacheClient(redisConfig);

redisConfig.db = 1;
RedisClient.getSessionClient(redisConfig);



app.use(express.json());


// 서버 종료 이벤트를 처리하는 함수
const shutdown = () => {
    console.log('Server is shutting down...');
    // 데이터베이스 연결 종료, 파일 저장 등 마무리 작업
    server.close(() => {
        console.log('HTTP server closed.');
        // 프로세스 종료
        process.exit(0);
    });
};

// SIGINT (Ctrl+C) 신호 감지
process.on('SIGINT', shutdown);

// SIGTERM (kill) 신호 감지
process.on('SIGTERM', shutdown);

