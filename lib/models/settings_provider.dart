import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingModel {
  List<String> templates;
  String apiKey;
  String langModel;

  SettingModel(
      {required this.templates, required this.apiKey, required this.langModel});

  // Map<String, dynamic>に変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'templates': templates,
      'apiKey': apiKey,
      'langModel': langModel,
    };
  }

  // Map<String, dynamic>から復元するファクトリーメソッド
  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      templates: (json['templates'] as List<dynamic>).cast<String>(),
      apiKey: json['apiKey'] as String,
      langModel: json['langModel'] as String,
    );
  }
}

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<String> _templates = [];
  String _apiKey = '';
  String _langModel = '';

  SettingsProvider(this._prefs) {
    // 初期化時に保存された設定を読み込む
    final settingModelJson = _prefs.getString('settingModel');
    if (settingModelJson != null) {
      try {
        final decodedJson =
            jsonDecode(settingModelJson) as Map<String, dynamic>;
        final settingModel = SettingModel.fromJson(decodedJson);
        _templates = settingModel.templates;
        _apiKey = settingModel.apiKey;
        _langModel = settingModel.langModel;
      } catch (e) {
        // 何もしない
      }
    }
    _updateSettingModel();
  }

  List<String> get templates => _templates;

  set templates(List<String> value) {
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

  // SettingModelを更新するメソッド
  void _updateSettingModel() {
    final settingModel = SettingModel(
        templates: _templates, apiKey: _apiKey, langModel: _langModel);
    final json = jsonEncode(settingModel.toJson());
    _prefs.setString('settingModel', json);
  }
}
