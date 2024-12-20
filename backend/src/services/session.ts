import { UserRole } from "@prisma/client";
import { generateRandomHash } from "../util/hash";
import { generateSha256 } from "../util/sha256";
import { UserRepository } from "../repositories/userRepository";
import { SessionStorage } from "../util/sessionStorage";

export const SESSION_TTL = 1200000

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

export class SessionService {
    public static sessionStore:SessionStorage<UserSession> = new SessionStorage<UserSession>('sa-session')

    public async createSession(username:string, role:UserRole, ip:string, lastRequest:number, aesKey:string, aesIv:string, userAgent:string) {
        const sessionHash = generateRandomHash(64)
        const signToken = generateRandomHash(64)

        const userRepository = new UserRepository()

        const userData = await userRepository.findByUsername(username)
        if(!userData && username != 'admin') throw new Error('User not found')
            
        await SessionService.sessionStore.delete(generateSha256(username))
        await SessionService.sessionStore.set(generateSha256(username),{
            sessionHash,
            userId: userData?.id || generateSha256(username),
            role,
            ip,
            lastRequest,
            lastToken: signToken,
            aesKey,
            aesIv,
            userAgent: userAgent,
            userData: {
                email: userData?.email || 'admin@admin.com',
                nickname: userData?.nickname || 'Admin',
                fullname: userData?.fullname || 'Administrator',
                displayName: userData?.fullname || 'Administrator',
            }
        },SESSION_TTL)

        return {sessionHash, signToken }
    }
}