// import 'package:hive_flutter/hive_flutter.dart';
import '../../features/shared/models/message_model.dart';
import '../../features/shared/models/chat_model.dart';

class LocalStorageService {
  // For now, we'll use in-memory storage as a placeholder
  final Map<String, ChatModel> _chats = {};
  final Map<String, List<MessageModel>> _messages = {};
  final Map<String, String> _settings = {};

  Future<void> init() async {
    // Initialize Hive when dependencies are available
    // await Hive.initFlutter();
  }

  // Chat operations
  Future<void> saveChat(ChatModel chat) async {
    _chats[chat.id] = chat;
  }

  Future<List<ChatModel>> getAllChats() async {
    return _chats.values.toList();
  }

  Future<ChatModel?> getChat(String chatId) async {
    return _chats[chatId];
  }

  Future<void> deleteChat(String chatId) async {
    _chats.remove(chatId);
    _messages.remove(chatId);
  }

  Future<void> clearAllChats() async {
    _chats.clear();
    _messages.clear();
  }

  // Message operations
  Future<void> saveMessage(String chatId, MessageModel message) async {
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(message);
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    return _messages[chatId] ?? [];
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    if (_messages.containsKey(chatId)) {
      _messages[chatId]!.removeWhere((msg) => msg.id == messageId);
    }
  }

  // Settings operations
  Future<void> saveSetting(String key, String value) async {
    _settings[key] = value;
  }

  Future<String?> getSetting(String key) async {
    return _settings[key];
  }

  Future<void> deleteSetting(String key) async {
    _settings.remove(key);
  }

  Future<void> clearAllSettings() async {
    _settings.clear();
  }

  Future<void> dispose() async {
    // Cleanup when needed
  }
}
