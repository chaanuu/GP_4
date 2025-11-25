import config from './config.js';

// next(error) 지원 (비동기 에러 처리 다 넘길 필요 없음)
import 'express-async-errors';
import express from 'express';

import { RedisClient } from './utils/Redis.js';
import { db } from './utils/DB.js';

// Helper for graceful shutdown
import { createHttpTerminator } from 'http-terminator';

// Logger Middleware
import morgan from 'morgan';


// Security middleware
import helmet from 'helmet';

// Auth Middleware
import { authMiddleware } from './middlewares/authMiddleware.js';


// routes
import { userRouter } from './routes/User.js';
import { exerciseRouter } from './routes/Exercise.js';
import { foodRouter } from './routes/Food.js';
import { exerciseLogRouter } from './routes/ExerciseLog.js';
import { mealLogRouter } from './routes/MealLog.js';
import { authRouter } from './routes/Auth.js';
import { OAuthRouter } from './routes/OAuth.js';


const port = config.port || 3000;

const app = express();
const router = express.Router();

router.use('/user', userRouter);
router.use('/exercise', exerciseRouter);
router.use('/food', foodRouter);
router.use('/exercise/log', exerciseLogRouter);
router.use('/meal/log', mealLogRouter);

// Logger
app.use(morgan('dev'));

// JSON Body Parser
app.use(express.json());

// Security Middleware
app.use(helmet());



// 서버 시작
const server = app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});

// HTTP Terminator 생성
const httpTerminator = createHttpTerminator({ server });





// 인증 라우트 설정
app.use('/auth', authRouter);
app.use('/oauth', OAuthRouter);

// 인증 미들웨어 설정
// app.use('/api', authMiddleware);

// 라우터 설정
app.use('/api', router);

// 업로드된 파일을 제공 (대부분 이미지)
app.use('/api/uploads', express.static('uploads'));



// Error Handling Middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    const status = err.status || 500;
    res.status(status).json({
        error: {
            message: err.message,
            code: err.code || 'INTERNAL_SERVER_ERROR'
        }
    });
});




const gracefulShutdown = async (signal) => {
    console.log(`\nReceived ${signal}. Shutting down gracefully...`);

    // 1. HTTP 서버 연결 종료
    await httpTerminator.terminate();
    console.log('HTTP server closed.');

    // 2. 데이터베이스 연결 종료
    await db.close(); // db.close()는 DB 유틸리티에 구현해야 합니다.
    // 3. Redis 연결 종료 (사용하는 경우)
    await RedisClient.disconnectAll();
    console.log('All Redis Client closed.');

    process.exit(0); // 모든 연결이 닫히면 프로세스 종료

};

// SIGINT (Ctrl+C) 신호 감지
process.on('SIGINT', gracefulShutdown);

// SIGTERM (kill) 신호 감지
process.on('SIGTERM', gracefulShutdown);

