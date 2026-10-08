const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const admin = require('firebase-admin');
const { createHmac } = require('node:crypto');
const { services, validateProfile, requireRecentIdentity, anonymousHistory, jobKey } = require('./memberLifecycle');
const NOW = Date.parse('2026-10-06T18:00:00Z');
const profile = { firstName: 'Test', lastName: 'Member', gender: 'Other', dateOfBirth: '2000-01-01T00:00:00.000Z' };
const identity = { phoneNumber: '+16505550001', email: 'test@example.invalid', tokensValidAfterTime: '1970-01-01T00:00:00Z' };
const request = (uid, data) => ({ auth: { uid, token: { auth_time: NOW / 1000, firebase: { sign_in_provider: 'phone' } } }, data });

test('registration rejects forged identity, creation date, privileges and benefit flags', () => {
  for (const key of ['uid', 'createdAt', 'visitCount', 'isStaff', 'isBanned', 'earlyReturn30Used']) {
    assert.throws(() => validateProfile({ ...profile, [key]: true }, NOW), e => e.code === 'invalid-argument');
  }
  assert.equal(validateProfile(profile, NOW).firstName, 'Test');
  assert.throws(() => validateProfile({ ...profile, dateOfBirth: '2099-01-01T00:00:00Z' }, NOW));
});
test('stale, missing, future, revoked or disabled identity cannot authorize erasure', () => {
  requireRecentIdentity(request('test', {}), identity, NOW);
  for (const time of [undefined, NOW / 1000 - 301, NOW / 1000 + 61]) {
    const r = request('test', {}); r.auth.token.auth_time = time;
    assert.throws(() => requireRecentIdentity(r, identity, NOW), e => e.details.reason === 'recent-login-required');
  }
  assert.throws(() => requireRecentIdentity(request('test', {}), { ...identity, disabled: true }, NOW));
  assert.throws(() => requireRecentIdentity(request('test', {}), { ...identity, tokensValidAfterTime: new Date(NOW + 1000).toISOString() }, NOW));
});
test('anonymous history preserves money and nested departures, drops personal and unknown fields', () => {
  const data = { uid: 'original', userId: 'original', firstName: 'secret', email: 'secret', extra: { phone: 'secret' }, pricing: { total: 19, adultCost: 12, email: 'secret' }, childDepartures: [{ count: 1, settled: true, phone: 'secret', pricing: { total: 7, name: 'secret' } }], squarePaymentIds: ['synthetic-payment'], drinkLogs: [{ gtin: '123', label: 'Tea', staffUid: 'staff', phone: 'secret' }] };
  const value = anonymousHistory('records', data, 'anonymous', 'original');
  assert.equal(value.uid, 'anonymous'); assert.equal(value.userId, 'anonymous');
  assert.equal(value.pricing.total, 19); assert.equal(value.childDepartures[0].pricing.total, 7);
  assert.deepEqual(value.squarePaymentIds, ['synthetic-payment']);
  assert.ok(!JSON.stringify(value).includes('secret')); assert.ok(!JSON.stringify(value).includes('original'));
  const guest = anonymousHistory('guestPassUses', { hostUid: 'other-member', guestUserId: 'original', guestFirstName: 'secret', periodKey: '2026-10' }, 'anonymous', 'original');
  assert.equal(guest.hostUid, 'other-member'); assert.equal(guest.guestUserId, 'anonymous'); assert.equal(guest.guestFirstName, undefined);
});

