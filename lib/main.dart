import 'package:chatgpt_clone/config/routes.dart';

import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/current_chat_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/image_upload_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_ui_cubit.dart';
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
      providers: [
        BlocProvider<ChatListBloc>(create: (_) => sl.di<ChatListBloc>()),
        BlocProvider<CurrentChatBloc>(create: (_) => sl.di<CurrentChatBloc>()),
        BlocProvider<ImageUploadBloc>(create: (_) => sl.di<ImageUploadBloc>()),
        BlocProvider<ChatUICubit>(create: (_) => sl.di<ChatUICubit>()),
      ],
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
