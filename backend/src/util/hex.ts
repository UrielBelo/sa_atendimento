const charmap = '0123456789abcdef';

export function stringToHex(input: string): string {
    const buffer = Buffer.from(input, 'utf8');
    return buffer.toString('hex');
}

export function hexToString(hex: string): string {
    const buffer = Buffer.from(hex, 'hex');
    return buffer.toString('utf8');
}

export function parseHex(hex: string): string {
    let result = ''
    for (let i = 0; i < hex.length; i++) {
        if(charmap.indexOf(hex[i]) !== -1){
            result += hex[i]
        }
    }
    return result
}