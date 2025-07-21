import 'package:flutter/material.dart';
import '../../../shared/models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<MessageModel> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _regenerateLastResponse,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
          ),
          if (_isLoading) _buildTypingIndicator(),
          MessageInput(
            onSendMessage: _sendMessage,
            onSendImage: _sendImageMessage,
            enabled: !_isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Send a message to begin chatting',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageBubble(
          message: message,
          onRetry: message.hasError ? () => _retryMessage(message.id) : null,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          CircleAvatar(radius: 16, child: Icon(Icons.smart_toy, size: 16)),
          SizedBox(width: 12),
          Text('ChatGPT is typing...'),
          SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();
    _generateResponse();
  }

  void _sendImageMessage(String imagePath, String caption) {
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: caption,
      type: MessageType.image,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      imageUrl:
          imagePath, // In real app, this would be uploaded to Cloudinary first
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();
    _generateResponse();
  }

  Future<void> _generateResponse() async {
    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    final assistantMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content:
          'This is a simulated response from ChatGPT. In the real implementation, this would come from the OpenAI API.',
      type: MessageType.text,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(assistantMessage);
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _retryMessage(String messageId) {
    // Find and retry the failed message
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      setState(() {
        _messages[messageIndex] = _messages[messageIndex].copyWith(
          hasError: false,
          isLoading: true,
        );
        _isLoading = true;
      });
      _generateResponse();
    }
  }

  void _regenerateLastResponse() {
    if (_messages.isNotEmpty && _messages.last.role == MessageRole.assistant) {
      setState(() {
        _messages.removeLast();
        _isLoading = true;
      });
      _generateResponse();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
