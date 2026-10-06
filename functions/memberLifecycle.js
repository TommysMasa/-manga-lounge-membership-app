// Member lifecycle is server owned. Clients never choose identity, business
// flags, creation time, deletion statistics, or the scope of erasure.
const admin = require('firebase-admin');
const { HttpsError, onCall } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { createHash, randomUUID } = require('node:crypto');
// Compatibility with the existing scanner bannedPhones registry. Keep this
// algorithm stable until the planned secret/hash migration is deployed.
function hashPhone(phone) {
  const digits = String(phone || '').replace(/\D/g, '');
  const number = digits.length === 10 ? `+1${digits}` : digits.length === 11 && digits.startsWith('1') ? `+${digits}` : null;
  return number ? require('node:crypto').createHmac('sha256', 'manga-lounge-ban-v1').update(number).digest('hex') : null;
}

const PROTECTED = new Set(['xFRZhV9Ve1PjizPdoIuf6TNDjhD2', 'Cuk0zcS6hOcwQw4e1c7ezmN4GeG2']);
const jobKey = uid => createHash('sha256').update(`member-erasure-v1:${uid}`).digest('hex');
const profileKeys = ['firstName', 'lastName', 'gender', 'dateOfBirth', 'referralSource', 'zipcode'];
const keep = (data, keys) => Object.fromEntries(keys.filter(k => {
  const value = data[k];
  return value === null || ['string', 'boolean', 'number'].includes(typeof value) || value instanceof admin.firestore.Timestamp ||
    (k === 'squarePaymentIds' && Array.isArray(value) && value.every(id => typeof id === 'string'));
}).map(k => [k, data[k]]));

function caller(request) {
  if (!request.auth?.uid || request.auth.token?.firebase?.sign_in_provider === 'anonymous') {
    throw new HttpsError('unauthenticated', 'Please sign in with your member account.');
  }
  return request.auth.uid;
}

function validateProfile(data, now) {
  if (!data || typeof data !== 'object' || Array.isArray(data) || Object.keys(data).some(k => !profileKeys.includes(k))) {
    throw new HttpsError('invalid-argument', 'Only profile fields are accepted.');
  }
  const result = {};
  for (const key of ['firstName', 'lastName', 'gender']) {
    if (typeof data[key] !== 'string' || !data[key].trim() || data[key].length > 100) {
      throw new HttpsError('invalid-argument', `Invalid ${key}.`);
    }
    result[key] = data[key].trim();
  }
  const birth = typeof data.dateOfBirth === 'string' && /^\d{4}-\d\d-\d\dT/.test(data.dateOfBirth) ? new Date(data.dateOfBirth) : null;
  if (!birth || !Number.isFinite(birth.getTime()) || birth.getTime() > now || birth.getUTCFullYear() < 1900) {
    throw new HttpsError('invalid-argument', 'Invalid date of birth.');
  }
  result.dateOfBirth = birth.toISOString();
  for (const key of ['referralSource', 'zipcode']) {
    if (data[key] != null && (typeof data[key] !== 'string' || data[key].length > 200)) {
      throw new HttpsError('invalid-argument', `Invalid ${key}.`);
    }
    result[key] = data[key]?.trim() || null;
  }
  return result;
}

function requireRecentIdentity(request, authUser, now) {
  const signedAt = Number(request.auth.token?.auth_time) * 1000;
  const revokedAt = Date.parse(authUser.tokensValidAfterTime || '') || 0;
  if (authUser.disabled || !Number.isFinite(signedAt) || signedAt < now - 5 * 60000 || signedAt > now + 60000 || signedAt < Math.floor(revokedAt / 1000) * 1000) {
    throw new HttpsError('failed-precondition', 'Please sign out and sign in again, then delete your account within five minutes.', { reason: 'recent-login-required' });
  }
}

