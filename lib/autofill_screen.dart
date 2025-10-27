// login_page.dart

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:pwacam/profile_screen.dart';
import 'package:pwacam/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // **تغییر ۱: یک FocusNode برای فیلد پسورد تعریف می‌کنیم**
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;

  Future<void> _performAuthAction(Future<void> Function() authFuture) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await authFuture();
      html.window.location.assign('/welcome');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onLogin() {
    _performAuthAction(() => AuthService.login(
          _usernameController.text,
          _passwordController.text,
        ));
  }

  void _onRegister() {
    _performAuthAction(() => AuthService.register(
          _usernameController.text,
          _passwordController.text,
        ));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose(); // **تغییر ۲: FocusNode را حتما dispose کنید**
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود / ثبت‌نام')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_person_sharp, size: 80, color: Colors.indigo),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'نام کاربری', prefixIcon: Icon(Icons.person_outline)),
                    autofillHints: const [AutofillHints.username, AutofillHints.newUsername],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    // **تغییر ۳: منطق انتقال فوکوس**
                    onChanged: (value) {
                      // اگر فیلد نام کاربری به طور ناگهانی پر شد (یعنی Autofill شده)
                      // و فیلد پسورد خالی بود، فوکوس را به پسورد منتقل کن.
                      if (value.isNotEmpty && _passwordController.text.isEmpty) {
                        _passwordFocusNode.requestFocus();
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'لطفا نام کاربری را وارد کنید';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode, // **تغییر ۴: اتصال FocusNode به فیلد پسورد**
                    decoration: const InputDecoration(labelText: 'رمز عبور', prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password, AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onLogin(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'لطفا رمز عبور را وارد کنید';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          onPressed: _onLogin,
                          child: const Text('ورود'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: _onRegister, child: const Text('ثبت‌نام')),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
