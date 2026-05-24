# Flutter Project Structure & Packages

**Version:** 1.0  
**Flutter:** 3.35+  
**Dart:** 3.9+  
**Last updated:** 2026-05-23

---

## 1. Architecture overview

**Pattern:** Feature-first Clean Architecture with Riverpod

```
Presentation (UI + Controllers/Notifiers)
        ↓
Domain (Entities + Repository interfaces + Use cases)
        ↓
Data (Repository implementations + Data sources + DTOs)
        ↓
External (Supabase, Storage, Local cache)
```

**State management:** Riverpod 2.x (providers + notifiers)  
**Navigation:** go_router with role-based redirects  
**Backend:** Supabase Flutter SDK

---

## 2. Directory structure

```
learning_management_system/
├── android/
├── ios/
├── web/
├── macos/
├── windows/
├── linux/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── docs/                          # Project documentation
├── supabase/
│   ├── migrations/                # SQL migrations
│   └── functions/                 # Edge functions
├── lib/
│   ├── main.dart
│   ├── app.dart                   # MaterialApp + router + theme
│   │
│   ├── core/
│   │   ├── config/
│   │   │   ├── env.dart           # Supabase URL, keys (from env)
│   │   │   └── app_config.dart
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── storage_buckets.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   └── failure.dart
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart
│   │   │   └── string_extensions.dart
│   │   ├── network/
│   │   │   └── supabase_client.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   ├── route_names.dart
│   │   │   └── route_guards.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       └── logger.dart
│   │
│   ├── shared/
│   │   ├── domain/
│   │   │   └── enums/
│   │   │       ├── user_role.dart
│   │   │       ├── cefr_level.dart
│   │   │       ├── course_status.dart
│   │   │       └── material_type.dart
│   │   ├── data/
│   │   │   └── models/            # Shared DTOs used across features
│   │   │       └── profile_model.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   └── connectivity_provider.dart
│   │   └── widgets/
│   │       ├── app_scaffold.dart
│   │       ├── loading_indicator.dart
│   │       ├── error_view.dart
│   │       ├── empty_state.dart
│   │       ├── confirm_dialog.dart
│   │       └── role_adaptive_shell.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── data/
│       │   │   ├── datasources/auth_remote_datasource.dart
│       │   │   ├── models/user_model.dart
│       │   │   └── repositories/auth_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/user.dart
│       │   │   └── repositories/auth_repository.dart
│       │   └── presentation/
│       │       ├── providers/auth_notifier.dart
│       │       ├── screens/
│       │       │   ├── login_screen.dart
│       │       │   ├── register_screen.dart
│       │       │   └── forgot_password_screen.dart
│       │       └── widgets/
│       │           └── auth_form_field.dart
│       │
│       ├── admin/
│       │   ├── data/ ...
│       │   ├── domain/ ...
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── admin_dashboard_screen.dart
│       │       │   ├── users_list_screen.dart
│       │       │   ├── user_form_screen.dart
│       │       │   └── centers_screen.dart
│       │       └── widgets/
│       │
│       ├── instructor/
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── instructor_dashboard_screen.dart
│       │       │   ├── course_editor_screen.dart
│       │       │   ├── lesson_editor_screen.dart
│       │       │   ├── material_upload_screen.dart
│       │       │   └── batch_roster_screen.dart
│       │       └── widgets/
│       │
│       ├── student/
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── student_dashboard_screen.dart
│       │       │   ├── catalog_screen.dart
│       │       │   ├── course_detail_screen.dart
│       │       │   └── my_courses_screen.dart
│       │       └── widgets/
│       │
│       ├── courses/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── providers/courses_provider.dart
│       │       ├── screens/course_list_screen.dart
│       │       └── widgets/course_card.dart
│       │
│       ├── lessons/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── screens/lesson_player_screen.dart
│       │       └── widgets/
│       │           ├── video_player_widget.dart
│       │           └── document_viewer_widget.dart
│       │
│       ├── enrollment/
│       │   └── ...
│       │
│       ├── profile/
│       │   └── presentation/
│       │       └── screens/profile_screen.dart
│       │
│       └── notifications/
│           └── presentation/
│               └── screens/notifications_screen.dart
│
└── test/
    ├── unit/
    ├── widget/
    └── integration/
```

---

## 3. Feature module template

Each feature follows this internal structure:

```
features/{feature_name}/
├── data/
│   ├── datasources/       # Remote (Supabase) + local (optional)
│   ├── models/            # JSON serializable DTOs
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Pure Dart business objects
│   ├── repositories/      # Abstract repository interfaces
│   └── usecases/          # Optional: single-purpose business logic
└── presentation/
    ├── providers/         # Riverpod notifiers & providers
    ├── screens/           # Full-page widgets
    └── widgets/           # Feature-specific reusable widgets
```

---

## 4. Packages (pubspec.yaml)

