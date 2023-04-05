import 'package:templai/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatsProvider chatsProvider =
        Provider.of<ChatsProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TemplAI'),
        actions: (chatsProvider.chatRooms.length <= 1)
            ? []
            : [
                IconButton(
                  onPressed: () {
                    // 左側のアイコンをタップしたときの処理
                    chatsProvider.incrementCurrentChatRoom();
                  },
                  icon: const Icon(Icons.keyboard_arrow_left, size: 24),
                ),
                Container(
                    alignment: Alignment.center,
                    child: Text(
                        '${chatsProvider.getCurrentChatRoomIndex() + 1} / ${chatsProvider.chatRooms.length}',
                        style: const TextStyle(fontSize: 20))),
                IconButton(
                  onPressed: () {
                    // 右側のアイコンをタップしたときの処理
                    chatsProvider.decrementCurrentChatRoom();
                  },
                  icon: const Icon(Icons.keyboard_arrow_right, size: 24),
                ),
              ],
      ),
      drawer: const MenuScreen(),
      body: const ChatScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatsProvider chatsProvider =
        Provider.of<ChatsProvider>(context, listen: true);
    return Drawer(
      child: ListView(
        children: <Widget>[
          SizedBox(
              height: 80,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                ),
                child: const Text('メニュー'),
              )),
          ListTile(
            title: const Text("定型文編集"),
            trailing: const Icon(Icons.edit_note),
            onTap: () => Navigator.pushNamed(context, '/editMessage'),
          ),
          ListTile(
              title: const Text("新規チャット"),
              trailing: const Icon(Icons.add),
              onTap: () {
                chatsProvider.incrementCurrentChatRoom(append: true);
                Navigator.pop(context);
              }),
          ListTile(
              title: const Text("チャットの消去"),
              trailing: const Icon(Icons.remove),
              onTap: () {
                CustomAlertDialog(
                    message: 'チャットを消去しますか？',
                    content: 'この操作は取り消せません。',
                    confirmText: '消去',
                    onConfirm: () {
                      chatsProvider
                          .deleteChatRoom(chatsProvider.currentChatRoom.id);
                      Navigator.pop(context);
                    }).show(context);
              }),
          Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: const SizedBox(height: 8)),
          const SizedBox(height: 8),
          ListTile(
              title: const Text("チャットの全消去"),
              trailing: const Icon(Icons.delete_outline),
              onTap: () {
                CustomAlertDialog(
                    message: 'チャットを全消去しますか？',
                    content: 'この操作は取り消せません。',
                    confirmText: '全消去',
                    onConfirm: () {
                      chatsProvider.deleteAllChatRoom();
                      Navigator.pop(context);
                    }).show(context);
              }),
          ListTile(
            title: const Text("設定"),
            trailing: const Icon(Icons.settings),
            onTap: () => Navigator.pushNamed(context, '/setting'),
          ),
          ListTile(
              title: const Text("ライセンス"),
              trailing: const Icon(Icons.info),
              onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'TemplAI',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '2023 k-hizaki',
                  ))
        ],
      ),
    );
  }
}
