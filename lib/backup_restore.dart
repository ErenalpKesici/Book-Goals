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
  bool _backupEnabled = false;
  BackupRestorePage(this.user);
  void loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      backupFrequencyIdx = prefs.getInt('backupFrequency') ?? -1;
      _backupEnabled = backupFrequencyIdx != -1;
    });
  }

  @override
  void initState() {
    loadFrequency();
    super.initState();
  }

  void savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('backupFrequency', _backupEnabled ? backupFrequencyIdx : -1);
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
            .push(MaterialPageRoute(builder: (context) => MyHomePage.init()));
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: FittedBox(child: Text('backup_restore'.tr())),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    "signedInAccount".tr() + '  -  ' + user!.email!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                      enabled: _backupEnabled,
                      leading: IconButton(
                          onPressed: () {
                            setState(() {
                              if (_backupEnabled)
                                _backupEnabled = false;
                              else {
                                backupFrequencyIdx = 0;
                                _backupEnabled = true;
                              }
                            });
                            savePrefs();
                          },
                          icon: Icon(Icons.security_rounded)),
                      title: _backupEnabled
                          ? Text(
                              'autoBackupEvery'.tr(),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              'autoBackupDisabled'.tr(),
                              textAlign: TextAlign.center,
                            ),
                      trailing: _backupEnabled
                          ? DropdownButton<String>(
                              alignment: AlignmentDirectional.center,
                              value: durations[backupFrequencyIdx],
                              onChanged: (String? newValue) async {
                                setState(() {
                                  backupFrequencyIdx = durations.indexWhere(
                                      (element) => element == newValue!);
                                });
                                savePrefs();
                              },
                              items: durations.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                          : null),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.restore),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('confirmRestore'.tr()),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('no'.tr())),
                                    ElevatedButton(
                                        onPressed: () async {
                                          final externalDir =
                                              await getExternalStorageDirectory();
                                          var doc = await FirebaseFirestore
                                              .instance
                                              .collection('Users')
                                              .doc(user!.email)
                                              .get();
                                          try {
                                            String json = doc.get('save');
                                            await File(externalDir!.path +
                                                    "/Save.json")
                                                .writeAsString(json);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .backgroundColor,
                                                    content: Text(
                                                        'Successfully restored from ' +
                                                            user!.email!)));
                                            update = true;
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyHomePage.init()));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .backgroundColor,
                                                    content: Text(
                                                        'Error from account: ' +
                                                            user!.email! +
                                                            " - " +
                                                            e.toString())));
                                          }
                                        },
                                        child: Text('yes'.tr()))
                                  ],
                                ));
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
                                  builder: (context) => MyHomePage.init()));
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
