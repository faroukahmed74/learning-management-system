import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../shared/domain/enums/user_role.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static final _values = <String, Map<String, String>>{
    'en': _en,
    'ar': _ar,
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  String get appName => _t('appName');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get close => _t('close');
  String get delete => _t('delete');
  String get edit => _t('edit');
  String get add => _t('add');
  String get loading => _t('loading');
  String get notFound => _t('notFound');
  String get required => _t('required');
  String get active => _t('active');
  String get inactive => _t('inactive');
  String get settings => _t('settings');
  String get theme => _t('theme');
  String get language => _t('language');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get themeSystem => _t('themeSystem');
  String get english => _t('english');
  String get arabic => _t('arabic');
  String get notifications => _t('notifications');
  String get profile => _t('profile');
  String get signOut => _t('signOut');
  String get notSignedIn => _t('notSignedIn');
  String get signIn => _t('signIn');
  String get signInSubtitle => _t('signInSubtitle');
  String get email => _t('email');
  String get password => _t('password');
  String get forgotPassword => _t('forgotPassword');
  String get createAccount => _t('createAccount');
  String get register => _t('register');
  String get fullName => _t('fullName');
  String get nativeLanguage => _t('nativeLanguage');
  String get targetLanguage => _t('targetLanguage');
  String get resetPassword => _t('resetPassword');
  String get resetLinkSent => _t('resetLinkSent');
  String get checkEmailReset => _t('checkEmailReset');
  String get backToLogin => _t('backToLogin');
  String get sendResetLink => _t('sendResetLink');
  String get resetPasswordHint => _t('resetPasswordHint');
  String get supabaseNotConfigured => _t('supabaseNotConfigured');
  String get updateEnvFile => _t('updateEnvFile');
  String get connectedToSupabase => _t('connectedToSupabase');
  String get databaseNotReady => _t('databaseNotReady');
  String get backendReachable => _t('backendReachable');
  String get applyMigrations => _t('applyMigrations');
  String get accountCreated => _t('accountCreated');
  String get emailRequired => _t('emailRequired');
  String get emailInvalid => _t('emailInvalid');
  String get passwordRequired => _t('passwordRequired');
  String get passwordMinLength => _t('passwordMinLength');
  String get passwordUppercase => _t('passwordUppercase');
  String get passwordLowercase => _t('passwordLowercase');
  String get passwordNumber => _t('passwordNumber');
  String fieldRequired(String field) => _t('fieldRequired').replaceAll('{field}', field);
  String get dashboard => _t('dashboard');
  String get users => _t('users');
  String get centers => _t('centers');
  String get courses => _t('courses');
  String get batches => _t('batches');
  String get home => _t('home');
  String get catalog => _t('catalog');
  String get myCourses => _t('myCourses');
  String get roleAdmin => _t('roleAdmin');
  String get roleInstructor => _t('roleInstructor');
  String get roleStudent => _t('roleStudent');
  String get setStudent => _t('setStudent');
  String get setInstructor => _t('setInstructor');
  String get setAdmin => _t('setAdmin');
  String get adminDashboard => _t('adminDashboard');
  String get students => _t('students');
  String get instructors => _t('instructors');
  String get activeCourses => _t('activeCourses');
  String get enrollments7d => _t('enrollments7d');
  String get noUsersYet => _t('noUsersYet');
  String get usersWillAppear => _t('usersWillAppear');
  String get noCentersYet => _t('noCentersYet');
  String get addCenterOrSeed => _t('addCenterOrSeed');
  String get addCenter => _t('addCenter');
  String get newCenter => _t('newCenter');
  String get name => _t('name');
  String get slug => _t('slug');
  String get instructorDashboard => _t('instructorDashboard');
  String get myCoursesTitle => _t('myCoursesTitle');
  String get createManageCourses => _t('createManageCourses');
  String get uploadMaterials => _t('uploadMaterials');
  String get uploadMaterialsDesc => _t('uploadMaterialsDesc');
  String get liveSessions => _t('liveSessions');
  String get liveSessionsDesc => _t('liveSessionsDesc');
  String get newCourse => _t('newCourse');
  String get noCoursesYet => _t('noCoursesYet');
  String get createFirstCourse => _t('createFirstCourse');
  String get configureSupabase => _t('configureSupabase');
  String get newBatch => _t('newBatch');
  String get noBatchesYet => _t('noBatchesYet');
  String get createBatchHint => _t('createBatchHint');
  String get batch => _t('batch');
  String get batchNotFound => _t('batchNotFound');
  String get editBatch => _t('editBatch');
  String get newBatchTitle => _t('newBatchTitle');
  String get selectCourse => _t('selectCourse');
  String get batchName => _t('batchName');
  String get maxStudents => _t('maxStudents');
  String get startDate => _t('startDate');
  String get endDate => _t('endDate');
  String get notSet => _t('notSet');
  String get createCourseFirst => _t('createCourseFirst');
  String get addStudent => _t('addStudent');
  String get noStudents => _t('noStudents');
  String get addStudentsHint => _t('addStudentsHint');
  String get searchStudent => _t('searchStudent');
  String get schedule => _t('schedule');
  String get noSessions => _t('noSessions');
  String get scheduleSessionHint => _t('scheduleSessionHint');
  String get scheduleLiveSession => _t('scheduleLiveSession');
  String get meetingUrl => _t('meetingUrl');
  String get course => _t('course');
  String get courseEditor => _t('courseEditor');
  String get newModule => _t('newModule');
  String get moduleTitle => _t('moduleTitle');
  String get deleteModule => _t('deleteModule');
  String get deleteModuleConfirm => _t('deleteModuleConfirm');
  String get addModule => _t('addModule');
  String get noModulesYet => _t('noModulesYet');
  String get newLesson => _t('newLesson');
  String get lessonTitle => _t('lessonTitle');
  String get editCourse => _t('editCourse');
  String get courseTitle => _t('courseTitle');
  String get languageTaught => _t('languageTaught');
  String get description => _t('description');
  String get manageModulesLessons => _t('manageModulesLessons');
  String get noMaterials => _t('noMaterials');
  String get uploadMaterialHint => _t('uploadMaterialHint');
  String get uploadMaterial => _t('uploadMaterial');
  String get upload => _t('upload');
  String get addMaterial => _t('addMaterial');
  String get uploading => _t('uploading');
  String get preview => _t('preview');
  String get studentHome => _t('studentHome');
  String get continueLearning => _t('continueLearning');
  String get browseEnrolled => _t('browseEnrolled');
  String get browseCatalog => _t('browseCatalog');
  String get findCourses => _t('findCourses');
  String get courseCatalog => _t('courseCatalog');
  String get noCoursesFound => _t('noCoursesFound');
  String get tryDifferentSearch => _t('tryDifferentSearch');
  String get searchCourses => _t('searchCourses');
  String get level => _t('level');
  String get allLevels => _t('allLevels');
  String get enrollInCourse => _t('enrollInCourse');
  String get enrolledSuccess => _t('enrolledSuccess');
  String get freePreview => _t('freePreview');
  String get enrollToUnlock => _t('enrollToUnlock');
  String percentComplete(int p, int done, int total) =>
      _t('percentComplete').replaceAll('{p}', '$p').replaceAll('{done}', '$done').replaceAll('{total}', '$total');
  String get notEnrolledYet => _t('notEnrolledYet');
  String get enrollFromCatalog => _t('enrollFromCatalog');
  String get lesson => _t('lesson');
  String get lessonNotFound => _t('lessonNotFound');
  String get noContentYet => _t('noContentYet');
  String get noMaterialsUploaded => _t('noMaterialsUploaded');
  String get couldNotLoadVideo => _t('couldNotLoadVideo');
  String get editProfile => _t('editProfile');
  String get phone => _t('phone');
  String get bio => _t('bio');
  String get nativeLabel => _t('nativeLabel');
  String get learningLabel => _t('learningLabel');
  String get markAllRead => _t('markAllRead');
  String get noNotificationsYet => _t('noNotificationsYet');
  String get title => _t('title');
  String get loadingStats => _t('loadingStats');
  String get loadingUsers => _t('loadingUsers');
  String get loadingCenters => _t('loadingCenters');
  String get loadingCourses => _t('loadingCourses');
  String get loadingBatches => _t('loadingBatches');
  String get loadingCatalog => _t('loadingCatalog');
  String get loadingLesson => _t('loadingLesson');
  String get couldNotVerifyConnection => _t('couldNotVerifyConnection');
  String get retry => _t('retry');
  String get createCourse => _t('createCourse');
  String get courseNotFound => _t('courseNotFound');
  String get status => _t('status');
  String get cefrLevel => _t('cefrLevel');
  String get startLabel => _t('startLabel');
  String get endLabel => _t('endLabel');
  String get addLesson => _t('addLesson');
  String minChars(int n) => _t('minChars').replaceAll('{n}', '$n');
  String unitLabel(int n) => _t('unitLabel').replaceAll('{n}', '$n');
  String get genericError => _t('genericError');
  String get emailNotConfirmed => _t('emailNotConfirmed');
  String get invalidCredentials => _t('invalidCredentials');
  String get emailAlreadyExists => _t('emailAlreadyExists');
  String get tooManyRequests => _t('tooManyRequests');
  String get permissionDenied => _t('permissionDenied');
  String get alreadyExists => _t('alreadyExists');
  String get networkError => _t('networkError');
  String get sessionExpired => _t('sessionExpired');
  String get uploadInvalidFile => _t('uploadInvalidFile');
  String get loadFailed => _t('loadFailed');
  String get uploadFailed => _t('uploadFailed');
  String get rosterError => _t('rosterError');
  String get sessionsError => _t('sessionsError');

  static const Map<String, String> _en = {
    'appName': 'Language Center LMS',
    'save': 'Save',
    'cancel': 'Cancel',
    'close': 'Close',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'loading': 'Loading...',
    'notFound': 'Not found',
    'required': 'Required',
    'active': 'Active',
    'inactive': 'Inactive',
    'settings': 'Settings',
    'theme': 'Theme',
    'language': 'Language',
    'themeLight': 'Light',
    'themeDark': 'Dark',
    'themeSystem': 'System',
    'english': 'English',
    'arabic': 'Arabic',
    'notifications': 'Notifications',
    'profile': 'Profile',
    'signOut': 'Sign Out',
    'notSignedIn': 'Not signed in',
    'signIn': 'Sign In',
    'signInSubtitle': 'Sign in to continue learning',
    'email': 'Email',
    'password': 'Password',
    'forgotPassword': 'Forgot password?',
    'createAccount': 'Create student account',
    'register': 'Register',
    'fullName': 'Full name',
    'nativeLanguage': 'Native language',
    'targetLanguage': 'Target language',
    'resetPassword': 'Reset password',
    'resetLinkSent': 'Reset link sent',
    'checkEmailReset': 'Check your email for a password reset link.',
    'backToLogin': 'Back to login',
    'sendResetLink': 'Send reset link',
    'resetPasswordHint': 'Enter your email and we will send you a reset link.',
    'supabaseNotConfigured': 'Supabase not configured',
    'updateEnvFile': 'Update .env with your Supabase URL and anon key.',
    'connectedToSupabase': 'Connected to Supabase',
    'databaseNotReady': 'Database not ready',
    'backendReachable': 'Backend is configured and reachable',
    'applyMigrations': 'Apply migrations — see docs/05_SUPABASE_SETUP.md',
    'accountCreated': 'Account created. Check your email to verify.',
    'emailRequired': 'Email is required',
    'emailInvalid': 'Enter a valid email',
    'passwordRequired': 'Password is required',
    'passwordMinLength': 'Password must be at least 8 characters',
    'passwordUppercase': 'Include at least one uppercase letter',
    'passwordLowercase': 'Include at least one lowercase letter',
    'passwordNumber': 'Include at least one number',
    'fieldRequired': '{field} is required',
    'dashboard': 'Dashboard',
    'users': 'Users',
    'centers': 'Centers',
    'courses': 'Courses',
    'batches': 'Batches',
    'home': 'Home',
    'catalog': 'Catalog',
    'myCourses': 'My Courses',
    'roleAdmin': 'Admin',
    'roleInstructor': 'Instructor',
    'roleStudent': 'Student',
    'setStudent': 'Set student',
    'setInstructor': 'Set instructor',
    'setAdmin': 'Set admin',
    'adminDashboard': 'Admin Dashboard',
    'students': 'Students',
    'instructors': 'Instructors',
    'activeCourses': 'Active Courses',
    'enrollments7d': 'Enrollments (7d)',
    'noUsersYet': 'No users yet',
    'usersWillAppear': 'Registered users will appear here.',
    'noCentersYet': 'No centers yet',
    'addCenterOrSeed': 'Add a center or run supabase/seed.sql.',
    'addCenter': 'Add center',
    'newCenter': 'New center',
    'name': 'Name',
    'slug': 'Slug',
    'instructorDashboard': 'Instructor Dashboard',
    'myCoursesTitle': 'My Courses',
    'createManageCourses': 'Create and manage your courses',
    'uploadMaterials': 'Upload Materials',
    'uploadMaterialsDesc': 'Videos, PDFs, audio for lessons',
    'liveSessions': 'Live Sessions',
    'liveSessionsDesc': 'Schedule classes with meeting links',
    'newCourse': 'New Course',
    'noCoursesYet': 'No courses yet',
    'createFirstCourse': 'Create your first course with modules and lessons.',
    'configureSupabase': 'Configure Supabase in .env to get started.',
    'newBatch': 'New Batch',
    'noBatchesYet': 'No batches yet',
    'createBatchHint': 'Create a class group and assign students.',
    'batch': 'Batch',
    'batchNotFound': 'Batch not found',
    'editBatch': 'Edit Batch',
    'newBatchTitle': 'New Batch',
    'selectCourse': 'Select a course',
    'batchName': 'Batch name',
    'maxStudents': 'Max students (optional)',
    'startDate': 'Start date',
    'endDate': 'End date',
    'notSet': 'Not set',
    'createCourseFirst': 'Create a course first before adding a batch.',
    'addStudent': 'Add student',
    'noStudents': 'No students',
    'addStudentsHint': 'Add students to this batch.',
    'searchStudent': 'Search by name or email',
    'schedule': 'Schedule',
    'noSessions': 'No sessions',
    'scheduleSessionHint': 'Schedule a live class with a meeting link.',
    'scheduleLiveSession': 'Schedule live session',
    'meetingUrl': 'Meeting URL',
    'title': 'Title',
    'course': 'Course',
    'courseEditor': 'Course Editor',
    'newModule': 'New Module',
    'moduleTitle': 'Module title',
    'deleteModule': 'Delete module?',
    'deleteModuleConfirm': 'All lessons in this module will be deleted.',
    'addModule': 'Add Module',
    'noModulesYet': 'No modules yet. Tap "Add Module" to start.',
    'newLesson': 'New Lesson',
    'lessonTitle': 'Lesson title',
    'editCourse': 'Edit Course',
    'courseTitle': 'Course title',
    'languageTaught': 'Language taught',
    'description': 'Description',
    'manageModulesLessons': 'Manage modules & lessons',
    'noMaterials': 'No materials',
    'uploadMaterialHint': 'Upload videos, PDFs, or audio for this lesson.',
    'uploadMaterial': 'Upload Material',
    'upload': 'Upload',
    'addMaterial': 'Add Material',
    'uploading': 'Uploading...',
    'preview': 'Preview',
    'studentHome': 'Student Home',
    'continueLearning': 'Continue Learning',
    'browseEnrolled': 'Browse your enrolled courses',
    'browseCatalog': 'Browse Catalog',
    'findCourses': 'Find courses to enroll in',
    'courseCatalog': 'Course Catalog',
    'noCoursesFound': 'No courses found',
    'tryDifferentSearch': 'Try a different search or filter.',
    'searchCourses': 'Search courses...',
    'level': 'Level',
    'allLevels': 'All levels',
    'enrollInCourse': 'Enroll in this course',
    'enrolledSuccess': 'Enrolled successfully!',
    'freePreview': 'Free preview',
    'enrollToUnlock': 'Enroll to unlock',
    'percentComplete': '{p}% complete ({done}/{total} lessons)',
    'notEnrolledYet': 'Not enrolled yet',
    'enrollFromCatalog': 'Browse the catalog and enroll in a course.',
    'lesson': 'Lesson',
    'lessonNotFound': 'Lesson not found',
    'noContentYet': 'No content yet',
    'noMaterialsUploaded': 'This lesson has no materials uploaded.',
    'couldNotLoadVideo': 'Could not load video',
    'editProfile': 'Edit profile',
    'phone': 'Phone',
    'bio': 'Bio',
    'nativeLabel': 'Native',
    'learningLabel': 'Learning',
    'markAllRead': 'Mark all read',
    'noNotificationsYet': 'No notifications yet',
    'loadingStats': 'Loading stats...',
    'loadingUsers': 'Loading users...',
    'loadingCenters': 'Loading centers...',
    'loadingCourses': 'Loading courses...',
    'loadingBatches': 'Loading batches...',
    'loadingCatalog': 'Loading catalog...',
    'loadingLesson': 'Loading lesson...',
    'couldNotVerifyConnection': 'Could not verify connection',
    'retry': 'Retry',
    'createCourse': 'Create Course',
    'courseNotFound': 'Course not found',
    'status': 'Status',
    'cefrLevel': 'CEFR Level',
    'startLabel': 'Start',
    'endLabel': 'End',
    'addLesson': 'Add Lesson',
    'minChars': 'Min {n} characters',
    'unitLabel': 'Unit {n}',
    'uploadFailed': 'Could not upload this file. Please try again.',
    'genericError': 'Something went wrong. Please try again.',
    'emailNotConfirmed': 'Please verify your email before signing in. Check your inbox for the confirmation link.',
    'invalidCredentials': 'Incorrect email or password. Please try again.',
    'emailAlreadyExists': 'An account with this email already exists.',
    'tooManyRequests': 'Too many attempts. Please wait a moment and try again.',
    'permissionDenied': 'You do not have permission to perform this action.',
    'alreadyExists': 'This item already exists.',
    'networkError': 'Could not connect. Check your internet connection and try again.',
    'sessionExpired': 'Your session has expired. Please sign in again.',
    'uploadInvalidFile': 'This file could not be uploaded. Try renaming it or use a different file.',
    'loadFailed': 'Could not load data. Please try again.',
    'rosterError': 'Could not load students.',
    'sessionsError': 'Could not load live sessions.',
  };

  static const Map<String, String> _ar = {
    'appName': 'نظام إدارة مركز اللغات',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'close': 'إغلاق',
    'delete': 'حذف',
    'edit': 'تعديل',
    'add': 'إضافة',
    'loading': 'جاري التحميل...',
    'notFound': 'غير موجود',
    'required': 'مطلوب',
    'active': 'نشط',
    'inactive': 'غير نشط',
    'settings': 'الإعدادات',
    'theme': 'المظهر',
    'language': 'اللغة',
    'themeLight': 'فاتح',
    'themeDark': 'داكن',
    'themeSystem': 'تلقائي',
    'english': 'English',
    'arabic': 'العربية',
    'notifications': 'الإشعارات',
    'profile': 'الملف الشخصي',
    'signOut': 'تسجيل الخروج',
    'notSignedIn': 'غير مسجل الدخول',
    'signIn': 'تسجيل الدخول',
    'signInSubtitle': 'سجّل الدخول لمتابعة التعلم',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'createAccount': 'إنشاء حساب طالب',
    'register': 'التسجيل',
    'fullName': 'الاسم الكامل',
    'nativeLanguage': 'اللغة الأم',
    'targetLanguage': 'اللغة المستهدفة',
    'resetPassword': 'إعادة تعيين كلمة المرور',
    'resetLinkSent': 'تم إرسال رابط إعادة التعيين',
    'checkEmailReset': 'تحقق من بريدك الإلكتروني للحصول على رابط إعادة التعيين.',
    'backToLogin': 'العودة لتسجيل الدخول',
    'sendResetLink': 'إرسال رابط إعادة التعيين',
    'resetPasswordHint': 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.',
    'supabaseNotConfigured': 'Supabase غير مُعد',
    'updateEnvFile': 'حدّث ملف .env بعنوان Supabase والمفتاح.',
    'connectedToSupabase': 'متصل بـ Supabase',
    'databaseNotReady': 'قاعدة البيانات غير جاهزة',
    'backendReachable': 'الخادم مُعد ويمكن الوصول إليه',
    'applyMigrations': 'طبّق migrations — راجع docs/05_SUPABASE_SETUP.md',
    'accountCreated': 'تم إنشاء الحساب. تحقق من بريدك للتفعيل.',
    'emailRequired': 'البريد الإلكتروني مطلوب',
    'emailInvalid': 'أدخل بريداً إلكترونياً صالحاً',
    'passwordRequired': 'كلمة المرور مطلوبة',
    'passwordMinLength': 'كلمة المرور 8 أحرف على الأقل',
    'passwordUppercase': 'يجب أن تحتوي على حرف كبير',
    'passwordLowercase': 'يجب أن تحتوي على حرف صغير',
    'passwordNumber': 'يجب أن تحتوي على رقم',
    'fieldRequired': '{field} مطلوب',
    'dashboard': 'لوحة التحكم',
    'users': 'المستخدمون',
    'centers': 'المراكز',
    'courses': 'الدورات',
    'batches': 'المجموعات',
    'home': 'الرئيسية',
    'catalog': 'الفهرس',
    'myCourses': 'دوراتي',
    'roleAdmin': 'مدير',
    'roleInstructor': 'مدرس',
    'roleStudent': 'طالب',
    'setStudent': 'تعيين كطالب',
    'setInstructor': 'تعيين كمدرس',
    'setAdmin': 'تعيين كمدير',
    'adminDashboard': 'لوحة تحكم المدير',
    'students': 'الطلاب',
    'instructors': 'المدرسون',
    'activeCourses': 'الدورات النشطة',
    'enrollments7d': 'التسجيلات (7 أيام)',
    'noUsersYet': 'لا يوجد مستخدمون',
    'usersWillAppear': 'سيظهر المستخدمون المسجلون هنا.',
    'noCentersYet': 'لا توجد مراكز',
    'addCenterOrSeed': 'أضف مركزاً أو شغّل supabase/seed.sql.',
    'addCenter': 'إضافة مركز',
    'newCenter': 'مركز جديد',
    'name': 'الاسم',
    'slug': 'المعرّف',
    'instructorDashboard': 'لوحة المدرس',
    'myCoursesTitle': 'دوراتي',
    'createManageCourses': 'إنشاء وإدارة دوراتك',
    'uploadMaterials': 'رفع المواد',
    'uploadMaterialsDesc': 'فيديوهات وPDF وصوت للدروس',
    'liveSessions': 'الجلسات المباشرة',
    'liveSessionsDesc': 'جدولة الحصص مع روابط الاجتماع',
    'newCourse': 'دورة جديدة',
    'noCoursesYet': 'لا توجد دورات',
    'createFirstCourse': 'أنشئ دورتك الأولى مع الوحدات والدروس.',
    'configureSupabase': 'اضبط Supabase في .env للبدء.',
    'newBatch': 'مجموعة جديدة',
    'noBatchesYet': 'لا توجد مجموعات',
    'createBatchHint': 'أنشئ مجموعة صفية وعيّن الطلاب.',
    'batch': 'مجموعة',
    'batchNotFound': 'المجموعة غير موجودة',
    'editBatch': 'تعديل المجموعة',
    'newBatchTitle': 'مجموعة جديدة',
    'selectCourse': 'اختر دورة',
    'batchName': 'اسم المجموعة',
    'maxStudents': 'الحد الأقصى للطلاب (اختياري)',
    'startDate': 'تاريخ البداية',
    'endDate': 'تاريخ النهاية',
    'notSet': 'غير محدد',
    'createCourseFirst': 'أنشئ دورة أولاً قبل إضافة مجموعة.',
    'addStudent': 'إضافة طالب',
    'noStudents': 'لا يوجد طلاب',
    'addStudentsHint': 'أضف طلاباً إلى هذه المجموعة.',
    'searchStudent': 'ابحث بالاسم أو البريد',
    'schedule': 'جدولة',
    'noSessions': 'لا توجد جلسات',
    'scheduleSessionHint': 'جدول حصة مباشرة مع رابط الاجتماع.',
    'scheduleLiveSession': 'جدولة جلسة مباشرة',
    'meetingUrl': 'رابط الاجتماع',
    'title': 'العنوان',
    'course': 'دورة',
    'courseEditor': 'محرر الدورة',
    'newModule': 'وحدة جديدة',
    'moduleTitle': 'عنوان الوحدة',
    'deleteModule': 'حذف الوحدة؟',
    'deleteModuleConfirm': 'سيتم حذف جميع الدروس في هذه الوحدة.',
    'addModule': 'إضافة وحدة',
    'noModulesYet': 'لا توجد وحدات. اضغط "إضافة وحدة" للبدء.',
    'newLesson': 'درس جديد',
    'lessonTitle': 'عنوان الدرس',
    'editCourse': 'تعديل الدورة',
    'courseTitle': 'عنوان الدورة',
    'languageTaught': 'اللغة المُدرَّسة',
    'description': 'الوصف',
    'manageModulesLessons': 'إدارة الوحدات والدروس',
    'noMaterials': 'لا توجد مواد',
    'uploadMaterialHint': 'ارفع فيديوهات أو PDF أو صوت لهذا الدرس.',
    'uploadMaterial': 'رفع مادة',
    'upload': 'رفع',
    'addMaterial': 'إضافة مادة',
    'uploading': 'جاري الرفع...',
    'preview': 'معاينة',
    'studentHome': 'الصفحة الرئيسية',
    'continueLearning': 'متابعة التعلم',
    'browseEnrolled': 'تصفح دوراتك المسجلة',
    'browseCatalog': 'تصفح الفهرس',
    'findCourses': 'ابحث عن دورات للتسجيل',
    'courseCatalog': 'فهرس الدورات',
    'noCoursesFound': 'لم يتم العثور على دورات',
    'tryDifferentSearch': 'جرّب بحثاً أو فلتراً مختلفاً.',
    'searchCourses': 'ابحث عن دورات...',
    'level': 'المستوى',
    'allLevels': 'جميع المستويات',
    'enrollInCourse': 'التسجيل في هذه الدورة',
    'enrolledSuccess': 'تم التسجيل بنجاح!',
    'freePreview': 'معاينة مجانية',
    'enrollToUnlock': 'سجّل للفتح',
    'percentComplete': '{p}% مكتمل ({done}/{total} دروس)',
    'notEnrolledYet': 'غير مسجل بعد',
    'enrollFromCatalog': 'تصفح الفهرس وسجّل في دورة.',
    'lesson': 'درس',
    'lessonNotFound': 'الدرس غير موجود',
    'noContentYet': 'لا يوجد محتوى',
    'noMaterialsUploaded': 'لا توجد مواد مرفوعة لهذا الدرس.',
    'couldNotLoadVideo': 'تعذر تحميل الفيديو',
    'editProfile': 'تعديل الملف',
    'phone': 'الهاتف',
    'bio': 'نبذة',
    'nativeLabel': 'الأم',
    'learningLabel': 'التعلم',
    'markAllRead': 'تعليم الكل كمقروء',
    'noNotificationsYet': 'لا توجد إشعارات',
    'loadingStats': 'جاري تحميل الإحصائيات...',
    'loadingUsers': 'جاري تحميل المستخدمين...',
    'loadingCenters': 'جاري تحميل المراكز...',
    'loadingCourses': 'جاري تحميل الدورات...',
    'loadingBatches': 'جاري تحميل المجموعات...',
    'loadingCatalog': 'جاري تحميل الفهرس...',
    'loadingLesson': 'جاري تحميل الدرس...',
    'couldNotVerifyConnection': 'تعذر التحقق من الاتصال',
    'retry': 'إعادة المحاولة',
    'createCourse': 'إنشاء دورة',
    'courseNotFound': 'الدورة غير موجودة',
    'status': 'الحالة',
    'cefrLevel': 'مستوى CEFR',
    'startLabel': 'البداية',
    'endLabel': 'النهاية',
    'addLesson': 'إضافة درس',
    'minChars': '{n} أحرف على الأقل',
    'unitLabel': 'الوحدة {n}',
    'uploadFailed': 'تعذر رفع الملف. حاول مرة أخرى.',
    'genericError': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
    'emailNotConfirmed': 'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول. تحقق من صندوق الوارد.',
    'invalidCredentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    'emailAlreadyExists': 'يوجد حساب مسجل بهذا البريد الإلكتروني.',
    'tooManyRequests': 'محاولات كثيرة. انتظر قليلاً ثم حاول مرة أخرى.',
    'permissionDenied': 'ليس لديك صلاحية لتنفيذ هذا الإجراء.',
    'alreadyExists': 'هذا العنصر موجود بالفعل.',
    'networkError': 'تعذر الاتصال. تحقق من الإنترنت وحاول مرة أخرى.',
    'sessionExpired': 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
    'uploadInvalidFile': 'تعذر رفع هذا الملف. جرّب تغيير الاسم أو استخدم ملفاً آخر.',
    'loadFailed': 'تعذر تحميل البيانات. حاول مرة أخرى.',
    'rosterError': 'تعذر تحميل الطلاب.',
    'sessionsError': 'تعذر تحميل الجلسات المباشرة.',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension UserRoleL10n on UserRole {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        UserRole.admin => l10n.roleAdmin,
        UserRole.instructor => l10n.roleInstructor,
        UserRole.student => l10n.roleStudent,
      };
}
