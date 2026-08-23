import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/journal/presentation/journal_view.dart';

class FlutterLabApp extends StatelessWidget {
  const FlutterLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lab — Bitácora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const JournalView(),
    );
  }
}
