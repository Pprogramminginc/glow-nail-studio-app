import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';
import 'data/appointment_store.dart';
import 'data/business_store.dart';
import 'data/studio_settings_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppointmentStore.loadAppointments();
  await BusinessStore.loadBusinessProfile();
  await StudioSettingsStore.loadStudioSettings();

  runApp(const GlowBeautyApp());
}

class GlowBeautyApp extends StatelessWidget {
  const GlowBeautyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glow Nail Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6F4E37),
        scaffoldBackgroundColor: const Color(0xFFF8F5F2),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F4E37)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6F4E37),
          foregroundColor: Colors.white,
        ),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
