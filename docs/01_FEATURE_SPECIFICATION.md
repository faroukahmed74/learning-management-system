# Language Learning Center LMS — Feature Specification

**Version:** 1.0  
**Status:** Ready for development  
**Platforms:** Android, iOS, Web, Windows, macOS  
**Backend:** Supabase (PostgreSQL + Auth + Storage) — MVP  
**Last updated:** 2026-05-23

---

## 1. Product overview

### 1.1 Purpose

A cross-platform Learning Management System (LMS) for a language learning center. The system supports administrators, instructors, and students with course delivery, media content (videos, documents, audio), enrollment, progress tracking, and role-based access.

### 1.2 Goals

- Single Flutter codebase for all platforms
- Low operational cost for video and document storage
- Clear role separation (Admin, Instructor, Student)
- Support CEFR language levels (A1–C2)
- MVP launch in 8–10 weeks; full product in phases

### 1.3 Out of scope (MVP)

- AI pronunciation scoring
- Parent portal
- Multi-tenant franchise management
- In-app payment processing (Phase 2)
- Offline video download
- Live video conferencing (Phase 2 — link-only in MVP)

---

## 2. User roles and permissions

### 2.1 Role matrix

| Feature | Admin | Instructor | Student |
|---------|:-----:|:----------:|:-------:|
| Manage users | ✅ | ❌ | ❌ |
| Manage centers/branches | ✅ | ❌ | ❌ |
| Create/edit courses | ✅ | ✅ (own) | ❌ |
| Upload materials | ✅ | ✅ (own courses) | ❌ |
| Enroll students | ✅ | ✅ (assigned batches) | ❌ |
| View all analytics | ✅ | ❌ | ❌ |
| View own class analytics | ✅ | ✅ | ❌ |
| Browse catalog | ✅ | ✅ | ✅ |
| Enroll self | ❌ | ❌ | ✅ |
| Watch lessons | ✅ | ✅ | ✅ (enrolled) |
| Submit assignments | ❌ | ❌ | ✅ |
| Grade submissions | ✅ | ✅ | ❌ |
| Send messages | ✅ | ✅ | ✅ |
| System settings | ✅ | ❌ | ❌ |

### 2.2 Role definitions

**Admin**
- Full system access
- Manages users, centers, courses, pricing, reports
- Can impersonate/support any record (audit logged)

**Instructor**
- Manages assigned courses and batches
- Uploads content, schedules sessions, grades work
- Views progress for enrolled students in their classes

**Student**
- Registers, enrolls, consumes content, submits work
- Tracks personal progress and certificates

---

## 3. Functional requirements

### 3.1 Authentication & registration

#### FR-AUTH-001: Email/password login
- Users log in with email and password
- Failed attempts show generic error (no user enumeration)
- Session persists with secure token refresh

#### FR-AUTH-002: Social login (Phase 1.5)
- Google Sign-In (all platforms)
- Apple Sign-In (iOS, macOS, Web)

#### FR-AUTH-003: Phone OTP (Phase 2)
- Optional phone registration for regions where phone is primary

#### FR-AUTH-004: Registration
- Student self-registration with: full name, email, password, phone (optional), native language, target language
- Optional placement test redirect after registration
- Email verification required before full access

#### FR-AUTH-005: Password reset
- Forgot password flow via email link
- Link expires in 1 hour

#### FR-AUTH-006: Role-based routing
- After login, redirect to role-appropriate home:
  - Admin → Admin dashboard
  - Instructor → Instructor dashboard
  - Student → Student home

#### FR-AUTH-007: Admin-created accounts
- Admin can create user with role assignment
- System sends invite email with set-password link

---

### 3.2 User profiles

#### FR-PROF-001: Profile fields
| Field | Admin | Instructor | Student |
|-------|-------|------------|---------|
| Full name | ✅ | ✅ | ✅ |
| Email | ✅ | ✅ | ✅ |
| Phone | ✅ | ✅ | ✅ |
| Avatar | ✅ | ✅ | ✅ |
| Bio | ✅ | ✅ | Optional |
| Native language | — | ✅ | ✅ |
| Target language(s) | — | ✅ | ✅ |
| CEFR level | — | — | ✅ |
| Center/branch | ✅ | ✅ | ✅ |
| Date of birth | ✅ | ✅ | Optional |
| Status (active/suspended) | ✅ | View | View own |

