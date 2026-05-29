import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'utils/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TranslationManager.loadSavedLanguage();
  runApp(const ColdStorageApp());
} 


class ColdStorageApp extends StatelessWidget {
  const ColdStorageApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MY WAREHOUSE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColor),
          primary: const Color(AppConstants.primaryColor),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
