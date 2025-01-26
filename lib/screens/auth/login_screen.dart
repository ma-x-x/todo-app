import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _usernameController,
                label: '用户名',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: '密码',
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '请输入密码';
                  }
                  if (value!.length < 6) {
                    return '密码长度不能小于6位';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _login,
                      child: const Text('登录'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('还没有账号？立即注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AuthProvider>().login(
            _usernameController.text,
            _passwordController.text,
          );

      // 添加调试输出
      print('Login successful');
      print('isAuthenticated: ${context.read<AuthProvider>().isAuthenticated}');
      print('currentUser: ${context.read<AuthProvider>().currentUser}');

      if (mounted && context.read<AuthProvider>().isAuthenticated) {
        print('Navigating to home screen');
        await Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false, // 清除所有路由历史
        );
      } else {
        print('Not authenticated after login');
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
