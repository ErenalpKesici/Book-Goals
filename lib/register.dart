import 'package:book_goals/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/src/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'AuthenticationServices.dart';
import 'main.dart';

class RegisterPageSend extends StatefulWidget {
  RegisterPageSend();
  @override
  State<StatefulWidget> createState() {
    return RegisterPage();
  }
}

class RegisterPage extends State<RegisterPageSend> {
  TextEditingController email = new TextEditingController();
  TextEditingController name = new TextEditingController();
  TextEditingController password = new TextEditingController();
  GoogleSignInAccount? googleAccount;
  GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("signup".tr().toString()),
        centerTitle: true,
      ),
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
                    controller: name,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        labelText: "id".tr().toString(),
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
                    decoration: InputDecoration(
                        labelText: "pass".tr().toString(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              ElevatedButton.icon(
                  icon: Icon(Icons.create_rounded),
                  label: Text("signup".tr().toString()),
                  onPressed: () async {
                    email.text = email.text.trim();
                    name.text = name.text.trim();
                    password.text = password.text.trim();
                    if (email.text != '' &&
                        name.text != '' &&
                        password.text != '') {
                      int result =
                          await context.read<AuthenticationServices>().signUp(
                                email: email.text,
                                password: password.text,
                              );
                      if (result == 1) {
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(email.text)
                            .set({
                          'email': email.text,
                          'name': name.text,
                          'password': password.text,
                          'dateUpdated': DateTime.now().toString(),
                        });
                        Users user = new Users(
                            email: email.text,
                            password: password.text,
                            name: name.text);
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                            content:
                                Text('welcome'.tr().toString() + name.text)));
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyHomePage.init()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                            content: Text('alertFormat'.tr().toString())));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                          content: Text('alertFill'.tr().toString())));
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
