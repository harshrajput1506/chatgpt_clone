import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/presentation/pages/chat_page.dart';
import 'package:chatgpt_clone/features/chat/presentation/pages/selectable_page.dart';
import 'package:chatgpt_clone/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String home = '/';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String selectablePage = '/selectable';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:chatId',
        builder: (context, state) {
          return ChatPage();
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.selectablePage,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final content = data['content'] ?? '';
          final role =
              data['role'] != null
                  ? MessageRole.values.firstWhere(
                    (e) => e.name == data['role'],
                    orElse: () => MessageRole.user,
                  )
                  : MessageRole.user;
          return SelectablePage(content: content, role: role);
        },
      ),
    ],
  );
}
