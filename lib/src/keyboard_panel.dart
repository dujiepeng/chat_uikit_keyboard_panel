import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../chat_uikit_keyboard_panel.dart';

class ChatUIKitKeyboardPanelController {
  _ChatUIKitKeyboardPanelState? _state;
  final FocusNode? inputPanelFocusNode;
  ChatUIKitKeyboardPanelType currentPanelType = ChatUIKitKeyboardPanelType.none;
  bool ignoreFocus = false;
  void _attach(_ChatUIKitKeyboardPanelState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  ChatUIKitKeyboardPanelController({this.inputPanelFocusNode}) {
    if (inputPanelFocusNode != null) {
      inputPanelFocusNode!.addListener(() {
        if (ignoreFocus) return;
        if (inputPanelFocusNode!.hasFocus) {
          switchPanel(ChatUIKitKeyboardPanelType.keyboard);
        }
      });
    }
  }

  void switchPanel(ChatUIKitKeyboardPanelType panelType) {
    if (_state != null) {
      _state!.switchPanel(panelType);
    }
  }
}

class ChatUIKitKeyboardPanel extends StatefulWidget {
  const ChatUIKitKeyboardPanel({
    required this.controller,
    this.maintainBottomViewPadding = false,
    this.onPanelChanged,
    this.bottomPanels = const <ChatUIKitBottomPanel>[],
    super.key,
  });

  final void Function(
    ChatUIKitKeyboardPanelType panelType,
    bool readOnly,
  )? onPanelChanged;
  final ChatUIKitKeyboardPanelController controller;
  final List<ChatUIKitBottomPanel> bottomPanels;
  final bool maintainBottomViewPadding;

  @override
  State<ChatUIKitKeyboardPanel> createState() => _ChatUIKitKeyboardPanelState();
}

class _ChatUIKitKeyboardPanelState extends State<ChatUIKitKeyboardPanel> {
  double keyboardHeight = 0;

  Widget? _currentPanel;
  bool _responding = true;

  double bottomPadding = 0;

  ChatUIKitKeyboardPanelType _currentPanelType =
      ChatUIKitKeyboardPanelType.none;

  ChatUIKitKeyboardPanelType get currentPanelType => _currentPanelType;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ChatUikitKeyboardHeight.instance.onKeyboardHeightChange =
          (height, safeArea) {
        debugPrint('height: $height, safeArea: $safeArea');
        if (_responding) {
          if (Platform.isAndroid) {
            keyboardHeight = height / View.of(context).devicePixelRatio;
          } else {
            keyboardHeight = height;
            if (currentPanelType == ChatUIKitKeyboardPanelType.keyboard) {
              if (widget.maintainBottomViewPadding == true) {
                keyboardHeight -= safeArea;
                keyboardHeight = max(keyboardHeight, 0);
              }
            }
          }

          setState(() {});
        }
      };
    });
  }

  @override
  void dispose() {
    widget.controller._detach();
    super.dispose();
  }

  void switchPanel(ChatUIKitKeyboardPanelType panelType) {
    _currentPanelType = panelType;
    bool readOnly = false;
    if (_currentPanelType == ChatUIKitKeyboardPanelType.none) {
      keyboardHeight = 0;
    } else {
      for (final panel in widget.bottomPanels) {
        if (panel.panelType == panelType) {
          keyboardHeight = panel.height;
          _currentPanel = panel.child;
          readOnly = panel.showCursor;
          break;
        }
      }
    }
    if (_currentPanelType != ChatUIKitKeyboardPanelType.keyboard) {
      _responding = false;
      if (!readOnly) {
        widget.controller.inputPanelFocusNode?.unfocus();
      } else {
        if (widget.controller.inputPanelFocusNode?.hasFocus == false) {
          widget.controller.ignoreFocus = true;
          widget.controller.inputPanelFocusNode?.requestFocus();
        }
      }
    } else {
      _responding = true;
    }
    widget.onPanelChanged?.call(panelType, readOnly);

    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.ignoreFocus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: SizedBox(
        height: keyboardHeight,
        width: double.infinity,
        child: _currentPanel,
      ),
      onEnd: () {},
    );

    return content;
  }
}
