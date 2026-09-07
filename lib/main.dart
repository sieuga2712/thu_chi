import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_shell.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/category_settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chỉ khởi tạo client, KHÔNG gọi mạng ở bước này — app vẫn phải chạy được
  // hoàn toàn offline (xem section 1). Các lệnh gọi Supabase thật sự (Phase
  // 11: đồng bộ ghi chú) chỉ xảy ra khi người dùng chủ động lưu/đồng bộ note.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ThuChiApp(),
    ),
  );
}

class ThuChiApp extends StatelessWidget {
  const ThuChiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      home: const AppShell(),
    );
  }
}
