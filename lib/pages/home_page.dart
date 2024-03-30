import 'package:c3_app/models/user_profile.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/services/database_service.dart';
import 'package:c3_app/services/navigation.service.dart';
import 'package:c3_app/services/alert_service.dart';
import 'package:c3_app/widgets/chat_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt getIt = GetIt.instance;

  late DatabaseService _databaseService;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
    _databaseService = getIt.get<DatabaseService>();
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
                _alertService.showToast(
                  text: "Logged out successfully",
                  icon: Icons.check,
                );
                _navigationService.pushReplacementNamed('/login');
              } else {
                _alertService.showToast(
                  text: "Error logging out",
                  icon: Icons.check,
                );
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
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
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading chats"),
          );
        }

    print(snapshot.data);
        if (snapshot.hasData && snapshot.data != null) {
          final users=snapshot.data!.docs;
          return ListView.builder(itemCount: users.length,itemBuilder: (context,index){
            UserProfile user=users[index].data();
            return Padding(
              
              padding: const EdgeInsets.all(8.0),
              child: ChatTile(userProfile: user, onTap: (){}),
            );
          });
        }

      return const Center(
        child: CircularProgressIndicator(),
      );
      
    
      },
    );
  }
}