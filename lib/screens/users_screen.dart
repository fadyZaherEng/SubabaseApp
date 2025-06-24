import 'package:flutter/material.dart';
import 'package:supabase_app/model/user.dart';
import 'package:supabase_app/screens/chat_screen.dart';
import 'package:supabase_app/utils/supabase_services.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserModel> users = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    users = await SupabaseServices.getAllUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].userId),
            subtitle: Text(users[index].email),
            trailing: IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      receiverEmail: users[index].email,
                      receiverId: users[index].userId,
                      receiverPassword: users[index].password,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
