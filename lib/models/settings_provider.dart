import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingTemplate {
  String title;
  String systemText;
  String fixedText;

  SettingTemplate(
      {required this.title, required this.systemText, required this.fixedText});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'systemText': systemText,
      'fixedText': fixedText,
    };
  }

  factory SettingTemplate.fromJson(Map<String, dynamic> json) {
    return SettingTemplate(
      title: json['title'] as String,
      systemText: json['systemText'] as String,
      fixedText: json['fixedText'] as String,
    );
  }
}

class SettingModel {
  List<SettingTemplate> templates;
  String apiKey;
  String langModel;

  SettingModel(
      {required this.templates, required this.apiKey, required this.langModel});

  Map<String, dynamic> toJson() {
    return {
      'templates': templates.map((template) => template.toJson()).toList(),
      'apiKey': apiKey,
      'langModel': langModel,
    };
  }

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      templates: (json['templates'] as List<dynamic>)
          .map((dynamic item) =>
              SettingTemplate.fromJson(item as Map<String, dynamic>))
          .toList(),
      apiKey: json['apiKey'] as String,
      langModel: json['langModel'] as String,
    );
  }
}

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<SettingTemplate> _templates = [
    SettingTemplate(
        title: "定型文のサンプル",
        systemText: "システム文はチャットのやり取りに表示されませんが、AIによって認識されます。",
        fixedText: "これは定型文のサンプルです。\n"
            "定型文編集画面から編集できます。\n"
            "AIとのチャットを開始するには、設定画面からAPI Keyを設定してください。"),
    SettingTemplate(
        title: "ツアープランナーのサンプル",
        systemText: "以下の制約で答えてください。\n"
            "- 日本語で記述する\n"
            "- 30文字以内で記述する\n"
            "- Step by Stepで考える",
        fixedText: "あなたはツアープランナーです。\n")
  ];
  String _apiKey = '';
  String _langModel = 'gpt-3.5-turbo';

  SettingsProvider(this._prefs) {
    final settingModelJson = _prefs.getString('settingModel');
    if (settingModelJson != null) {
      try {
        final decodedJson =
            jsonDecode(settingModelJson) as Map<String, dynamic>;
        final settingModel = SettingModel.fromJson(decodedJson);
        _templates = settingModel.templates;
        _apiKey = settingModel.apiKey;
        _langModel = (settingModel.langModel.isEmpty)
            ? 'gpt-3.5-turbo'
            : settingModel.langModel;
      } catch (e) {
        // 何もしない
      }
    }
    _updateSettingModel();
  }

  List<SettingTemplate> get templates => _templates;

  set templates(List<SettingTemplate> value) {
    _templates = value;
    _updateSettingModel();
    notifyListeners();
  }

  String get apiKey => _apiKey;

  set apiKey(String value) {
    _apiKey = value;
    _updateSettingModel();
    notifyListeners();
  }

  String get langModel => _langModel;

  set langModel(String value) {
    _langModel = value;
    _updateSettingModel();
    notifyListeners();
  }

  void _updateSettingModel() {
    final settingModel = SettingModel(
        templates: _templates, apiKey: _apiKey, langModel: _langModel);
    final json = jsonEncode(settingModel.toJson());
    _prefs.setString('settingModel', json);
  }
}
