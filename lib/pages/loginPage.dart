import 'package:chatapp_firebase/services/auth_service.dart';
import 'package:chatapp_firebase/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../const.dart';
import '../services/alert_services.dart';
import '../widgets/customFormField.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIT = GetIt.instance;
  late Size size;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  String? email,password;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertServices _alertServices;
  @override
  void initState() {
    _authService = _getIT.get<AuthService>();
    _navigationService = _getIT.get<NavigationService>();
    _alertServices = _getIT.get<AlertServices>();
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: Column(
        children: [
          _hederWidget(),
          _loginForm(),
          _loginButton(),
          _createAnAccLink(),
        ],
      ),
    ));
  }

  Widget _hederWidget() {
    return SizedBox(
      width: size.width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi Welcome Back!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            "Hi again, you've been missed",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: size.height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: size.height * 0.05,
      ),
      child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormField(
                hintText: "Email",
                height: size.height * 0.1, validationRegEx: EMAIL_VALIDATION_REGEX,
                onSaved: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              CustomFormField(
                hintText: "Password",
                height: size.height * 0.1, validationRegEx: PASSWORD_VALIDATION_REGEX,
                obscureText: true,
                onSaved: (val ) {
                  setState(() {
                    password = val;
                  });
                },
              ),
            ],
          )),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: size.width,
      child: MaterialButton(
        onPressed: () async{
          if ( _loginFormKey.currentState?.validate() ?? false){
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);
            print(result);
            if (result){
              _navigationService.pushReplacementNamed("/home");

            }else{
              _alertServices.showToast(text: "Failed to login, Please try again!",icon: Icons.error);

            }

          }
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAnAccLink() {
    return  Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Don't have an account ?  "),
        GestureDetector(
          onTap: () {
            _navigationService.pushNamed("/register");
          },
          child: Text(
            "Sign Up",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ));
  }
}
