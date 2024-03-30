import 'package:firebase_auth/firebase_auth.dart';

class AuthService{

  final FirebaseAuth _firebaseauth = FirebaseAuth.instance;

  User? _user;

  User? get user => _user;
  AuthService(){
    _firebaseauth.authStateChanges().listen(authStateChangesStreamListner);
  }


  Future<bool> login(String email, String password) async {
    try{
    
    final credential=  await _firebaseauth.signInWithEmailAndPassword(email: email, password: password);
    if(credential.user!=null){
      _user = credential.user;
      return true;
    }

    }catch(e){
      print(e);
      return false;
    }
    return false; 
  }

  Future<bool> register(String email, String password) async {
    try{
    
    final credential=  await _firebaseauth.createUserWithEmailAndPassword(email: email, password: password);
    if(credential.user!=null){
      _user = credential.user;
      return true;
    }

    }catch(e){
      print(e);
      return false;
    }
    return false; 
  }


  void authStateChangesStreamListner(User? user){
  if(user!=null){
    _user = user;
  }else{
    _user = null;
  }
  }

  Future<bool> logout()async{
    try{
      _firebaseauth.signOut();
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }
}