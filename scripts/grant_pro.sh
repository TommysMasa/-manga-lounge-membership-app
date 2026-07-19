#!/bin/bash
# Grants 1 month of Pro to a member immediately, without waiting for the
# first Square invoice payment. Used when a member signs up at the counter
# and the subscription's first charge is scheduled for the next day.
#
# Usage:
#   RC_SECRET_KEY=sk_xxx ./scripts/grant_pro.sh <FIREBASE_UID>
#
# The RevenueCat webhook then mirrors the grant to Firestore automatically,
# so the app shows Pro within seconds.

set -euo pipefail

ENTITLEMENT_ID="Manga Lounge Memberapp Pro"

if [ $# -lt 1 ]; then
  echo "Usage: RC_SECRET_KEY=sk_xxx $0 <FIREBASE_UID>" >&2
  exit 1
fi
if [ -z "${RC_SECRET_KEY:-}" ]; then
  echo "Error: set the RC_SECRET_KEY environment variable (RevenueCat secret key, sk_...)" >&2
  exit 1
fi

UID_ARG="$1"
BASE="https://api.revenuecat.com/v1/subscribers"

# GET auto-creates the subscriber if the member never opened the paywall
echo "==> Ensuring subscriber exists: $UID_ARG"
curl -sS -f "$BASE/$UID_ARG" \
  -H "Authorization: Bearer $RC_SECRET_KEY" > /dev/null

echo "==> Granting 1 month of '$ENTITLEMENT_ID'"
ENTITLEMENT_ENC=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$ENTITLEMENT_ID")
curl -sS -f -X POST "$BASE/$UID_ARG/entitlements/$ENTITLEMENT_ENC/promotional" \
  -H "Authorization: Bearer $RC_SECRET_KEY" \
  -H "Content-Type: application/json" \
  -d '{"duration": "monthly"}' > /dev/null

echo "==> Done. Pro is active for $UID_ARG (app updates within ~1 minute)."
