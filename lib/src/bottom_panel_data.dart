import 'package:flutter/material.dart';

enum ChatUIKitKeyboardPanelType {
  none,
  emoji,
  more,
  voice,
  keyboard,
}

class ChatUIKitBottomPanelData {
  const ChatUIKitBottomPanelData({
    this.child,
    required this.height,
    required this.panelType,
    this.showCursor = false,
  });
  final double height;
  final Widget? child;
  final bool showCursor;
  final ChatUIKitKeyboardPanelType panelType;
}
