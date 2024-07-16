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
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    console.error(`Failed to send notification to ${tokens[idx]}: ${resp.error}`);
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

exports.scheduledResetTasks = functions.pubsub.schedule('every day 00:00').timeZone('America/Sao_Paulo').onRun(async (context) => {
    const now = new Date();
    const day = now.getDate();
    const dayOfWeek = now.getDay();

    try {
        // Fetch all pets
        const petsSnapshot = await admin.firestore().collection('pets').get();

        // Iterate over all pets
        for (const petDoc of petsSnapshot.docs) {
            const petId = petDoc.id;

            // Reset daily tasks
            await resetTaskCollection(petId, 'dailyTasks');

            // Reset weekly tasks (assuming the week starts on Sunday)
            if (dayOfWeek === 0) {
                await resetTaskCollection(petId, 'weeklyTasks');
            }

            // Reset monthly tasks
            if (day === 1) {
                await resetTaskCollection(petId, 'monthlyTasks');
            }
        }

        console.log('Tasks reset successfully');
    } catch (error) {
        console.error('Error resetting tasks: ', error);
    }
});

async function resetTaskCollection(petId, taskField) {
    const petRef = admin.firestore().collection('pets').doc(petId);
    const petDoc = await petRef.get();

    if (!petDoc.exists) {
        console.log(`Pet with ID ${petId} does not exist.`);
        return;
    }

    const petData = petDoc.data();
    const taskGroups = petData[taskField] || [];

    const updatedTaskGroups = taskGroups.map(taskGroup => {
        const updatedInstances = taskGroup.instances.map(instance => {
            return { ...instance, completed: false, completedByUserID: null };
        });
        return { ...taskGroup, instances: updatedInstances };
    });

    const updatedData = { [taskField]: updatedTaskGroups };
    await petRef.update(updatedData);
}