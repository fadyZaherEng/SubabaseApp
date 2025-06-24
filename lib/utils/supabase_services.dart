import 'dart:io';

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

  ///auth functions
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
  /// create, read, update, delete
  /// DataBase functions
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
      await supabase.from('tasks').insert({
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
    return await supabase.from('tasks').select('*');
  }

  // get task by id
  static Future<Map<String, dynamic>?> getTaskById(int id) async {
    return await supabase.from('tasks').select().eq('id', id).single();
  }

  ///Storage services
  // upload file to storage
  static Future<void> uploadFile({
    required File file,
    required void Function(String) onUploadSuccess,
    required void Function(String) onUploadFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Uploading file...", true);

      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      final fileName = file.uri.pathSegments.last;
      final uploadPath = 'user_files/${user.id}/$fileName';

      final response = await supabase.storage.from('files').upload(
          uploadPath, file,
          fileOptions: const FileOptions(upsert: true));

      onChangeStatus("File uploaded successfully", false);
      onUploadSuccess("File uploaded to: $uploadPath");
    } catch (e) {
      debugPrint("Upload failed: $e");
      onChangeStatus("Upload failed: $e", false);
      onUploadFailure("Upload failed: $e");
    }
  }

  // download file from storage
  static Future<void> downloadFile({
    required String fileName,
    required void Function(String) onDownloadSuccess,
    required void Function(String) onDownloadFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Downloading File...", true);
      await supabase.storage.from('files').download(fileName);
      onChangeStatus("File Downloaded Successfully", false);
      onDownloadSuccess("File Downloaded Successfully");
    } catch (e) {
      debugPrint(e.toString());
      onChangeStatus("Download File Failed : $e", false);
      onDownloadFailure("Download File Failed : $e");
    }
  }

  // delete file from storage
  static Future<void> deleteFile({
    required String fileName,
    required void Function(String) onDeleteSuccess,
    required void Function(String) onDeleteFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Deleting File...", true);
      await supabase.storage.from('files').remove([fileName]);
      onChangeStatus("File Deleted Successfully", false);
      onDeleteSuccess("File Deleted Successfully");
    } catch (e) {
      debugPrint(e.toString());
      onChangeStatus("Delete File Failed : $e", false);
      onDeleteFailure("Delete File Failed : $e");
    }
  }
}
