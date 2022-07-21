import 'dart:convert';
import 'dart:io';

import 'package:book_goals/AuthenticationServices.dart';
import 'package:book_goals/preferences.dart';
import 'package:book_goals/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper_functions.dart';
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

class BackupRestorePage extends State<BackupRestorePageSend> {
  Users? user;
  int backupFrequencyIdx = 0;
  List<String> durations = getDurations();
  BackupRestorePage(this.user);
  void loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backupFrequencyIdx = prefs.getInt('backupFrequency') ?? 0;
    });
  }

  @override
  void initState() {
    savePrefs();
    loadFrequency();
    super.initState();
  }

  void savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('backupFrequency', backupFrequencyIdx);
    prefs.setString('email', user!.email!);
    // final externalDir = await getExternalStorageDirectory();
    // await File(externalDir!.path + "/Preferences.json").writeAsString(
    //     jsonEncode(Preferences(
    //         user: user!.email, backupFrequencyIdx: backupFrequencyIdx)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const MyHomePage()));
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: FittedBox(child: Text('Backup/Restore'.tr())),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text("signedInAccount".tr() + ' ' + user!.email!),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                      leading: const Icon(Icons.security_rounded),
                      title: Text(
                        "autoBackupEvery".tr(),
                        textAlign: TextAlign.center,
                      ),
                      trailing: DropdownButton<String>(
                        alignment: AlignmentDirectional.center,
                        value: durations[backupFrequencyIdx],
                        onChanged: (String? newValue) async {
                          setState(() {
                            durations[backupFrequencyIdx] = newValue!;
                          });
                          savePrefs();
                        },
                        items: durations
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )),
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
                        var doc = await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user!.email)
                            .get();
                        try {
                          String json = doc.get('save');
                          print(json);
                          await File(externalDir!.path + "/Save.json")
                              .writeAsString(json);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              content: Text('Successfully restored from ' +
                                  user!.email!)));
                          update = true;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MyHomePage()));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              content: Text('Error from account: ' +
                                  user!.email! +
                                  " - " +
                                  e.toString())));
                        }
                      },
                      label: Text("restore".tr()),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          icon: const Icon(Icons.backup_rounded),
                          onPressed: () async {
                            final externalDir =
                                await getExternalStorageDirectory();
                            String readSave =
                                await File(externalDir!.path + "/Save.json")
                                    .readAsString();
                            if (readSave == '') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  content: const Text(
                                      'Cannot backup when there is nothing to back up ')));
                            } else {
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user!.email)
                                  .update({
                                'dateUpdated': DateTime.now().toString(),
                                'save': readSave
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      content: Text(
                                          'Successfully backed up to ' +
                                              user!.email!)));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const MyHomePage()));
                            }
                          },
                          label: Text("backup".tr())),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    label: Text("logout".tr()),
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await context.read<AuthenticationServices>().signOut();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => InitialPageSend()));
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
