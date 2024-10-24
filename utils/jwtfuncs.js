import jwt from 'jsonwebtoken';
import dotenv from "dotenv";

dotenv.config();


export function setUser(data) {
    try {
        return jwt.sign(data, process.env.JWT_SECRET || 'notaverygoodsecret', { expiresIn: '4h' });
    } catch (err) {
        console.error('Token signing for user failed:', err);
        return null;
    }
}

export function getUser(token) {
    if (!token || typeof token !== 'string') {
        return null;
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'notaverygoodsecret');
        return decoded;
    } catch (err) {
        console.error('Token verification for user failed:', err);
        return null;
    }
}
