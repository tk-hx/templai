import 'package:templai/common.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.isEmpty) {
      return;
    }
    ChatMessage message = ChatMessage(
      text: text,
      name: "User",
    );
    setState(() {
      _messages.insert(0, message);
    });
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
    final MessagesProvider messagesProvider =
        Provider.of<MessagesProvider>(context, listen: true);

    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(messagesProvider.messages),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final String name;

  const ChatMessage({Key? key, required this.text, this.name = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
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
