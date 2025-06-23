import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_app/screens/home_screen.dart';
import 'package:supabase_app/screens/sign_up_screen.dart';
import 'package:supabase_app/utils/supabase_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isLoading = true;
                          _errorMessage = '';
                        });
                        await SupabaseServices.signIn(
                          email: _emailController.text,
                          password: _passwordController.text,
                          onSignInSuccess: (message) {
                            setState(() {
                              _isLoading = false;
                              _errorMessage = message;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const HomeScreen();
                                },
                              ),
                            );
                          },
                          onSignInFailure: (message) {
                            setState(() {
                              _isLoading = false;
                              _errorMessage = message;
                            });
                          },
                          onChangeStatus: (text, isLoading) {
                            setState(() {
                              _isLoading = isLoading;
                              _errorMessage = text;
                            });
                          },
                        );
                      },
                      child: const Text('Sign In'),
                    ),
                  ),
                  _isLoading ? const CircularProgressIndicator() : Container(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SignUpScreen();
                          },
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(_errorMessage),
          ],
        ),
      ),
    );
  }
}
