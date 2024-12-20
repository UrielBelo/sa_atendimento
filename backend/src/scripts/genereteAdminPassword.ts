import { generateSha256 } from "../util/sha256";

export function generateAdminPassword(): string {
    const currentDatetime = new Date()
    const password = generateSha256( 
        currentDatetime.getDate().toString() +
        currentDatetime.getMonth().toString() +
        currentDatetime.getFullYear().toString() +
        'rq8TZY3amnYTDSkp'
    )
    console.log(password)
    return password
}

generateAdminPassword()