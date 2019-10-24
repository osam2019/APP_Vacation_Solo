import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

bool callOnce = true;
List<dynamic> userList;
FirebaseUser loggedInUser;
enum user {
  cadre, // 0
  soldier, // 1
  admin, // 2
}
void getStoredData() async {
  await authService.firestore
      .collection('group')
      .document(loggedInUser.email)
      .updateData({"member": userList, "leader": loggedInUser.email});
}

class Group {
  final firestore = Firestore.instance;
  final auth = FirebaseAuth.instance;
  FirebaseUser user;
  void getGroupData() async {
    final GroupType = await firestore.collection('userinfo').getDocuments();
    for (var Group in GroupType.documents) {}
  }

  void groupStream() async {
    await for (var snapshot in firestore.collection('groups').snapshots()) {
      for (var group in snapshot.documents) {
        print(group.data);
      }
    }
  }
}

final Group authService = Group();

final usrRef = FirebaseDatabase.instance.reference().child('userinfo');
final groupsRef = FirebaseDatabase.instance.reference().child('groups');
