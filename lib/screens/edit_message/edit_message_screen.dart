import 'package:templai/common.dart';

class EditMessageScreen extends StatefulWidget {
  const EditMessageScreen({Key? key}) : super(key: key);

  @override
  EditMessageScreenState createState() => EditMessageScreenState();
}

class EditMessageScreenState extends State<EditMessageScreen> {
  void _showAddMessageDialog(SettingsProvider settingsProvider) {
    final templates = settingsProvider.templates;
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
                  templates.add(newValue);
                  settingsProvider.templates = templates;
                  Navigator.of(context).pop();
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

  void _showEditMessageDialog(SettingsProvider settingsProvider, int index) {
    final templates = settingsProvider.templates;
    final controller = TextEditingController(text: templates[index]);

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
                  templates[index] = controller.text;
                  settingsProvider.templates = templates;
                  Navigator.of(context).pop();
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
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    final templates = settingsProvider.templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('定型文編集'),
      ),
      body: ListView.builder(
        itemCount: settingsProvider.templates.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(settingsProvider.templates[index]),
            onTap: () => _showEditMessageDialog(settingsProvider, index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: const EdgeInsets.only(right: 12.0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditMessageDialog(settingsProvider, index);
                  },
                ),
                IconButton(
                  padding: const EdgeInsets.all(0.0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    CustomAlertDialog(
                        message: '${settingsProvider.templates[index]}を削除しますか？',
                        content: 'この操作は取り消せません。',
                        confirmText: '削除',
                        onConfirm: () {
                          setState(() {
                            templates.removeAt(index);
                            settingsProvider.templates = templates;
                          });
                          Navigator.pop(context);
                        }).show(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddMessageDialog(settingsProvider);
        },
      ),
    );
  }
}
