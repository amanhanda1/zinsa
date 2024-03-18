const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteOldAlerts = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
      const cutoffTime = Date.now() - 24 * 60 * 60 * 1000; // 24 hours ago
      const alertsRef = admin.firestore().collection("Alerts");

      const snapshot = await alertsRef
          .where("timestamp", "<", new Date(cutoffTime))
          .get();

      const batch = admin.firestore().batch();
      snapshot.forEach((doc) => {
        batch.delete(doc.ref);
      });

      return batch.commit();
    });
