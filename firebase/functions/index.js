/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendTaskCompletedNotification = functions.https.onCall(async (data, context) => {
    const groupID = data.groupID;
    const userID = data.userID;
    const title = data.title;
    const body = data.body;

    if (!groupID || !userID || !title || !body) {
        console.error("Missing groupID, userID, title or body.");
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
            'arguments "groupID", "userID", "title" and "body".');
    }

    try {
        // Fetch all users in the group except the current user
        const usersSnapshot = await admin.firestore().collection('users')
            .where('groupID', '==', groupID).get();

        const tokens = [];
        usersSnapshot.forEach(doc => {
            const data = doc.data();
            if (data.fcmToken && doc.id !== userID) {
                tokens.push(data.fcmToken);
            }
        });

        if (tokens.length === 0) {
            throw new Error('No FCM tokens found for users in the group.');
        }

        const message = {
            notification: {
                title: title,
                body: body
            },
            tokens: tokens
        };

        const response = await admin.messaging().sendMulticast(message);

        if (response.failureCount > 0) {
            const errors = [];
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    console.error(`Failed to send notification to ${tokens[idx]}: ${resp.error}`);
                    errors.push(resp.error);
                }
            });
            return { success: false };
        }

        return { success: true };

    } catch (error) {
        console.error("Error sending notification:", error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});
