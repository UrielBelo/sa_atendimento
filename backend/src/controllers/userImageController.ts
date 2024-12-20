import { parseHex } from '../util/hex';
import requestError from '../helper/requestError';
import { Request, Response } from 'express';
import fs from 'fs';

export class UserImageController {
    static async getUserImage(req:Request, res:Response) : Promise<void> {
        try {
            const { userId } = req.params;
            const userIdParsed = parseHex(userId);
            const userImagePath = `./assets/users/${userIdParsed}.png`;
            const userImage = fs.readFileSync(userImagePath);

            if(!userImage) {
                res.status(404).json({error: 'User image not found'});
                return
            }

            res.status(200).json({
                'image': `data:image/png;base64,${userImage.toString('base64')}`
            });
            return
        } catch (error) {
            requestError(error, res);
            return
        }
    }
}