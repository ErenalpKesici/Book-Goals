import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:book_goals/AuthenticationWrapper.dart';
import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class SettingsPageSend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPage();
  }
}

class SettingsPage extends State<SettingsPageSend> {
  SettingsPage();
  String? language;
  late final SharedPreferences prefs;

  void getLang() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      language = prefs.getString('lang');
      language = language ?? Platform.localeName.split('_')[0];
    });
  }

  @override
  void initState() {
    getLang();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: Text("settings".tr()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: language == 'en'
                ? null
                : () {
                    setState(() {
                      prefs.setString('lang', 'en');
                      EasyLocalization.of(context)!
                          .setLocale(const Locale('en'));
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SettingsPageSend()));
                    });
                  },
            icon: Image.asset("assets/imgs/en.png",
                color: Colors.white.withOpacity(language == 'en' ? 0.5 : 1),
                colorBlendMode: BlendMode.modulate),
          ),
          IconButton(
            onPressed: language == 'tr'
                ? null
                : () {
                    setState(() {
                      prefs.setString('lang', 'tr');
                      EasyLocalization.of(context)!
                          .setLocale(const Locale('tr'));
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SettingsPageSend()));
                    });
                  },
            icon: Image.asset("assets/imgs/tr.png",
                color: Colors.white.withOpacity(language == 'tr' ? 0.5 : 1),
                colorBlendMode: BlendMode.modulate),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ElevatedButton.icon(
            //     onPressed: () async {
            //       tryUpdate(context);
            //     },
            //     icon: const Icon(Icons.update),
            //     label: const Text("Check for updates")),
            ElevatedButton.icon(
                onPressed: () async {
                  runApp(EasyLocalization(supportedLocales: const [
                    Locale('tr'),
                    Locale('en'),
                  ], path: 'assets/translations', child: const MyApp()));
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AuthenticationWrapper()));
                },
                icon: const Icon(Icons.import_export),
                label: Text("backup_restore".tr()))
          ],
        ),
      ),
    );
  }
}
