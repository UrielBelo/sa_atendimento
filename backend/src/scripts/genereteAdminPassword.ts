import { generateSha256 } from "../util/sha256";

export function generateAdminPassword(): string {
    const currentDatetime = new Date()
    const password = 
        currentDatetime.getDate().toString() +
        currentDatetime.getMonth().toString() +
        currentDatetime.getFullYear().toString() +
        'rq8TZY3amnYTDSkp'
    console.log(password)
    return generateSha256(password)
}

generateAdminPassword()