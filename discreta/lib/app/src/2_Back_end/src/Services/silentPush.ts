import logger from "../logs";
import * as admin from "firebase-admin";
import * as cron from "node-cron";
import * as path from "path";

// Initialize Firebase Admin only once
if (!admin.apps.length) {
  const serviceAccount = require(path.join(__dirname, "../../serviceAccountKey.json"));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

async function sendSilentPushToAllActiveUsers(): Promise<void> {
  try {
    const usersSnapshot = await db
      .collection("users")
      .where("fcmToken", "!=", null)
      .get();

    const promises = usersSnapshot.docs.map((doc) => {
      const token = doc.data().fcmToken;
      if (!token) return Promise.resolve();

      return admin.messaging().send({
        token,
        apns: {
          headers: {
            "apns-priority": "5",
            "apns-push-type": "background",
          },
          payload: {
            aps: {
              "content-available": 1,
            },
          },
        },
      }).catch((err) => {
        logger.error(`Silent push failed for ${doc.id}: ${err.message}`);
      });
    });

    await Promise.all(promises);
    logger.info(`Silent push sent to ${usersSnapshot.docs.length} users`);

  } catch (err: any) {
    logger.error(`sendSilentPushToAllActiveUsers error: ${err.message}`);
  }
}

// 4x daily during business hours — stays under Apple's ~5/day throttle limit
cron.schedule("0 9,12,15,18 * * *", () => {
  logger.info("Cron fired — sending silent push");
  sendSilentPushToAllActiveUsers();
});
