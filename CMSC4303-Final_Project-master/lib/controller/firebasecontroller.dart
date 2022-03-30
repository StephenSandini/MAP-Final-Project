import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/comments.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';

class FirebaseController {
  static Future<User> signIn({@required String email, @required String password}) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

//Create New Account
  static Future<void> createAccount(
      {@required String email, @required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

// TYPE AND RETURN TYPES
  static Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    String filename,
    @required String uid,
    @required Function listener,
  }) async {
    filename ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    //Call Back Function to show progress
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if (event.bytesTransferred == event.totalBytes)
        progress = null; //Upload completely done
      listener(progress);
    });
    await task;
    String downloadURL = await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL: downloadURL,
      Constant.ARG_FILENAME: filename,
    };
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.serialize());
    return ref.id; //DOCUMENT ID
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      //doc.data() refs to the PhotoMemo deserialize document datastructure
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<dynamic>> getImageLabels({@required File photoFile}) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(photoFile);
    final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);
    //Labels are
    List<dynamic> labels = <dynamic>[];
    for (ImageLabel label in cloudLabels) {
      if (label.confidence >= Constant.MIN_ML_CONFIDENCE)
        labels.add(label.text.toLowerCase());
    }
    return labels;
  }

  static Future<void> updatePhotoMemo(
      //ONLY UPDATES THINGS THAT ARE CHANGED
      String docId,
      Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<List<PhotoMemo>> getPhotoMemoSharedWithMe(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    //DELETE PHOTOMEMO FROM THE FIRESTORE
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(p.docId)
        .delete();
    //DELETE THE PICTURE FILE
    await FirebaseStorage.instance.ref().child(p.photoFilename).delete();
    //  var comments = await FirebaseFirestore.instance
    //       .collection(Constant.COMMENTS_COLLECTION)
    //       .where(Comments.LINK_ID, isEqualTo: p.docId)
    //       .doc()
  }

  static Future<List<PhotoMemo>> searchImage({
    @required String createdBy,
    @required List<String> searchLabels,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var results = <PhotoMemo>[];
    querySnapshot.docs
        .forEach((doc) => results.add(PhotoMemo.deserialize(doc.data(), doc.id)));

    return results;
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Working AREA
  //////////////////////////////////////////////////////////////////////////////
  static Future<List<PhotoMemo>> getMyFavoritePhotoMemos({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .where(PhotoMemo.FAVORITE, isEqualTo: 'true')
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<void> updateFavorite(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<List<Comments>> getCommentsList({@required String linkId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.COMMENTS_COLLECTION)
        .where(Comments.LINK_ID, isEqualTo: linkId)
        .orderBy(Comments.TIMESTAMP, descending: true)
        .get();

    var result = <Comments>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Comments.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<PhotoMemo>> getSharedWithList({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.SHARED_WITH, descending: true)
        .get();
    var results = <PhotoMemo>[];
    querySnapshot.docs
        .forEach((doc) => results.add(PhotoMemo.deserialize(doc.data(), doc.id)));

    return results;
  }

  static Future<String> addComment(Comments comment) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.COMMENTS_COLLECTION)
        .add(comment.serialize());
    return ref.id;
  }

  static Future<void> deleteComment({@required String docId}) async {
    await FirebaseFirestore.instance
        .collection(Constant.COMMENTS_COLLECTION)
        .doc(docId)
        .delete();
  }
}