// Replace the entire document with an explicit business-field projection.
// Unexpected fields (including nested personal data) are never retained.
const visitFields = ['entryTime', 'exitTime', 'stayTimeMinutes', 'stayTimeFormatted', 'createdAt', 'childrenCount', 'countsTowardVisitCount', 'isGuest', 'guestPassComp', 'guestHasApp', 'squareTerminalCheckoutId', 'squarePaymentIds', 'partySize', 'usedBlanket', 'broughtDrink', 'boughtDrink', 'broughtSnack'];
const pricingFields = ['adultCost', 'childrenCost', 'subtotal', 'dayPassCapUsd', 'childDayPassCapUsd', 'cappedAdultCost', 'cappedChildrenCost', 'cappedSubtotal', 'adultDayPassCapSavings', 'childrenDayPassCapSavings', 'dayPassCapSavings', 'discount', 'discountDescription', 'total', 'proComp', 'guestPassComp', 'lpThirtyMinExtension', 'lpFourDollarHour'];
const eventFields = ['eventId', 'providerEventId', 'orderId', 'provider', 'attributionMethod', 'identityVerified', 'state', 'grossMinor', 'currency', 'ticketCount', 'checkedInCount', 'providerChangedAt', 'hasRefundedTickets', 'providerStatus', 'verifiedAt', 'registrationStatus', 'checkedInAt', 'csvReportedAmount', 'source', 'importedAt'];
function anonymousHistory(collection, data, anonymousId, uid) {
  let output;
  if (collection === 'records' || collection === 'Records') {
    output = keep(data, visitFields);
    for (const key of ['uid', 'userId', 'membershipId', 'guestPassHostUid']) {
      if (Object.hasOwn(data, key)) output[key] = !uid || data[key] === uid ? anonymousId : data[key];
    }
    if (data.pricing) output.pricing = keep(data.pricing, pricingFields);
    if (Array.isArray(data.childDepartures)) output.childDepartures = data.childDepartures.map(d => ({
      ...keep(d, ['count', 'minutes', 'at', 'settled', 'squareTerminalCheckoutId', 'squarePaymentIds']),
      ...(d.pricing ? { pricing: keep(d.pricing, pricingFields) } : {}),
    }));
    if (Array.isArray(data.drinkLogs)) output.drinkLogs = data.drinkLogs.map(d => keep(d, ['gtin', 'label', 'loggedAt', 'previousRemainingPct']));
  } else if (collection === 'goodsPurchases') {
    output = { ...keep(data, ['gtin', 'label', 'purchasedAt', 'price']), uid: anonymousId };
  } else if (collection === 'guestPassUses') {
    output = keep(data, ['periodKey', 'monthKey', 'guestHasApp', 'recordId', 'usedAt']);
    for (const key of ['hostUid', 'guestUserId']) if (Object.hasOwn(data, key)) output[key] = !uid || data[key] === uid ? anonymousId : data[key];
  } else {
    output = keep(data, eventFields);
  }
  return { ...output, anonymized: true };
}

