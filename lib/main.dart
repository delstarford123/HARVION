import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'core/main_navigation.dart';

void main() async {
  // 1. Ensure Flutter is ready for native calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase (CLI Generated)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Initialize Hive for Offline Data
  await Hive.initFlutter();

  // 4. Open the boxes needed for the Admin Queue and Offline storage
  await Hive.openBox(AppConstants.boxOfflineQueue);
  await Hive.openBox(AppConstants.boxSavedArticles);
  await Hive.openBox(AppConstants.boxSabbathNotes);

  runApp(const VineApp());
}

class VineApp extends StatelessWidget {
  const VineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // 🎨 Applying your custom VINE Theme
      theme: AppTheme.lightTheme,

      // 🔓 THE DOORS ARE OPEN!
      // Everyone goes straight to the dashboard to explore the free content first.
      home: const MainNavigation(),
    );
  }
}