const emulator = process.env.FIRESTORE_EMULATOR_HOST;
if (emulator && emulator !== '127.0.0.1:18080') throw Error('Use the dedicated localhost test emulator only.');
before(async () => {
  if (!emulator) return;
  const response = await fetch('http://127.0.0.1:18080/emulator/v1/projects/demo-member-lifecycle/databases/(default)/documents', { method: 'DELETE' });
  if (!response.ok) throw Error('Synthetic database reset failed.');
  admin.initializeApp({ projectId: 'demo-member-lifecycle' }); db = admin.firestore();
  await db.doc('config/memberLifecycle').set({ serverOnly: true });
});
after(async () => { if (db) await db.terminate(); });
const integration = (name, fn) => test(name, { skip: !emulator }, fn);
let db;
function setup(uid, options = {}) {
  if (!db) { admin.initializeApp({ projectId: 'demo-member-lifecycle' }); db = admin.firestore(); }
  let failures = options.failures || 0;
  const deleted = [];
  const auth = { getUser: async id => { assert.equal(id, uid); return identity; }, deleteUser: async id => { assert.equal(id, uid); if (failures-- > 0) throw Object.assign(Error('synthetic transient failure'), { code: 'auth/internal-error' }); deleted.push(id); } };
  const audit = [];
  return { db, deleted, audit, api: services({ db, auth, now: () => NOW, audit: value => audit.push(value), eraseRevenueCat: options.eraseRevenueCat || (async () => 'requested') }) };
}
integration('server creation owns age/status, is idempotent and applies the persistent ban immediately', async () => {
  const uid = 'create-test'; const { db, api } = setup(uid);
  const hash = createHmac('sha256', 'manga-lounge-ban-v1').update(identity.phoneNumber).digest('hex');
  await db.collection('bannedPhones').doc(hash).set({ createdAt: admin.firestore.Timestamp.fromMillis(NOW) });
  await api.createProfile(request(uid, profile));
  const user = (await db.collection('users').doc(uid).get()).data();
  assert.equal(user.createdAt, new Date(NOW).toISOString()); assert.equal(user.isBanned, true); assert.equal(user.status, 'checked_out');
  await api.createProfile(request(uid, { ...profile, firstName: 'Replacement' }));
  assert.equal((await db.collection('users').doc(uid).get()).data().firstName, 'Test');
});
integration('erasure refuses stale identity, staff, owner, shop, forged UID and active visits before mutations', async () => {
  for (const uid of ['stale-test', 'staff-test', 'active-test', 'xFRZhV9Ve1PjizPdoIuf6TNDjhD2', 'Cuk0zcS6hOcwQw4e1c7ezmN4GeG2', 'forged-test']) {
    const { db, api } = setup(uid);
    await db.collection('users').doc(uid).set({ ...profile, isStaff: uid === 'staff-test', status: uid === 'active-test' ? 'checked_in' : 'checked_out' });
    const r = request(uid, { confirm: true });
    if (uid === 'stale-test') r.auth.token.auth_time -= 301;
    if (uid === 'forged-test') r.data.uid = 'someone-else';
    await assert.rejects(api.deleteAccount(r));
    assert.equal((await db.collection('accountDeletionJobs').doc(jobKey(uid)).get()).exists, false);
    assert.equal((await db.collection('users').doc(uid).get()).exists, true);
  }
});
integration('partial Auth failure resumes erasure, retains anonymous finances and counts once', async () => {
  const uid = 'erase-test'; const { db, api, audit, deleted } = setup(uid, { failures: 1 });
  await db.collection('users').doc(uid).set({ ...profile, isBanned: true, status: 'checked_out', fcmToken: 'secret-token' });
  await db.collection('users').doc(uid).collection('private').doc('data').set({ email: 'secret' });
  await db.collection('records').doc('erase-visit').set({ uid, userId: uid, email: 'secret', pricing: { total: 25, phone: 'secret' } });
  await db.collection('Records').doc('erase-legacy').set({ membershipId: uid, entryTime: admin.firestore.Timestamp.fromMillis(NOW), email: 'secret' });
  await db.collection('records').doc('other-visit').set({ uid: 'other', cameWithUids: [uid, 'other-friend'], pricing: { total: 9 } });
  await db.collection('goodsPurchases').doc('erase-goods').set({ uid, price: 5, label: 'Tea', name: 'secret' });
  await db.collection('guestPassUses').doc('erase-guest').set({ hostUid: 'other-host', guestUserId: uid, guestFirstName: 'secret', periodKey: '2026-10' });
  for (const collection of ['mangaSearches', 'memberRequests', 'memberRequestNotifications', 'surveyResponses', 'couponReminderEvents', 'waitlist', 'eventTicketClicks']) await db.collection(collection).doc('erase-personal').set({ uid, email: 'secret' });
  await db.collection('subscriptions').doc(uid).set({ isPro: true });
  assert.deepEqual(await api.deleteAccount(request(uid, { confirm: true })), { accepted: true, completed: false });
  const ref = db.collection('accountDeletionJobs').doc(jobKey(uid));
  assert.equal((await ref.get()).data().state, 'pending');
  assert.equal((await db.collection('deletionStats').doc('2026-10').get()).exists, false);
  const money = (await db.collection('records').doc('erase-visit').get()).data();
  assert.equal(money.pricing.total, 25); assert.match(money.uid, /^retired_/); assert.equal(money.email, undefined);
  assert.equal((await db.collection('users').doc(uid).collection('private').doc('data').get()).exists, false);
  assert.deepEqual((await db.collection('records').doc('other-visit').get()).data().cameWithUids, ['other-friend']);
  assert.equal((await db.collection('guestPassUses').doc('erase-guest').get()).data().hostUid, 'other-host');
  await api.processJob(ref);
  await api.processJob(ref);
  assert.equal((await db.collection('deletionStats').doc('2026-10').get()).data().count, 1);
  assert.equal((await ref.get()).data().state, 'complete');
  assert.equal((await ref.get()).data().uid, undefined); assert.equal((await ref.get()).data().email, undefined); assert.equal((await ref.get()).data().anonymousId, undefined);
  assert.deepEqual(deleted, [uid]);
  assert.ok(!JSON.stringify(audit).includes(uid));
  const hash = createHmac('sha256', 'manga-lounge-ban-v1').update(identity.phoneNumber).digest('hex');
  assert.equal((await db.collection('bannedPhones').doc(hash).get()).exists, true);
  await assert.rejects(api.createProfile(request(uid, profile)), e => e.code === 'failed-precondition');
});

