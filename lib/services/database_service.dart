import 'package:c3_app/models/chat.dart';
import 'package:c3_app/models/message.dart';
import 'package:c3_app/models/user_profile.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
 

  final GetIt getIt = GetIt.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AuthService _authService;


 DatabaseService() {
    _setUpUserCollection();
    _authService = getIt.get<AuthService>();
  
  }
  CollectionReference<UserProfile>? _usersCollection;
 CollectionReference? _chatCollection;


  void _setUpUserCollection() {
    _usersCollection = _firestore.collection('users').withConverter<UserProfile>(
      fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
      toFirestore: (userProfile, _) => userProfile.toJson(),
    );

    _chatCollection = _firestore.collection('chats').withConverter<Chat>(
      fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    );
  }

  Future<void> createUserProfile(String uid, String name, String pfpUrl) async {
    try {
      await _usersCollection!.doc(uid).set(UserProfile(
        uid: uid,
        name: name,
        pfpURL: pfpUrl,
      ));
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection!
        .where("uid", isNotEqualTo: _authService.user?.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

Future<bool> checkChatExists(String uid1,String uid2)async{
 String ChatId=generateChatID(uid1: uid1, uid2: uid2);

  try {
      final result=await _chatCollection!.doc(ChatId).get();
      if(result != null){
        return result.exists;
      }
      return false;
    } catch (e) {
      rethrow;
    }
}

Future<void> createChat(String uid1,String uid2)async{
  String ChatId=generateChatID(uid1: uid1, uid2: uid2);
  try {
     final docRef= await _chatCollection!.doc(ChatId);

  final chat=Chat(id: ChatId, participants: [uid1,uid2], messages: []);

  await docRef.set(chat);
     
    } catch (e) {
      rethrow;
    }
    }

    Future<void> sendMessage(String uid1,uid2,Message message)async{
      String ChatId=generateChatID(uid1: uid1, uid2: uid2);
      try {
        final docRef=await _chatCollection!.doc(ChatId);
        await docRef.update({
          "messages": FieldValue.arrayUnion([message.toJson()])
        });
        
      } catch (e) {
        rethrow;
      }
      try {
       
      } catch (e) {
        rethrow;
      }
    }

    Stream <DocumentSnapshot<Chat>> getChatData(String uid1,String uid2){
      String ChatId=generateChatID(uid1: uid1, uid2: uid2);
      return _chatCollection!.doc(ChatId).snapshots() as Stream<DocumentSnapshot<Chat>>;
    }


    Future<bool> createForum(String uid, String title, String description) async {
      try {
        await _firestore.collection('forum').add({
          'user': uid,
          'title': title,
          'description': description,
          'dateTime': DateTime.now(),
        });

        return true;
      } catch (e) {
        rethrow;
      }


    }

    Stream<QuerySnapshot> getForum(){
      return _firestore.collection('forum').snapshots();
    }


  Stream<QuerySnapshot> getForumPostsByUserId() {
    return _firestore
        .collection('forum')
        .where('user', isEqualTo: _authService.user!.uid)
        .snapshots();
  }
  
    Future<void> deleteForum(String id)async{
      try {
        await _firestore.collection('forum').doc(id).delete();
      } catch (e) {
        rethrow;
      }
    }


    Future<UserProfile> getUserProfile(String uid)async{
      try {
        final result=await _usersCollection!.doc(uid).get();
        return result.data()!;
      } catch (e) {
        rethrow;
      }
    }

   

}