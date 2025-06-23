import 'package:flutter/material.dart';
import 'package:supabase_app/screens/sign_in_screen.dart';
import 'package:supabase_app/utils/supabase_services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
            ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                await SupabaseServices.signUp(
                  email: _emailController.text,
                  password: _passwordController.text,
                  onSignUpSuccess: (message) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = message;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  onSignUpFailure: (message) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = message;
                    });
                  },
                  onChangeStatus: (message, isLoading) {
                    setState(() {
                      _isLoading = isLoading;
                      _errorMessage = message;
                    });
                  },
                );
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 8),
            if (_errorMessage.isNotEmpty) Text(_errorMessage),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              },
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