integration('preview permits server erasure while legacy cutover remains off', async () => {
  await db.doc('config/memberLifecycle').set({serverOnly:false,previewEnabled:true});
  const uid='preview-member'; const {api}=setup(uid);
  await db.doc(`users/${uid}`).set({...profile,status:'checked_out'});
  assert.deepEqual(await api.deleteAccount(request(uid,{confirm:true})),{accepted:true,completed:true});
  assert.equal((await db.doc('config/memberLifecycle').get()).data().serverOnly,false);
});

integration('RevenueCat failure remains retryable after Auth removal and never reports erasure complete early', async () => {
  const uid = 'external-erasure-test'; let calls = 0;
  const { db, api } = setup(uid, { eraseRevenueCat: async id => {
    assert.equal(id, uid);
    if (++calls === 1) throw Error('synthetic provider outage');
    return 'requested';
  } });
  await db.doc(`users/${uid}`).set({ ...profile, status: 'checked_out' });
  const previousCount = (await db.doc('deletionStats/2026-10').get()).data()?.count || 0;
  assert.deepEqual(await api.deleteAccount(request(uid, { confirm: true })), { accepted: true, completed: false });
  const ref = db.doc(`accountDeletionJobs/${jobKey(uid)}`);
  assert.equal((await ref.get()).data().state, 'pending');
  assert.equal((await ref.get()).data().uid, uid);
  assert.equal((await db.doc('deletionStats/2026-10').get()).data()?.count || 0, previousCount);
  await api.processJob(ref);
  const result = (await ref.get()).data();
  assert.equal(result.state, 'complete');
  assert.equal(result.revenueCatErasure, 'requested');
  assert.equal(result.uid, undefined);
  assert.equal((await db.doc('deletionStats/2026-10').get()).data().count, previousCount + 1);
});
