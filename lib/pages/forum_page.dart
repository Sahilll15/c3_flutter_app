import 'package:c3_app/models/user_profile.dart';
import 'package:c3_app/services/alert_service.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/services/database_service.dart';
import 'package:c3_app/widgets/custom_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class ForumText {
  String user;
  String title;
  String description;
  String dateTime; // Date and time property

  ForumText({
    required this.user,
    required this.title,
    required this.description,
    required this.dateTime,
  });
}

class _ForumPageState extends State<ForumPage> {
  final GetIt getIt = GetIt.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<ForumText> forumPosts = [];
  late DatabaseService _databaseService;
  late AuthService _authService;
  late AlertService _alertService;

  String? title, description;

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _databaseService = getIt.get<DatabaseService>();
    _alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forum"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          forumForm(),
          const SizedBox(height: 20),
          Expanded(
            child: _forumPosts(),
          ),
        ],
      ),
    );
  }

  Widget forumForm() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomFormField(
                hintText: 'title',
                placeholderText: 'Enter the title',
                onSaved: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),

              CustomFormField(
                hintText: 'description',
                placeholderText: 'Enter the description',
                onSaved: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
             ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Call the createForum method
      bool success = await _databaseService.createForum(_authService.user!.uid, title!, description!);
      print(success);
      if (success) {
        // Show success alert
        _alertService.showToast(
          text: "Forum created successfully",
          icon: Icons.check,
        );
      } else {
        // Show error alert if forum creation fails
        _alertService.showToast(
          text: "Error creating forum",
          icon: Icons.error,
        );
      }
    }
  },
  child: const Text("Post"),
),

            ],
          ),
        ),
      ),
    );
  }


StreamBuilder _forumPosts() {
  return StreamBuilder(
    stream: _databaseService.getForum(),
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
