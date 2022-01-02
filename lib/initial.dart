import 'package:book_goals/register.dart';
import 'package:book_goals/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/src/provider.dart';

import 'AuthenticationServices.dart';
import 'backup_restore.dart';
class InitialPageSend extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return InitialPage();
  }
}
class InitialPage extends State<InitialPageSend>{
  TextEditingController email =  TextEditingController();
  TextEditingController name =  TextEditingController();
  TextEditingController password =  TextEditingController();
  GoogleSignInAccount? googleAccount;
  GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
               padding: const EdgeInsets.all(8.0),
               child: Container(
                  child: TextField(controller: email,
                    textAlign: TextAlign.center,
                     decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
             ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TextField(controller: password,
                    textAlign: TextAlign.center,
                     decoration: InputDecoration(labelText: 'Pasword'.toString(), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)) ),
                  ),
                ),
              ),
               ElevatedButton.icon(icon: Icon(Icons.login), label: Text("Login"), onPressed: () async{
                 print(email.text +" " + password.text);
                if(email.text != "" && password.text != ""){
                  email.text = email.text.trim();
                  password.text = password.text.trim();
                  DocumentReference doc = FirebaseFirestore.instance.collection("Users").doc(email.text);
                  var document = await doc.get();
                  if(!document.exists){
                    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('alertNotFound'.toString())));
                    return;
                  }
                  if(document.get('email') == email.text && document.get('password') == password.text){
                    int result = await context.read<AuthenticationServices>().signIn(
                      email: email.text,
                      password: password.text,
                    );
                    if(result == 1){
                      Users user =  Users(email: document.get('email'), name: document.get('name'), password: document.get('password')); 
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BackupRestorePageSend(user: user)));
                    }
                    else
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('n')));
                  }
                  else
                    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Wrong entered'.toString())));
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Fill all fields'.toString())));
                }
              }),
              const SizedBox(height: 25,),
              ElevatedButton.icon(style: ElevatedButton.styleFrom(primary: Colors.white), onPressed: ()async{ 
                var result;     
                await googleSignIn.signIn().then((userData){
                  print(userData?.email);
                  result = context.read<AuthenticationServices>().signIn(
                      email: userData!.email,
                      password: userData.id,
                  );
                  googleAccount = userData;
                });
                int read = await result;
                if(read == 1){
                  DocumentReference doc = FirebaseFirestore.instance.collection("Users").doc(googleAccount!.email);
                  var document = await doc.get();
                  if(!document.exists)
                    return;
                  Users user =  Users(email: document.get('email'), password: document.get('password'), name: document.get('name'));  
                }
                else if(read == 0){
                  await googleSignIn.signIn().then((userData){
                    result = context.read<AuthenticationServices>().signUp(
                        email: userData?.email,
                        password: userData?.id,
                    );
                    googleAccount = userData;
                  });
                  FirebaseFirestore.instance.collection('Users').doc(googleAccount!.email).set({'email': googleAccount!.email, 'name': googleAccount!.displayName, 'password': googleAccount!.id});  
                  ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('welcome'.toString() + googleAccount!.displayName!)));
                }
              }, icon: Icon(Icons.one_k), label: Text("Continue with Google".toString(), style: TextStyle( color: Colors.black))),
              SizedBox(height: 50,),
              ElevatedButton.icon(onPressed: ()async{ 
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>RegisterPageSend()));
              }, icon: Icon(Icons.create_sharp), label: Text("No Account?", )),
            ],
          ),
        ),
      ),
    );
}}