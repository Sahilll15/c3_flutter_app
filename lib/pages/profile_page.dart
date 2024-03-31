import 'package:c3_app/models/user_profile.dart';
import 'package:c3_app/services/alert_service.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/services/database_service.dart';
import 'package:c3_app/services/navigation.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  final GetIt getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService  _databaseService;

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
       resizeToAvoidBottomInset: false,
       appBar: AppBar(
        title: const Text("Profile"),
        
      ),
      body: _buildUI(),
      
    );
  }
  


Widget _buildUI(){
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
          
         
          const SizedBox(height: 20),
          _userProfile(),
          const SizedBox(height: 20),
          const Text(
            'Forum Posts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _forumPosts(),
          ),
        ],
      ),
    ),
  );
}

Widget _userProfile(){
  return FutureBuilder<UserProfile>(
    future: _databaseService.getUserProfile(_authService.user!.uid),
    builder: (context, snapshot){
      if(snapshot.connectionState == ConnectionState.waiting){
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if(snapshot.hasError){
        return Center(
          child: Text('An error occurred'),
        );
      }
      
      // Accessing the UserProfile object directly from the snapshot
      UserProfile userProfile = snapshot.data!;
      
      // Print the data from the UserProfile object
      print('User profile data: ${userProfile.toJson()}');
 
      
      return Column(
        children: [
          CircleAvatar(
            radius: 50,
            // Set the background image here if available
            backgroundImage: NetworkImage(userProfile.pfpURL!),
            
          ),
          SizedBox(height: 20),
          Text(
           userProfile.name!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactInfo(Icons.email,'${userProfile.name}@gmail.com'),
            ],
          ),
          SizedBox(height: 20),
          
        ],
      );
    },
  );
}


  Widget _buildContactInfo(IconData icon, String text){
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Text(text),
      ],
    );
  }

  StreamBuilder _forumPosts() {
  return StreamBuilder(
    stream: _databaseService.getForumPostsByUserId(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text(
            "Error loading forum posts",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        );
      }

      if (snapshot.hasData && snapshot.data != null) {
        final forumPosts = snapshot.data!.docs;
    
        return ListView.builder(
          itemCount: forumPosts.length,
          itemBuilder: (context, index) {
            final forumPost = forumPosts[index].data();
                print(forumPost);
            final userData = _databaseService.getUserProfile(forumPost['user'] as String);
            final timestamp = forumPost['dateTime'] as Timestamp;
            final forumDateTime = timestamp.toDate();
final formattedDateTime = DateFormat.yMMMd().add_jm().format(forumDateTime);
           
            return FutureBuilder<UserProfile>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final userProfile = snapshot.data!;
                  print(userProfile); 
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        forumPost['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            forumPost['description'],
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Posted by: ${userProfile.name}',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Date: $formattedDateTime',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      }

      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

  
}
