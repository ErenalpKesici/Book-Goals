import 'package:book_goals/backup_restore.dart';
import 'package:book_goals/initial.dart';
import 'package:book_goals/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);
  Future<Users> findUser(email) async{
    DocumentReference doc = FirebaseFirestore.instance.collection("Users").doc(email);
    var document = await doc.get();
    Users ret = Users(email: document.get('email'), password: document.get('password'), name: document.get('name')); 
    // Users ret = Users(email: 'e', password: 'e',name: 'e');
    return ret;
  }
  @override
  Widget build(BuildContext context){
    final firebaseUser = context.watch<User?>();
    if(firebaseUser != null) {
      return FutureBuilder(
        future: findUser(firebaseUser.email),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData)
            return BackupRestorePageSend(user: snapshot.data);
          else 
            return Center(child: CircularProgressIndicator());
        },
    );
    }
    return InitialPageSend();
  }
}