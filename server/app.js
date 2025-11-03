import config from './config.js';

// next(error) 지원 (비동기 에러 처리 다 넘길 필요 없음)
import 'express-async-errors';
import express from 'express';
import { RedisClient } from './utils/Redis.js';


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

// 서버 시작
const server = app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});






// 인증 라우트 설정
app.use('/auth', authRouter);

// 인증 미들웨어 설정
app.use('/api', authMiddleware);

// 라우터 설정
app.use('/api', router);

// 업로드된 파일을 제공 (대부분 이미지)
app.use('/uploads', express.static('uploads'));



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

