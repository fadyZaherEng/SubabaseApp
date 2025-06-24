import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_app/model/massage.dart';
import 'package:supabase_app/model/user.dart';
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
        ///check if user not exists then create user
        UserModel user = UserModel(
          userId: response.session!.user.id,
          email: email,
          password: password,
        );
        final userId = response.session!.user.id;

        // Check if user already exists
        final existing = await supabase
            .from('users')
            .select()
            .eq('userId', userId)
            .maybeSingle();

        if (existing == null) {
          // User not found → insert
          await supabase.from('users').insert(user.toJson());
          debugPrint("✅ User created.");
        } else {
          debugPrint("⚠️ User already exists.");
        }

        onChangeStatus("Signed In Successfully", false);
        onSignInSuccess("Signed In Successfully");
      } else {
        onChangeStatus("Something went wrong", false);
        onSignInFailure("Something went wrong");
      }
    } catch (e) {
      onChangeStatus("Sign In Failed : $e", false);
      onSignInFailure("Sign In Failed : $e");
      debugPrint(e.toString());
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
    required Uint8List file,
    required void Function(String) onUploadSuccess,
    required void Function(String) onUploadFailure,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    try {
      onChangeStatus("Uploading file...", true);

      final user = supabase.auth.currentUser;
      if (user == null) {
        onChangeStatus("User is not authenticated", false);
        throw Exception("User is not authenticated");
      }

      final uploadPath =
          'user_files/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      ///get list of this path
      // final existingFiles = await supabase.storage
      //     .from('files')
      //     .list(path: 'user_files/');
      ///check if file already exists
      // if (existingFiles.map((e) => e.name).contains(uploadPath)) {
      //   onChangeStatus("File already exists", false);
      //   onUploadFailure("File already exists");
      //   return;
      // }
      ///Delete existing file
      // if (existingFiles.isNotEmpty) {
      //   await supabase.storage.from('files').remove(existingFiles.map((e) => e.name).toList());
      // }
      ///replace file if another file  in the same path
      // final existingFile = await supabase.storage
      //     .from('files')
      //     .list(path: 'user_files/${user.id}/');
      // if (existingFiles.isNotEmpty) {
      //   await supabase.storage.from('files').remove(existingFile.map((e) => e.name).toList());
      // }
      ///TODO: TOAccess Privacy Storage run this sql  in sql editor of supabase
      //-- Allow authenticated users to upload to storage
      // create policy "Authenticated upload"
      // on storage.objects
      // for insert
      // with check (auth.role() = 'authenticated');
      //
      // -- Optional: allow viewing files
      // create policy "Authenticated read"
      // on storage.objects
      // for select
      // using (auth.role() = 'authenticated');
      ///upload this
      await supabase.storage.from('files').updateBinary(
            uploadPath,
            file,
          );

      ///get Download url
      final downloadUrl =
          supabase.storage.from('files').getPublicUrl(uploadPath);
      debugPrint("Download URL: $downloadUrl");
      onChangeStatus("File uploaded successfully", false);
      onUploadSuccess("File uploaded to: $uploadPath");
    } catch (e) {
      debugPrint("Upload failed: $e");
      onChangeStatus("Upload failed: $e", false);
      onUploadFailure("Upload failed: $e");
    }
  }

  ///Chat services
  //get current user id
  static String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  ///get all users
  static Future<List<UserModel>> getAllUsers() async {
    debugPrint("Getting all users...");
    List<Map<String, dynamic>> users = await supabase.from("users").select('*');
    debugPrint("Users: $users");
    return users.map((e) => UserModel.fromJson(e)).toList();
  }

  //send message
  static Future<void> sendMessage({
    required String content,
    required String receiverId,
    required String receiverEmail,
    required String senderEmail,
    required String senderId,
    required void Function(String) onMessageSent,
    required void Function(String) onMessageFailed,
    required void Function(String text, bool isLoading) onChangeStatus,
  }) async {
    final String currentUserId = getCurrentUserId() ?? "";

    final Massage message = Massage(
      senderId: currentUserId,
      message: content,
      isRead: false,
      // Not read when sent
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      receiverId: receiverId,
      isMine: senderId == currentUserId,
      createdAt: DateTime.now().toIso8601String(),
      chatId: generateChatId(currentUserId, receiverId),
    );

    try {
      onChangeStatus("Sending message...", true);
      await supabase.from('massages').insert(message.toJson());
      onChangeStatus("Message sent successfully", false);
      onMessageSent("Message sent successfully");
    } catch (e) {
      debugPrint(e.toString());
      onChangeStatus("Send message failed : $e", false);
      onMessageFailed("Send message failed : $e");
    }
  }

  static String generateChatId(String user1, String user2) {
    // Consistent order so sender/receiver order doesn't matter
    final sorted = [user1, user2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  //TODO: get messages by id and  send  message by id for receiver  and sender
  ///ابقا اجرب ال ريل داتا بيز يمكن فيها نظام ال اتشلديرنت وال
  ///tree w children w parent as firebase realtime database
  ///get messages
  static Stream<List<Massage>> getMessagesWithUser(String otherUserId) {
    final String currentUserId = getCurrentUserId() ?? "";
    final String chatId = generateChatId(currentUserId, otherUserId);

    return supabase
        .from('massages')
        .stream(primaryKey: ['id'])
        .eq('chatId', chatId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Massage.fromJson(map)).toList());
  }
}
