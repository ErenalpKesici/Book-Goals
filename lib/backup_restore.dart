import 'dart:io';

import 'package:book_goals/AuthenticationServices.dart';
import 'package:book_goals/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';

import 'initial.dart';
import 'main.dart';

class BackupRestorePageSend extends StatefulWidget {
  late Users? user;
  BackupRestorePageSend({@required this.user});
  @override
  State<StatefulWidget> createState() {
    return BackupRestorePage(this.user);
  }
}
class BackupRestorePage extends State<BackupRestorePageSend>{
  Users? user;
  BackupRestorePage(@required this.user);
  @override
  void initState() {
       super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text('Backup/Restore')),
        centerTitle: true, 
        actions: [      
            
        ],  
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text("Signed in Account: " + user!.email!),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final externalDir = await getExternalStorageDirectory();
                    var doc = await FirebaseFirestore.instance.collection('Users').doc(user!.email).get();
                    try{
                      String json = doc.get('save');
                      await File(externalDir!.path + "/Save.json").writeAsString(json);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).backgroundColor, content: Text('Successfully restored from '  + user!.email!)));
                      update =true;
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyHomePage()));
                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).backgroundColor, content: Text('Error from account: '  + user!.email!+" - " + e.toString())));
                    }
                  },
                  child: const Text("Restore"),
                ),
                const SizedBox(width: 5,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final externalDir = await getExternalStorageDirectory();
                      FirebaseFirestore.instance.collection('Users').doc(user!.email).update({'save': (await File(externalDir!.path+"/Save.json").readAsString()).toString()});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).backgroundColor, content: Text('Successfully backed up to ' + user!.email!)));
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyHomePage()));
                    },
                    child: const Text("Backup")
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
                  label: Text("Sign out"),
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await context.read<AuthenticationServices>().signOut();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>InitialPageSend()));
                  },
                ),  
          ],
        ),
      )
    );
  }
}