import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {'name': '', 'email': '', 'password': ''};
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthProvider>(context, listen: false)
            .login(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<AuthProvider>(context, listen: false)
            .register(_authData['name']!, _authData['email']!, _authData['password']!);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    if(mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.teal),
              const SizedBox(height: 8),
              const Text(
                'Convo',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 30),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  height: _authMode == AuthMode.Signup ? 270 : 160,
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          if (_authMode == AuthMode.Signup)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                              onSaved: (value) => _authData['name'] = value!,
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'E-Mail',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => !value!.contains('@') ? 'Invalid email' : null,
                            onSaved: (value) => _authData['email'] = value!,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            controller: _passwordController,
                            validator: (value) => value!.length < 6 ? 'Password is too short' : null,
                            onSaved: (value) => _authData['password'] = value!,
                          ),
                          // REVISED ANIMATION: Using AnimatedOpacity for simplicity and robustness.
                          AnimatedOpacity(
                            opacity: _authMode == AuthMode.Signup ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: TextFormField(
                              enabled: _authMode == AuthMode.Signup,
                              decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
                              obscureText: true,
                              validator: _authMode == AuthMode.Signup
                                  ? (value) => value != _passwordController.text ? 'Passwords do not match!' : null
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                ),
              TextButton(
                onPressed: _switchAuthMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}