import 'dart:io';

import 'package:chatapp_firebase/models/user_profile.dart';
import 'package:chatapp_firebase/services/alert_services.dart';
import 'package:chatapp_firebase/services/database_service.dart';
import 'package:chatapp_firebase/services/media_service.dart';
import 'package:chatapp_firebase/services/navigation_service.dart';
import 'package:chatapp_firebase/services/storage_service.dart';
import 'package:chatapp_firebase/widgets/customFormField.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../const.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIT = GetIt.instance;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertServices _alertServices;

  late Size size;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  File? selectedImage;
  String? name, password, email;
  bool isLoading = false;

  void initState() {
    _authService = _getIT.get<AuthService>();
    _mediaService = _getIT.get<MediaService>();
    _navigationService = _getIT.get<NavigationService>();
    _storageService = _getIT.get<StorageService>();
    _databaseService = _getIT.get<DatabaseService>();
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
          if (!isLoading) _registerForm(),
          if (!isLoading) _loginAccLink(),
          if (isLoading) _lodingIndicator(),
        ],
      ),
    ));
  }

  Widget _lodingIndicator() {
    return Expanded(
        child: Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    ));
  }

  Widget _registerForm() {
    return Container(
      height: size.height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: size.height * 0.05,
      ),
      child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pfpSelectionWidget(),
              CustomFormField(
                hintText: "Name",
                height: size.height * 0.1,
                validationRegEx: NAME_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              CustomFormField(
                hintText: "Email",
                height: size.height * 0.1,
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              CustomFormField(
                hintText: "Password",
                height: size.height * 0.1,
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              _registerButton()
            ],
          )),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: size.width,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _registerFormKey.currentState?.save();
              bool result = await _authService.signUp(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                    file: selectedImage!, uid: _authService.user!.uid);
                if (pfpURL != null) {
                  await _databaseService.createUserProfile(
                      userProfile: UserProfile(
                          uid: _authService.user!.uid,
                          name: name,
                          pfpURL: pfpURL));
                  _alertServices.showToast(text: "User registered successfully",icon: Icons.check);
                  _navigationService.goBack();
                  _navigationService.pushReplacementNamed("/home");
                }else{
                  throw Exception('Unable to upload user profile');
                }
              }else{
                throw Exception('Unable to register user');
              }
            }
          } catch (e) {
            print(e);
            _alertServices.showToast(text: "Failed to register, Please try again!",icon: Icons.check);
          }
          setState(() {
            isLoading = false;
          });
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccLink() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an account ?  "),
        GestureDetector(
          onTap: () {
            _navigationService.goBack();
          },
          child: Text(
            "Sign In",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ));
  }

  Widget _pfpSelectionWidget() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
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
            "Let's, get going!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            "Register an account using the form below",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
