import 'common.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MessagesProvider>(
              create: (context) => MessagesProvider()),
        ],
        child: MaterialApp(
          title: 'TemplAI',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => const HomeScreen(),
            '/menu': (BuildContext context) => const MenuScreen(),
            '/chat': (BuildContext context) => const ChatScreen(),
            '/editMessage': (BuildContext context) => const EditMessageScreen(),
          },
          initialRoute: '/',
        ));
  }
}
