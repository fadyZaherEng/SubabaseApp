import 'package:flutter/material.dart';
import 'package:supabase_app/model/task.dart';
import 'package:supabase_app/screens/sign_in_screen.dart';
import 'package:supabase_app/screens/storage_screen.dart';
import 'package:supabase_app/utils/supabase_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool isLoading = false;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await SupabaseServices.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
              );
            },
          ),
          //storage button
          IconButton(
            icon: const Icon(Icons.storage, color: Colors.green),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StorageScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Welcome to Supabase!'),
            const SizedBox(height: 16.0),
            //add text here to add tasks
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(labelText: 'Add Task'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (_taskController.text.isEmpty) return;
                await SupabaseServices.insertTask(
                  title: _taskController.text,
                  description: 'description',
                  isCompleted: false,
                  onChangeStatus: (String text, bool isLoading) {
                    setState(() {
                      this.isLoading = isLoading;
                    });
                  },
                  onInsertSuccess: (String text) async {
                    setState(() {
                      _taskController.clear();
                    });
                  },
                  onInsertFailure: (String text) {
                    setState(() {
                      _taskController.clear();
                    });
                  },
                );
                _taskController.clear();
                getTasks();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
            const SizedBox(height: 16.0),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(tasks[index].title),
                            subtitle: Text(tasks[index].description),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await SupabaseServices.deleteTask(
                                  id: tasks[index].id,
                                  onChangeStatus:
                                      (String text, bool isLoading) {
                                    setState(() {
                                      isLoading = isLoading;
                                    });
                                  },
                                  onDeleteSuccess: (String text) {
                                    getTasks();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  onDeleteFailure: (String text) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                );
                                getTasks();
                              },
                            ),
                            leading: Checkbox(
                              value: tasks[index].isCompleted,
                              onChanged: (bool? value) async {
                                await SupabaseServices.updateTask(
                                  id: tasks[index].id,
                                  title: tasks[index].title,
                                  description: tasks[index].description,
                                  isCompleted: value ?? false,
                                  onChangeStatus:
                                      (String text, bool isLoading) {
                                    setState(() {
                                      isLoading = isLoading;
                                    });
                                  },
                                  onUpdateSuccess: (String text) {
                                    getTasks();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  onUpdateFailure: (String text) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                );
                                getTasks();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void getTasks() async {
    tasks.clear();
    final tasksMap = await SupabaseServices.getTasks();
    for (Map<String, dynamic> task in tasksMap) {
      tasks.add(Task.fromJson(task));
    }
    setState(() {});
  }
}
