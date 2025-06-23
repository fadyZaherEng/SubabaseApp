import 'package:flutter/material.dart';
import 'package:supabase_app/screens/sign_up_screen.dart';
import 'package:supabase_app/utils/supabase_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseServices.initializeSupabase();
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
      home: const SignUpScreen(),
    );
  }
}
