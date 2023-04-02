import 'package:templai/common.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  List<OpenAIChatCompletionChoiceMessageModel> _getOpenAIMessages(
      List<ChatMessage> messages, int groupId) {
    return messages
        .where((e) => e.groupId == groupId && e.role != "error")
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

    int id = chatsProvider.getLastId() + 1;
    int groupId = chatsProvider.getLastGroupId();

    chatsProvider.addMessage(ChatMessage(
      id: id,
      groupId: groupId,
      role: "user",
      text: text,
      senderName: "User",
      timestamp: DateTime.now(),
    ));

    if (settingsProvider.apiKey.isEmpty) {
      chatsProvider.addMessage(ChatMessage(
        id: id,
        groupId: groupId,
        role: "error",
        text: "APIキーを設定すると、OpenAIのAPIを利用できます。",
        senderName: "System",
        timestamp: DateTime.now(),
      ));
      return;
    }

    try {
      OpenAI.apiKey = settingsProvider.apiKey;
      OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat
          .create(
              model: settingsProvider.langModel,
              messages: _getOpenAIMessages(chatsProvider.messages, groupId));
      chatsProvider.addMessage(ChatMessage(
        id: id + 1,
        groupId: groupId,
        role: "assistant",
        text: chatCompletion.choices.first.message.content,
        senderName: "Assistant",
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      chatsProvider.addMessage(ChatMessage(
        id: id + 1,
        groupId: groupId,
        role: "error",
        text: e.toString(),
        senderName: "System",
        timestamp: DateTime.now(),
      ));
    }
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.isEmpty) {
      return;
    }

    _getOpenAIMessage(text);
  }

  void _showTemplates(List<String> messages) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("定型文を選択してください"),
          children: messages.map((templateMessage) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _textController.text = templateMessage;
                });
              },
              child: Text(templateMessage),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTextComposer(List<String> messages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTemplates(messages),
          ),
          Flexible(
            child: TextFormField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(
                hintText: "メッセージを入力してください",
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
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
    final chatMessages = chatsProvider.messages
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
