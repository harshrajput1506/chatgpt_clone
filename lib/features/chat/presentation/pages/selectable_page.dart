import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:flutter/material.dart';

class SelectablePage extends StatelessWidget {
  final String content;
  final MessageRole role;
  const SelectablePage({super.key, required this.content, required this.role});

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'SelectablePage initialized with content: $content and role: $role',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Text',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
