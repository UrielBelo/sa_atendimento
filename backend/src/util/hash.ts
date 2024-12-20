import { getRandomIntInclusive } from "./random"

const _charmap = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0987654321@()!#[]{}*-+"

export function generateRandomHash(size:number):string {
    const randomHash:string[] = []
    for(let i = 0; i < size; i++){
        randomHash.push(_charmap[getRandomIntInclusive(0,_charmap.length - 1)])
    }
    return randomHash.join('')
}