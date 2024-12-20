export function stringToHex(input: string): string {
    const buffer = Buffer.from(input, 'utf8');
    return buffer.toString('hex');
}

export function hexToString(hex: string): string {
    const buffer = Buffer.from(hex, 'hex');
    return buffer.toString('utf8');
}