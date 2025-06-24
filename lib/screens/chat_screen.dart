import 'package:flutter/material.dart';
import 'package:supabase_app/model/massage.dart';
import 'package:supabase_app/utils/supabase_services.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;
  final String receiverPassword;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverPassword,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Massage>>(
              stream: SupabaseServices.getMessages(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return const Center(child: CircularProgressIndicator());
                // } else
                  if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                } else {
                  List<Massage> messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      Massage message = messages[index];
                      return ListTile(
                        title: Text(message.message),
                        subtitle: Text(message.senderEmail),
                        trailing: Text(message.createdAt.toString()),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Send a message',
                border: const OutlineInputBorder(),
                suffixIcon: InkWell(
                    onTap: () async {
                      await SupabaseServices.sendMessage(
                        content: _messageController.text.trim(),
                        receiverId: widget.receiverId,
                        receiverEmail: widget.receiverEmail,
                        senderEmail: widget.receiverEmail,
                        senderId: widget.receiverId,
                        onMessageSent: (message) {
                          setState(() {});
                          _messageController.clear();
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text(message)),
                          // );
                        },
                        onMessageFailed: (message) {
                          setState(() {});
                          _messageController.clear();
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text(message)),
                          // );
                        },
                        onChangeStatus: (text, isLoading) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(text)),
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.send)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
