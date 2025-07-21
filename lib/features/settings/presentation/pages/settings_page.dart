import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedModel = 'gpt-3.5-turbo';
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Theme'),
                    subtitle: Text(_getThemeModeLabel(_themeMode)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showThemeDialog,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Configuration',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Model'),
                    subtitle: Text(_selectedModel),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showModelDialog,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('API Key'),
                    subtitle: const Text('Set your OpenAI API key'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _showApiKeyDialog,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Clear Chat History'),
                    subtitle: const Text('Delete all conversations'),
                    trailing: const Icon(Icons.delete, color: Colors.red),
                    onTap: _showClearHistoryDialog,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Export Data'),
                    subtitle: const Text('Download your chat history'),
                    trailing: const Icon(Icons.download),
                    onTap: _exportData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('GitHub Repository'),
                    subtitle: const Text('View source code'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: _openRepository,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ThemeMode.values.map((mode) {
                    return RadioListTile<ThemeMode>(
                      title: Text(_getThemeModeLabel(mode)),
                      value: mode,
                      groupValue: _themeMode,
                      onChanged: (value) {
                        setState(() {
                          _themeMode = value!;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showModelDialog() {
    final models = ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Model'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  models.map((model) {
                    return RadioListTile<String>(
                      title: Text(model),
                      value: model,
                      groupValue: _selectedModel,
                      onChanged: (value) {
                        setState(() {
                          _selectedModel = value!;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('OpenAI API Key'),
            content: TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                hintText: 'sk-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save API key
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API key saved')),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Chat History'),
            content: const Text(
              'This will permanently delete all your conversations. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat history cleared')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete All'),
              ),
            ],
          ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality would be implemented here'),
      ),
    );
  }

  void _openRepository() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Would open GitHub repository')),
    );
  }
}
