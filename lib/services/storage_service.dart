import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  StorageService() {}

  Future<String?> uploadUserPfp({required File file, required String uid}) async{

    Reference fileRef = await _firebaseStorage.ref('users/prpf').child("$uid${p.extension(file.path)}");
    UploadTask uploadTask  =  fileRef.putFile(file);
    return uploadTask.then((p){
      if (p.state == TaskState.success){
        return fileRef.getDownloadURL();
      }
    });
  }
}
