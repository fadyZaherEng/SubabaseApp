import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_app/screens/home_screen.dart';
import 'package:supabase_app/screens/sign_up_screen.dart';
import 'package:supabase_app/utils/supabase_services.dart';

bool isRemember = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseServices.initializeSupabase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isRemember = prefs.getBool('isRemember') ?? false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Supabase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _handleAuth(),
    );
  }

  Widget _handleAuth() {
    if (isRemember) {
      return const HomeScreen();
    } else {
      return const SignUpScreen();
    }
  }
}
