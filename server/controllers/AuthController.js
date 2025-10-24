import jwt from 'jsonwebtoken';
import { JwtService } from '../services/JwtService.js';

export class AuthController {
    static async login(req, res) {
        const { userId } = req.body;

        if (!userId) {
            return res.status(400).json({ message: 'userId is required' });
        }

        try {
            // JWT 토큰 생성
            const token = JwtService.generateToken({ userId });

            // 응답으로 토큰 반환
            return res.status(200).json({ token });
        } catch (error) {
            console.error('Error during login:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
    }

    static async refreshToken(req, res) {
        const oldRefreshToken = req.cookies.refreshToken;
        if (!oldRefreshToken) {
            return res.status(400).json({ message: 'Refresh token is required' });
        }

        try {
            const decoded = jwt.verify(oldRefreshToken, process.env.JWT_REFRESH_SECRET);
            const userId = decoded.userId;

            const storedUserId = await JwtService.verifyRefreshToken(oldRefreshToken);

            if (!storedUserId || storedUserId !== userId) {
                return res.status(401).json({ message: 'Invalid refresh token' });
            }

            await sessionClient.del(oldRefreshToken);

            const newTokens = await JwtService.generateTokens(userId);

            res.cookie('refreshToken', newTokens.refreshToken, {
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                sameSite: 'Strict',
                maxAge: JwtService.REFRESH_TTL * 1000
            });

            return res.status(200).json({ accessToken: newTokens.accessToken });
        } catch (error) {
            return res.status(401).json({ message: 'Token invalid or expired' });
        }
    }

    static async logout(req, res) {
        const refreshToken = req.cookies.refreshToken;
        if (!refreshToken) {
            return res.status(400).json({ message: 'Refresh token is required' });
        }

        try {
            await sessionClient.del(refreshToken);
            res.clearCookie('refreshToken');

            return res.status(200).json({ message: 'Logged out successfully' });
        } catch (error) {
            console.error('Error during logout:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
    }


}