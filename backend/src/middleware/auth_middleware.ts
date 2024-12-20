import { SESSION_TTL, SessionService } from '../services/session';
import aes from '../util/aes';
import { Request, Response, NextFunction } from 'express';
import { generateSha256 } from '../util/sha256';
import { generateRandomHash } from '../util/hash';

type UserSession = {
    sessionHash: string
    userId: string,
    role: string,
    ip: string,
    userAgent: string,
    lastRequest: number,
    lastToken: string,
    aesKey: string,
    aesIv: string,
    userData: UserData
}
type UserData = {
    email: string,
    nickname: string | null,
    fullname: string,
    displayName: string,
}

declare global {
    namespace Express {
        interface Request {
        user?: {
            session:UserSession,
                [key: string]: any; // Para propriedades adicionais
            } 
        }
    }
}

export const authMiddleware = async (req:Request, res:Response, next:NextFunction) => {
    try {
        const userHash = req.headers['x-user-hash'] as string;
        const cipherToken = req.headers['x-authorization'] as string;
        const scrambler = req.headers['x-scrambler'] as string;
        const cipherClientTimestamp = req.headers['x-client-timestamp'] as string;
        const cipherRequestToken = req.headers['x-request-token'] as string;
        const clientIp = req.ip;
        const userAgent = req.headers['user-agent'] as string;

        if (!cipherToken || !scrambler || !cipherClientTimestamp || !clientIp || !cipherRequestToken || !userHash) {
            res.status(401).json({ error: 'Missing authentication headers' });
            return
        }

        const userSession = await SessionService.sessionStore.get(userHash);
        if (!userSession) {
            res.status(401).json({ error: 'User session not found' });
            return 
        }
        if (clientIp != userSession.ip) {
            res.status(401).json({ error: 'IP mismatch' });
            return 
        }
        if (userAgent != userSession.userAgent) {
            res.status(401).json({ error: 'User agent mismatch' });
            return
        }

        const aesKey = userSession.aesKey;
        const aesIv = userSession.aesIv;
        const lastToken = userSession.lastToken

        const decipherToken = aes.decrypt(cipherToken, aesKey, aesIv);
        const clientTimestamp = parseInt(aes.decrypt(cipherClientTimestamp, aesKey, aesIv));
        const requestProove = aes.decrypt(cipherRequestToken, aesKey, aesIv);

        const [ rawSessionHash, receivedTimestamp , receivedScrambler ] = decipherToken.split(':');
        if (receivedScrambler !== scrambler) {
            res.status(401).json({ error: 'Scrambler mismatch' });
            return 
        }

        if (receivedTimestamp !== clientTimestamp.toString()) {
            res.status(401).json({ error: 'Timestamp mismatch' });
            return 
        }

        if (userSession.lastRequest >= clientTimestamp) {
            res.status(401).json({ error: 'Request timestamp is too old' });
            return 
        }
        let resultToken = generateSha256(lastToken + requestProove).startsWith('00')

        if (!resultToken) {
            res.status(401).json({ error: 'Request token is invalid' });
            return 
        }

        if(rawSessionHash !== userSession.sessionHash){
            res.status(401).json({ error: 'Session hash mismatch' });
            return 
        }
        const newSignToken = generateRandomHash(64)
        userSession.lastToken = newSignToken
        userSession.lastRequest = clientTimestamp

        await SessionService.sessionStore.update(userHash, userSession, SESSION_TTL);

        res.setHeader('x-sign-token', aes.encrypt(newSignToken, aesKey, aesIv));
        res.setHeader('Cache-Control','no-cache, no-store, must-revalidate');
        req.user = {
            session: userSession
        }

        next();
    } catch (error) {
        res.status(401).json({ error: 'Authentication failed' });
        return 
    }
}