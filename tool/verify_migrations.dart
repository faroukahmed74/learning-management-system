// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Verifies that expected Supabase schema objects exist.
/// Uses the anon key — table existence is detected even when RLS blocks reads.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!File('.env').existsSync()) {
    print('FAIL: .env not found');
    exit(1);
  }

  await dotenv.load(fileName: '.env');
  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (url.isEmpty || key.isEmpty || url.contains('your-project')) {
    print('FAIL: Set SUPABASE_URL and SUPABASE_ANON_KEY in .env');
    exit(1);
  }

  print('Supabase migration verification');
  print('Project: $url\n');

  await Supabase.initialize(url: url, anonKey: key);
  final client = Supabase.instance.client;

  final tables = [
    'centers',
    'profiles',
    'courses',
    'course_modules',
    'lessons',
    'lesson_materials',
    'batches',
    'enrollments',
    'lesson_progress',
    'live_sessions',
    'notifications',
    'audit_logs',
  ];

  final views = ['admin_dashboard_stats'];

  var passed = 0;
  var failed = 0;
  final failures = <String>[];

  void pass(String label) {
    passed++;
    print('  OK   $label');
  }

  void fail(String label, String detail) {
    failed++;
    failures.add('$label: $detail');
    print('  FAIL $label — $detail');
  }

  print('Migration 20260523000000_initial_schema.sql');
  for (final table in tables) {
    final ok = await _tableExists(client, table);
    if (ok) {
      pass('table public.$table');
    } else {
      fail('table public.$table', 'missing — run initial_schema.sql');
    }
  }

  print('\nMigration 20260523000001_rls_storage.sql');
  for (final view in views) {
    final ok = await _tableExists(client, view);
    if (ok) {
      pass('view public.$view');
    } else {
      fail('view public.$view', 'missing — run rls_storage.sql');
    }
  }

  for (final bucket in ['avatars', 'course-thumbnails', 'materials']) {
    try {
      await client.storage.from(bucket).list();
      pass('storage bucket $bucket');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Bucket not found') || msg.contains('404')) {
        fail('storage bucket $bucket', 'missing — run rls_storage.sql');
      } else {
        // Bucket exists; list may fail due to RLS without auth — that is OK.
        pass('storage bucket $bucket');
      }
    }
  }

  print('\nMigration 20260525000003_mvp_features.sql');
  // View must exist; grant to authenticated is applied in mvp migration.
  final statsOk = await _tableExists(client, 'admin_dashboard_stats');
  if (statsOk) {
    pass('admin_dashboard_stats (required by mvp_features grant)');
  } else {
    fail('admin_dashboard_stats', 'missing — run rls_storage.sql first');
  }

  // Enrollment trigger cannot be verified via REST without service role.
  print('  SKIP trigger trg_notify_enrollment (requires SQL Editor check)');

  print('\nSeed supabase/seed.sql');
  try {
    final rows = await client.from('centers').select('slug').eq('slug', 'main-center');
    if (rows.isNotEmpty) {
      pass('default center main-center');
    } else {
      fail('default center main-center', 'not found — run seed.sql');
    }
  } catch (e) {
    final msg = e.toString();
    if (msg.contains('PGRST205')) {
      fail('seed check', 'centers table missing');
    } else {
      // RLS may block anon reads on centers — try published courses as connectivity fallback
      print('  WARN centers seed check blocked by RLS (log in as admin to confirm seed)');
    }
  }

  print('\nMigration 20260524000002_fix_signup_trigger.sql');
  print('  SKIP auth trigger (verify by registering a new test user)');

  print('\n--- Summary ---');
  print('Passed: $passed');
  print('Failed: $failed');

  if (failures.isNotEmpty) {
    print('\nAction required:');
    for (final f in failures) {
      print('  • $f');
    }
    print('\nRun missing files in Supabase Dashboard → SQL Editor, in order:');
    print('  1. supabase/migrations/20260523000000_initial_schema.sql');
    print('  2. supabase/migrations/20260523000001_rls_storage.sql');
    print('  3. supabase/migrations/20260524000002_fix_signup_trigger.sql');
    print('  4. supabase/migrations/20260525000003_mvp_features.sql');
    print('  5. supabase/seed.sql');
    exit(1);
  }

  print('\nAll verifiable schema objects are present.');
  print('Manually confirm: signup works + email confirm settings in Supabase Auth.');
}

Future<bool> _tableExists(SupabaseClient client, String name) async {
  try {
    await client.from(name).select().limit(0);
    return true;
  } catch (e) {
    final msg = e.toString();
    if (msg.contains('PGRST205') ||
        msg.contains('Could not find the table') ||
        msg.contains('schema cache')) {
      return false;
    }
    // RLS / permission / empty — table exists
    return true;
  }
}
