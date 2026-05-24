// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!File('.env').existsSync()) {
    print('ERROR: .env file not found. Copy .env.example to .env first.');
    exit(1);
  }

  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (url.isEmpty || key.isEmpty || url.contains('your-project')) {
    print('ERROR: SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env');
    exit(1);
  }

  print('Connecting to $url ...');

  await Supabase.initialize(url: url, anonKey: key);
  final client = Supabase.instance.client;

  try {
    await client.from('centers').select('id').limit(1);
    print('SUCCESS: Connected to Supabase');
    print('Database migrations appear to be applied.');
  } catch (e) {
    print('PARTIAL: Connected but DB query failed (run migrations first):');
    print('  $e');
    exit(1);
  }
}
