import 'package:templai/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TemplAI'),
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
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(),
            child: Text('メニュー'),
          ),
          ListTile(
            title: const Text("定型文編集"),
            trailing: const Icon(Icons.edit_note),
            onTap: () => Navigator.pushNamed(context, '/editMessage'),
          ),
          ListTile(
            title: const Text("設定"),
            trailing: const Icon(Icons.settings),
            onTap: () => Navigator.pushNamed(context, '/setting'),
          ),
        ],
      ),
    );
  }
}
