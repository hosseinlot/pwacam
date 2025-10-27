import 'package:flutter/material.dart';

class AutofillScreen extends StatefulWidget {
  const AutofillScreen({super.key});

  @override
  State<AutofillScreen> createState() => _AutofillScreenState();
}

class _AutofillScreenState extends State<AutofillScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _simulateLogin() {
    // بررسی می‌کند که آیا فیلدها معتبر هستند یا خیر
    if (_formKey.currentState!.validate()) {
      // در یک سناریوی واقعی، اینجا اطلاعات را به سرور ارسال می‌کنید
      // برای شبیه‌سازی، ما فقط اطلاعات را چاپ کرده و یک پیام موفقیت نشان می‌دهیم
      // این "ارسال موفق" به مرورگر کمک می‌کند تا بفهمد که باید پیشنهاد ذخیره رمز را بدهد
      print('Username: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ورود موفقیت‌آمیز بود! مرورگر باید پیشنهاد ذخیره را بدهد.'), backgroundColor: Colors.green));
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
      appBar: AppBar(title: const Text('autofill screen')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // ۱. تمام فیلدهای فرم را داخل یک AutofillGroup قرار می‌دهیم
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_person, size: 80, color: Colors.indigo),
                  const SizedBox(height: 32),

                  // فیلد نام کاربری
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'username', prefixIcon: Icon(Icons.person_outline)),
                    // ۲. این راهنما به مرورگر می‌گوید که این فیلد برای نام کاربری است
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // فیلد رمز عبور
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'password', prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    // ۲. این راهنما به مرورگر می‌گوید که این فیلد برای رمز عبور است
                    autofillHints: const [AutofillHints.password],
                    onEditingComplete: _simulateLogin, // برای لاگین با زدن دکمه Enter روی کیبورد
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _simulateLogin, child: const Text('login')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
