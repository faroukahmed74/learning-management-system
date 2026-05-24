import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

SupabaseClient? get supabaseClient =>
    Env.isConfigured ? Supabase.instance.client : null;
