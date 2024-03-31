import 'package:cloud_firestore/cloud_firestore.dart';

class ForumText {
  String id; 
  String user;
  String title;
  String description;
  DateTime dateTime; 

  ForumText({
    this.id = '', 
    required this.user,
    required this.title,
    required this.description,
    required this.dateTime,
  });

 
  ForumText.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user = json['user'],
        title = json['title'],
        description = json['description'],
        dateTime = json['dateTime'].toDate();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['title'] = title;
    data['description'] = description;
    data['dateTime'] = Timestamp.fromDate(dateTime);
    return data;
  }


}
