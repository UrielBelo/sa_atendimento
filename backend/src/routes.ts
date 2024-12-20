import { Router } from "express";
import { LoginController } from "./controllers/loginController";

const authRouter = Router();

authRouter.post('/prelogin', LoginController.preLogin);
authRouter.post('/login', LoginController.login);

export { authRouter };