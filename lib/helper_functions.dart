import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:book_goals/preferences.dart';
import 'package:book_goals/settings_page.dart';
import 'package:book_goals/stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:isolate';
import 'backup_restore.dart';
import 'book.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';
import 'old_goals.dart';
import 'package:http/http.dart' as http;

List<String> getDurations() {
  return <String>['days'.tr(), 'weeks'.tr(), 'months'.tr(), 'years'.tr()];
}

List<String> getPeriods() {
  return <String>[
    '30_days'.tr(),
    '3_months'.tr(),
    '6_months'.tr(),
    '1_years'.tr(),
    "all_time".tr()
  ];
}

void writeSave() async {
  final externalDir = await getExternalStorageDirectory();
  await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(data));
}

void tryBackup() async {
  final prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email') ?? '';
  if (email == '') return;
  int backupFrequencyIdx = prefs.getInt('backupFrequencyIdx') ?? 0;
  if (backupFrequencyIdx == -1) return;
  final externalDir = await getExternalStorageDirectory();

  // if (await File(externalDir!.path + "/Preferences.json").exists()) {
  //   String readPref =
  //       await File(externalDir.path + "/Preferences.json").readAsString();
  //   pref = Preferences.empty();
  //   Map<String, dynamic> prefs = jsonDecode(readPref);
  //   prefs.forEach((key, value) {
  //     switch (key) {
  //       case ('user'):
  //         pref!.user = value;
  //         break;
  //       case ('backupFrequency'):
  //         pref!.backupFrequency = value;
  //         break;
  //     }
  //   });

  var doc =
      await FirebaseFirestore.instance.collection('Users').doc(email).get();
  DateTime dateUpdated = DateTime.parse(doc.get('dateUpdated'));
  int frequencyDays = 0;
  switch (backupFrequencyIdx) {
    case (0):
      frequencyDays = 1;
      break;
    case (1):
      frequencyDays = 7;
      break;
    case (2):
      frequencyDays = 30;
      break;
    case (3):
      frequencyDays = 365;
      break;
  }
  if (DateUtils.dateOnly(dateUpdated.add(Duration(days: frequencyDays)))
          .compareTo(DateUtils.dateOnly(DateTime.now())) <
      1) {
    String readSave =
        await File(externalDir!.path + "/Save.json").readAsString();
    if (doc.get('save') != readSave) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(email)
          .update({'dateUpdated': DateTime.now().toString(), 'save': readSave});
    }
  }
}

List<Book> filterDuplicates(List<Book> books) {
  List<Book> ret = List.empty(growable: true);
  for (Book book in books) {
    bool duplicate = false;
    for (Book ret in ret) {
      if (book.title == ret.title) {
        duplicate = true;
        break;
      }
    }
    if (!duplicate) {
      ret.add(book);
    }
  }
  return ret;
}

TextStyle getCardTextStyle() {
  return const TextStyle(
    letterSpacing: 0.5,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(0.0, 0.0),
        blurRadius: 10.0,
        color: Colors.black,
      ),
      Shadow(
        offset: Offset(0.0, 0.0),
        blurRadius: 10.0,
        color: Colors.black,
      ),
    ],
  );
}

Future<String> getIdOfBook(String query) async {
  http.Response r = await http.get(Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=' +
          query +
          ':&key=AIzaSyDLoyAOZDuFluC26GIEFsEhj1ogF_EnsSQ'));
  Map<String, dynamic> bookResults = jsonDecode(r.body);
  if (bookResults['totalItems'] < 1) return '';
  List<Book> ret = List.empty(growable: true);
  return bookResults['items'][0]['id'];
}

Future<void> updateIdOfBooks() async {
  for (int i = 0; i < data.goals.length; i++) {
    if (data.goals[i].books != null) {
      for (int j = 0; j < data.goals[i].books!.length; j++) {
        if (data.goals[i].books![j].id == '') {
          data.goals[i].books![j].id =
              await getIdOfBook(data.goals[i].books![j].title!);
        }
      }
    }
  }
  writeSave();
}

