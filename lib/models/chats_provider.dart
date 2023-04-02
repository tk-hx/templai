import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatMessage {
  int id;
  int groupId;
  String text;
  String role;
  String senderName;
  DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.role,
    required this.text,
    required this.senderName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'role': role,
      'text': text,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      role: json['role'] as String,
      text: json['text'] as String,
      senderName: json['senderName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class ChatsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<ChatMessage> _messages = [];

  ChatsProvider(this._prefs) {
    // 初期化時に保存された設定を読み込む
    final chatMessageJson = _prefs.getString('chatMessage');
    if (chatMessageJson != null) {
      try {
        final decodedJson = jsonDecode(chatMessageJson) as Map<String, dynamic>;
        final chatMessage = ChatMessage.fromJson(decodedJson);
        _messages = [chatMessage];
      } catch (e) {
        _messages = [];
        _updateChatMessage();
        return;
      }

      final decodedJson = jsonDecode(chatMessageJson) as Map<String, dynamic>;
      final chatMessage = ChatMessage.fromJson(decodedJson);
      _messages = [chatMessage];
    }
  }

  List<ChatMessage> get messages => _messages;
  set messages(List<ChatMessage> value) {
    _messages = value;
    _updateChatMessage();
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _updateChatMessage();
    notifyListeners();
  }

  void editMessage(ChatMessage message, int index) {
    _messages[index] = message;
    _updateChatMessage();
    notifyListeners();
  }

  void removeMessageAt(int index) {
    _messages.removeAt(index);
    _updateChatMessage();
    notifyListeners();
  }

  int getLastId() {
    if (_messages.isNotEmpty) {
      return _messages.last.id;
    } else {
      return 0;
    }
  }

  int getLastGroupId() {
    if (_messages.isNotEmpty) {
      return _messages.last.groupId;
    } else {
      return 0;
    }
  }

  // ChatMessageを更新するメソッド
  void _updateChatMessage() {
    // ChatMessageをJSONに変換して保存する
    final jsonList = _messages.map((message) => message.toJson()).toList();
    _prefs.setString('chatMessage', jsonEncode(jsonList));
  }
}