#### FR-PROF-002: Profile editing
- Users edit own profile (except role and email — email change via verification)
- Admin edits any profile

#### FR-PROF-003: Avatar upload
- Max 2 MB, JPG/PNG/WebP
- Stored in object storage; URL in profile

---

### 3.3 Center / branch management (Admin)

#### FR-CEN-001: CRUD centers
- Name, address, phone, email, timezone, logo
- Active/inactive flag

#### FR-CEN-002: Assign users to center
- Users belong to one primary center
- Admin can filter all lists by center

---

### 3.4 Course management

#### FR-CRS-001: Course entity
| Field | Type | Notes |
|-------|------|-------|
| title | string | Required |
| slug | string | URL-friendly, unique |
| description | text | Rich text (markdown) |
| language_taught | enum | e.g. English, French, German |
| level | enum | A1, A2, B1, B2, C1, C2 |
| thumbnail | image | Optional |
| instructor_id | FK | Primary instructor |
| center_id | FK | Optional |
| status | enum | draft, published, archived |
| price | decimal | Optional (Phase 2 payments) |
| duration_weeks | int | Optional |
| max_students | int | Optional |

#### FR-CRS-002: Course modules
- Ordered sections within a course (e.g. "Unit 1: Greetings")
- Fields: title, description, sort_order

#### FR-CRS-003: Lessons
- Belong to a module
- Fields: title, description, sort_order, duration_minutes, is_free_preview
- Lesson types: video, document, mixed, live_session_link

#### FR-CRS-004: Course CRUD permissions
- Admin: all courses
- Instructor: own courses only
- Student: read published courses in catalog

#### FR-CRS-005: Course catalog
- Filter by language, level, instructor, center
- Search by title/description
- Preview free lessons without enrollment

---

### 3.5 Materials & media

#### FR-MAT-001: Material types
| Type | Extensions | Max size (MVP) |
|------|------------|----------------|
| Video | mp4, webm | 500 MB |
| Document | pdf, docx, pptx, xlsx | 50 MB |
| Audio | mp3, m4a, wav | 100 MB |
| Image | jpg, png, webp | 10 MB |
| Link | URL | — |

#### FR-MAT-002: Upload flow
1. Instructor selects file → client validates type/size
2. Upload to object storage (presigned URL or Supabase Storage)
3. Metadata saved in `lesson_materials` table
4. Video: store stream URL; transcoding status tracked (Phase 2)

#### FR-MAT-003: Video playback
- HLS or MP4 streaming
- Resume from last position (stored in `lesson_progress`)
- Playback speed: 0.75x, 1x, 1.25x, 1.5x
- Full-screen on mobile/desktop

#### FR-MAT-004: Document viewing
- In-app PDF viewer (web + mobile)
- Download button (if policy allows)
- External open for DOCX/PPTX (Phase 1); in-app viewer Phase 2

#### FR-MAT-005: Material ordering
- Multiple materials per lesson; drag-and-drop sort order

#### FR-MAT-006: Material deletion
- Soft delete with audit log
- Storage cleanup job (Phase 2)

---

### 3.6 Enrollment & batches

#### FR-ENR-001: Enrollment
- Student enrolls in published course (self-serve or admin/instructor assigned)
- Status: active, completed, dropped, suspended
- enrolled_at, completed_at timestamps

#### FR-ENR-002: Batches / class groups
- Optional grouping: "English A2 — Morning Batch Jan 2026"
- Fields: course_id, name, start_date, end_date, schedule (JSON), max_students
- Instructor assigned to batch
- Students enrolled in batch (inherits course access)

#### FR-ENR-003: Enrollment limits
- Respect max_students on course/batch
- Waitlist (Phase 2)

---

### 3.7 Progress tracking

#### FR-PRG-001: Lesson progress
- Per student per lesson: status (not_started, in_progress, completed)
- video_position_seconds for resume
- completed_at timestamp
- Auto-mark complete at 90% video watched

#### FR-PRG-002: Course progress
- Computed: completed_lessons / total_lessons × 100
- Display on student dashboard and instructor class view

#### FR-PRG-003: Skill tracking (Phase 2)
- Per-skill CEFR sub-scores: reading, writing, listening, speaking

