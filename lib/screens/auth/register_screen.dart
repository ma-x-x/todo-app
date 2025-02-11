import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';

/// 注册页面
/// 提供用户注册功能
/// 包含用户名、邮箱、密码等信息的输入和验证
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// 表单全局键，用于验证表单
  final _formKey = GlobalKey<FormState>();

  /// 用户名输入控制器
  final _usernameController = TextEditingController();

  /// 邮箱输入控制器
  final _emailController = TextEditingController();

  /// 密码输入控制器
  final _passwordController = TextEditingController();

  /// 确认密码输入控制器
  final _confirmPasswordController = TextEditingController();

  /// 用户名输入框焦点
  final _usernameFocus = FocusNode();

  /// 邮箱输入框焦点
  final _emailFocus = FocusNode();

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
                child: Form(
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
                          Icons.app_registration,
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
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocus);
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
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.orange.shade400),
                          ),
                          labelText: '用户名',
                          labelStyle: TextStyle(color: Colors.orange.shade700),
                          prefixIcon:
                              Icon(Icons.person, color: Colors.orange.shade600),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        label: '邮箱',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '请输入邮箱';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return '请输入有效的邮箱地址';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.orange.shade900),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.orange.shade400),
                          ),
                          labelText: '邮箱',
                          labelStyle: TextStyle(color: Colors.orange.shade700),
                          prefixIcon:
                              Icon(Icons.email, color: Colors.orange.shade600),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _passwordController,
                        label: '密码',
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '请输入密码';
                          }
                          if (value!.length < 6) {
                            return '密码长度不能小于6位';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.orange.shade900),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.orange.shade400),
                          ),
                          labelText: '密码',
                          labelStyle: TextStyle(color: Colors.orange.shade700),
                          prefixIcon:
                              Icon(Icons.lock, color: Colors.orange.shade600),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: '确认密码',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return '请确认密码';
                          }
                          if (value != _passwordController.text) {
                            return '两次输入的密码不一致';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.orange.shade900),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.orange.shade400),
                          ),
                          labelText: '确认密码',
                          labelStyle: TextStyle(color: Colors.orange.shade700),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Colors.orange.shade600),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            if (auth.isLoading) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange.shade400,
                                ),
                              );
                            }
                            return ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                '注册',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange.shade700,
                        ),
                        child: const Text(
                          '已有账号？返回登录',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 执行注册操作
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AuthProvider>().register(
            _usernameController.text,
            _passwordController.text,
            _emailController.text,
          );
      if (mounted) {
        Navigator.pop(context); // 注册成功后返回登录页
      }
    } catch (e) {
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }
}
