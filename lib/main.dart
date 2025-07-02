import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart'; // 🚨 NEW

import 'core/routes/app_routes.dart';
import 'feature/auth/provider/auth_provider.dart';
import 'feature/todo/provider/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required for SQLite on desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Set minimum window size for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(350, 700)); // 🚫 Users can't resize below this
    setWindowMaxSize(Size.infinite); // Optional: allow full-screen
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Task Flow',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: AppRoutes.login,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
