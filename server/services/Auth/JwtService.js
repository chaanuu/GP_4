import JWT from 'jsonwebtoken';
import { RedisClient } from '../../utils/Redis.js';
import config from '../../config.js';

const jwtConfig = config.jwt;

const sessionClient = RedisClient.getSessionClient();


export class JwtService {
    static ACCESS_TTL = 60 * 60; // 1시간
    static REFRESH_TTL = 30 * 24 * 60 * 60; // 30일

    static async generateTokens(userId) {
        const accessToken = JWT.sign({ userId }, jwtConfig.accessSecret, { expiresIn: ACCESS_TTL });
        const refreshToken = JWT.sign({ userId }, jwtConfig.refreshSecret, { expiresIn: REFRESH_TTL });

        // Redis에 리프레시 토큰 저장
        await sessionClient.setex(refreshToken, REFRESH_TTL, userId);

        return { accessToken, refreshToken };
    }

    static async verifyAccessToken(token) {
        return JWT.verify(token, jwtConfig.accessSecret);
    }

    static async verifyRefreshToken(token) {
        return JWT.verify(token, jwtConfig.refreshSecret);
    }

    static async getUserIdFromRefreshToken(token) {
        const userId = await sessionClient.get(token);
        return userId;
    }

    static async revokeRefreshToken(token) {
        await sessionClient.del(token);
    }

}