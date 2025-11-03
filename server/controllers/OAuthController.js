import { db } from "../utils/DB.js";
import { User } from "../models/User/User.js";
import { OAuthVerifyService } from "../services/Auth/OAuthService.js";

export class OAuthController {
    static async googleLogin(req, res) {
        const idToken = req.query.idToken;
        if (!idToken) {
            return res.status(400).json({ error: 'ID 토큰이 필요합니다.' });
        }

        try {
            const googleUser = await OAuthVerifyService.verifyGoogleToken(idToken);

            // 이메일로 사용자 조회
            let user = await User.getByEmail(googleUser.email);
            if (!user) {
                // 사용자가 없으면 새로 생성
                const newUser = new User(googleUser.email, null, googleUser.name, googleUser.picture);
                const result = await newUser.save();
                user = await User.getById(result.insertId);
            }
        } catch (error) {
            return res.status(401).json({ error: error.message });
        }

        // 성공적으로 로그인 처리
        res.status(200).json({ message: 'Google 로그인 성공', user });
    }

    static async appleLogin(req, res) {
        const idToken = req.query.idToken;
        if (!idToken) {
            return res.status(400).json({ error: 'ID 토큰이 필요합니다.' });
        }

        try {
            const appleUser = await OAuthVerifyService.verifyAppleToken(idToken);

            // 이메일로 사용자 조회
            let user = await User.getByEmail(appleUser.email);
            if (!user) {
                // 사용자가 없으면 새로 생성
                const newUser = new User(appleUser.email, null);
                const result = await newUser.save();
                user = await User.getById(result.insertId);
            }
        } catch (error) {
            return res.status(401).json({ error: error.message });
        }

        // 성공적으로 로그인 처리
        res.status(200).json({ message: 'Apple 로그인 성공', user });
    }

}