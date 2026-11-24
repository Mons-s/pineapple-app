const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

const STATUS_MESSAGES = {
  confirmed: {
    title: "Order confirmed ✅",
    body: "Your FreshPine order has been confirmed by the farm.",
  },
  out_for_delivery: {
    title: "On the way 🚚",
    body: "Your pineapples are on their way to you!",
  },
  delivered: {
    title: "Delivered! 🍍",
    body: "Your order has been delivered. Enjoy your fresh pineapples!",
  },
  cancelled: {
    title: "Order cancelled",
    body: "Your FreshPine order has been cancelled. Contact us if you have questions.",
  },
};

exports.notifyBuyerOnStatusChange = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.status === after.status) return null;

    const msgContent = STATUS_MESSAGES[after.status];
    if (!msgContent) return null;

    const buyerId = after.buyerId;
    if (!buyerId || buyerId === "guest") return null;

    const db = getFirestore();
    const userDoc = await db.doc(`users/${buyerId}`).get();
    const token = userDoc.data()?.fcmToken;
    if (!token) return null;

    try {
      await getMessaging().send({
        token,
        notification: {
          title: msgContent.title,
          body: msgContent.body,
        },
        android: {
          notification: {
            channelId: "freshpine_orders",
            priority: "high",
          },
        },
      });
    } catch (err) {
      console.error("FCM send failed for order", event.params.orderId, err);
    }

    return null;
  }
);
