import 'package:templai/common.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  late TextEditingController _apiController;

  @override
  void initState() {
    super.initState();
    _apiController = TextEditingController();
  }

  void _showApiPrompt() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("API Keyの取得先"),
              content: const Text(
                  '1. OpenAIのAPI Key取得ページを開いて、ログインまたはユーザー登録を実施してください。\n\n'
                  '2. APIキーを取得して、キーをコピーしてください。\n\n'
                  '3. コピーしたAPIキーを、上のテキストボックスにペーストしてください。'),
              actions: [
                TextButton(
                    onPressed: () {
                      launchUrl(
                          Uri.parse(
                              'https://platform.openai.com/account/api-keys'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text("OpenAIのページを開く")),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("閉じる"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = Provider.of<SettingsProvider>(context);
    _apiController.text = settingsProvider.apiKey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API Key',
                style: TextStyle(fontSize: 18.0),
              ),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _apiController,
                      decoration: const InputDecoration(
                        hintText: 'API Keyを入力してください',
                      ),
                      onTap: () {
                        _apiController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _apiController.text.length);
                      },
                      onChanged: (value) => {settingsProvider.apiKey = value},
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showApiPrompt();
                    },
                    child: const Text('取得先'),
                  ),
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              const Text(
                '利用モデル',
                style: TextStyle(fontSize: 18.0),
              ),
              DropdownButton(
                value: settingsProvider.langModel,
                items: const [
                  DropdownMenuItem(
                    value: 'gpt-3.5-turbo',
                    child: Text('GPT 3.5 Turbo'),
                  ),
                  DropdownMenuItem(
                    value: 'text-davinci-003',
                    child: Text('GPT 3.5'),
                  ),
                  DropdownMenuItem(
                    value: 'gpt-4',
                    child: Text('GPT 4'),
                  ),
                ],
                onChanged: (value) {
                  settingsProvider.langModel = value.toString();
                },
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen(
      {Key? key, required this.pageTitle, required this.urlString})
      : super(key: key);
  final String urlString;
  final String pageTitle;

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  bool _isLoading = false;
  // String _title = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.urlString));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          Container(
            color: Colors.lightBlue,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                    color: Colors.white,
                    onPressed: () async {
                      _controller.goBack();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                    ),
                    color: Colors.white,
                    onPressed: () async {
                      _controller.goForward();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
