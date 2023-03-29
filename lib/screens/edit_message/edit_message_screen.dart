import 'package:templai/common.dart';

class EditMessageScreen extends StatefulWidget {
  const EditMessageScreen({Key? key}) : super(key: key);

  @override
  EditMessageScreenState createState() => EditMessageScreenState();
}

class EditMessageScreenState extends State<EditMessageScreen> {
  void _addMessage(String value) {
    setState(() {
      Provider.of<MessagesProvider>(context, listen: false).messages.add(value);
    });
    Navigator.of(context).pop();
  }

  void _removeMessage(int index) {
    setState(() {
      Provider.of<MessagesProvider>(context, listen: false)
          .messages
          .removeAt(index);
    });
  }

  void _editMessage(int index, String value) {
    setState(() {
      Provider.of<MessagesProvider>(context, listen: false).messages[index] =
          value;
    });
    Navigator.of(context).pop();
  }

  void _showAddMessageDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新しい定型文を追加'),
          content: TextFormField(
            controller: controller,
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  _addMessage(newValue);
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  void _showEditMessageDialog(int index) {
    final message =
        Provider.of<MessagesProvider>(context, listen: false).messages[index];
    final controller = TextEditingController(text: message);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('定型文の編集'),
          content: TextFormField(
            controller: controller,
            maxLines: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '値を入力してください';
              }
              return null;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _editMessage(index, controller.text);
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> messages = Provider.of<MessagesProvider>(context).messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('定型文編集'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: ValueKey(messages[index]),
            onDismissed: (direction) {
              final removedMessage = messages[index];
              _removeMessage(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('定型文を削除しました'),
                  action: SnackBarAction(
                    label: '元に戻す',
                    onPressed: () {
                      setState(() {
                        messages.insert(index, removedMessage);
                      });
                    },
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(messages[index]),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditMessageDialog(index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddMessageDialog();
        },
      ),
    );
  }
}
