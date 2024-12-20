import express, { NextFunction, Response, Request } from 'express';
import { rateLimit } from 'express-rate-limit'
import { authRouter, homeRouter } from './routes';
import path from 'path';
import cors from 'cors';
import http from 'http'

const limiter = rateLimit({
	windowMs: 60, // 1 minute
	limit: 700, // Limit each IP to 500 requests per `window` (here, per minute).
	standardHeaders: 'draft-8', // draft-6: `RateLimit-*` headers; draft-7 & draft-8: combined `RateLimit` header
	legacyHeaders: false, // Disable the `X-RateLimit-*` headers.
})

function firstIPWallChecker(req:Request, res:Response, next:NextFunction) {
    const ip = req.ip
    if(ip == undefined) return res.status(403).json({ error: 'IP Não Informado' });

    next()
}

const app = express();
const PORT = process.env.PORT || 3003;
app.use(limiter);
app.use(express.json());
app.use(express.static(__dirname + '/web'))
app.use( (req:Request, res:Response, next:NextFunction) => {
    firstIPWallChecker(req,res, next)
})
app.use(cors())
app.get('/', (_,res:Response) => {
    res.setHeader('Cache-Control','public, max-age=600, immutable').sendFile(path.join(__dirname, './web/index.html'), {root: __dirname})
})

app.use('/auth', authRouter)
app.use('/home', homeRouter)

app.get('/ping', (_,res:Response) => {
    res.status(200).send('pong')
})

const httpServer = http.createServer(app);
httpServer.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});