# Launch Checklist

Use this before beta/production launch.

## Backend
- [ ] Run all migrations in `supabase/migrations/` (including `20260525000003_mvp_features.sql`)
- [ ] Run `supabase/seed.sql` for default center
- [ ] Promote admin via `supabase/scripts/promote_admin.sql`
- [ ] Verify RLS: student cannot access non-enrolled lesson materials
- [ ] Set production `.env` (never commit secrets)

## App
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Test auth → enroll → watch lesson → progress saves
- [ ] Test instructor: batch → add student → schedule live session
- [ ] Test on Chrome, one mobile device, one desktop

## Legal & ops
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] Apple Developer / Google Play accounts (if shipping mobile)

## Deploy
- [ ] Web: build with `flutter build web`
- [ ] Android: `flutter build apk --release`
- [ ] iOS: archive via Xcode / TestFlight
