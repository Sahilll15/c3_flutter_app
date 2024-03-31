import 'package:c3_app/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;

  const ChatTile({
    Key? key,
    required this.userProfile,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 255, 244, 244), // Set the desired background color here
      child: ListTile(
        onTap: () {
          onTap();
        },
        dense: false,
        leading: CircleAvatar(
          backgroundImage: userProfile.pfpURL != null
              ? NetworkImage(userProfile.pfpURL!)
              : null,
        ),
        title: Text(userProfile.name ?? ''),
      ),
    );
  }
}