---

### 3.8 Assignments & quizzes (Phase 2 — spec included)

#### FR-ASG-001: Assignments
- Title, description, due_date, max_score, attachments
- Student submission: text, file upload, audio recording
- Instructor grades with score + feedback

#### FR-QUZ-001: Quizzes
- Multiple choice, true/false, fill-in-blank
- Auto-grading for objective questions
- Attempt limit and time limit (optional)
- Pass score threshold

---

### 3.9 Live sessions (MVP: link only)

#### FR-LIV-001: Session scheduling
- Title, course/batch, start_time, end_time, meeting_url (Zoom/Meet/Jitsi)
- Reminder notification 1 hour before (Phase 2)

#### FR-LIV-002: Attendance (Phase 2)
- Manual mark present/absent by instructor
- Optional auto from meeting duration

---

### 3.10 Messaging (Phase 2 — spec included)

#### FR-MSG-001: Direct messages
- Student ↔ Instructor
- Admin can view (moderation)

#### FR-MSG-002: Announcements
- Admin/instructor broadcast to course or batch
- Appears on student dashboard

---

### 3.11 Notifications

#### FR-NOT-001: In-app notifications (MVP)
- New material, enrollment confirmed, assignment graded
- Mark read/unread; list in notification center

#### FR-NOT-002: Push notifications (Phase 2)
- FCM/APNs via Firebase Cloud Messaging

#### FR-NOT-003: Email notifications (Phase 2)
- Welcome, password reset, enrollment, reminders

---

### 3.12 Admin dashboard

#### FR-ADM-001: Overview widgets
- Total students, instructors, active courses
- New enrollments (7/30 days)
- Storage usage summary

#### FR-ADM-002: User management
- List/filter/search users by role, center, status
- Create, edit, suspend, delete (soft)
- Bulk import CSV (Phase 2)

#### FR-ADM-003: Reports (Phase 2)
- Enrollment report, completion rates, instructor activity
- Export CSV/PDF

#### FR-ADM-004: Audit log
- Who did what, when (admin actions, content changes)

---

### 3.13 Instructor dashboard

#### FR-INS-001: My courses
- List courses with student count, completion rate

#### FR-INS-002: My batches
- Upcoming sessions, pending submissions (Phase 2)

#### FR-INS-003: Student roster
- Per batch: name, progress %, last activity

#### FR-INS-004: Content upload
- Quick upload to lesson from dashboard

---

### 3.14 Student dashboard

#### FR-STU-001: My courses
- Enrolled courses with progress bar
- Continue watching (last lesson)

#### FR-STU-002: Catalog
- Browse and enroll in available courses

#### FR-STU-003: Upcoming sessions
- Next live class with join link

#### FR-STU-004: Profile & settings
- Edit profile, change password, notification preferences

---

### 3.15 Certificates (Phase 2)

#### FR-CERT-001: Auto-issue on course completion
- PDF with student name, course, date, QR verification code

---

### 3.16 Placement test (Phase 2)

#### FR-PLT-001: Adaptive or fixed MCQ test
- Result assigns CEFR level to student profile

---

## 4. Non-functional requirements

### 4.1 Performance
- App cold start < 3s on mid-range mobile
- Video start playback < 2s on 10 Mbps connection
- API p95 latency < 500ms for non-media endpoints
- Support 500 concurrent users (MVP target)

### 4.2 Security
- HTTPS everywhere
- JWT/session tokens with refresh rotation
- Row Level Security (RLS) on all Supabase tables
- File upload virus scan (Phase 2)
- Rate limiting on auth endpoints
- No direct storage URLs without signed access for private content

### 4.3 Accessibility
- Minimum WCAG 2.1 AA on web
- Semantic labels on interactive elements
- Keyboard navigation on desktop/web

### 4.4 Localization
- UI languages: English (default), Arabic (RTL) — Phase 1.5
- Course content language varies by course

### 4.5 Availability
- 99.5% uptime target (MVP)
- Daily database backups (Supabase managed)

### 4.6 Platforms
| Platform | Min version |
|----------|-------------|
| Android | API 24 (7.0) |
| iOS | 13.0 |
| Web | Chrome, Safari, Firefox, Edge (last 2 versions) |
| Windows | 10+ |
| macOS | 10.15+ |

