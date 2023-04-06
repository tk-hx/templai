import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class ChatMessage {
  int id;
  String text;
  String role;
  String senderName;
  DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    required this.senderName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'role': role,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      text: json['text'] as String,
      role: json['role'] as String,
      senderName: json['senderName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class ChatRoom {
  int id;
  List<ChatMessage> messages = [];

  int maxMessageId = 0;

  ChatRoom({
    required this.id,
    required this.messages,
  }) {
    maxMessageId =
        (messages.isEmpty) ? 0 : messages.map((e) => e.id).reduce(max);
  }

  void addMessage(ChatMessage message) {
    messages.add(message);
    maxMessageId++;
  }

  void deleteMessage(int messageId) {
    messages.removeWhere((message) => message.id == messageId);
    maxMessageId =
        (messages.isEmpty) ? 0 : messages.map((e) => e.id).reduce(max);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as int,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
    );
  }
}

class ChatsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  int _maxChatRoomId = 0;
  List<ChatRoom> _chatRooms = [];
  ChatRoom _currentChatRoom = ChatRoom(id: 1, messages: []);

  ChatsProvider(this._prefs) {
    final jsonString = _prefs.getString('chatRooms');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _chatRooms = jsonList.map((e) => ChatRoom.fromJson(e)).toList();
      _maxChatRoomId =
          (_chatRooms.isEmpty) ? 0 : _chatRooms.map((e) => e.id).reduce(max);
    } else {
      addChatRoom([]);
    }
    _currentChatRoom = _chatRooms.last;
  }

  List<ChatRoom> get chatRooms => _chatRooms;
  ChatRoom get currentChatRoom => _currentChatRoom;

  void addChatRoom(List<ChatMessage> messages) {
    _chatRooms.add(ChatRoom(id: _maxChatRoomId + 1, messages: messages));
    _maxChatRoomId++;
    _currentChatRoom = _chatRooms[_chatRooms.length - 1];
    _saveChatRoomsToPrefs();
    notifyListeners();
  }

  void deleteChatRoom(int roomId) {
    int chatRoomIndex = _chatRooms.indexWhere((room) => room.id == roomId);
    _chatRooms.removeAt(chatRoomIndex);
    _maxChatRoomId =
        (_chatRooms.isEmpty) ? 0 : _chatRooms.map((e) => e.id).reduce(max);
    int currentChatRoomIndex = (chatRoomIndex < _chatRooms.length)
        ? chatRoomIndex
        : _chatRooms.length - 1;
    if (currentChatRoomIndex < 0) {
      _maxChatRoomId = 0;
      addChatRoom([]);
    } else {
      _currentChatRoom = _chatRooms[currentChatRoomIndex];
    }
    _saveChatRoomsToPrefs();
    notifyListeners();
  }

  void deleteAllChatRoom() {
    _chatRooms.clear();
    _maxChatRoomId = 0;
    addChatRoom([]);
  }

  int getCurrentChatRoomIndex() {
    int currentChatRoomIndex = _chatRooms.indexOf(_currentChatRoom);
    return currentChatRoomIndex;
  }

  void incrementCurrentChatRoom({bool append = false}) {
    if (append) {
      addChatRoom([]);
      _currentChatRoom = _chatRooms.last;
      notifyListeners();
      return;
    }
    int currentChatRoomIndex = getCurrentChatRoomIndex();
    if (currentChatRoomIndex < _chatRooms.length - 1) {
      _currentChatRoom = _chatRooms[currentChatRoomIndex + 1];
      notifyListeners();
    } else if (currentChatRoomIndex == _chatRooms.length - 1) {
      // addChatRoom([]);
    }
  }

  void decrementCurrentChatRoom() {
    int currentChatRoomIndex = getCurrentChatRoomIndex();
    if (currentChatRoomIndex > 0) {
      _currentChatRoom = _chatRooms[currentChatRoomIndex - 1];
    }
    notifyListeners();
  }

  int addMessageToCurrentChatRoom(String text, String role, String senderName) {
    ChatMessage message = ChatMessage(
      id: _currentChatRoom.maxMessageId + 1,
      text: text,
      role: role,
      senderName: senderName,
      timestamp: DateTime.now(),
    );
    _currentChatRoom.addMessage(message);

    _saveChatRoomsToPrefs();
    notifyListeners();

    return message.id;
  }

  void editMessageToChatRoom(
      int roomId, int messageId, String text, String role, String senderName) {
    if (_chatRooms.isEmpty) {
      return;
    }
    int roomIndex = _chatRooms.indexWhere((e) => e.id == roomId);
    int messageIndex =
        _chatRooms[roomIndex].messages.indexWhere((e) => e.id == messageId);

    _chatRooms[roomIndex].messages[messageIndex].text = text;
    _chatRooms[roomIndex].messages[messageIndex].role = role;
    _chatRooms[roomIndex].messages[messageIndex].senderName = senderName;

    _saveChatRoomsToPrefs();
    notifyListeners();
  }

  void _saveChatRoomsToPrefs() {
    final List<dynamic> jsonList = _chatRooms.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    _prefs.setString('chatRooms', jsonString);
  }
}
