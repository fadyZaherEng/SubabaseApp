import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  static const String supabaseUrl = 'https://czxsyvxroawdzgvijzmi.supabase.co';
  static const String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6eHN5dnhyb2F3ZHpndmlqem1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2ODI4NjQsImV4cCI6MjA2NjI1ODg2NH0.wUkuKuzCzlaBvA8X8JJ18dZjZROrrNocnyMMRjvk1ws";
  static SupabaseClient supabase = Supabase.instance.client;

  static Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  //sign up
  static Future<void> signUp({
    required String email,
    required String password,
    required void Function(String) onSignUpSuccess,
    required void Function(String) onSignUpFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Signing Up...", true);
      AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        onChangeStatus(
          "Signed Up Successfully , Please verify your email",
          false,
        );
        onSignUpSuccess(
          "Signed Up Successfully , Please verify your email",
        );
      } else {
        onChangeStatus("Something went wrong", false);
        onSignUpFailure("Something went wrong");
      }
    } catch (e) {
      onChangeStatus("Sign Up Failed : $e", false);
      onSignUpFailure("Sign Up Failed : $e");
    }
  }

  //sign in
  static Future<void> signIn({
    required String email,
    required String password,
    required void Function(String) onSignInSuccess,
    required void Function(String) onSignInFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Signing In...", true);
      AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        onChangeStatus("Signed In Successfully", false);
        onSignInSuccess("Signed In Successfully");
      } else {
        onChangeStatus("Something went wrong", false);
        onSignInFailure("Something went wrong");
      }
    } catch (e) {
      onChangeStatus("Sign In Failed : $e", false);
      onSignInFailure("Sign In Failed : $e");
    }
  }
}
