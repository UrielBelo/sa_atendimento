import { createHash } from 'crypto';

export function generateSha256(input: string): string {
    return createHash('sha256').update(input).digest('hex');
}