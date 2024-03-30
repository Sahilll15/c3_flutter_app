import 'package:c3_app/models/user_profile.dart';
import 'package:c3_app/services/auth_service.auth.dart';
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

  void _setUpUserCollection() {
    _usersCollection = _firestore.collection('users').withConverter<UserProfile>(
      fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
      toFirestore: (userProfile, _) => userProfile.toJson(),
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
}