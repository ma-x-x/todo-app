import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _storage = const FlutterSecureStorage();

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
      print('开始登录流程...'); // 调试日志
      await context.read<AuthProvider>().login(
            _usernameController.text,
            _passwordController.text,
          );

      print('登录成功，检查认证状态...'); // 调试日志
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      print('认证状态: ${authProvider.isAuthenticated}'); // 调试日志
      print('当前用户: ${authProvider.currentUser}'); // 调试日志

      if (authProvider.isAuthenticated) {
        print('准备导航到首页...'); // 调试日志
        if (!mounted) return;

        // 确保清除所有之前的路由
        await Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.home,
          (route) => false,
        );
        print('导航完成'); // 调试日志

        // 登录成功后立即验证
        final savedToken = await _storage.read(key: 'token');
        print('保存后立即验证token: $savedToken');
      } else {
        print('登录后认证状态异常'); // 调试日志
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录失败：认证状态无效')),
        );
      }
    } catch (e) {
      print('登录错误: $e'); // 调试日志
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败：${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
