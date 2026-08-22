const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

exports.sendDailyReminder = onSchedule(
  {
    schedule: "0 9 * * 1-5",
    timeZone: "America/Toronto",
  },
  async () => {
    const today = new Date();
    const todayStr = `${today.getFullYear()}-${today.getMonth() + 1}-${today.getDate()}`;

    const usersSnap = await db.collection("users").get();

    const sends = usersSnap.docs.map(async (doc) => {
      const data = doc.data();
      const token = data.fcmToken;
      const lastOpenDate = data.lastOpenDate;
      const streakCount = data.streakCount !== undefined ? data.streakCount : 0;
      const firstName = data.firstName !== undefined ? data.firstName : "there";

      if (!token) return;
      if (lastOpenDate === todayStr) return;

      if (streakCount >= 30) {
        const dayOfMonth = today.getDate();
        if (dayOfMonth % 3 !== 0) return;
      } else if (streakCount >= 14) {
        const dayOfYear = Math.floor(
          (today - new Date(today.getFullYear(), 0, 0)) / 86400000
        );
        if (dayOfYear % 2 !== 0) return;
      }

      await messaging.send({
        token,
        notification: {
          title: "Discreta",
          body: `Going for a showing today, ${firstName}? Tap to activate Discreta.`,
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
          },
        },
      });
    });

    await Promise.allSettled(sends);
  }
);