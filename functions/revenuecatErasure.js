// Server-only customer erasure. Never use a mobile SDK public key here.
async function deleteRevenueCatCustomer(uid, secret, { request = fetch } = {}) {
  if (typeof uid !== 'string' || !uid || typeof secret !== 'string' || !secret.trim()) {
    throw Error('RevenueCat erasure configuration missing');
  }
  const response = await request(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${secret}` },
    signal: AbortSignal.timeout(30000),
    redirect: 'error',
  });
  // Do not fetch the subscriber to verify: RevenueCat GET creates absent users.
  // Do not log response bodies: they may contain identity and purchase data.
  if (response.status === 200) return 'requested';
  if (response.status === 404) return 'already_absent';
  throw Error('RevenueCat erasure request failed');
}
module.exports = { deleteRevenueCatCustomer };
