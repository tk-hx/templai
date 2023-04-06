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
                  var title = '';
                  if (newValue.length >= 20) {
                    title = '${newValue.substring(0, 17)}...';
                  } else {
                    title = newValue;
                  }
                  templates.add(SettingTemplate(
                      title: title, systemText: '', fixedText: newValue));
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
    final titleController = TextEditingController(text: templates[index].title);
    final systemController =
        TextEditingController(text: templates[index].systemText);
    final textController =
        TextEditingController(text: templates[index].fixedText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('定型文の編集'),
          content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: titleController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: "タイトル",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '値を入力してください';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: systemController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: "システム文(省略可)",
                    ),
                  ),
                  TextFormField(
                    controller: textController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: "定型文",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '値を入力してください';
                      }
                      return null;
                    },
                  ),
                ],
              )),
          actions: [
            TextButton(
              onPressed: () {
                templates[index].title = titleController.text;
                templates[index].systemText = systemController.text;
                templates[index].fixedText = textController.text;
                settingsProvider.templates = templates;
                Navigator.of(context).pop();
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
            title: Text(settingsProvider.templates[index].title),
            onTap: () => _showEditMessageDialog(settingsProvider, index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: const EdgeInsets.all(0.0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    CustomAlertDialog(
                        message:
                            '${settingsProvider.templates[index].title}を削除しますか？',
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
