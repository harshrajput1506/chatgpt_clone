import 'package:flutter/material.dart';
import '../../../shared/models/chat_model.dart';
import '../../../../core/utils/formatters.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ChatModel> _chats = [
    ChatModel(
      id: '1',
      title: 'Sample Chat 1',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
      messageIds: [],
    ),
    ChatModel(
      id: '2',
      title: 'Sample Chat 2',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      messageIds: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _chats.isEmpty ? _buildEmptyState() : _buildChatList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Start a new conversation by tapping the + button',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.chat)),
            title: Text(
              chat.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              DateTimeFormatter.formatChatListTime(chat.lastMessageTime),
              style: const TextStyle(fontSize: 12),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteChat(chat.id);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
            ),
            onTap: () => _openChat(chat.id),
          ),
        );
      },
    );
  }

  void _createNewChat() {
    final newChatId = DateTime.now().millisecondsSinceEpoch.toString();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChatPage(chatId: newChatId)),
    );
  }

  void _openChat(String chatId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ChatPage(chatId: chatId)));
  }

  void _deleteChat(String chatId) {
    setState(() {
      _chats.removeWhere((chat) => chat.id == chatId);
    });
  }
}
