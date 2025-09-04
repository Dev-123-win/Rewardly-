const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.setAdmin = functions.https.onCall(async (data, context) => {
  if (context.auth.token.admin !== true) {
    return {error: "Only admins can set other admins."};
  }
  const user = await admin.auth().getUser(data.uid);
  await admin.auth().setCustomUserClaims(user.uid, {
    admin: data.isAdmin,
  });

  return {message: `Success! ${user.email} is now an admin.`};
});

exports.resetDailyStats = functions.pubsub.schedule("every 24 hours").onRun(async (context) => {
  const usersRef = admin.firestore().collection("users");
  const snapshot = await usersRef.get();

  const promises = [];
  const now = new Date();

  snapshot.forEach((doc) => {
    const user = doc.data();
    const lastAdDate = user.lastAdWatchedDate ? user.lastAdWatchedDate.toDate() : null;
    let dailyStreak = user.dailyStreak || 0;

    if (lastAdDate) {
      const diff = now.getTime() - lastAdDate.getTime();
      const hours = diff / (1000 * 60 * 60);

      if (hours >= 24 && hours < 48) {
        // User watched an ad yesterday, so the streak is maintained.
        // We don't increment it here, that happens when they watch an ad today.
      } else if (hours >= 48) {
        // It's been more than 48 hours, so reset the streak.
        dailyStreak = 0;
      }
    } else {
        dailyStreak = 0;
    }


    promises.push(doc.ref.update({
      adsWatchedToday: 0,
      dailyStreak: dailyStreak,
    }));
  });

  await Promise.all(promises);
  console.log("Daily stats reset for all users.");
  return null;
});
