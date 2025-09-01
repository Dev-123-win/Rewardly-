const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.setAdmin = functions.https.onCall(async (data, context) => {
  // Check if the user is an admin.
  if (context.auth.token.admin !== true) {
    return { error: "Only admins can set other admins." };
  }

  // Get the user and set the custom claim.
  const user = await admin.auth().getUser(data.uid);
  await admin.auth().setCustomUserClaims(user.uid, {
    admin: data.isAdmin,
  });

  return { message: `Success! ${user.email} is now an admin.` };
});
