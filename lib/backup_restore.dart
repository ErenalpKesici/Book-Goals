import 'dart:convert';
import 'dart:io';

import 'package:book_goals/AuthenticationServices.dart';
import 'package:book_goals/preferences.dart';
import 'package:book_goals/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';

import 'initial.dart';
import 'main.dart';

Preferences? pref;
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
  String backupFrequency = pref==null?'Day':pref!.backupFrequency!;
  BackupRestorePage(this.user);
  @override
  void initState() {
    savePrefs();
    super.initState();
  }
  void savePrefs() async{
    final externalDir = await getExternalStorageDirectory();
    await File(externalDir!.path + "/Preferences.json").writeAsString(jsonEncode(Preferences(user: user!.email, backupFrequency: backupFrequency)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('Backup/Restore')),
        centerTitle: true, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text("Signed in Account: " + user!.email!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.security_rounded),
                title: const Text("Automatically backup every ", textAlign: TextAlign.center,),
                trailing: DropdownButton<String>(
                  alignment: AlignmentDirectional.center,
                  value: backupFrequency,
                  onChanged: (String? newValue) async{
                    setState(() {
                      backupFrequency = newValue!;
                    });
                    savePrefs();
                  },
                  items: <String>['Day', 'Week', 'Month'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  onPressed: () async {
                    final externalDir = await getExternalStorageDirectory();
                    // CollectionReference _documentRef = FirebaseFirestore.instance.collection('Users');
                    // _documentRef.get().then((value){
                    //   for(int i=0;i<value.docs.length;i++){
                    //     print(value.docs[i].id.contains('.').toString()+" : " + value.docs[i].id);
                    //     if(!value.docs[i].id.contains('.')){
                    //       value.docs[i].reference.delete();
                    //     }
                    //   }
                    // });
                    var doc = await FirebaseFirestore.instance.collection('Users').doc(user!.email).get();
                    try{
                      String json = doc.get('save');
                      print(json);
                      await File(externalDir!.path + "/Save.json").writeAsString(json);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).backgroundColor, content: Text('Successfully restored from '  + user!.email!)));
                      update =true;
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
                    }catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).backgroundColor, content: Text('Error from account: '  + user!.email!+" - " + e.toString())));
                    }
                  },
                  label: const Text("Restore"),
                ),
                const SizedBox(width: 5,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.backup_rounded),
                    onPressed: () async {
                      final externalDir = await getExternalStorageDirectory();
                      String readSave = await File(externalDir!.path+"/Save.json").readAsString();
                      if(readSave == ''){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).backgroundColor, content: const Text('Cannot backup when there is nothing to back up ')));
                      }
                      else{
                        FirebaseFirestore.instance.collection('Users').doc(user!.email).update({'dateUpdated': DateTime.now().toString(), 'save': readSave});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).backgroundColor, content: Text('Successfully backed up to ' + user!.email!)));
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
                      }
                    },
                    label: const Text("Backup")
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                label: const Text("Sign out"),
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await context.read<AuthenticationServices>().signOut();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>InitialPageSend()));
                },
              ),
            ),  
          ],
        ),
      )
    );
  }
}