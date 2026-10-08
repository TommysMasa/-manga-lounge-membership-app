const { test } = require('node:test');
const assert = require('node:assert/strict');
const { deleteRevenueCatCustomer } = require('./revenuecatErasure');
test('customer erasure sends only server credential and encoded identity to DELETE', async () => {
  const result = await deleteRevenueCatCustomer('synthetic/identity', 'synthetic-secret', { request: async (url, options) => {
    assert.equal(url, 'https://api.revenuecat.com/v1/subscribers/synthetic%2Fidentity');
    assert.equal(options.method, 'DELETE');
    assert.equal(options.headers.Authorization, 'Bearer synthetic-secret');
    assert.equal(options.redirect, 'error');
    return { status: 200 };
  } });
  assert.equal(result, 'requested');
});
test('absent customer is success; credential, rate limit and provider errors must retry', async () => {
  assert.equal(await deleteRevenueCatCustomer('synthetic', 'key', { request: async () => ({ status: 404 }) }), 'already_absent');
  for (const status of [401, 403, 429, 500]) {
    await assert.rejects(deleteRevenueCatCustomer('synthetic', 'key', { request: async () => ({ status }) }));
  }
  await assert.rejects(deleteRevenueCatCustomer('synthetic', ''));
  await assert.rejects(deleteRevenueCatCustomer('synthetic', 'key', { request: async () => { throw Error('timeout'); } }));
});
