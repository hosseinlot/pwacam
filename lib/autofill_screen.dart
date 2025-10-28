// login_page.dart

// **۱. دو import جدید و ضروری اضافه می‌شود**
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // **۲. کنترلر و فوکوس‌نود پسورد حذف و با المنت HTML جایگزین می‌شود**
  late final html.InputElement _passwordInputElement;
  final String _passwordViewId = "native-password-field";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // **۳. المنت HTML ساخته و رجیستر می‌شود**
    _passwordInputElement = _createPasswordInputElement();
    _registerPasswordInputElement();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsername();
    });
  }

  // این تابع المنت HTML پسورد را با استایل‌های مناسب می‌سازد
  html.InputElement _createPasswordInputElement() {
    final element = html.InputElement(type: 'password');
    element.id = 'password'; // برای Autofill بهتر
    element.setAttribute('autocomplete', 'current-password');

    // **۴. استایل‌های CSS برای شبیه‌سازی ظاهر TextFormField**
    element.style
      ..width = '100%'
      ..height = '100%'
      ..border = 'none'
      ..outline = 'none'
      ..padding = '8px 12px' // پدینگ داخلی
      ..backgroundColor = 'transparent'
      ..fontSize = '16px' // اندازه فونت
      ..fontFamily = 'system-ui, sans-serif'; // فونت پیش‌فرض سیستم

    element.placeholder = 'رمز عبور'; // متن راهنما

    return element;
  }

  // این تابع المنت ساخته شده را برای استفاده در فلاتر رجیستر می‌کند
  void _registerPasswordInputElement() {
    ui_web.platformViewRegistry.registerViewFactory(
      _passwordViewId,
      (int viewId) => _passwordInputElement,
    );
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    if (savedUsername != null && mounted) {
      _usernameController.text = savedUsername;
      // **۵. به جای FocusNode، مستقیماً به خود المنت HTML فوکوس می‌دهیم**
      _passwordInputElement.focus();
    }
  }

  Future<void> _performAuthAction(Future<void> Function() authFuture) async {
    // **۶. اعتبارسنجی فرم فلاتر و فیلد HTML به صورت جداگانه**
    final isFlutterFormValid = _formKey.currentState!.validate();
    final isPasswordEmpty = _passwordInputElement.value?.isEmpty ?? true;

    if (!isFlutterFormValid || (_usernameController.text.isNotEmpty && isPasswordEmpty)) {
      if (isPasswordEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفا رمز عبور را وارد کنید'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authFuture();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_username', _usernameController.text);
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
    // **۷. مقدار پسورد مستقیماً از المنت HTML خوانده می‌شود**
    _performAuthAction(() => AuthService.login(
          _usernameController.text,
          _passwordInputElement.value ?? '',
        ));
  }

  void _onRegister() {
    _performAuthAction(() => AuthService.register(
          _usernameController.text,
          _passwordInputElement.value ?? '',
        ));
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'لطفا نام کاربری را وارد کنید';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // **۸. TextFormField پسورد با HtmlElementView جایگزین می‌شود**
                  Container(
                    height: 50, // ارتفاع را مطابق با TextFormField خودتان تنظیم کنید
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: HtmlElementView(
                      viewType: _passwordViewId,
                    ),
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
