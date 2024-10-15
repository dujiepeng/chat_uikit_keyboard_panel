import 'package:flutter/services.dart';

class ChatUikitKeyboardHeight {
  MethodChannel channel = const MethodChannel('chat_uikit_keyboard_panel');
  static ChatUikitKeyboardHeight? _instance;
  static ChatUikitKeyboardHeight get instance =>
      _instance ??= ChatUikitKeyboardHeight._();

  void Function(double height, double safeArea)? _onKeyboardHeightChange;

  ChatUikitKeyboardHeight._() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'height') {
        Map map = call.arguments;
        double height = map["height"] ?? 0;
        double safeArea = map["safeArea"] ?? 0;
        _onKeyboardHeightChange?.call(height, safeArea);
      }
    });
  }

  set onKeyboardHeightChange(
      void Function(double height, double safeArea) value) {
    _onKeyboardHeightChange = value;
  }
}
