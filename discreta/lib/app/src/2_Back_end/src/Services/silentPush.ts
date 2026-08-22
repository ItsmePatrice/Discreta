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

async function sendVisiblePushToAllActiveUsers(): Promise<void> {
  try {
    const usersSnapshot = await db
      .collection("users")
      .where("fcmToken", "!=", null)
      .get();

    const promises = usersSnapshot.docs.map((doc) => {
      const token = doc.data().fcmToken;
      const firstName = doc.data().firstName;

      if (!token || !firstName) return Promise.resolve();

      return admin.messaging().send({
        token,
        notification: {
          title: "Discreta",
          body: `Hey ${firstName}, heading out for a showing? Open Discreta before you go 🔒`,
        },
        apns: {
          headers: {
            "apns-priority": "10",
            "apns-push-type": "alert",
          },
          payload: {
            aps: {
              "content-available": 1,
              sound: "default",
            },
          },
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "discreta_reminders",
          },
        },
      }).catch((err) => {
        logger.error(`Visible push failed for ${doc.id}: ${err.message}`);
      });
    });

    await Promise.all(promises);
    logger.info(`Visible push sent to ${usersSnapshot.docs.length} users`);

  } catch (err: any) {
    logger.error(`sendVisiblePushToAllActiveUsers error: ${err.message}`);
  }
}


// Visible push notification — 9am daily, Montreal time (handles EST/EDT automatically)
cron.schedule("0 9 * * *", () => {
  logger.info("Cron fired — sending visible push notification");
  sendVisiblePushToAllActiveUsers();
}, {
  timezone: "America/Toronto",
});