function services({ db = admin.firestore(), auth = admin.auth(), now = Date.now, audit = value => console.log(JSON.stringify(value)) } = {}) {
  const jobs = db.collection('accountDeletionJobs');
  const stamp = () => admin.firestore.Timestamp.fromMillis(now());
  const timestamp = admin.firestore.FieldValue.serverTimestamp;

  async function createProfile(request) {
    const uid = caller(request), time = now();
    const profile = validateProfile(request.data, time);
    const identity = await auth.getUser(uid);
    if (identity.disabled || !identity.phoneNumber) throw new HttpsError('permission-denied', 'A verified phone number is required.');
    const banHash = hashPhone(identity.phoneNumber);
    const ref = db.collection('users').doc(uid);
    await db.runTransaction(async tx => {
      const [existing, deletion, ban] = await Promise.all([
        tx.get(ref), tx.get(jobs.doc(jobKey(uid))),
        banHash ? tx.get(db.collection('bannedPhones').doc(banHash)) : Promise.resolve(null),
      ]);
      if (deletion.exists) throw new HttpsError('failed-precondition', 'This account has been retired. Sign in with a new account.');
      if (existing.exists) return; // Retry never resets benefits or membership age.
      tx.create(ref, { ...profile, uid, status: 'checked_out', createdAt: new Date(time).toISOString(), updatedAt: null, lastEntryTime: null, ...(ban?.exists ? { isBanned: true } : {}) });
    });
    return { created: true };
  }

  async function deleteAccount(request) {
    const uid = caller(request);
    if (PROTECTED.has(uid)) throw new HttpsError('permission-denied', 'Store and owner accounts cannot be retired here.');
    if (!request.data || request.data.confirm !== true || Object.keys(request.data).some(k => k !== 'confirm')) {
      throw new HttpsError('invalid-argument', 'Confirm deletion of your own account.');
    }
    const rollout = await db.collection('config').doc('memberLifecycle').get();
    if (rollout.data()?.serverOnly !== true) throw new HttpsError('failed-precondition', 'Server account deletion is not enabled yet. Please try again after the app update.');
    const identity = await auth.getUser(uid);
    requireRecentIdentity(request, identity, now()); // Before any write, including job acceptance.
    const ref = jobs.doc(jobKey(uid));
    await db.runTransaction(async tx => {
      const [job, user, visits] = await Promise.all([
        tx.get(ref), tx.get(db.collection('users').doc(uid)),
        tx.get(db.collection('records').where('uid', '==', uid)),
      ]);
      const profile = user.data();
      if (profile?.isStaff === true) throw new HttpsError('permission-denied', 'Staff accounts cannot be retired here.');
      if (job.exists) return;
      if (profile?.status === 'checked_in' || profile?.isCheckedIn === true || profile?.currentRecordId || visits.docs.some(d => d.data().entryTime && d.data().exitTime === null)) throw new HttpsError('failed-precondition', 'Please check out at the store before deleting your account.');
      const parts = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Los_Angeles', year: 'numeric', month: '2-digit' }).formatToParts(new Date(now()));
      const month = `${parts.find(p => p.type === 'year').value}-${parts.find(p => p.type === 'month').value}`;
      tx.create(ref, { uid, state: 'pending', acceptedAt: stamp(), month, anonymousId: `retired_${randomUUID()}`, attempts: 0, phoneHash: identity.phoneNumber ? createHash('sha256').update(identity.phoneNumber).digest('hex') : null, email: identity.email || null, banHash: hashPhone(identity.phoneNumber) });
      if (user.exists) tx.update(user.ref, { accountDeletionPending: true, fcmToken: admin.firestore.FieldValue.delete() });
      if (profile?.isBanned === true) {
        const hash = hashPhone(identity.phoneNumber);
        if (!hash) throw new HttpsError('failed-precondition', 'Please contact support to retire this account.');
        tx.set(db.collection('bannedPhones').doc(hash), { createdAt: stamp() });
      }
    });
    await processJob(ref);
    return { accepted: true, completed: (await ref.get()).data()?.state === 'complete' };
  }

  async function matching(collection, field, value, action) {
    // Restart from the first remaining match. Each write removes its selector,
    // so a retry after a partial batch never misses documents or double-counts.
    while (true) {
      const snap = await db.collection(collection).where(field, '==', value).limit(100).get();
      if (snap.empty) return;
      for (const doc of snap.docs) await action(doc);
    }
  }

  async function processJob(ref) {
    const lease = randomUUID();
    const job = await db.runTransaction(async tx => {
      const current = (await tx.get(ref)).data();
      if (!current || current.state === 'complete' || current.leaseUntil?.toMillis() > now()) return null;
      tx.update(ref, { state: 'processing', lease, leaseUntil: admin.firestore.Timestamp.fromMillis(now() + 10 * 60000), attempts: current.attempts + 1 });
      return current;
    });
    if (!job) return;
    const uid = job.uid;
    try {
      const histories = { records: ['uid', 'userId', 'guestPassHostUid'], Records: ['membershipId', 'uid', 'userId'], goodsPurchases: ['uid'], guestPassUses: ['hostUid', 'guestUserId'], eventParticipants: ['attributedUid'], eventbritePurchases: ['attributedUid'] };
      for (const [collection, fields] of Object.entries(histories)) {
        for (const field of fields) await matching(collection, field, uid, doc => db.runTransaction(async tx => {
          const latest = await tx.get(doc.ref);
          if (!latest.exists || latest.data()[field] !== uid) return;
          tx.set(doc.ref, anonymousHistory(collection, latest.data(), job.anonymousId, uid));
        }));
      }
      for (const [collection, fields] of Object.entries({ mangaSearches: ['uid'], memberRequests: ['uid'], memberRequestNotifications: ['uid'], surveyResponses: ['uid', 'userId'], waitlist: ['uid'], couponReminderEvents: ['uid', 'userId'], eventTicketClicks: ['uid'] })) {
        for (const field of fields) await matching(collection, field, uid, doc => db.recursiveDelete(doc.ref));
      }
      // Remove references from other members without erasing their profiles
      // or changing their visit counts / guest-pass quota usage.
      for (const collection of ['users', 'records']) {
        while (true) {
          const related = await db.collection(collection).where('cameWithUids', 'array-contains', uid).limit(100).get();
          if (related.empty) break;
          for (const doc of related.docs) await doc.ref.update({ cameWithUids: admin.firestore.FieldValue.arrayRemove(uid) });
        }
      }
      await matching('users', 'guestPassHostUid', uid, doc => doc.ref.update({ guestPassHostUid: admin.firestore.FieldValue.delete() }));
      if (job.email) {
        for (const email of new Set([job.email, job.email.toLowerCase().trim()])) {
          await matching('surveyResponses', 'email', email, doc => db.recursiveDelete(doc.ref));
          await matching('surveyResponses', 'emailHash', createHash('sha256').update(email).digest('hex'), doc => db.recursiveDelete(doc.ref));
        }
      }
      if (job.phoneHash) {
        await matching('coupons', 'phoneHash', job.phoneHash, async doc => {
          const token = doc.data().couponToken;
          if (typeof token === 'string' && token && !token.includes('/')) await db.collection('couponTokens').doc(token).delete();
          await db.recursiveDelete(doc.ref);
        });
        await db.collection('couponPhones').doc(job.phoneHash).delete();
        await matching('waitlist', 'phoneHash', job.phoneHash, doc => db.recursiveDelete(doc.ref));
      }
      for (const collection of ['subscriptions', 'surveyResponses', 'eventTicketClickLimits', 'eventFlyerUploadRateLimits', 'eventTestRateLimits']) {
        await db.recursiveDelete(db.collection(collection).doc(uid));
      }
      const notifications = await db.collection('eventNotifications').get();
      for (const notification of notifications.docs) {
        await db.recursiveDelete(notification.ref.collection('deliveries').doc(uid));
      }
      const latestProfile = await db.collection('users').doc(uid).get();
      if (latestProfile.data()?.isBanned === true && job.banHash) {
        await db.collection('bannedPhones').doc(job.banHash).set({ createdAt: stamp() });
      }
      await db.recursiveDelete(db.collection('users').doc(uid));
      try { await auth.deleteUser(uid); } catch (error) { if (error.code !== 'auth/user-not-found') throw error; }
      await db.runTransaction(async tx => {
        const current = (await tx.get(ref)).data();
        if (current.state === 'complete') return;
        if (current.lease !== lease) throw Error('Lease changed');
        const complete = { state: 'complete', acceptedAt: current.acceptedAt, completedAt: stamp(), attempts: current.attempts };
        // Replace the job: erase UID, phone hashes and anonymous history ID.
        // The hashed job key only prevents recreation under the same Auth UID.
        tx.set(ref, complete);
        tx.set(db.collection('deletionStats').doc(job.month), { count: admin.firestore.FieldValue.increment(1), lastUpdated: timestamp() }, { merge: true });
      });
      audit({ event: 'MEMBER_ACCOUNT_DELETION', outcome: 'complete', operationId: lease });
    } catch (error) {
      await db.runTransaction(async tx => {
        const current = (await tx.get(ref)).data();
        if (current?.lease === lease && current.state !== 'complete') tx.update(ref, { state: 'pending', leaseUntil: stamp() });
      });
      // Never log raw errors, phone numbers, names, request bodies or UID.
      audit({ event: 'MEMBER_ACCOUNT_DELETION', outcome: 'retry_required', operationId: lease, severity: 'ERROR' });
      throw new HttpsError('unavailable', 'Your deletion request was accepted. Processing will retry automatically.');
    }
  }

  async function retryJobs() {
    const pending = await jobs.where('state', 'in', ['pending', 'processing']).limit(50).get();
    for (const doc of pending.docs) {
      try { await processJob(doc.ref); } catch (_) { /* Safe error already recorded; retry next run. */ }
    }
  }
  return { createProfile, deleteAccount, processJob, retryJobs };
}

exports.createMemberProfile = onCall({ region: 'us-central1', maxInstances: 10 }, request => services().createProfile(request));
exports.deleteMyAccount = onCall({ region: 'us-central1', maxInstances: 10, timeoutSeconds: 540 }, request => services().deleteAccount(request));
exports.retryMemberAccountDeletions = onSchedule({ region: 'us-central1', schedule: 'every 15 minutes', timeoutSeconds: 540, maxInstances: 1 }, () => services().retryJobs());
// RevenueCat can deliver delayed renewals after erasure. Do not resurrect a
// retired account's subscription document; store cancellation is separate.
exports.removeRetiredSubscription = onDocumentWritten({ document: 'subscriptions/{uid}', region: 'us-central1' }, async event => {
  if (!event.data?.after.exists) return;
  const deletion = await admin.firestore().collection('accountDeletionJobs').doc(jobKey(event.params.uid)).get();
  if (deletion.exists) await event.data.after.ref.delete();
});
exports.services = services;
exports.validateProfile = validateProfile;
exports.requireRecentIdentity = requireRecentIdentity;
exports.anonymousHistory = anonymousHistory;
exports.jobKey = jobKey;
