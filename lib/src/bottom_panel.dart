import 'package:flutter/material.dart';

enum ChatUIKitKeyboardPanelType {
  none,
  emoji,
  more,
  voice,
  keyboard,
}

class ChatUIKitBottomPanel extends StatefulWidget {
  const ChatUIKitBottomPanel({
    required this.child,
    required this.height,
    required this.panelType,
    this.showCursor = false,
    super.key,
  });
  final double height;
  final Widget child;
  final bool showCursor;
  final ChatUIKitKeyboardPanelType panelType;
  @override
  State<ChatUIKitBottomPanel> createState() => _ChatUIKitBottomPanelState();
}

class _ChatUIKitBottomPanelState extends State<ChatUIKitBottomPanel> {
  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;
    content = MediaQuery.removeViewPadding(
      removeTop: true,
      removeBottom: true,
      context: context,
      child: content,
    );

    return content;
  }
}
