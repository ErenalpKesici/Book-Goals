import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:book_goals/AuthenticationWrapper.dart';
import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';
class SettingsPageSend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPage();
  }
}
class SettingsPage extends State<SettingsPageSend>{
  SettingsPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"), centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(onPressed: () async{
              tryUpdate(context);
            }, icon: const Icon(Icons.update), label: const Text("Check for updates")),
            ElevatedButton.icon(onPressed: () async{
              runApp(const MyApp());
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AuthenticationWrapper()));
            }, icon: const Icon(Icons.import_export), label: const Text("Backup/Restore"))
          ],
        ),
      ),
    );
  }
}