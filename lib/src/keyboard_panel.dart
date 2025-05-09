import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../chat_uikit_keyboard_panel.dart';

class ChatUIKitKeyboardPanelController {
  _ChatUIKitKeyboardPanelState? _state;
  late final FocusNode _inputPanelFocusNode;
  late final TextEditingController _inputPanelController;
  ChatUIKitKeyboardPanelType get currentPanelType =>
      _state?._currentPanelType ?? ChatUIKitKeyboardPanelType.none;

  bool readOnly = false;
  bool ignoreFocus = false;

  void _attach(_ChatUIKitKeyboardPanelState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  FocusNode get inputPanelFocusNode => _inputPanelFocusNode;

  TextEditingController get inputTextEditingController => _inputPanelController;

  String get text => _inputPanelController.text;

  void clearText() {
    _inputPanelController.clear();
  }

  ChatUIKitKeyboardPanelController(
      {TextEditingController? inputTextEditingController}) {
    _inputPanelController =
        inputTextEditingController ?? TextEditingController();
    _inputPanelFocusNode = FocusNode();
    _inputPanelFocusNode.addListener(() {
      if (ignoreFocus) return;
      if (_inputPanelFocusNode.hasFocus) {
        switchPanel(ChatUIKitKeyboardPanelType.keyboard);
      }
    });
  }

  void switchPanel(ChatUIKitKeyboardPanelType panelType, {Duration? duration}) {
    if (_state != null) {
      _state!.switchPanel(panelType, duration: duration);
    }
  }

  void dispose() {
    _inputPanelFocusNode.dispose();
    _inputPanelController.dispose();
  }
}

class ChatUIKitKeyboardPanel extends StatefulWidget {
  const ChatUIKitKeyboardPanel({
    required this.controller,
    this.maintainBottomViewPadding = false,
    this.onPanelChanged,
    this.bottomPanels = const <ChatUIKitBottomPanelData>[],
    this.bottomDistance = 0,
    super.key,
  });

  final void Function(
    ChatUIKitKeyboardPanelType panelType,
    bool readOnly,
  )? onPanelChanged;
  final ChatUIKitKeyboardPanelController controller;
  final List<ChatUIKitBottomPanelData> bottomPanels;
  final bool maintainBottomViewPadding;
  final double bottomDistance;

  @override
  State<ChatUIKitKeyboardPanel> createState() => _ChatUIKitKeyboardPanelState();
}

class _ChatUIKitKeyboardPanelState extends State<ChatUIKitKeyboardPanel> {
  double keyboardHeight = 0;
  double lastKeyboardHeight = 0;
  Widget? _currentPanel;
  bool _responding = true;
  Duration? _duration;
  double bottomPadding = 0;

  ChatUIKitKeyboardPanelType _currentPanelType =
      ChatUIKitKeyboardPanelType.none;

  // ChatUIKitKeyboardPanelType _lastPanelType = ChatUIKitKeyboardPanelType.none;

  ChatUIKitKeyboardPanelType get currentPanelType => _currentPanelType;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ChatUikitKeyboardHeight.instance.addKeyboardHeightCallback(update);
    });
  }

  void update(double height, double safeArea) {
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
  }

  @override
  dispose() {
    widget.controller._detach();
    ChatUikitKeyboardHeight.instance.removeKeyboardHeightCallback(update);
    super.dispose();
  }

  void switchPanel(ChatUIKitKeyboardPanelType panelType, {Duration? duration}) {
    _duration = duration;
    // _lastPanelType = _currentPanelType;
    _currentPanelType = panelType;
    bool readOnly = false;
    if (_currentPanelType == ChatUIKitKeyboardPanelType.none) {
      keyboardHeight = 0;
    } else {
      for (final panel in widget.bottomPanels) {
        if (panel.panelType == panelType) {
          if (_currentPanelType == ChatUIKitKeyboardPanelType.keyboard) {
            keyboardHeight = max(keyboardHeight, 0);
          } else {
            keyboardHeight = panel.height;
          }
          if (lastKeyboardHeight != 0) {
            _currentPanel = panel.child ?? _currentPanel;
          } else {
            _currentPanel = panel.child;
          }

          readOnly = panel.showCursor;
          break;
        }
      }
    }
    if (_currentPanelType != ChatUIKitKeyboardPanelType.keyboard) {
      _responding = false;
      if (!readOnly) {
        widget.controller._inputPanelFocusNode.unfocus();
      } else {
        if (widget.controller._inputPanelFocusNode.hasFocus == false) {
          widget.controller.ignoreFocus = true;
          widget.controller._inputPanelFocusNode.requestFocus();
        }
      }
    } else {
      _responding = true;
      if (widget.controller._inputPanelFocusNode.hasFocus == false) {
        widget.controller.ignoreFocus = true;
        widget.controller._inputPanelFocusNode.requestFocus();
      }
    }
    widget.onPanelChanged?.call(panelType, readOnly);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.controller.ignoreFocus = false;
      lastKeyboardHeight = keyboardHeight;
      debugPrint(
          'switchPanel: $panelType, readOnly: $readOnly, height: $keyboardHeight');
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedSize(
      duration: _duration ?? const Duration(milliseconds: 150),
      alignment: Alignment.topCenter,
      curve: Curves.linear,
      child: SizedBox(
        height: _currentPanelType == ChatUIKitKeyboardPanelType.keyboard
            ? max(keyboardHeight - widget.bottomDistance, 0)
            : keyboardHeight,
        width: double.infinity,
        child: _currentPanel,
      ),
      onEnd: () {
        _duration = null;
      },
    );

    return content;
  }
}
