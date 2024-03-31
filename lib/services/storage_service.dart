import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

class StorageService{
  
  StorageServce(){

  }

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadUserPFP(
 File file,
     String uid
  ) async {
    try{
      final ref = _storage.ref('users/pfps').child('$uid${p.extension(file.path)}');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    }catch(e){
      print(e);
      return null;
    }
  }

  Future<String?> uploadChatImage(
    File file,
    String chatID
  ) async {
    try{
      final ref = _storage.ref('chats/$chatID').child('image${p.extension(file.path)}');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    }catch(e){
      print(e);
      return null;
    }
  }
}