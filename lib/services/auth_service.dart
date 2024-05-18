import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebseAuth = FirebaseAuth.instance;
  User? _user;
  User? get user {
    return _user;
  }

  AuthService() {
    _firebseAuth.authStateChanges().listen(authStateChangesStreamListner);
  }
  Future<bool> logout() async {
    try {
      await _firebseAuth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      final credentials = await _firebseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credentials.user != null) {
        _user = credentials.user;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  void authStateChangesStreamListner(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
}
