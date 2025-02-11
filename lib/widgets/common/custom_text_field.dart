import 'package:flutter/material.dart';

/// 自定义输入框组件
///
/// 封装了常用的输入框功能，包括：
/// - 输入法支持（中文输入）
/// - 密码输入模式
/// - 错误提示
/// - 自定义样式
class CustomTextField extends StatelessWidget {
  /// 输入控制器
  final TextEditingController controller;

  /// 输入框标签文本
  final String? label;

  /// 输入验证器
  final String? Function(String?)? validator;

  /// 是否是密码输入
  /// 设置为 true 时会:
  /// 1. 显示密码掩码
  /// 2. 使用安全键盘
  /// 3. 禁用输入法和输入建议
  final bool obscureText;

  /// 键盘类型
  /// 常用类型：
  /// - TextInputType.text: 普通文本输入
  /// - TextInputType.multiline: 多行文本输入
  /// - TextInputType.number: 数字输入
  /// - TextInputType.emailAddress: 邮箱输入
  final TextInputType? keyboardType;

  /// 键盘动作按钮类型
  final TextInputAction? textInputAction;

  /// 提交回调
  final void Function(String)? onSubmitted;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 最大行数
  /// 为 1 时是单行输入，大于 1 时是多行输入
  final int? maxLines;

  /// 前缀图标
  final Widget? prefixIcon;

  /// 后缀图标
  final Widget? suffixIcon;

  /// 提示文本
  final String? hintText;

  /// 文本样式
  final TextStyle? style;

  /// 输入框装饰
  final InputDecoration? decoration;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.style,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      decoration: decoration ??
          InputDecoration(
            labelText: label,
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            errorStyle: const TextStyle(
              fontSize: 12,
              height: 1,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
      style: style,
      cursorColor: Theme.of(context).colorScheme.primary,
      cursorWidth: 2.0,
      showCursor: true,
      obscureText: obscureText,
      keyboardType: obscureText
          ? TextInputType.visiblePassword // 密码输入框使用密码键盘
          : (keyboardType ?? TextInputType.text), // 其他情况使用指定的键盘类型
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      enableInteractiveSelection: !obscureText, // 非密码输入时允许文本选择
      autocorrect: !obscureText, // 非密码输入时启用自动更正
      enableSuggestions: !obscureText, // 非密码输入时启用输入建议
      textCapitalization: maxLines == 1 && !obscureText
          ? TextCapitalization.sentences // 单行非密码输入时启用句首字母大写
          : TextCapitalization.none,
      enableIMEPersonalizedLearning: !obscureText, // 非密码输入时启用输入法个性化学习
      obscuringCharacter: '•', // 密码掩码字符
      readOnly: false, // 是否只读
    );
  }
}
