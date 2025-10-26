import jwt from 'jsonwebtoken';
import { JwtService } from '../services/JwtService.js';
import { OAuthService } from '../services/OAuthService.js';
import { UserService } from '../services/User/UserService.js';

import { GoogleOAuthError, GoogleOAuthError, InternalServerError, NotFoundError, ValidationError }
    from '../utils/errors.js';



export class AuthController {
    static async login(req, res) {
        const { userId } = req.body;

        // TODO: 실제 검증 로직 추가해서 미들웨어로 분리할 것
        if (!userId) {
            return res.status(400).json({ message: 'userId is required' });
        }

        // JWT 토큰 생성
        const token = JwtService.generateTokens({ userId });

        // 응답으로 토큰 반환
        return res.status(200).json({ token });

    }

    static async logout(req, res) {
        const refreshToken = req.cookies.refreshToken;
        if (!refreshToken) {
            throw new InternalServerError('Refresh token is required');
        }

        await sessionClient.del(refreshToken);
        res.clearCookie('refreshToken');
        return res.status(200).json({ message: 'Logged out successfully' });

    }

    static registerUser(req, res) {
        const { email, password, name } = req.body;

        // TODO : 미들웨어로 뺄 것
        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        const newUser = UserService.registerUser(email, password, name);
        return res.status(201).json({ message: 'User registered successfully', user: newUser });



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


    static async googleLogin(req, res) {
        const { idToken } = req.body;
        const googleUser = await OAuthService.verifyGoogleToken(idToken);
        if (!googleUser) {
            throw new GoogleOAuthError('Invalid Google Token');
        }
        let user;

        try {
            user = await this.login(req, res, googleUser.email);
        } catch (error) {
            if (!(error instanceof NotFoundError)) {
                throw error;
            }
            // 사용자가 없으면 새로 등록
            UserService.registerUser(googleUser.email, null, googleUser.name);

        }


    }


    static async appleLogin(req, res) {
        const { idToken } = req.body;

        const appleUser = await OAuthService.verifyAppleToken(idToken);
        if (!appleUser) {
            throw new GoogleOAuthError('Invalid Apple Token');
        }
        let user;
        try {
            user = await UserService.getUserByEmail(appleUser.email);
        } catch (error) {
            if (!(error instanceof NotFoundError)) {
                throw error;
            }
            // 사용자가 없으면 새로 등록
            UserService.registerUser(appleUser.email, null, null);
        }
        return res.status(200).json({ message: "Login successful", user });

    }

}