import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService{

  final ImagePicker _picker=ImagePicker();



  MediaService(){

  }


  Future<File?>  getImageGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}