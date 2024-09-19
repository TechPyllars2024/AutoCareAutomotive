import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
}
