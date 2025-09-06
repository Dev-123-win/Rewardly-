const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkIn = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().collection("users").doc(userId);

  try {
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User document not found.");
    }

    const userData = userDoc.data();
    const now = admin.firestore.Timestamp.now();
    const today = new Date(now.toMillis());
    today.setHours(0, 0, 0, 0);

    const lastCheckIn = userData.lastCheckIn?.toDate();
    if (lastCheckIn) {
        const lastCheckInDate = new Date(lastCheckIn.getTime());
        lastCheckInDate.setHours(0, 0, 0, 0);
        if (lastCheckInDate.getTime() === today.getTime()) {
            throw new functions.https.HttpsError(
                "already-exists",
                "User has already checked in today."
            );
        }
    }

    let newStreak = 1;
    if (lastCheckIn) {
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
      yesterday.setHours(0, 0, 0, 0);
      const lastCheckInDate = new Date(lastCheckIn.getTime());
      lastCheckInDate.setHours(0, 0, 0, 0);

      if (lastCheckInDate.getTime() === yesterday.getTime()) {
        newStreak = userData.streak + 1;
      }
    }

    let pointsEarned = 10;
    if (newStreak % 30 === 0) {
      pointsEarned += 250;
    } else if (newStreak % 14 === 0) {
      pointsEarned += 100;
    } else if (newStreak % 7 === 0) {
      pointsEarned += 50;
    } else if (newStreak % 3 === 0) {
      pointsEarned += 20;
    }

    const batch = admin.firestore().batch();

    batch.update(userRef, {
      lastCheckIn: now,
      streak: newStreak,
      points: admin.firestore.FieldValue.increment(pointsEarned),
    });

    const checkInRef = admin.firestore().collection("daily_check_ins").doc();
    batch.set(checkInRef, {
      userId: userId,
      timestamp: now,
    });

    await batch.commit();

    return { pointsEarned, newStreak };
  } catch (error) {
    console.error("Check-in failed:", error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
      "internal",
      "An unexpected error occurred."
    );
  }
});
