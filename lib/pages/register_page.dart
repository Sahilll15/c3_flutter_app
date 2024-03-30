import 'dart:io';

import 'package:c3_app/consts.dart';
import 'package:c3_app/services/alert_service.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/services/database_service.dart';
import 'package:c3_app/services/media_service.dart';
import 'package:c3_app/services/navigation.service.dart';
import 'package:c3_app/services/storage_service.dart';
import 'package:c3_app/widgets/custom_form_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  final GetIt getIt = GetIt.instance;
  late MediaService _mediaService;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService  _databaseService;
  late StorageService _storageService;
  bool loading = false;

  String? email, password, name;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _mediaService = getIt.get<MediaService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
    _storageService = getIt.get<StorageService>();
    _databaseService = getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerText(),
            const SizedBox(height: 100),
            if (!loading) _registerForm(),
            const SizedBox(height: 30),
            if (!loading) _createAndAccountLink(),
            if (loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Text _headerText() {
    return const Text(
      "Register",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Form _registerForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _pfpSelectionField(),
          CustomFormField(
            hintText: 'Name',
            placeholderText: 'Enter the name',
            validationRegEx: NAME_VALIDATION_REGEX,
            onSaved: (value) {
              setState(() {
                name = value;
              });
            },
          ),
          CustomFormField(
            hintText: 'Email',
            placeholderText: 'Enter the email',
            validationRegEx: EMAIL_VALIDATION_REGEX,
            onSaved: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          CustomFormField(
            hintText: 'Password',
            placeholderText: 'Enter the password',
            validationRegEx: PASSWORD_VALIDATION_REGEX,
            onSaved: (value) {
              setState(() {
                password = value;
              });
            },
          ),
          const SizedBox(height: 30),
          _registerButton(),
        ],
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            loading = true;
          });
          if (_registerFormKey.currentState?.validate() ?? false) {
            _registerFormKey.currentState?.save();
            bool result = await _authService.register(email!, password!);
            if (result) {
              if (selectedImage != null) {
               String? imageUrl = await _storageService.uploadUserPFP(
  selectedImage!,
  _authService.user!.uid,
);  

if(imageUrl != null){
  await _databaseService.createUserProfile(
    _authService.user!.uid,
    name!,
    imageUrl,
  );
}
              }
              _alertService.showToast(
                text: 'Register Successful',
                icon: Icons.check,
              );
              _navigationService.pushReplacementNamed('/home');
            } else {
              _alertService.showToast(
                text: 'Register Failed',
                icon: Icons.error,
              );
            }
          }

          setState(() {
            loading = false;
          });
        },
        child: const Text('Register'),
      ),
    );
  }

  Widget _createAndAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Already have an account?'),
          TextButton(
            onPressed: () {
              _navigationService.pushNamed('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}