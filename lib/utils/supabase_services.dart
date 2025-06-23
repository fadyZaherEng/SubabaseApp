import 'package:flutter/material.dart';
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

  // sign out
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  ///make tasks table and columns in supabase (id, title, description, created_at, is_completed)
  ///CRUD operations
  //insert data into tasks table
  static Future<void> insertTask({
    required String title,
    required String description,
    required bool isCompleted,
    required void Function(String) onInsertSuccess,
    required void Function(String) onInsertFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Inserting Task...", true);
      final response = await supabase.from('tasks').insert({
        'title': title,
        'description': description,
        'is_completed': isCompleted,
      });

      onChangeStatus("Task Inserted Successfully", false);
      onInsertSuccess("Task Inserted Successfully");
    } catch (e) {
      debugPrint(e.toString());
      onChangeStatus("Insert Task Failed : $e", false);
      onInsertFailure("Insert Task Failed : $e");
    }
  }

  //update data in tasks table
  static Future<void> updateTask({
    required int id,
    required String title,
    required String description,
    required bool isCompleted,
    required void Function(String) onUpdateSuccess,
    required void Function(String) onUpdateFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Updating Task...", true);
      final response = await supabase.from('tasks').update({
        'title': title,
        'description': description,
        'is_completed': isCompleted,
      }).eq('id', id);
      if (response.error == null) {
        onChangeStatus("Task Updated Successfully", false);
        onUpdateSuccess("Task Updated Successfully");
      } else {
        onChangeStatus("Something went wrong", false);
        onUpdateFailure("Something went wrong");
      }
    } catch (e) {
      debugPrint(e.toString());
      onChangeStatus("Update Task Failed : $e", false);
      onUpdateFailure("Update Task Failed : $e");
    }
  }

  //delete data in tasks table
  static Future<void> deleteTask({
    required int id,
    required void Function(String) onDeleteSuccess,
    required void Function(String) onDeleteFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Deleting Task...", true);
      final response = await supabase.from('tasks').delete().eq('id', id);
      if (response.error == null) {
        onChangeStatus("Task Deleted Successfully", false);
        onDeleteSuccess("Task Deleted Successfully");
      } else {
        onChangeStatus("Something went wrong", false);
        onDeleteFailure("Something went wrong");
      }
    } catch (e) {
      debugPrint(e.toString());
      onChangeStatus("Delete Task Failed : $e", false);
      onDeleteFailure("Delete Task Failed : $e");
    }
  }

  // get all tasks
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await supabase.from('tasks').select();
    return response;
  }

  // get task by id
  static Future<Map<String, dynamic>?> getTaskById(int id) async {
    final response =
        await supabase.from('tasks').select().eq('id', id).single();
    return response;
  }
}
