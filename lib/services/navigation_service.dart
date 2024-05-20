import 'package:chatapp_firebase/pages/home_page.dart';
import 'package:chatapp_firebase/pages/loginPage.dart';
import 'package:chatapp_firebase/pages/register_page.dart';
import 'package:flutter/cupertino.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginPage(),
    "/home": (context) => HomePage(),
    "/register": (context) => RegisterPage(),
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routs {
    return _routes;
  }

  NavigationService() {
    _navigatorKey= GlobalKey<NavigatorState>();
  }
  void pushNamed (String routeName){
    _navigatorKey.currentState?.pushNamed(routeName);
  }
  void pushReplacementNamed (String routeName){
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }
  void goBack (){
    _navigatorKey.currentState?.pop();
  }
}
