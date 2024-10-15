import 'package:flutter/services.dart';

class ChatUikitKeyboardHeight {
  MethodChannel channel = const MethodChannel('chat_uikit_keyboard_panel');
  static ChatUikitKeyboardHeight? _instance;
  static ChatUikitKeyboardHeight get instance =>
      _instance ??= ChatUikitKeyboardHeight._();

  void Function(double height)? _onKeyboardHeightChange;

  ChatUikitKeyboardHeight._() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'height') {
        final double height = call.arguments as double;

        _onKeyboardHeightChange?.call(height);
      }
    });
  }

  set onKeyboardHeightChange(void Function(double height) value) {
    _onKeyboardHeightChange = value;
  }
}
