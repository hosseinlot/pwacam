// login_page.dart

import 'package:flutter/material.dart';
import 'dart:html' as html; // <-- این import جدید و بسیار مهم است
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

  bool _isLoading = false;

  Future<void> _performAuthAction(Future<void> Function() authFuture) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await authFuture();

      // *** راه حل قطعی و نهایی اینجاست ***
      // به جای استفاده از Navigator فلاتر، مستقیماً به مرورگر دستور می‌دهیم
      // که به آدرس جدید برود. این یک بارگذاری مجدد کامل صفحه است.
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // بقیه کد build دقیقاً مثل قبل است و نیازی به تغییر ندارد
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
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'لطفا نام کاربری را وارد کنید';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
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
