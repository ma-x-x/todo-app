import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';

/// 登录页面
/// 提供用户名和密码登录功能
/// 包含登录表单和注册页面入口
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// 表单全局键，用于验证表单
  final _formKey = GlobalKey<FormState>();

  /// 用户名输入控制器
  final _usernameController = TextEditingController();

  /// 密码输入控制器
  final _passwordController = TextEditingController();

  /// 用户名输入框焦点
  final _usernameFocus = FocusNode();

  /// 密码输入框焦点
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    // 释放 FocusNode
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF3E6), // 非常浅的橙色
              Color(0xFFFFE4D4), // 浅珊瑚粉
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: SingleChildScrollView(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withOpacity(0.2),
                            ),
                            child: Icon(
                              Icons.account_circle,
                              size: 80,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 40),
                          CustomTextField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            label: '用户名',
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.person),
                            obscureText: false,
                            onSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocus);
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '请输入用户名';
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.orange.shade900),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.5),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                borderSide:
                                    BorderSide(color: Colors.orange.shade400),
                              ),
                              labelText: '用户名',
                              labelStyle:
                                  TextStyle(color: Colors.orange.shade700),
                              prefixIcon: Icon(Icons.person,
                                  color: Colors.orange.shade600),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            label: '密码',
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.lock),
                            obscureText: true,
                            onSubmitted: (_) => _login(),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return '请输入密码';
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.orange.shade900),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.5),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                borderSide:
                                    BorderSide(color: Colors.orange.shade400),
                              ),
                              labelText: '密码',
                              labelStyle:
                                  TextStyle(color: Colors.orange.shade700),
                              prefixIcon: Icon(Icons.lock,
                                  color: Colors.orange.shade600),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 2,
                              ),
                              child: auth.isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      '登录',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange.shade700,
                            ),
                            child: const Text(
                              '还没有账号？立即注册',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 执行登录操作
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().login(
              _usernameController.text,
              _passwordController.text,
            );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
}