Future<List<Book>> queryBooks(String query) async {
  http.Response r = await http.get(Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=' +
          query +
          ':&key=AIzaSyDLoyAOZDuFluC26GIEFsEhj1ogF_EnsSQ'));
  // print(r.body);
  //  print('https://www.googleapis.com/books/v1/volumes?q='+query+':&key=AIzaSyDLoyAOZDuFluC26GIEFsEhj1ogF_EnsSQ');
  Map<String, dynamic> bookResults = jsonDecode(r.body);
  if (bookResults['totalItems'] < 1) return List.empty();
  List<Book> ret = List.empty(growable: true);
  List<dynamic> items = bookResults['items'];
  for (Map<String, dynamic> item in items) {
    Map<String, dynamic> volumeInfo = item['volumeInfo'];
    List? cats = volumeInfo['categories'];
    List<String> categories = List.empty(growable: true);
    List? auths = volumeInfo['authors'];
    List<String> authors = List.empty(growable: true);
    if (cats != null) {
      for (var cat in cats) {
        categories.add(cat);
      }
    }
    if (auths != null) {
      for (var auth in auths) {
        authors.add(auth);
      }
    }
    DateTime? datePublished;
    if (volumeInfo['publishedDate'] != null) {
      if (int.tryParse(volumeInfo['publishedDate']) != null) {
        List? date = volumeInfo['publishedDate'].split('-');
        if (date!.length == 3) {
          datePublished = DateTime(
              int.parse(date[0]), int.parse(date[1]), int.parse(date[2]));
        } else if (date.length == 2) {
          datePublished = DateTime(int.parse(date[0]), int.parse(date[1]));
        } else {
          datePublished = DateTime(int.parse(date[0]));
        }
      }
    }
    Book book = Book(
        id: item['id'],
        title: volumeInfo['title'],
        categories: categories,
        authors: authors,
        date: DateTime.now(),
        nOfPages: volumeInfo['pageCount'],
        rating: 5,
        datePublished: datePublished,
        imgUrl: volumeInfo['imageLinks'] == null
            ? ''
            : volumeInfo['imageLinks']['thumbnail']);
    ret.add(book);
  }
  ret = filterDuplicates(ret);
  return ret;
}

DecorationImage getDecorationImage(String imgUrl) {
  DecorationImage decorationImage = const DecorationImage(
    opacity: .5,
    colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
    fit: BoxFit.none,
    image: AssetImage('assets/imgs/logo.png'),
  );
  if (imgUrl != '') {
    decorationImage = DecorationImage(
      fit: BoxFit.cover,
      image: NetworkImage(imgUrl),
    );
  }
  return decorationImage;
}

Drawer getDrawer(BuildContext context) {
  String enabledWidget = context.widget.toString();
  return Drawer(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
    ),
    backgroundColor: Colors.black45,
    child: ListView(
      children: [
        const DrawerHeader(
            child: Opacity(
          opacity: .75,
          child: Image(
            image: AssetImage('assets/imgs/logo.png'),
            fit: BoxFit.scaleDown,
          ),
        )),
        Divider(
          height: 16,
          color: Theme.of(context).primaryColor,
        ),
        ListTile(
          enabled: enabledWidget != "MyHomePage",
          leading: const Icon(Icons.home),
          title: Text(
            "homePage".tr(),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            if (context.widget.toString() != "MyHomePage") {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MyHomePage.init()));
            }
          },
        ),
        ListTile(
          enabled: enabledWidget != "OldGoalsPageSend",
          leading: const Icon(Icons.history),
          title: Text(
            "allGoals".tr(),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            if (context.widget.toString() != "OldGoalsPageSend") {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const OldGoalsPageSend()));
            }
          },
        ),
        ListTile(
          enabled: enabledWidget != "StatsPageSend",
          leading: const Icon(Icons.bar_chart_rounded),
          title: Text(
            "statistics".tr(),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            if (context.widget.toString() != "StatsPageSend") {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StatsPageSend()));
            }
          },
        ),
        ListTile(
          enabled: enabledWidget != "SettingsPageSend",
          leading: const Icon(Icons.settings),
          title: Text(
            "settings".tr(),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            if (context.widget.toString() != "SettingsPageSend") {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPageSend()));
            }
          },
        ),
      ],
    ),
  );
}

List<BottomNavigationBarItem> getNavs() {
  return [
    BottomNavigationBarItem(
      icon: const Icon(Icons.sports_score_rounded),
      label: 'myGoal'.tr(),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.search),
      label: 'search'.tr(),
    ),
    BottomNavigationBarItem(
        icon: const Icon(Icons.library_books), label: "myLibrary".tr())
  ];
}

ReceivePort _port = ReceivePort();
void downloadCallback(
    String id, DownloadTaskStatus status, int progress) async {
  final SendPort? send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

void reviewBook(BuildContext context, Book book) async {
  double rating = 5;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          alignment: Alignment.center,
          title: Text(
            'reviewBook'.tr(),
            textAlign: TextAlign.center,
          ),
          content: RatingBar.builder(
              allowHalfRating: true,
              itemBuilder: ((context, index) => const Icon(
                    Icons.star,
                    color: Colors.yellow,
                  )),
              onRatingUpdate: (rated) => rating = rated),
          actions: [
            ElevatedButton.icon(
                onPressed: () {
                  book.rating = rating;
                  writeSave();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.reviews),
                label: Text('review'.tr()))
          ],
        );
      });
}

Widget getBookReview(Book book) {
  return RatingBar.builder(
      initialRating: book.rating!,
      allowHalfRating: true,
      itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.yellow,
          ),
      onRatingUpdate: (rated) {
        book.rating = rated;
        writeSave();
      });
}
