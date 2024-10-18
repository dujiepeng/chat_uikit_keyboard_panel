import 'package:chat_uikit_keyboard_panel/chat_uikit_keyboard_panel.dart';

import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatUIKitKeyboardPanelController _keyboardPanelController;

  ChatUIKitKeyboardPanelType _currentPanelType =
      ChatUIKitKeyboardPanelType.none;
  bool readOnly = false;
  bool hasSelectionMove = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _keyboardPanelController = ChatUIKitKeyboardPanelController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      reverse: true,
      controller: _scrollController,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
        );
      },
      itemCount: 100,
    );

    content = GestureDetector(
      onTap: () {
        _keyboardPanelController.switchPanel(ChatUIKitKeyboardPanelType.none);
      },
      child: content,
    );

    content = Column(
      children: <Widget>[
        Expanded(
          child: content,
        ),
        _keyboardWidget(),
        _keyboardPanel(),
      ],
    );

    content = SafeArea(
      maintainBottomViewPadding: true,
      child: content,
    );

    content = Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: content,
    );

    return content;
  }

  Widget _keyboardWidget() {
    return Container(
      color: Colors.red,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Listener(
              onPointerDown: (event) {
                hasSelectionMove = false;
              },
              onPointerMove: (event) {
                hasSelectionMove = true;
              },
              onPointerUp: (event) {
                if (readOnly && !hasSelectionMove) {
                  _keyboardPanelController
                      .switchPanel(ChatUIKitKeyboardPanelType.keyboard);
                  readOnly = false;
                }
              },
              child: TextField(
                focusNode: _keyboardPanelController.inputPanelFocusNode,
                readOnly: readOnly,
                showCursor: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _keyboardPanelController.switchPanel(
                  _currentPanelType == ChatUIKitKeyboardPanelType.emoji
                      ? ChatUIKitKeyboardPanelType.none
                      : ChatUIKitKeyboardPanelType.emoji);
            },
            icon: const Icon(Icons.face),
          ),
          IconButton(
            onPressed: () {
              _keyboardPanelController.switchPanel(
                  _currentPanelType == ChatUIKitKeyboardPanelType.more
                      ? ChatUIKitKeyboardPanelType.none
                      : ChatUIKitKeyboardPanelType.more);
            },
            icon: const Icon(Icons.more),
          )
        ],
      ),
    );
  }

  Widget _keyboardPanel() {
    return ChatUIKitKeyboardPanel(
      maintainBottomViewPadding: true,
      controller: _keyboardPanelController,
      bottomPanels: <ChatUIKitBottomPanel>[
        inputPanel(),
        emojiPanel(),
        morePanel(),
      ],
      onPanelChanged: (panelType, readOnly) {
        _currentPanelType = panelType;
        if (this.readOnly != readOnly) {
          setState(() {
            this.readOnly = readOnly;
          });
        }
      },
    );
  }

  ChatUIKitBottomPanel inputPanel() {
    return const ChatUIKitBottomPanel(
      height: 0,
      panelType: ChatUIKitKeyboardPanelType.keyboard,
      child: SizedBox.shrink(),
    );
  }

  ChatUIKitBottomPanel emojiPanel() {
    return ChatUIKitBottomPanel(
      height: 210,
      panelType: ChatUIKitKeyboardPanelType.emoji,
      showCursor: true,
      child: Container(
        color: Colors.blue,
      ),
    );
  }

  ChatUIKitBottomPanel morePanel() {
    return ChatUIKitBottomPanel(
      height: 300,
      panelType: ChatUIKitKeyboardPanelType.more,
      child: Container(
        color: Colors.green,
      ),
    );
  }
}
