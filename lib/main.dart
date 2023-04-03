import 'package:flutter/foundation.dart';

import 'common.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bindingの初期化
  final prefs = await SharedPreferences.getInstance();

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('lib/assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  runApp(MainApp(prefs: prefs));
}

class MainApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MainApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
              create: (context) => SettingsProvider(prefs)),
          ChangeNotifierProvider<ChatsProvider>(
              create: (context) => ChatsProvider(prefs)),
        ],
        child: MaterialApp(
          title: 'TemplAI',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            fontFamily: 'NotoSansJapanse',
          ),
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => const HomeScreen(),
            '/menu': (BuildContext context) => const MenuScreen(),
            '/chat': (BuildContext context) => const ChatScreen(),
            '/editMessage': (BuildContext context) => const EditMessageScreen(),
            '/setting': (BuildContext context) => const SettingScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/webView') {
              return MaterialPageRoute(
                  builder: (context) => settings.arguments as WebViewScreen);
            }
            return null;
          },
          initialRoute: '/',
        ));
  }
}