### 4.1 Core dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Navigation
  go_router: ^14.8.1

  # Backend
  supabase_flutter: ^2.9.0

  # Serialization
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # UI
  flutter_screenutil: ^5.9.3
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  flutter_svg: ^2.0.17

  # Media
  video_player: ^2.9.3
  chewie: ^1.10.0
  file_picker: ^8.3.7
  pdfx: ^2.8.0
  url_launcher: ^6.3.1

  # Forms & validation
  reactive_forms: ^17.0.1

  # Utils
  intl: ^0.20.2
  equatable: ^2.0.7
  dartz: ^0.10.1
  logger: ^2.5.0
  connectivity_plus: ^6.1.4
  shared_preferences: ^2.5.3
  flutter_dotenv: ^5.2.1
  uuid: ^4.5.1
  path: ^1.9.1

  # Platform
  universal_platform: ^1.1.0
```

### 4.2 Dev dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.15
  freezed: ^2.5.8
  json_serializable: ^6.9.4
  riverpod_generator: ^2.6.4
  mocktail: ^1.0.4
```

### 4.3 Phase 2 additions

```yaml
# Add when implementing Phase 2 features:
firebase_core: ^3.12.1
firebase_messaging: ^15.2.4       # Push notifications
google_sign_in: ^6.2.2
sign_in_with_apple: ^6.1.4
image_picker: ^1.1.2
record: ^5.2.1                    # Audio recording for speaking practice
flutter_local_notifications: ^18.0.1
sentry_flutter: ^8.14.1           # Error tracking
```

---

## 5. Package rationale

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | Reactive state, DI, testability |
| `go_router` | Declarative routing, deep links, redirects |
| `supabase_flutter` | Auth, Postgres, Storage, Realtime |
| `freezed` + `json_serializable` | Immutable models, JSON parsing |
| `chewie` + `video_player` | Cross-platform video playback |
| `pdfx` | In-app PDF viewing |
| `file_picker` | Material upload (web + desktop + mobile) |
| `reactive_forms` | Complex forms with validation |
| `cached_network_image` | Thumbnail/avatar caching |
| `flutter_screenutil` | Responsive sizing (optional; can use LayoutBuilder instead) |
| `connectivity_plus` | Offline detection |
| `flutter_dotenv` | Environment variables (Supabase keys) |

---

## 6. Routing design

### 6.1 Route structure

```
/                           → Splash (redirect by auth)
/login                      → Login
/register                   → Register
/forgot-password            → Forgot password

/admin                      → Admin shell
/admin/dashboard
/admin/users
/admin/users/:id
/admin/centers
/admin/courses

/instructor                 → Instructor shell
/instructor/dashboard
/instructor/courses
/instructor/courses/:id/edit
/instructor/courses/:id/lessons/:lessonId
/instructor/batches
/instructor/batches/:id

/student                    → Student shell
/student/dashboard
/student/catalog
/student/courses/:id
/student/courses/:id/lessons/:lessonId
/student/my-courses

/profile                    → Shared profile
/notifications              → Shared notifications
```

### 6.2 Role guard logic

```dart
// Pseudocode
redirect: (context, state) {
  final user = ref.read(authProvider);
  if (user == null) return '/login';
  if (state.matchedLocation.startsWith('/admin') && user.role != admin) {
    return roleHome(user.role);
  }
  // ... same for instructor, student
}
```

---

## 7. Responsive layout strategy

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 600 | Bottom nav, single column |
| Tablet | 600–1024 | Navigation rail, 2 columns |
| Desktop | > 1024 | Sidebar nav, multi-column dashboard |

Use `LayoutBuilder` or `ResponsiveBreakpoints` pattern in `role_adaptive_shell.dart`.

**Platform priorities:**
- **Admin:** Web + Desktop first
- **Instructor:** Web + Tablet
- **Student:** Mobile + Web

---

## 8. Environment configuration

```env
# .env (not committed)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

```dart
// lib/core/config/env.dart
class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
}
```

---

## 9. Naming conventions

| Item | Convention | Example |
|------|------------|---------|
| Files | snake_case | `course_card.dart` |
| Classes | PascalCase | `CourseCard` |
| Providers | camelCase + Provider | `coursesProvider` |
| Screens | suffix `_screen` | `LoginScreen` |
| Models | suffix `_model` | `CourseModel` |
| Entities | plain noun | `Course` |
| Repositories | suffix `_repository` | `CourseRepository` |

---

## 10. Testing strategy

| Type | Location | Tools |
|------|----------|-------|
| Unit | `test/unit/` | mocktail, flutter_test |
| Widget | `test/widget/` | flutter_test, ProviderScope |
| Integration | `test/integration/` | integration_test |

**Priority test targets:**
- Auth flow (login, logout, role redirect)
- Enrollment logic
- Progress calculation
- Route guards
- Form validators

---

## 11. Code generation commands

```bash
# Generate freezed + json_serializable + riverpod
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

---

## 12. Platform-specific notes

### Web
- Use `file_picker` for uploads (no path provider)
- Video: ensure CORS configured on storage bucket
- Consider `url_strategy` for clean URLs

### Desktop (Windows/macOS/Linux)
- File drag-and-drop for uploads (Phase 2)
- Larger sidebar navigation default

### Mobile
- Request storage permissions for downloads
- Background audio for lesson playback (Phase 2)
- Push notification setup per platform

---

## 13. Document history

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-23 | Initial structure and package list |
