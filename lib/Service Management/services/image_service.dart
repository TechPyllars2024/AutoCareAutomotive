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
      return _image; // Return the selected image file
    }
    return null; // Return null if no image was picked
  }

  // Function to upload image to Firebase Storage and return the download URL
  Future<String?> uploadImage(File image, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL(); // Return download URL
    } catch (e) {
      return null; // Return null if upload fails
    }
  }
}
