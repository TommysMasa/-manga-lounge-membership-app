const crypto = require("crypto");

const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret, defineString } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp, FieldValue } = require("firebase-admin/firestore");

initializeApp();

// Shared secret set as the Authorization header in the RevenueCat
// webhook configuration. Create it with:
//   firebase functions:secrets:set REVENUECAT_WEBHOOK_AUTH
const webhookAuth = defineSecret("REVENUECAT_WEBHOOK_AUTH");

// --- Square integration configuration ---
// Secrets (set with `firebase functions:secrets:set <NAME>`):
//   SQUARE_ACCESS_TOKEN            Square API access token
//   SQUARE_WEBHOOK_SIGNATURE_KEY   Signature key of the Square webhook subscription
//   REVENUECAT_SECRET_KEY          RevenueCat secret API key (sk_...)
const squareAccessToken = defineSecret("SQUARE_ACCESS_TOKEN");
const squareSignatureKey = defineSecret("SQUARE_WEBHOOK_SIGNATURE_KEY");
const revenueCatSecretKey = defineSecret("REVENUECAT_SECRET_KEY");

// Params (set in functions/.env or on first deploy):
//   SQUARE_NOTIFICATION_URL  Exact webhook URL configured in Square (used
//                            for signature verification)
//   SQUARE_API_BASE          https://connect.squareup.com (production) or
//                            https://connect.squareupsandbox.com (sandbox)
const squareNotificationUrl = defineString("SQUARE_NOTIFICATION_URL", {
  default: "",
});
const squareApiBase = defineString("SQUARE_API_BASE", {
  default: "https://connect.squareup.com",
});

// Must match the entitlement identifier in the RevenueCat dashboard
const RC_ENTITLEMENT_ID = "Manga Lounge Memberapp Pro";

// Recurring invoices created from the POS Invoices add-on have no
// subscription_id, so membership invoices are recognized by their title
// instead. Staff must include this phrase in the invoice title.
const MEMBERSHIP_INVOICE_KEYWORD = "manga lounge pro";

// Event types after which the entitlement is (still) active
const ACTIVATING_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "SUBSCRIPTION_EXTENDED",
  // Promotional entitlement grants (e.g. Square payments) arrive as
  // NON_RENEWING_PURCHASE with store == "PROMOTIONAL"
  "NON_RENEWING_PURCHASE",
  // CANCELLATION only turns off auto-renew; access lasts until EXPIRATION
  "CANCELLATION",
  "BILLING_ISSUE",
]);

// Event types after which the entitlement is gone
const DEACTIVATING_EVENTS = new Set(["EXPIRATION", "SUBSCRIPTION_PAUSED"]);

function isAnonymous(appUserId) {
  return typeof appUserId !== "string" || appUserId.startsWith("$RCAnonymousID:");
}

function subscriptionDoc(db, uid) {
  return db.collection("subscriptions").doc(uid);
}

/**
 * RevenueCat webhook receiver.
 *
 * Keeps `subscriptions/{uid}` in Firestore in sync with App Store /
 * Google Play purchases managed by RevenueCat. Square (in-store) payments
 * write to the same collection from the store-side system, using
 * source: "square".
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

        const batch = db.batch();
        for (const uid of from) {
          batch.set(
            subscriptionDoc(db, uid),
            {
              isPro: false,
              source: "revenuecat",
              updatedAt: FieldValue.serverTimestamp(),
              lastEvent: type,
            },
            { merge: true }
          );
        }
        for (const uid of to) {
          batch.set(
            subscriptionDoc(db, uid),
            {
              isPro: true,
              source: "revenuecat",
              updatedAt: FieldValue.serverTimestamp(),
              lastEvent: type,
            },
            { merge: true }
          );
        }
        await batch.commit();
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
        // PROMOTIONAL = granted via API (Square / comp), otherwise store IAP
        source: event.store === "PROMOTIONAL" ? "promotional" : "revenuecat",
        productId: event.product_id || null,
        updatedAt: FieldValue.serverTimestamp(),
        lastEvent: type,
      };
      if (event.expiration_at_ms) {
        data.expiresAt = Timestamp.fromMillis(event.expiration_at_ms);
      }

      await subscriptionDoc(db, appUserId).set(data, { merge: true });
      res.status(200).send("OK");
    } catch (error) {
      console.error("Webhook processing failed", error);
      // Non-2xx makes RevenueCat retry the delivery later
      res.status(500).send("Internal error");
    }
  }
);

/**
 * Verifies the HMAC-SHA256 signature Square attaches to webhook requests.
 * The signature is computed over (notification URL + raw request body).
 */
function isValidSquareSignature(req) {
  const signature = req.headers["x-square-hmacsha256-signature"];
  if (!signature || !req.rawBody) return false;

  const hmac = crypto.createHmac("sha256", squareSignatureKey.value());
  hmac.update(squareNotificationUrl.value() + req.rawBody.toString("utf8"));
  const expected = hmac.digest("base64");

  try {
    return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
  } catch (_) {
    return false;
  }
}

/**
 * Returns true if the paid invoice is for the membership. Checks the
 * invoice title first, then falls back to the order line item names
 * (the POS invoice flow doesn't always expose a title field).
 */
