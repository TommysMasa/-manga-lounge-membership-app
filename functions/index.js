const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp, FieldValue } = require("firebase-admin/firestore");

initializeApp();

// Shared secret set as the Authorization header in the RevenueCat
// webhook configuration. Create it with:
//   firebase functions:secrets:set REVENUECAT_WEBHOOK_AUTH
const webhookAuth = defineSecret("REVENUECAT_WEBHOOK_AUTH");

// Event types after which the entitlement is (still) active
const ACTIVATING_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "SUBSCRIPTION_EXTENDED",
  // Promotional entitlement grants (dashboard comps) arrive as
  // NON_RENEWING_PURCHASE with store == "PROMOTIONAL"
  "NON_RENEWING_PURCHASE",
  // CANCELLATION only turns off auto-renew; access lasts until EXPIRATION
  "CANCELLATION",
  "BILLING_ISSUE",
]);

// Event types after which the entitlement is gone
const DEACTIVATING_EVENTS = new Set(["EXPIRATION", "SUBSCRIPTION_PAUSED"]);

const DEFAULT_PRO_CAP = 150;

function isAnonymous(appUserId) {
  return typeof appUserId !== "string" || appUserId.startsWith("$RCAnonymousID:");
}

function subscriptionDoc(db, uid) {
  return db.collection("subscriptions").doc(uid);
}

function proCapDoc(db) {
  return db.collection("config").doc("proCap");
}

/**
 * Writes subscriptions/{uid} and adjusts config/proCap.activeCount only when
 * the stored isPro flag actually flips (renewals must not inflate the count).
 *
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} uid
 * @param {boolean} isPro
 * @param {Object} data - fields to merge onto the subscription doc (includes isPro)
 */
async function setSubscriptionAndAdjustCap(db, uid, isPro, data) {
  const subRef = subscriptionDoc(db, uid);
  const capRef = proCapDoc(db);

  await db.runTransaction(async (tx) => {
    const subSnap = await tx.get(subRef);
    const capSnap = await tx.get(capRef);

    const wasPro = subSnap.exists === true && subSnap.data().isPro === true;

    tx.set(subRef, data, { merge: true });

    if (wasPro === isPro) return;

    const limit =
      capSnap.exists && typeof capSnap.data().limit === "number"
        ? capSnap.data().limit
        : DEFAULT_PRO_CAP;
    const current =
      capSnap.exists && typeof capSnap.data().activeCount === "number"
        ? capSnap.data().activeCount
        : 0;
    const next = Math.max(0, current + (isPro ? 1 : -1));

    tx.set(
      capRef,
      {
        limit,
        activeCount: next,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });
}

/**
 * RevenueCat webhook receiver.
 *
 * Keeps `subscriptions/{uid}` in Firestore in sync with App Store /
 * Google Play purchases and promotional grants managed by RevenueCat.
 * Also maintains `config/proCap` (soft launch seat counter).
 *
 * Configure in RevenueCat: Project settings > Integrations > Webhooks,
 * with the function URL and the REVENUECAT_WEBHOOK_AUTH value as the
 * Authorization header.
 */
exports.revenuecatWebhook = onRequest(
  // Public invoker: callers are authenticated by the Authorization
  // header check below, not by IAM.
  { secrets: [webhookAuth], region: "us-central1", invoker: "public" },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    if (req.headers.authorization !== webhookAuth.value()) {
      console.warn("Webhook rejected: bad authorization header");
      res.status(401).send("Unauthorized");
      return;
    }

    const event = req.body && req.body.event;
    if (!event || !event.type) {
      res.status(400).send("Missing event");
      return;
    }

    const db = getFirestore();
    const type = event.type;
    console.log(`RevenueCat event: ${type} for ${event.app_user_id}`);

    try {
      if (type === "TRANSFER") {
        // Purchases moved between users (e.g. restore on a new account):
        // deactivate the old user(s), activate the new one(s).
        const from = (event.transferred_from || []).filter((id) => !isAnonymous(id));
        const to = (event.transferred_to || []).filter((id) => !isAnonymous(id));

        for (const uid of from) {
          await setSubscriptionAndAdjustCap(db, uid, false, {
            isPro: false,
            source: "revenuecat",
            updatedAt: FieldValue.serverTimestamp(),
            lastEvent: type,
          });
        }
        for (const uid of to) {
          await setSubscriptionAndAdjustCap(db, uid, true, {
            isPro: true,
            source: "revenuecat",
            updatedAt: FieldValue.serverTimestamp(),
            lastEvent: type,
          });
        }
        res.status(200).send("OK");
        return;
      }

      const appUserId = event.app_user_id;
      if (isAnonymous(appUserId)) {
        // Cannot map to a Firebase user; the TRANSFER event that follows
        // a login will reconcile the state.
        console.log("Skipping anonymous user event");
        res.status(200).send("OK (anonymous)");
        return;
      }

      let isPro;
      if (ACTIVATING_EVENTS.has(type)) {
        isPro = true;
      } else if (DEACTIVATING_EVENTS.has(type)) {
        isPro = false;
      } else {
        // TEST, INVOICE_ISSUANCE, etc: nothing to sync
        res.status(200).send("OK (ignored)");
        return;
      }

      const data = {
        isPro,
        // PROMOTIONAL = granted via API/dashboard (comp), otherwise store IAP
        source: event.store === "PROMOTIONAL" ? "promotional" : "revenuecat",
        productId: event.product_id || null,
        updatedAt: FieldValue.serverTimestamp(),
        lastEvent: type,
      };
      if (event.expiration_at_ms) {
        data.expiresAt = Timestamp.fromMillis(event.expiration_at_ms);
      }

      await setSubscriptionAndAdjustCap(db, appUserId, isPro, data);
      res.status(200).send("OK");
    } catch (error) {
      console.error("Webhook processing failed", error);
      // Non-2xx makes RevenueCat retry the delivery later
      res.status(500).send("Internal error");
    }
  }
);
