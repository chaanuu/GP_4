import request from 'supertest';
import express from 'express';
import { jest } from '@jest/globals';

// 테스트 대상 모듈 import
import { OAuthVerifyService } from '../services/Auth/OAuthVerifyService.js';
import { UserService } from '../services/User/UserService.js';
import { JwtService } from '../services/Auth/JwtService.js';
import { authMiddleware } from '../middlewares/authMiddleware.js';
import { User } from '../models/User/User.js';
import { userRouter } from '../routes/User.js';

// 외부 라이브러리 모킹
const mockVerifyIdToken = jest.fn();
jest.mock('google-auth-library', () => ({
  OAuth2Client: jest.fn(() => ({
    verifyIdToken: mockVerifyIdToken,
  })),
}));
jest.mock('apple-signin-auth', () => ({
  __esModule: true, // ES 모듈임을 명시
  default: {
    verifyIdToken: jest.fn(),
  },
}));

import { OAuth2Client } from 'google-auth-library';
import appleSignin from 'apple-signin-auth';
import { RedisClient } from '../utils/Redis.js';
import { db } from '../utils/DB.js';

describe('전체 애플리케이션 테스트', () => {

  // ==================================
  //         서비스 계층 테스트
  // ==================================

  describe('OAuthVerifyService', () => {
    beforeEach(() => {
      jest.clearAllMocks();
      process.env.GOOGLE_CLIENT_ID = 'test-google-client-id';
      process.env.APPLE_CLIENT_ID = 'test-apple-client-id';
    });

    it('Google 토큰을 성공적으로 검증해야 합니다', async () => {
      const mockPayload = { email: 'test@google.com', name: 'Test User', picture: 'url' };
      (new OAuth2Client()).verifyIdToken.mockResolvedValue({
        getPayload: () => mockPayload,
      });

      const result = await OAuthVerifyService.verifyGoogleToken('valid-google-token');
      expect(result).toEqual({
        email: mockPayload.email,
        name: mockPayload.name,
        picture: mockPayload.picture,
      });
      expect((new OAuth2Client()).verifyIdToken).toHaveBeenCalledWith({
        idToken: 'valid-google-token',
        audience: 'test-google-client-id',
      });
    });

    it('유효하지 않은 Google 토큰에 대해 에러를 던져야 합니다', async () => {
      (new OAuth2Client()).verifyIdToken.mockRejectedValue(new Error('Invalid token'));
      await expect(OAuthVerifyService.verifyGoogleToken('invalid-token')).rejects.toThrow('유효하지 않은 Google 토큰입니다.');
    });

    it('Apple 토큰을 성공적으로 검증해야 합니다', async () => {
      const mockPayload = { sub: 'apple-user-id', email: 'test@apple.com' };
      appleSignin.verifyIdToken.mockResolvedValue(mockPayload);

      const result = await OAuthVerifyService.verifyAppleToken('valid-apple-token');
      expect(result).toEqual({ sub: mockPayload.sub, email: mockPayload.email });
      expect(appleSignin.verifyIdToken).toHaveBeenCalledWith('valid-apple-token', {
        audience: 'test-apple-client-id',
      });
    });

    it('유효하지 않은 Apple 토큰에 대해 에러를 던져야 합니다', async () => {
      appleSignin.verifyIdToken.mockRejectedValue(new Error('Invalid token'));
      await expect(OAuthVerifyService.verifyAppleToken('invalid-token')).rejects.toThrow('유효하지 않은 Apple 토큰입니다.');
    });
  });

  describe('UserService', () => {
    beforeEach(() => {
      jest.restoreAllMocks();
    });

    it('ID로 사용자를 성공적으로 찾아야 합니다', async () => {
      const mockUser = { id: 1, email: 'test@test.com' };
      const getByIdSpy = jest.spyOn(User, 'getById').mockResolvedValue(mockUser);

      const user = await UserService.getUserById(1);
      expect(user).toEqual(mockUser);
      expect(getByIdSpy).toHaveBeenCalledWith(1);
    });

    it('ID로 사용자를 찾지 못하면 NotFoundError를 던져야 합니다', async () => {
      const getByIdSpy = jest.spyOn(User, 'getById').mockResolvedValue(null);
      await expect(UserService.getUserById(99)).rejects.toThrow('User not found');
    });
  });

  // ==================================
  //        미들웨어 계층 테스트
  // ==================================

  describe('authMiddleware', () => {
    let req, res, next;

    beforeEach(() => {
      jest.restoreAllMocks();
      req = { headers: {} };
      res = {};
      next = jest.fn();
    });

    it('유효한 토큰이 있으면 req.user를 설정하고 next()를 호출해야 합니다', async () => {
      req.headers.authorization = 'Bearer valid-token';
      const decoded = { userId: 1 };
      jest.spyOn(JwtService, 'verifyAccessToken').mockResolvedValue(decoded);

      await authMiddleware(req, res, next);

      expect(req.user).toEqual({ userId: 1 });
      expect(next).toHaveBeenCalledWith(); // 인자 없이 호출
    });

    it('토큰이 없으면 401 에러를 next()로 전달해야 합니다', async () => {
      await authMiddleware(req, res, next);

      expect(next).toHaveBeenCalledWith(expect.any(Error));
      const error = next.mock.calls[0][0];
      expect(error.status).toBe(401);
      expect(error.message).toBe('Authorization header missing or malformed');
    });

    it('만료된 토큰이면 에러를 next()로 전달해야 합니다', async () => {
      req.headers.authorization = 'Bearer expired-token';
      const tokenError = new Error('Token expired');
      jest.spyOn(JwtService, 'verifyAccessToken').mockRejectedValue(tokenError);

      await authMiddleware(req, res, next);

      expect(next).toHaveBeenCalledWith(tokenError);
    });
  });

  // ==================================
  //        컨트롤러/라우터 통합 테스트
  // ==================================

  describe('User Routes', () => {
    const app = express();
    app.use(express.json());
    app.use('/user', userRouter); // 실제 라우터 사용

    beforeEach(() => {
      // 각 테스트 전에 모킹된 함수들을 초기화
      jest.restoreAllMocks();
    });

    it('GET /user/:id - 사용자를 성공적으로 반환해야 합니다', async () => {
      const mockUser = { id: 1, email: 'user@example.com', password_hash: 'hashed' };
      // Service 계층을 모킹하여 DB 의존성 제거
      jest.spyOn(UserService, 'getUserById').mockResolvedValue(mockUser);

      const response = await request(app).get('/user/1');

      expect(response.status).toBe(200);
      expect(response.body).toEqual(mockUser);
      expect(UserService.getUserById).toHaveBeenCalledWith('1');
    });

    it('POST /user - 새 사용자를 생성해야 합니다', async () => {
      const newUser = { email: 'new@example.com', password: 'password123' };
      const createdUser = { id: 2, email: 'new@example.com' };
      jest.spyOn(UserService, 'registerUser').mockResolvedValue(createdUser);

      const response = await request(app)
        .post('/user')
        .send(newUser);

      expect(response.status).toBe(201);
      expect(response.body).toEqual(createdUser);
      expect(UserService.registerUser).toHaveBeenCalledWith(newUser.email, newUser.password);
    });
  });
});