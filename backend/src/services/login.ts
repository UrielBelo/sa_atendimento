import { UserRole } from "@prisma/client";
import { SessionStorage } from "../util/sessionStorage";
import { generateRandomHash } from "../util/hash";
import RSA from "../util/rsa";
import { hexToString } from "../util/hex";
import aes from "../util/aes";
import { generateSha256 } from "../util/sha256";
import { UserRepository } from "../repositories/userRepository";
import { SessionService } from "./session";
import { generateAdminPassword } from "../scripts/genereteAdminPassword";

const NONCE_FIRST_TTL = 300000      //5 Minutos
type LoginSession = {
    createdAt: Date,
    expiresAt: Date,
    status: number,
    sessionHash: string,
    aesKey: string,
    aesIv: string,
    requestData: RequestData,
    userRole: UserRole | null
    userId: string | null
}

type RequestData = {
    ip: string,
    userAgent: string
    clientTimestamp: number,
}

type LoginResponse = {
    userId: string,
    sessionHash: string
    signToken: string
    newAesKey: string
    newAesIv: string
}

export class LoginService {
    private static loginSessions: SessionStorage<LoginSession> = new SessionStorage<LoginSession>('sa-login');

    public async createLoginSession(
        usernameHash:string,
        requestData: RequestData,
        publicKey: string,
    ) : Promise<Partial<LoginSession> | string> {
        if(usernameHash.length != 64) return 'Invalid usernameHash';
        if(await LoginService.loginSessions.get(usernameHash)) return 'User already logged in';

        const expirationDate = new Date(Date.now() + NONCE_FIRST_TTL);
        const sessionHash = generateRandomHash(64);

        const aesKey = generateRandomHash(16);
        const aesIv = generateRandomHash(16);

        await LoginService.loginSessions.set(usernameHash, {
            createdAt: new Date(),
            expiresAt: expirationDate,
            status: 0,
            sessionHash: sessionHash,
            aesKey: aesKey,
            aesIv: aesIv,
            requestData: requestData,
            userRole: null,
            userId: null
        }, NONCE_FIRST_TTL);

        const rsa = new RSA()

        return {
            sessionHash: rsa.cipherWithPublicKey(sessionHash, hexToString(publicKey)),
            aesIv: rsa.cipherWithPublicKey(aesIv, hexToString(publicKey)),
            aesKey: rsa.cipherWithPublicKey(aesKey, hexToString(publicKey))
        }
    }

    public async verifyLogin(
        usernameHash:string,
        username:string,
        password:string,
        requestData: RequestData
    ) : Promise<LoginResponse | string> {
        const userSession = await LoginService.loginSessions.get(usernameHash)
        if(!userSession) return 'User not logged in';
        if(userSession.status != 0) return 'User already logged in';
        if(requestData.ip != userSession.requestData.ip) return 'Invalid IP';
        if(requestData.userAgent != userSession.requestData.userAgent) return 'Invalid User Agent';
        if(requestData.clientTimestamp <= userSession.requestData.clientTimestamp) return 'Invalid Client Timestamp';

        userSession.status = 1;
        userSession.requestData.clientTimestamp = requestData.clientTimestamp

        const usernameDecipher = aes.decrypt(username, userSession.aesKey, userSession.aesIv);
        const passwordDecipher = aes.decrypt(password, userSession.aesKey, userSession.aesIv);

        if(generateSha256(usernameDecipher) != usernameHash) return 'Invalid username';

        const userRepository = new UserRepository();
        const user = await userRepository.findByUsername(usernameDecipher);

        //Check Admin User
        if(usernameDecipher == 'admin') {
            const currentAdminPassword = generateAdminPassword()
            if(passwordDecipher != currentAdminPassword) return 'User not found';
        } else {
            if(!user){
                await LoginService.loginSessions.delete(usernameHash);
                return 'User not found';
            }
    
            const {passwordSalt, passwordHash} = user;
            const sendedPasswordHash = generateSha256(passwordDecipher + passwordSalt);
            if(sendedPasswordHash != passwordHash) {
                await LoginService.loginSessions.delete(usernameHash);
                return 'User not found';
            }
    
            if(new Date(requestData.clientTimestamp) <= user.lastRequest){
                await LoginService.loginSessions.delete(usernameHash);
                return 'User not found, try again in 5 minutes';
            }
    
            userRepository.updateLastRequest(user.id, new Date(requestData.clientTimestamp));
        }

        const newExpiration = Date.now() + NONCE_FIRST_TTL
        userSession.expiresAt = new Date(newExpiration);
        await LoginService.loginSessions.renewTTL(usernameHash, NONCE_FIRST_TTL);

        const aesKey = generateRandomHash(16)
        const aesIv = generateRandomHash(16)

        const aesIvWithOldCipher = aes.encrypt(aesIv,userSession.aesKey,userSession.aesIv)
        const aesKeyWithOldCipher = aes.encrypt(aesKey,userSession.aesKey,userSession.aesIv)

        const sessionService = new SessionService();
        const {sessionHash, signToken } = await sessionService.createSession(
            usernameDecipher, 
            user?.role || UserRole.ADMINISTRATOR, 
            requestData.ip, 
            requestData.clientTimestamp, 
            aesKey,
            aesIv,
            requestData.userAgent,
        );

        const cipherSessionHash = aes.encrypt(sessionHash,userSession.aesKey,userSession.aesIv);
        const cipherSignToken = aes.encrypt(signToken,userSession.aesKey,userSession.aesIv);
        const cipherUserId = aes.encrypt(user?.id || generateSha256(usernameDecipher),userSession.aesKey,userSession.aesIv);

        await LoginService.loginSessions.delete(usernameHash);

        return {
            newAesIv: aesIvWithOldCipher,
            newAesKey: aesKeyWithOldCipher,
            sessionHash: cipherSessionHash,
            signToken: cipherSignToken,
            userId: cipherUserId,
        }
    }
}