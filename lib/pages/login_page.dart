import 'package:c3_app/consts.dart';
import 'package:c3_app/services/alert_service.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/services/navigation.service.dart';
import 'package:c3_app/widgets/custom_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey=GlobalKey();
  final GetIt getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  String? email,password;


  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
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
            _loginForm(),
            const SizedBox(height: 30),
            _loginButton(),
            const SizedBox(height: 10),
            _createAndAccountLink(),
            
          ],
        ),
      ),
    );
  }

 Widget _headerText() {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Hi, welcome back to c3 app',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        
      ],
    ),
  );
}

  Widget _loginForm(){
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        margin: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormField(hintText: 'Email',placeholderText: 'Enter the email',
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onSaved: (value){
           setState(() {
              email=value;
           });
                
                },
              ),
              const SizedBox(height: 30),
              CustomFormField(hintText: 'Password',placeholderText: 'Enter the password',
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              onSaved: (value){
                setState(() {
                  password=value;
                });
              
              },
              ),
            ],
          ),
        ),
      );
  }

  Widget _loginButton(){
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: ElevatedButton(
        onPressed: ()async{
         if(_loginFormKey.currentState?.validate() ?? false){
          _loginFormKey.currentState?.save();
          bool result =await _authService.login(email!, password!);
          if(result){
            _alertService.showToast(
              text: 'Login Successful',
              icon: Icons.check,
            );
            _navigationService.pushReplacementNamed('/home');
          }else{
            _alertService.showToast(
              text: 'Login Failed',
              icon: Icons.error,
            );
          }
         }
        },
        child: const Text('Login'),
        
      ),
      
    );
  }

  Widget _createAndAccountLink(){
    return Expanded(child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Don\'t have an account?'),
        TextButton(
          onPressed: (){
            _navigationService.pushNamed('/register');
          },
          child: const Text('Create an account'),
        ),
      ],
    )
    );
  }
}
