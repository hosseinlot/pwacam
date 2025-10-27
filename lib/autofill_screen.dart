import 'package:flutter/material.dart';
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

  // **تغییر ۱: اضافه کردن متغیر برای مدیریت وضعیت بارگذاری**
  bool _isLoading = false;

  Future<void> _handleFormSubmit() async {
    if (_formKey.currentState!.validate()) {
      // فعال کردن حالت بارگذاری
      setState(() {
        _isLoading = true;
      });

      try {
        // **تغییر ۲: فراخوانی واقعی API**
        await AuthService.login(
          _usernameController.text,
          _passwordController.text,
        );

        // اگر API موفق بود، به صفحه بعد می‌رویم
        if (mounted) {
          Navigator.pushReplacement(
            // از pushReplacement استفاده می‌کنیم تا کاربر نتواند به صفحه لاگین بازگردد
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
        }
      } catch (e) {
        // **تغییر ۳: مدیریت خطا**
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')), // نمایش پیام خطا از API
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // در هر صورت (موفق یا ناموفق)، حالت بارگذاری را غیرفعال می‌کنیم
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleFormRegisterSubmit() async {
    if (_formKey.currentState!.validate()) {
      // فعال کردن حالت بارگذاری
      setState(() {
        _isLoading = true;
      });

      try {
        // **تغییر ۲: فراخوانی واقعی API**
        await AuthService.register(
          _usernameController.text,
          _passwordController.text,
        );

        // اگر API موفق بود، به صفحه بعد می‌رویم
        if (mounted) {
          Navigator.pushReplacement(
            // از pushReplacement استفاده می‌کنیم تا کاربر نتواند به صفحه لاگین بازگردد
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
        }
      } catch (e) {
        // **تغییر ۳: مدیریت خطا**
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')), // نمایش پیام خطا از API
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // در هر صورت (موفق یا ناموفق)، حالت بارگذاری را غیرفعال می‌کنیم
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
                  const Icon(
                    Icons.lock_person_sharp,
                    size: 80,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'نام کاربری',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    autofillHints: const [AutofillHints.username],
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
                    decoration: const InputDecoration(
                      labelText: 'رمز عبور',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleFormSubmit(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا رمز عبور را وارد کنید';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleFormSubmit,
                          child: const Text('ورود'),
                        ),
                  ElevatedButton(
                    onPressed: _handleFormRegisterSubmit,
                    child: const Text('register'),
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
