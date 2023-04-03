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
  int _currentGroupId = 0;

  ChatsProvider(this._prefs) {
    // 初期化時に保存された設定を読み込む
    final chatMessageJson = _prefs.getString('chatMessage');
    if (chatMessageJson != null) {
      try {
        final decodedJson = jsonDecode(chatMessageJson) as List<dynamic>;
        _messages =
            decodedJson.map((json) => ChatMessage.fromJson(json)).toList();
        _currentGroupId = _messages.last.groupId;
      } catch (e) {
        _messages = [];
        _currentGroupId = 0;
        _updateChatMessage();
        return;
      }
    }
  }

  List<ChatMessage> get messages => _messages;
  set messages(List<ChatMessage> value) {
    _messages = value;
    _updateChatMessage();
    notifyListeners();
  }

  List<ChatMessage> getMessagesByGroupId() {
    return _messages.where((e) => e.groupId == _currentGroupId).toList();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _updateChatMessage();
    notifyListeners();
  }

  void editMessage(ChatMessage message, int id) {
    final index = _messages.indexWhere((e) => e.id == id);
    _messages[index] = message;
    _updateChatMessage();
    notifyListeners();
  }

  void removeMessage() {
    if (_messages.isEmpty) {
      return;
    }
    for (int i = _messages.length - 1; i >= 0; i--) {
      // _messagesのgroupIdは常に順番である事を前提
      // 後続のgroupIdを減らす(暫定対応)
      if (_messages[i].groupId > _currentGroupId) {
        _messages[i].groupId--;
      } else if (_messages[i].groupId == _currentGroupId) {
        _messages.removeAt(i);
      } else {
        break;
      }
    }
    if (_messages.isEmpty) {
      _currentGroupId = 0;
    } else if (_currentGroupId > _messages.last.groupId) {
      _currentGroupId = _messages.last.groupId;
    }
    _updateChatMessage();
    notifyListeners();
  }

  void removeAllMessage() {
    _messages = [];
    _currentGroupId = 0;
    _updateChatMessage();
    notifyListeners();
  }

  int getLastId() {
    if (_messages.isNotEmpty) {
      return _messages.last.id;
    } else {
      return -1;
    }
  }

  int getLastGroupId() {
    if (_messages.isNotEmpty) {
      return _messages.last.groupId;
    } else {
      return 0;
    }
  }

  void incrementGroupId() {
    final maxGroupId = (_messages.isNotEmpty) ? _messages.last.groupId : 0;
    _currentGroupId =
        (maxGroupId + 1 > _currentGroupId) ? _currentGroupId + 1 : 0;
    _updateChatMessage();
    notifyListeners();
  }

  void decrementGroupId() {
    _currentGroupId = (_currentGroupId > 0) ? _currentGroupId - 1 : 0;
    _updateChatMessage();
    notifyListeners();
  }

  int getCurrentGroupId() {
    return _currentGroupId;
  }

  // ChatMessageを更新するメソッド
  void _updateChatMessage() {
    // ChatMessageをJSONに変換して保存する
    final jsonList = _messages.map((message) => message.toJson()).toList();
    final json = jsonEncode(jsonList);
    debugPrint(json);
    _prefs.setString('chatMessage', json);
  }
}
