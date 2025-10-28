// login_page.dart

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
  late final html.InputElement _usernameInputElement;
  late final html.InputElement _passwordInputElement;
  final String _formViewId = "native-login-form";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameInputElement = _createInputElement(type: 'text', placeholder: 'نام کاربری', autocomplete: 'username');
    _passwordInputElement = _createInputElement(type: 'password', placeholder: 'رمز عبور', autocomplete: 'current-password');
    _registerFormView();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsername();
    });
  }

  // **تغییر ۱: استایل‌دهی دقیق بر اساس کدهای Decoration شما**
  html.InputElement _createInputElement({required String type, required String placeholder, required String autocomplete}) {
    final element = html.InputElement(type: type);
    element.setAttribute('autocomplete', autocomplete);
    element.placeholder = placeholder;

    // تعریف رنگ‌ها بر اساس AppColors شما (مقادیر حدسی هستند، در صورت نیاز جایگزین کنید)
    final normalBorderColor = '#E5E7EB'; // معادل Colors.grey.shade300
    final focusedBorderColor = '#7F56D9'; // معادل AppColors.brand300
    final focusedShadowRingColor = '#F4EBFF'; // معادل AppColors.brand50
    final subtleShadowColor = 'rgba(10, 12, 18, 0.075)'; // معادل Color(0x0C0A0C12)

    // استایل‌های حالت عادی (Normal Decoration)
    element.style
      ..backgroundColor = '#FFFFFF' // رنگ پس‌زمینه سفید
      ..border = '1px solid $normalBorderColor'
      ..borderRadius = '8px'
      ..padding = '0 16px'
      ..outline = 'none'
      ..fontSize = '16px'
      ..fontFamily = 'Vazirmatn, system-ui, sans-serif' // فونت وزیرمتن را اضافه کردم
      ..width = '100%'
      ..height = '48px'
      ..boxSizing = 'border-box'
      ..transition = 'border-color 0.2s, box-shadow 0.2s'; // انیمیشن نرم

    // افکت حالت فوکوس (Focused Decoration)
    element.onFocus.listen((event) {
      element.style.borderColor = focusedBorderColor;
      // ترکیب دو سایه شما: یک سایه ring و یک سایه drop
      element.style.boxShadow = '0 1px 2px $subtleShadowColor, 0 0 0 4px $focusedShadowRingColor';
    });

    // برگشت به حالت عادی
    element.onBlur.listen((event) {
      element.style.borderColor = normalBorderColor;
      element.style.boxShadow = 'none'; // حذف سایه
    });

    return element;
  }

  void _registerFormView() {
    final passwordContainer = html.DivElement()
      ..style.marginTop = '16px'
      ..append(_passwordInputElement);

    final formContainer = html.DivElement()
      ..append(_usernameInputElement)
      ..append(passwordContainer);

    ui_web.platformViewRegistry.registerViewFactory(
      _formViewId,
      (int viewId) => formContainer,
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
        const SnackBar(content: Text('لطفا نام کاربری و رمز عبور را وارد کنید')),
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_person_sharp, size: 80, color: Colors.indigo),
              const SizedBox(height: 32),
              SizedBox(
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
