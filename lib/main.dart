import 'package:chatgpt_clone/config/routes.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'config/injector.dart' as sl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependencies
  sl.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<ChatBloc>(create: (_) => sl.di<ChatBloc>())],
      child: MaterialApp.router(
        title: 'ChatGPT Clone',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
