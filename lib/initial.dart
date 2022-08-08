import 'package:book_goals/register.dart';
import 'package:book_goals/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'AuthenticationServices.dart';
import 'backup_restore.dart';

class InitialPageSend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InitialPage();
  }
}

class InitialPage extends State<InitialPageSend> {
  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  GoogleSignInAccount? googleAccount;
  GoogleSignIn googleSignIn = GoogleSignIn();
  bool passHidden = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login'.tr()), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TextField(
                    controller: email,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TextField(
                    controller: password,
                    textAlign: TextAlign.center,
                    obscureText: passHidden,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          color: passHidden
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                          icon: Icon(Icons.remove_red_eye_outlined),
                          onPressed: () {
                            setState(() {
                              if (passHidden)
                                passHidden = false;
                              else
                                passHidden = true;
                            });
                          },
                        ),
                        labelText: 'pass'.tr(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: Text("login".tr()),
                  onPressed: () async {
                    if (email.text != "" && password.text != "") {
                      email.text = email.text.trim();
                      password.text = password.text.trim();
                      if (await context.read<AuthenticationServices>().signIn(
                                email: email.text,
                                password: password.text,
                              ) ==
                          1) {
                        DocumentReference doc = FirebaseFirestore.instance
                            .collection("Users")
                            .doc(email.text);
                        var document = await doc.get();
                        if (document.get('email') == email.text &&
                            document.get('password') == password.text) {
                          Users user = Users(
                              email: document.get('email'),
                              name: document.get('name'),
                              password: document.get('password'));
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  BackupRestorePageSend(user: user)));
                        } else
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('n')));
                      } else
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('accountNonExist'.tr())));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('enterAllFields'.tr())));
                    }
                  }),
              const SizedBox(
                height: 25,
              ),
              SignInButton(Buttons.Google, text: 'loginGoogle'.tr(),
                  onPressed: () async {
                Users user;
                UserCredential userCredential = await context
                    .read<AuthenticationServices>()
                    .signInWithGoogle();
                if (!userCredential.additionalUserInfo!.isNewUser) {
                  DocumentReference doc = FirebaseFirestore.instance
                      .collection("Users")
                      .doc(userCredential.user!.email);

                  var document = await doc.get();
                  user = Users(
                      email: document.get('email'),
                      password: document.get('password'),
                      name: document.get('name'));
                } else {
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userCredential.user!.email)
                      .set({
                    'email': userCredential.user!.email,
                    'name': userCredential.user!.displayName,
                    'password': userCredential.user!.uid,
                    'picture': userCredential.user!.photoURL,
                  });
                  user = Users(
                      email: userCredential.user!.email,
                      password: userCredential.user!.uid,
                      name: userCredential.user!.displayName);
                }
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BackupRestorePageSend(
                          user: user,
                        )));
              }),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RegisterPageSend()));
                  },
                  icon: Icon(Icons.create_sharp),
                  label: Text(
                    "noaccount".tr(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
