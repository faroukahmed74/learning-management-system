# Language Center LMS

Cross-platform Learning Management System built with Flutter and Supabase.

## Setup

| Step | Doc | Action |
|------|-----|--------|
| 1 | [Supabase Setup](docs/05_SUPABASE_SETUP.md) | Create project, copy keys to `.env` |
| 2 | Migrations | Run all SQL files in `supabase/migrations/` |
| 3 | [Admin Bootstrap](docs/06_ADMIN_BOOTSTRAP.md) | Register user, promote to admin |
| 4 | App | `flutter pub get && flutter run -d chrome` |

```bash
cp .env.example .env
flutter pub get
dart run tool/verify_supabase.dart
flutter run -d chrome
```

## Features (MVP)

| Area | Features |
|------|----------|
| **Auth** | Login, register, role-based routing |
| **Admin** | Dashboard stats, users (role change), centers CRUD |
| **Instructor** | Courses, modules, lessons, materials, **batches**, roster, live sessions |
| **Student** | Catalog search/filter, **enrollment**, my courses, lesson player |
| **Progress** | Video resume, auto-complete at 90%, course progress bars |
| **Profile** | Edit profile, avatar upload |
| **Notifications** | In-app list, mark read, enrollment alerts |

## Documentation

- [Feature Spec](docs/01_FEATURE_SPECIFICATION.md)
- [Database ERD](docs/02_DATABASE_ERD.md)
- [Flutter Structure](docs/03_FLUTTER_STRUCTURE.md)
- [MVP Roadmap](docs/04_MVP_ROADMAP.md)
- [Launch Checklist](docs/07_LAUNCH_CHECKLIST.md)

## Run

```bash
flutter pub get
flutter run -d chrome    # web
flutter run -d macos     # desktop
flutter test
flutter analyze
```

**Note:** Do not run `dart run pdfx:install_web` — it breaks `web/index.html` PDF setup.

## New migration

After pulling updates, run in Supabase SQL Editor:

`supabase/migrations/20260525000003_mvp_features.sql`
