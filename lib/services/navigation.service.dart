import 'package:c3_app/pages/forum_page.dart';
import 'package:c3_app/pages/home_page.dart';
import 'package:c3_app/pages/login_page.dart';
import 'package:c3_app/pages/profile_page.dart';
import 'package:c3_app/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationService{

  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String,Widget Function(BuildContext)> _routes = {
    "/login":(context)=>LoginPage(),
    '/home':(context)=>ForumPage(),
    '/register':(context)=>RegisterPage(),
    '/chatlist':(context)=>HomePage(),
    '/profile':(context)=>ProfilePage(),
  };

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;


  Map<String,Widget Function(BuildContext)> get routes => _routes;

  NavigationService(){
    _navigatorKey = GlobalKey<NavigatorState>();
  }


  void pushNamed(String routeName){
    _navigatorKey.currentState!.pushNamed(routeName);
  }

  void push(MaterialPageRoute routeName){
    _navigatorKey.currentState!.push(routeName);
  }

  void goback(){
    _navigatorKey.currentState!.pop();
  }

  void pushReplacementNamed(String routeName){
    _navigatorKey.currentState!.pushReplacementNamed(routeName);
  }
}