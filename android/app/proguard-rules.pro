-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**

# 添加性能优化规则
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# 保留 Flutter 相关
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }

# 移除日志
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# 移除 Play Core 相关规则
# -keep class com.google.android.play.core.** { *; }
# -keep class com.google.android.play.core.splitcompat.** { *; }
# -keep class com.google.android.play.core.splitinstall.** { *; }
# -keep class com.google.android.play.core.tasks.** { *; }
# -dontwarn com.google.android.play.core.** 