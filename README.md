# Language Center LMS

Cross-platform Learning Management System built with Flutter.

## Setup (do these in order)

| Step | Doc | Action |
|------|-----|--------|
| 1 | [Supabase Setup](docs/05_SUPABASE_SETUP.md) | Create project, copy keys to `.env` |
| 2 | Migrations | Run SQL files in `supabase/migrations/` |
| 3 | [Admin Bootstrap](docs/06_ADMIN_BOOTSTRAP.md) | Register user, promote to admin |
| 4 | App | Instructor creates courses |
| 5 | App | Upload videos/PDFs, students watch |

```bash
cp .env.example .env   # Step 1
flutter pub get
flutter run -d chrome
dart run tool/verify_supabase.dart   # verify Step 1-2
```

## Documentation

- [Feature Spec](docs/01_FEATURE_SPECIFICATION.md)
- [Database ERD](docs/02_DATABASE_ERD.md)
- [Flutter Structure](docs/03_FLUTTER_STRUCTURE.md)
- [MVP Roadmap](docs/04_MVP_ROADMAP.md)

## Current features

- Auth (login, register, role-based routing)
- Supabase connection status on login
- Instructor: course CRUD, modules, lessons, material upload
- Student: published course catalog, lesson player (video + PDF)
- Admin/Instructor/Student role shells

## Run

```bash
flutter pub get
dart run pdfx:install_web   # required once for web (fixes white screen)
flutter run -d chrome    # web
flutter run -d macos     # desktop
flutter run              # mobile
```
