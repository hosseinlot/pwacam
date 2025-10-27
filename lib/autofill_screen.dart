import 'package:flutter/material.dart';
import 'package:pwacam/profile_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // **تغییر ۲: اضافه کردن یک تاخیر بسیار کوتاه**
      // این به مرورگر فرصت می‌دهد تا اطلاعات فرم را قبل از ناوبری ثبت کند
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        // بررسی اینکه ویجت هنوز در صفحه وجود دارد
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحه ورود')),
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
                    autofillHints: const [AutofillHints.username],
                    // **تغییر ۱: اضافه کردن TextInputAction.next**
                    // این باعث می‌شود دکمه "بعدی" روی کیبورد نمایش داده شود
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا نام کاربری را وارد کنید';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'رمز عبور', prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    // **تغییر ۱: اضافه کردن TextInputAction.done**
                    // این باعث می‌شود دکمه "انجام" روی کیبورد نمایش داده شود
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _login,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا رمز عبور را وارد کنید';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _login, child: const Text('ورود')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
