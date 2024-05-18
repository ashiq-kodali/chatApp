import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
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
  @override
  void initState() {
    _authService = _getIT.get<AuthService>();
    _navigationService = _getIT.get<NavigationService>();
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [IconButton(onPressed: ()async {
          bool result = await _authService.logout();
          if (result){
            _navigationService.pushReplacementNamed("/login");
          }
        },
            color: Colors.red,
            icon: const Icon(Icons.logout))],
      ),
    );
  }
}
