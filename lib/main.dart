import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_shell.dart';
import 'core/constants/app_config.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: ThuChiApp()));
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
