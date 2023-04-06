import 'package:templai/common.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  String systemText = '';

  List<OpenAIChatCompletionChoiceMessageModel> _getOpenAIMessages(
      ChatRoom chatRoom) {
    return chatRoom.messages
        .where((e) => e.role != "blank" && e.text != "")
        .map((e) {
      OpenAIChatMessageRole role;
      switch (e.role) {
        case "user":
          role = OpenAIChatMessageRole.user;
          break;
        case "system":
          role = OpenAIChatMessageRole.system;
          break;
        case "assistant":
          role = OpenAIChatMessageRole.assistant;
          break;
        default:
          throw Exception("Unknown role: ${e.role}");
      }
      return OpenAIChatCompletionChoiceMessageModel(
        content: e.text,
        role: role,
      );
    }).toList();
  }

  void _getOpenAIMessage(String text) async {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    ChatsProvider chatsProvider =
        Provider.of<ChatsProvider>(context, listen: false);

    chatsProvider.addMessageToCurrentChatRoom(text, "user", "User");

    if (settingsProvider.apiKey.isEmpty) {
      chatsProvider.addMessageToCurrentChatRoom(
          "APIキーを設定すると、OpenAIのAPIを利用できます。", "blank", "System");
      return;
    }

    if (systemText != '') {
      chatsProvider.addMessageToCurrentChatRoom(systemText, "system", "System");
    }

    int messageId =
        chatsProvider.addMessageToCurrentChatRoom("...", "blank", "System");
    int roomId = chatsProvider.currentChatRoom.id;

    try {
      OpenAI.apiKey = settingsProvider.apiKey;
      OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat
          .create(
              model: settingsProvider.langModel,
              messages: _getOpenAIMessages(chatsProvider.currentChatRoom));

      chatsProvider.editMessageToChatRoom(
          roomId,
          messageId,
          chatCompletion.choices.first.message.content,
          "assistant",
          "Assistant");
    } catch (e) {
      chatsProvider.editMessageToChatRoom(
          roomId, messageId, e.toString(), "blank", "System");
    }
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.isEmpty) {
      return;
    }

    _getOpenAIMessage(text);
  }

  void _showTemplates(List<SettingTemplate> templates) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("定型文を選択してください"),
          children: templates.map((template) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  systemText = template.systemText;
                  _textController.text = template.fixedText;
                });
              },
              child: Text(template.title),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTextComposer(List<SettingTemplate> templates) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () => _showTemplates(templates),
              ),
              Flexible(
                child: TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration.collapsed(
                    hintText: "メッセージを入力してください",
                  ),
                  maxLines: null,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        systemText = '';
                      });
                    }
                  },
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _handleSubmitted(_textController.text);
                    setState(() {
                      systemText = '';
                    });
                  }),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: (systemText != "")
                ? const Text("+システム文あり",
                    style: TextStyle(fontSize: 10, color: Colors.blueAccent))
                : const Text(""),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatsProvider chatsProvider =
        Provider.of<ChatsProvider>(context, listen: true);
    final SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: true);
    final chatMessages = chatsProvider.currentChatRoom.messages
        .where((e) => e.role != "system")
        .map((chatMessage) => ChatMessageFrame(
              text: chatMessage.text,
              name: chatMessage.senderName,
            ))
        .toList()
        .reversed
        .toList();

    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => chatMessages[index],
              itemCount: chatMessages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(settingsProvider.templates),
          ),
        ],
      ),
    );
  }
}

class ChatMessageFrame extends StatelessWidget {
  final String text;
  final String name;

  const ChatMessageFrame({Key? key, required this.text, this.name = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        name == "User" ? Colors.grey.shade50 : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
        color: bgColor,
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: ChatMessageAvatar(name: name),
          ),
          Expanded(child: ChatMessageBubble(name: name, message: text)),
        ],
      ),
    );
  }
}

class ChatMessageAvatar extends StatelessWidget {
  final String name;

  const ChatMessageAvatar({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16.0),
      child: CircleAvatar(child: Text(name[0])),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final String name;
  final String message;

  const ChatMessageBubble({Key? key, required this.name, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: Text(message),
        ),
      ],
    );
  }
}
