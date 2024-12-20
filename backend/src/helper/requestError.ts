import { Response } from 'express';

function requestError (error:unknown, res:Response) : Response {
    if(error instanceof Error) {
        return res.status(500).json({error: error.message})
    } else {
        return res.status(500).json({error: 'Falha Catastrófica ao processar requisição'})
    }
}

export default requestError