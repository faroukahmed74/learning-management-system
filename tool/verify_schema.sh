#!/usr/bin/env bash
# Verify all LMS tables, views, and storage buckets exist on Supabase.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "FAIL: .env not found"
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

if [[ -z "${SUPABASE_URL:-}" || -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "FAIL: SUPABASE_URL and SUPABASE_ANON_KEY required in .env"
  exit 1
fi

TABLES=(
  centers profiles courses course_modules lessons lesson_materials
  batches enrollments lesson_progress live_sessions notifications audit_logs
)
VIEWS=(admin_dashboard_stats)
BUCKETS=(avatars course-thumbnails materials)

check_rest() {
  local name="$1"
  local body
  body=$(curl -sS "${SUPABASE_URL}/rest/v1/${name}?select=id&limit=0" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "Accept: application/json")
  if echo "$body" | grep -qE 'PGRST205|Could not find the table|schema cache'; then
    return 1
  fi
  return 0
}

check_bucket() {
  local bucket="$1"
  local code
  code=$(curl -sS -o /dev/null -w "%{http_code}" \
    "${SUPABASE_URL}/storage/v1/object/list/${bucket}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"prefix":"","limit":1}')
  [[ "$code" != "404" ]]
}

pass=0
fail=0

echo "LMS schema verification"
echo "Project: ${SUPABASE_URL}"
echo ""

echo "=== Tables (12) ==="
for t in "${TABLES[@]}"; do
  if check_rest "$t"; then
    echo "  OK   public.$t"
    pass=$((pass + 1))
  else
    echo "  FAIL public.$t — missing"
    fail=$((fail + 1))
  fi
done

echo ""
echo "=== Views (1) ==="
for v in "${VIEWS[@]}"; do
  if check_rest "$v"; then
    echo "  OK   public.$v"
    pass=$((pass + 1))
  else
    echo "  FAIL public.$v — missing"
    fail=$((fail + 1))
  fi
done

echo ""
echo "=== Storage buckets (3) ==="
for b in "${BUCKETS[@]}"; do
  if check_bucket "$b"; then
    echo "  OK   bucket $b"
    pass=$((pass + 1))
  else
    echo "  FAIL bucket $b — missing"
    fail=$((fail + 1))
  fi
done

echo ""
echo "=== Seed ==="
seed=$(curl -sS "${SUPABASE_URL}/rest/v1/centers?select=slug&slug=eq.main-center" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Accept: application/json")
if echo "$seed" | grep -q 'main-center'; then
  echo "  OK   seed center main-center"
  pass=$((pass + 1))
elif echo "$seed" | grep -q 'PGRST205'; then
  echo "  FAIL centers table missing"
  fail=$((fail + 1))
else
  echo "  WARN seed not visible via anon (RLS) — confirm in SQL Editor"
fi

echo ""
echo "=== Deep check (SQL Editor) ==="
echo "  Run supabase/scripts/verify_schema.sql for:"
echo "    • 8 enum types, 7 functions, 12 triggers, RLS, grants"
echo ""

echo "--- Summary ---"
echo "Passed: $pass"
echo "Failed: $fail"

if [[ "$fail" -gt 0 ]]; then
  echo ""
  echo "Run migrations in order:"
  echo "  1. supabase/migrations/20260523000000_initial_schema.sql"
  echo "  2. supabase/migrations/20260523000001_rls_storage.sql"
  echo "  3. supabase/migrations/20260524000002_fix_signup_trigger.sql"
  echo "  4. supabase/migrations/20260525000003_mvp_features.sql"
  echo "  5. supabase/seed.sql"
  exit 1
fi

echo ""
echo "All REST-verifiable objects present."
echo "Run verify_schema.sql in Supabase SQL Editor for full DB audit."
