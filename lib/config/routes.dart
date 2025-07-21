// import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
// import '../features/home/presentation/pages/home_page.dart';
// import '../features/chat/presentation/pages/chat_page.dart';
// import '../features/settings/presentation/pages/settings_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String chat = '/chat';
  static const String settings = '/settings';
}

// Navigation will be handled manually for now since go_router isn't configured yet
// final GoRouter appRouter = GoRouter(
//   initialLocation: AppRoutes.home,
//   routes: [
//     GoRoute(
//       path: AppRoutes.home,
//       builder: (context, state) => const HomePage(),
//     ),
//     GoRoute(
//       path: '${AppRoutes.chat}/:chatId',
//       builder: (context, state) {
//         final chatId = state.pathParameters['chatId'] ?? '';
//         return ChatPage(chatId: chatId);
//       },
//     ),
//     GoRoute(
//       path: AppRoutes.settings,
//       builder: (context, state) => const SettingsPage(),
//     ),
//   ],
// );
