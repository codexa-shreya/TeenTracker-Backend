import { Router } from 'express';
import healthRoutes from './healthRoutes.js';
import systemRoutes from './systemRoutes.js';
import categoryRoutes from './categoryRoutes.js';

const apiRouter = Router();

// Sub-domain routes
apiRouter.use('/health', healthRoutes);
apiRouter.use('/system', systemRoutes);
apiRouter.use('/categories', categoryRoutes);

export default apiRouter;
