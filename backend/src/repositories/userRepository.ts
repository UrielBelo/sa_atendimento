import { PrismaClient, User, UserRole } from '@prisma/client';

const prisma = new PrismaClient();

export class UserRepository {
    async findByUsername(username:string): Promise<User | null> {
        return await prisma.user.findUnique({
            where: {
                username: username
            }
        });
    }

    async create(
        username:string,
        nickname:string | null,
        fullname:string,
        passwordHash:string,
        passwordSalt:string,
        lastRequest:Date,
        email:string,
        role:UserRole,
        systems:string[],
    ):Promise<User | null> {
        return prisma.user.create({
            data: {
                username: username,
                nickname: nickname,
                fullname: fullname,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                lastRequest: lastRequest,
                email: email,
                role: role,
                systems: systems
            }
        })
    }

    async updateLastRequest(id:string, lastRequest:Date):Promise<User | null> {
        return prisma.user.update({
            where: {
                id: id
            },
            data: {
                lastRequest: lastRequest
            }
        })
    }

    async updatePassword(id:string, passwordHash:string, passwordSalt:string):Promise<User | null> {
        return prisma.user.update({
            where: {
                id: id
            },
            data: {
                passwordHash: passwordHash,
                passwordSalt: passwordSalt
            }
        })
    }

    async update(id:string, data:Partial<User>):Promise<User | null> {
        return prisma.user.update({
            where: {
                id: id
            },
            data: data
        })
    }
}
