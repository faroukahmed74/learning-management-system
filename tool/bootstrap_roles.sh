#!/usr/bin/env bash
# Bootstrap dev users via Supabase Admin API (requires service role key).
# Usage:
#   1. Add SUPABASE_SERVICE_ROLE_KEY to .env (Dashboard → Settings → API → service_role)
#   2. ./tool/bootstrap_roles.sh admin@example.com [instructor@example.com]

set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "ERROR: .env not found"
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  echo "ERROR: Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env"
  echo "Get service_role from Supabase Dashboard → Settings → API"
  exit 1
fi

ADMIN_EMAIL="${1:-${ADMIN_EMAIL:-}}"
INSTRUCTOR_EMAIL="${2:-${INSTRUCTOR_EMAIL:-}}"

if [[ -z "$ADMIN_EMAIL" ]]; then
  echo "Usage: $0 admin@example.com [instructor@example.com]"
  exit 1
fi

confirm_and_promote() {
  local email="$1"
  local role="$2"

  echo "→ $email → $role"

  local user_json
  user_json=$(curl -sS "${SUPABASE_URL}/auth/v1/admin/users?email=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$email'))")" \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}")

  local user_id
  user_id=$(echo "$user_json" | python3 -c "import sys,json; d=json.load(sys.stdin); users=d.get('users',[]); print(users[0]['id'] if users else '')" 2>/dev/null || true)

  if [[ -z "$user_id" ]]; then
    echo "  SKIP user not found in Auth — register in app first: $email"
    return 1
  fi

  curl -sS -X PUT "${SUPABASE_URL}/auth/v1/admin/users/${user_id}" \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"email_confirm":true}' >/dev/null

  local patch_body
  patch_body=$(python3 -c "import json; print(json.dumps({'role': '$role', 'status': 'active'}))")

  curl -sS -X PATCH "${SUPABASE_URL}/rest/v1/profiles?email=eq.$(python3 -c "import urllib.parse; print(urllib.parse.quote('$email'))")" \
    -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=minimal" \
    -d "$patch_body" >/dev/null

  echo "  OK confirmed + promoted"
}

echo "Bootstrapping roles on ${SUPABASE_URL}"
confirm_and_promote "$ADMIN_EMAIL" "admin"

if [[ -n "$INSTRUCTOR_EMAIL" ]]; then
  confirm_and_promote "$INSTRUCTOR_EMAIL" "instructor"
fi

echo "Done. Sign out and sign in again in the app."
