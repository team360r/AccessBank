import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

class AccessBankApp extends StatelessWidget {
  const AccessBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AccessBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text('AccessBank'),
        ),
      ),
    );
  }
}
