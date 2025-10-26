import { JWT } from 'jsonwebtoken';
import { RedisClient } from '../utils/Redis';

const sessionClient = RedisClient.getSessionClient();


export class JwtService {
    static ACCESS_TTL = 60 * 60; // 1시간
    static REFRESH_TTL = 30 * 24 * 60 * 60; // 30일

    static async generateTokens(userId) {
        const accessToken = JWT.sign({ userId }, process.env.JWT_ACCESS_SECRET, { expiresIn: ACCESS_TTL });
        const refreshToken = JWT.sign({ userId }, process.env.JWT_REFRESH_SECRET, { expiresIn: REFRESH_TTL });

        // Redis에 리프레시 토큰 저장
        await sessionClient.setex(refreshToken, REFRESH_TTL, userId);

        return { accessToken, refreshToken };
    }

    static async verifyAccessToken(token) {
        return JWT.verify(token, process.env.JWT_ACCESS_SECRET);
    }

    static async verifyRefreshToken(token) {
        return JWT.verify(token, process.env.JWT_REFRESH_SECRET);
    }

    static async getUserIdFromRefreshToken(token) {
        const userId = await sessionClient.get(token);
        return userId;
    }

    static async revokeRefreshToken(token) {
        await sessionClient.del(token);
    }

}