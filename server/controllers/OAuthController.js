import { verifyGoogleToken, verifyAppleToken } from "../utils/Oauth.js";
import { db } from "../utils/DB.js";
import { User } from "../models/User/User.js";

export class OAuthController {
    static async googleLogin(req, res) {
        const { idToken } = req.body;

        try {
            const googleUser = await verifyGoogleToken(idToken);
            if (!googleUser) {
                return res.status(401).json({ message: "Invalid Google token" });
            }

            let user = await db.read('users', { email: googleUser.email });
            if (!user) {
                user = new User(googleUser.name);
                user.email = googleUser.email;
                await user.save();
            }

            return res.status(200).json({ message: "Login successful", user });
        } catch (error) {
            console.error("Google login error:", error);
            return res.status(500).json({ message: "Internal server error" });
        }
    }


    static async appleLogin(req, res) {
        const { idToken } = req.body;

        try {
            const appleUser = await verifyAppleToken(idToken);
            if (!appleUser) {
                return res.status(401).json({ message: "Invalid Apple token" });
            }

            let user = await db.read('users', { email: appleUser.email });
            if (!user) {
                user = new User(appleUser.name);
                user.email = appleUser.email;
                await user.save();
            }

            return res.status(200).json({ message: "Login successful", user });
        } catch (error) {
            console.error("Apple login error:", error);
            return res.status(500).json({ message: "Internal server error" });
        }
    }
}