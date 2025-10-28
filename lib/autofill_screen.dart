// login_page.dart

// **۱. import های لازم**
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
  // **۲. کنترلرهای HTML برای هر دو فیلد**
  late final html.InputElement _usernameInputElement;
  late final html.InputElement _passwordInputElement;
  final String _formViewId = "native-login-form";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // **۳. ساخت و رجیستر کردن کل فرم HTML**
    _usernameInputElement = _createUsernameInputElement();
    _passwordInputElement = _createPasswordInputElement();
    _registerFormView();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsername();
    });
  }

  // تابع ساخت فیلد نام کاربری HTML
  html.InputElement _createUsernameInputElement() {
    final element = html.InputElement(type: 'text');
    element.id = 'username';
    element.setAttribute('autocomplete', 'username');
    element.placeholder = 'نام کاربری';
    element.style
      ..width = '100%'
      ..height = '48px'
      ..border = '1px solid grey'
      ..borderRadius = '4px'
      ..padding = '0 12px'
      ..marginBottom = '16px' // فاصله تا فیلد بعدی
      ..fontSize = '16px'
      ..boxSizing = 'border-box';
    return element;
  }

  // تابع ساخت فیلد رمز عبور HTML
  html.InputElement _createPasswordInputElement() {
    final element = html.InputElement(type: 'password');
    element.id = 'password';
    element.setAttribute('autocomplete', 'current-password');
    element.placeholder = 'رمز عبور';
    element.style
      ..width = '100%'
      ..height = '48px'
      ..border = '1px solid grey'
      ..borderRadius = '4px'
      ..padding = '0 12px'
      ..fontSize = '16px'
      ..boxSizing = 'border-box';
    return element;
  }

  // این تابع هر دو فیلد را داخل یک عنصر والد قرار داده و رجیستر می‌کند
  void _registerFormView() {
    final container = html.DivElement()
      ..append(_usernameInputElement)
      ..append(_passwordInputElement);

    ui_web.platformViewRegistry.registerViewFactory(
      _formViewId,
      (int viewId) => container,
    );
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    if (savedUsername != null && mounted) {
      _usernameInputElement.value = savedUsername;
      _passwordInputElement.focus();
    }
  }

  Future<void> _performAuthAction(Future<void> Function() authFuture) async {
    final username = _usernameInputElement.value ?? '';
    final password = _passwordInputElement.value ?? '';

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا نام کاربری و رمز عبور را وارد کنید'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authFuture();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_username', username);
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
          _usernameInputElement.value ?? '',
          _passwordInputElement.value ?? '',
        ));
  }

  void _onRegister() {
    _performAuthAction(() => AuthService.register(
          _usernameInputElement.value ?? '',
          _passwordInputElement.value ?? '',
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود / ثبت‌نام')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // **۴. دیگر به AutofillGroup یا Form نیازی نیست**
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_person_sharp, size: 80, color: Colors.indigo),
              const SizedBox(height: 32),

              // **۵. ویجت‌های TextFormField با HtmlElementView جایگزین شدند**
              SizedBox(
                // ارتفاع تقریبی دو فیلد + فاصله بین آنها
                height: 48 + 16 + 48,
                child: HtmlElementView(
                  viewType: _formViewId,
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
    );
  }
}
