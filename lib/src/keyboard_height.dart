import 'package:flutter/services.dart';

class ChatUikitKeyboardHeight {
  MethodChannel channel = const MethodChannel('chat_uikit_keyboard_panel');
  static ChatUikitKeyboardHeight? _instance;
  static ChatUikitKeyboardHeight get instance =>
      _instance ??= ChatUikitKeyboardHeight._();

  final List<KeyboardHeightCallback> _keyboardHeightCallbacks = [];

  ChatUikitKeyboardHeight._() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'height') {
        Map map = call.arguments;
        double height = map["height"] ?? 0;
        double safeArea = map["safeArea"] ?? 0;

        for (var element in _keyboardHeightCallbacks) {
          element(height, safeArea);
        }
      }
    });
  }

  void addKeyboardHeightCallback(KeyboardHeightCallback callback) {
    _keyboardHeightCallbacks.add(callback);
  }

  void removeKeyboardHeightCallback(KeyboardHeightCallback callback) {
    _keyboardHeightCallbacks.remove(callback);
  }
}

typedef KeyboardHeightCallback = void Function(double height, double safeArea);
