import { Router } from "express";
import { LoginController } from "./controllers/loginController";
import { UserImageController } from "./controllers/userImageController";
import { authMiddleware } from "./middleware/auth_middleware";

const authRouter = Router();
const homeRouter = Router();

authRouter.post('/prelogin', LoginController.preLogin);
authRouter.post('/login', LoginController.login);

homeRouter.get('/userImage/:userId', authMiddleware , UserImageController.getUserImage);

export { authRouter, homeRouter };