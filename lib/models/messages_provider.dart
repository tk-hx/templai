import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesProvider with ChangeNotifier {
  final List<String> _messages = [
    'あなたは〇〇です。〇〇してください。',
  ];

  List<String> get messages => _messages;

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messages = prefs.getStringList('messages') ?? [];
    _messages.addAll(messages);
    notifyListeners();
  }

  Future<void> addMessage(String message) async {
    _messages.add(message);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('messages', _messages);
  }

  Future<void> removeMessage(int index) async {
    _messages.removeAt(index);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('messages', _messages);
  }
}
