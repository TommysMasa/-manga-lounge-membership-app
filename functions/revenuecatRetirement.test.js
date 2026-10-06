const { test } = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const { createHash } = require('node:crypto');
function receiver(initial) {
  const documents = new Map(Object.entries(initial));
  const writes = [];
  const db = { collection: name => ({ doc: id => ({ path: `${name}/${id}` }) }), runTransaction: async fn => fn({
    get: async ref => ({ exists: documents.has(ref.path), data: () => documents.get(ref.path) }),
    set: (ref, value, options) => { writes.push(ref.path); documents.set(ref.path, options?.merge ? { ...documents.get(ref.path), ...value } : value); },
  }) };
  const sandbox = { exports: {}, console: { log() {}, warn() {}, error() {} }, require: name => {
    if (name === 'node:crypto') return require(name);
    if (name === 'firebase-functions/v2/https') return { onRequest: (_, handler) => handler };
    if (name === 'firebase-functions/params') return { defineSecret: () => ({ value: () => 'synthetic-secret' }) };
    if (name === 'firebase-admin/app') return { initializeApp() {} };
    if (name === 'firebase-admin/firestore') return { getFirestore: () => db, Timestamp: { fromMillis: value => value }, FieldValue: { serverTimestamp: () => 'synthetic-time' } };
    if (name === './memberLifecycle') return {};
    throw Error(`Unexpected dependency ${name}`);
  } };
  vm.runInNewContext(fs.readFileSync(require.resolve('./index'), 'utf8'), sandbox);
  async function send(event) {
    let status, body;
    const res = { status: value => { status = value; return res; }, send: value => { body = value; } };
    await sandbox.exports.revenuecatWebhook({ method: 'POST', headers: { authorization: 'synthetic-secret' }, body: { event } }, res);
    return { status, body };
  }
  return { send, documents, writes };
}
test('delayed renewal acknowledges receipt without resurrecting a retired UID or consuming a seat', async () => {
  const uid = 'synthetic-retired';
  const key = createHash('sha256').update(`member-erasure-v1:${uid}`).digest('hex');
  const api = receiver({ [`accountDeletionJobs/${key}`]: { state: 'complete' }, 'config/proCap': { activeCount: 20, limit: 30 } });
  assert.equal((await api.send({ type: 'RENEWAL', app_user_id: uid, product_id: 'test-product' })).status, 200);
  assert.deepEqual(api.writes, []);
  assert.equal(api.documents.has(`subscriptions/${uid}`), false);
});
test('normal renewals continue updating subscription state without double-counting seats', async () => {
  const api = receiver({ 'subscriptions/synthetic-active': { isPro: true }, 'config/proCap': { activeCount: 20, limit: 30 } });
  assert.equal((await api.send({ type: 'RENEWAL', app_user_id: 'synthetic-active', product_id: 'test-product' })).status, 200);
  assert.equal(api.documents.get('subscriptions/synthetic-active').isPro, true);
  assert.equal(api.documents.get('config/proCap').activeCount, 20);
});
