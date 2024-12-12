import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  File? _image;

  // Function to pick image from source (gallery or camera)
  Future<File?> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      return _image;
    }
    return null;
  }

  // Function to upload image to Firebase Storage and return the download URL
  Future<String?> uploadImage(File image, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