---

## 5. User flows

### 5.1 Student registration and first lesson

```
Register → Verify email → (Optional placement test) → Browse catalog
→ Enroll in course → Dashboard → Open lesson → Watch video
→ Progress saved → Mark complete → Next lesson
```

### 5.2 Instructor publishes course

```
Create course (draft) → Add modules → Add lessons → Upload materials
→ Preview → Publish → Assign to batch → Students enroll
```

### 5.3 Admin onboarding instructor

```
Admin creates instructor account → Invite email sent
→ Instructor sets password → Completes profile → Admin assigns courses
```

---

## 6. API contract overview (Supabase + Edge Functions)

### 6.1 Auth
- Supabase Auth: signUp, signIn, signOut, resetPassword, refreshSession

### 6.2 Core tables (direct Supabase client with RLS)
- profiles, courses, modules, lessons, lesson_materials
- enrollments, batches, lesson_progress, live_sessions
- notifications, audit_logs

### 6.3 Edge Functions (custom logic)
| Function | Purpose |
|----------|---------|
| `enroll-student` | Validate limits, create enrollment |
| `get-signed-media-url` | Time-limited URL for private video/doc |
| `compute-course-progress` | Aggregate lesson progress |
| `send-notification` | Create in-app + push notification |
| `admin-create-user` | Admin invite flow |

### 6.4 Storage buckets
| Bucket | Access | Content |
|--------|--------|---------|
| `avatars` | Public read | Profile photos |
| `course-thumbnails` | Public read | Course images |
| `materials` | Private (signed URL) | Videos, docs, audio |
| `submissions` | Private | Assignment uploads (Phase 2) |

---

## 7. UI screens inventory

### 7.1 Shared
- Splash, Login, Register, Forgot password, Email verification
- Profile view/edit, Settings, Notifications list

### 7.2 Admin (15 screens MVP)
- Dashboard, Users list, User detail/edit, Create user
- Centers list, Center edit
- Courses list (all), Audit log
- System settings (basic)

### 7.3 Instructor (12 screens MVP)
- Dashboard, My courses, Course editor (modules/lessons)
- Lesson editor + material upload, Batch list, Batch detail
- Student roster, Live session create/list

### 7.4 Student (10 screens MVP)
- Dashboard, Catalog, Course detail, My courses
- Lesson player (video/doc), Progress view
- Live sessions list, Profile

**Total MVP screens: ~40**

---

## 8. Data validation rules

| Entity | Rule |
|--------|------|
| Email | Valid format, unique |
| Password | Min 8 chars, 1 upper, 1 lower, 1 digit |
| Course title | 3–120 chars |
| Video upload | Max 500 MB, mp4/webm |
| Slug | Lowercase, alphanumeric + hyphens, unique |
| Enrollment | One active enrollment per student per course |

---

## 9. Error handling

| Scenario | User message | Action |
|----------|--------------|--------|
| Network offline | "No connection. Check your internet." | Retry button |
| Upload failed | "Upload failed. Try again." | Resume upload (Phase 2) |
| Unauthorized | "Session expired. Please log in." | Redirect to login |
| Not enrolled | "Enroll to access this lesson." | Show enroll CTA |
| File too large | "File exceeds maximum size (X MB)." | Block upload |

---

## 10. Acceptance criteria (MVP release)

- [ ] Admin can create instructor and student accounts
- [ ] Instructor can create course with modules, lessons, video + PDF
- [ ] Student can register, browse catalog, enroll, watch video with resume
- [ ] Progress tracked and visible to student and instructor
- [ ] Role-based access enforced (student cannot access admin routes)
- [ ] Apps run on Android, iOS, Web without critical bugs
- [ ] Private materials not accessible without enrollment (RLS verified)
- [ ] Admin dashboard shows user and enrollment counts

---

## 11. Glossary

| Term | Definition |
|------|------------|
| CEFR | Common European Framework of Reference for Languages (A1–C2) |
| Batch | A scheduled class group within a course |
| Lesson | Single learning unit within a module |
| Module | Section/chapter grouping lessons in a course |
| RLS | Row Level Security (Postgres/Supabase) |
| Enrollment | Student's active registration in a course |

---

## 12. Document history

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-23 | Initial specification for MVP development |
