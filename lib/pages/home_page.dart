import 'package:chatapp_firebase/models/user_profile.dart';
import 'package:chatapp_firebase/pages/chat_page.dart';
import 'package:chatapp_firebase/services/alert_services.dart';
import 'package:chatapp_firebase/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIT = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertServices _alertServices;
  late DatabaseService _databaseService;

  @override
  void initState() {
    _authService = _getIT.get<AuthService>();
    _navigationService = _getIT.get<NavigationService>();
    _alertServices = _getIT.get<AlertServices>();
    _databaseService = _getIT.get<DatabaseService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
              onPressed: () async {
                bool result = await _authService.logout();
                if (result) {
                  _alertServices.showToast(
                      text: 'Successfully logged out!', icon: Icons.check);
                  _navigationService.pushReplacementNamed("/login");
                }
              },
              color: Colors.red,
              icon: const Icon(Icons.logout))
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: _chatList(),
    ));
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load data"),
          );
        }
        print('Profiles : ${snapshot.data}');
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              return ChatTile(
                userProfile: user,
                onTap: () async {
                  final chatExist = await _databaseService.checkChatExists(
                      _authService.user!.uid, user.uid!);
                  if (!chatExist) {
                    await _databaseService.createNewChat(
                      _authService.user!.uid,
                      user.uid!,
                    );
                  }
                  _navigationService.push(MaterialPageRoute(builder: (context) {
                    return ChatPage(chatUser: user,);
                  },));
                },
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
