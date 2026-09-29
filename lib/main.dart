import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/photo_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure Firebase options are configured for your platform
  await Firebase.initializeApp();
  runApp(const SnaplyApp());
}

class SnaplyApp extends StatelessWidget {
  const SnaplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AppAuthProvider, PhotoProvider>(
          create: (_) => PhotoProvider(),
          update: (_, auth, photo) {
            photo!.updateUser(auth.user?.uid);
            return photo;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Snaply',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF9F9F9),
              primaryColor: Colors.black,
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
                secondary: Color(0xFFE60023),
              ),
              textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: Colors.white,
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                secondary: Color(0xFFE60023),
              ),
              textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}