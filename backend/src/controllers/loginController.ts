import requestError from '../helper/requestError';
import { LoginService } from '../services/login';
import { Request, Response } from 'express';
export class LoginController {
    static async preLogin(req:Request, res:Response):Promise<void> {
        try {
            const { usernameHash, publicKey, timestamp } = req.body
            const ip = req.ip
            const userAgent = req.headers['user-agent']

            if(!ip){
                res.status(403).json({error: 'Invalid IP'});
                return
            }

            const loginService = new LoginService();
            const loginSession = await loginService.createLoginSession(
                usernameHash,
                {
                    ip, 
                    userAgent: (userAgent || 'Unkown User Agent'),
                    clientTimestamp: timestamp
                }, 
                publicKey
            );
            if(typeof loginSession === 'string') {
                res.status(403).json({error: loginSession});
                return
            }

            res.status(200).json(loginSession);
            return
        } catch (error) {
            requestError(error, res)
            return
        }
    }

    static async login(req:Request, res:Response):Promise<void> {
        try {
            const { usernameHash, username, password, timestamp } = req.body
            const ip = req.ip
            const userAgent = req.headers['user-agent']

            if(!ip){
                res.status(403).json({error: 'Invalid IP'});
                return
            }

            const loginService = new LoginService();
            const loginResponse = await loginService.verifyLogin(
                usernameHash,
                username,
                password,
                {
                    ip, 
                    userAgent: (userAgent || 'Unkown User Agent'),
                    clientTimestamp: timestamp
                }
            );
            if(typeof loginResponse === 'string') {
                res.status(403).json({error: loginResponse});
                return
            }

            res.status(200).json(loginResponse);
            return
        } catch (error) {
            requestError(error, res)
            return
        }
    }
}