async function isMembershipInvoice(invoice) {
  if (invoice.subscription_id) return true;

  const title = (invoice.title || "").toLowerCase();
  if (title.includes(MEMBERSHIP_INVOICE_KEYWORD)) return true;

  if (!invoice.order_id) return false;
  const response = await fetch(
    `${squareApiBase.value()}/v2/orders/${invoice.order_id}`,
    {
      headers: {
        Authorization: `Bearer ${squareAccessToken.value()}`,
        "Content-Type": "application/json",
      },
    }
  );
  if (!response.ok) {
    console.warn(`Order lookup failed for invoice ${invoice.id}: ${response.status}`);
    return false;
  }
  const body = await response.json();
  const lineItems = (body.order && body.order.line_items) || [];
  return lineItems.some((item) =>
    (item.name || "").toLowerCase().includes(MEMBERSHIP_INVOICE_KEYWORD)
  );
}

/** Fetches a Square customer and returns its reference_id (= Firebase UID). */
async function getSquareCustomerReferenceId(customerId) {
  const response = await fetch(
    `${squareApiBase.value()}/v2/customers/${customerId}`,
    {
      headers: {
        Authorization: `Bearer ${squareAccessToken.value()}`,
        "Content-Type": "application/json",
      },
    }
  );
  if (!response.ok) {
    throw new Error(`Square customer lookup failed: ${response.status}`);
  }
  const body = await response.json();
  return body.customer && body.customer.reference_id;
}

/** Grants one month of the Pro entitlement on RevenueCat. */
async function grantProOnRevenueCat(uid) {
  const headers = {
    Authorization: `Bearer ${revenueCatSecretKey.value()}`,
    "Content-Type": "application/json",
  };
  const subscriberUrl =
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`;

  // GET creates the subscriber if it doesn't exist yet (e.g. the member
  // paid at the counter before ever opening the paywall in the app).
  const getResponse = await fetch(subscriberUrl, { headers });
  if (!getResponse.ok) {
    const text = await getResponse.text();
    throw new Error(
      `RevenueCat subscriber lookup failed: ${getResponse.status} ${text}`
    );
  }

  const response = await fetch(
    `${subscriberUrl}/entitlements/${encodeURIComponent(RC_ENTITLEMENT_ID)}/promotional`,
    {
      method: "POST",
      headers,
      body: JSON.stringify({ duration: "monthly" }),
    }
  );
  if (!response.ok) {
    const text = await response.text();
    throw new Error(`RevenueCat grant failed: ${response.status} ${text}`);
  }
}

/**
 * Square webhook receiver.
 *
 * Flow: at the counter, staff create the Square subscription with the
 * member's Firebase UID (from their Membership QR) stored as the Square
 * customer's reference ID. Each time a subscription invoice is paid,
 * this function grants one month of Pro on RevenueCat, which in turn
 * updates the app and mirrors to Firestore via the RevenueCat webhook.
 *
 * Configure in Square Developer Dashboard > Webhooks with the event
 * `invoice.payment_made`.
 */
exports.squareWebhook = onRequest(
  {
    secrets: [squareAccessToken, squareSignatureKey, revenueCatSecretKey],
    region: "us-central1",
    // Public invoker: callers are authenticated by the Square HMAC
    // signature check below, not by IAM.
    invoker: "public",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    if (!isValidSquareSignature(req)) {
      console.warn("Square webhook rejected: invalid signature");
      res.status(401).send("Unauthorized");
      return;
    }

    const eventType = req.body && req.body.type;
    if (eventType !== "invoice.payment_made") {
      res.status(200).send("OK (ignored)");
      return;
    }

    try {
      const invoice =
        req.body.data && req.body.data.object && req.body.data.object.invoice;
      if (!invoice) {
        res.status(400).send("Missing invoice");
        return;
      }

      // Membership invoices come from either the Subscriptions API
      // (subscription_id is set) or a recurring invoice series created on
      // the POS (recognized by the keyword in the title or line items).
      if (!(await isMembershipInvoice(invoice))) {
        console.log(`Invoice ${invoice.id} is not a membership invoice; ignoring`);
        res.status(200).send("OK (not a membership invoice)");
        return;
      }

      const customerId =
        invoice.primary_recipient && invoice.primary_recipient.customer_id;
      if (!customerId) {
        console.warn(`Invoice ${invoice.id} has no customer`);
        res.status(200).send("OK (no customer)");
        return;
      }

      const uid = await getSquareCustomerReferenceId(customerId);
      if (!uid) {
        // Staff forgot to set the reference ID; log loudly so it can be fixed
        console.error(
          `Square customer ${customerId} has no reference_id (Firebase UID). ` +
            "Set it in Square, then re-send the webhook event or grant manually."
        );
        res.status(200).send("OK (no reference_id)");
        return;
      }

      await grantProOnRevenueCat(uid);
      console.log(`Granted 1 month Pro to ${uid} (Square invoice ${invoice.id})`);
      res.status(200).send("OK");
    } catch (error) {
      console.error("Square webhook processing failed", error);
      // Non-2xx makes Square retry the delivery
      res.status(500).send("Internal error");
    }
  }
);
