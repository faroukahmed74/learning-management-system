import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

final supabaseConnectionProvider = FutureProvider<bool>((ref) async {
  if (!Env.isConfigured) return false;

  try {
    await Supabase.instance.client.from('centers').select('id').limit(1);
    return true;
  } catch (_) {
    return false;
  }
});
