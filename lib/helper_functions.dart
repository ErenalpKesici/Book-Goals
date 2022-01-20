import 'dart:convert';
import 'dart:io';

import 'package:book_goals/preferences.dart';
import 'package:book_goals/search.dart';
import 'package:book_goals/settings_page.dart';
import 'package:book_goals/stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'backup_restore.dart';
import 'book.dart';
import 'library_page.dart';
import 'main.dart';
import 'old_goals.dart';

void writeSave() async{
  final externalDir = await getExternalStorageDirectory();
  await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(data));
}

void tryBackup() async{
  final externalDir = await getExternalStorageDirectory();
  if(await File(externalDir!.path+"/Preferences.json").exists()){
    String readPref = await File(externalDir.path+"/Preferences.json").readAsString();
    pref = Preferences.empty();
    Map<String, dynamic> prefs = jsonDecode(readPref);
    prefs.forEach((key, value) {
      switch(key){
        case('user'):
          pref!.user = value;
          break;
        case('backupFrequency'):
          pref!.backupFrequency = value;
          break;
      }
    });
    var doc = await FirebaseFirestore.instance.collection('Users').doc(pref!.user).get();
    DateTime dateUpdated = DateTime.parse(doc.get('dateUpdated'));
    int frequencyDays = 0;
    switch(pref!.backupFrequency){
      case('Day'):
        frequencyDays = 1;
        break;
      case('Week'):
        frequencyDays = 7;
        break;
      case('Month'):
        frequencyDays = 30;
        break;
    }
    if(DateUtils.dateOnly(dateUpdated.add(Duration(days: frequencyDays))).compareTo(DateUtils.dateOnly(DateTime.now())) < 1){
      String readSave = await File(externalDir.path+"/Save.json").readAsString();
      if(doc.get('save') != readSave) {
        FirebaseFirestore.instance.collection('Users').doc(pref!.user).update({'dateUpdated': DateTime.now().toString(), 'save': readSave});
      }
    }
  }
}
List<Book> filterDuplicates(List<Book> books){
  List<Book> ret = List.empty(growable: true);
  for(Book book in books){
    bool duplicate = false;
    for(Book ret in ret) {
      if(book.title == ret.title) {
        duplicate = true;
        break;
      }
    }
    if(!duplicate){
      ret.add(book);
    }
  }
  return ret;
}
Future<List<Book>> getTitles(String query)async{ 
  Response r = await get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q='+query+':&key=AIzaSyDLoyAOZDuFluC26GIEFsEhj1ogF_EnsSQ'));
  //  print('https://www.googleapis.com/books/v1/volumes?q='+query+':&key=AIzaSyDLoyAOZDuFluC26GIEFsEhj1ogF_EnsSQ');
  Map<String, dynamic> bookResults =  jsonDecode(r.body);
  if(bookResults['totalItems'] < 1)return List.empty();
  List<Book> ret = List.empty(growable: true);
  List<dynamic> items = bookResults['items'];
  for(Map<String, dynamic> item in items){
    Map<String, dynamic> volumeInfo = item['volumeInfo'];
    List? cats = volumeInfo['categories'];
    List<String> categories = List.empty(growable: true);
    List? auths = volumeInfo['authors'];
    List<String> authors = List.empty(growable: true);
    if(cats != null){
      for(var cat in cats){
        categories.add(cat);
      }
    }
    if(auths != null){
      for(var auth in auths){
        authors.add(auth);
      }
    }
    DateTime? datePublished;
    if(volumeInfo['publishedDate'] != null){
      if(int.tryParse(volumeInfo['publishedDate']) != null){
        List? date = volumeInfo['publishedDate'].split('-');
        if(date!.length == 3) {
          datePublished = DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]));
        } 
        else if(date.length == 2){
          datePublished = DateTime(int.parse(date[0]), int.parse(date[1]));
        }
        else {
          datePublished = DateTime(int.parse(date[0]));
        }
      }
    }
    Book book = Book(id: item['id'], title: volumeInfo['title'], categories: categories, authors: authors, date: DateTime.now(), nOfPages: volumeInfo['pageCount'], rating: 5, datePublished: datePublished, imgUrl: volumeInfo['imageLinks']==null?'':volumeInfo['imageLinks']['thumbnail']);
      ret.add(book);
  }
  ret = filterDuplicates(ret);
  return ret;
}
Drawer getDrawer(BuildContext context){
  return Drawer(
    child: ListView(
      children: [
        const DrawerHeader(
            child: Image(image: AssetImage('assets/logo.png'),
            fit: BoxFit.fitHeight,
          )
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("Home Page", textAlign: TextAlign.center,),
          onTap: (){
            if(context.widget.toString() != "MyHomePage"){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>const MyHomePage()));
            }
            else {
              Navigator.of(context).pop();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.library_books),
          title: const Text("Library", textAlign: TextAlign.center,),
          onTap: (){
            if(context.widget.toString() != "LibraryPageSend"){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>LibraryPageSend()));
            }
            else {
              Navigator.of(context).pop();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text("Previous Goals", textAlign: TextAlign.center,),
          onTap: (){
            if(context.widget.toString() != "OldGoalsPageSend"){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>const OldGoalsPageSend()));
            }
            else {
              Navigator.of(context).pop();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart_rounded),
          title: const Text("Statistics", textAlign: TextAlign.center,),
          onTap: (){
            if(context.widget.toString() != "StatsPageSend"){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>StatsPageSend()));
            }
            else {
              Navigator.of(context).pop();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("Settings", textAlign: TextAlign.center,),
          onTap: (){
            if(context.widget.toString() != "SettingsPageSend"){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>SettingsPageSend()));
            }
            else {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    ),
  );
}
List<BottomNavigationBarItem> getNavs(){
  return const [
    BottomNavigationBarItem(
      icon: Icon(Icons.sports_score_rounded),
      label: 'Goals',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    )];
}
void updateNav(int idx, currentNavIdx, BuildContext context){
  switch(idx){
    case(0):
      currentNavIdx = 0;
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
      break;
    case(1):
      currentNavIdx = 1;
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SearchPageSend()));
      break;
  }
}