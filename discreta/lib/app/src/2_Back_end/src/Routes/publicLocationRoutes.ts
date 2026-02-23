import express from 'express';
const router = express.Router();
import path from 'path';

router.get('/track/:token', (req, res) => {
  res.sendFile(
    path.join(__dirname, '../public/alert.html')
  );
});

export default router;