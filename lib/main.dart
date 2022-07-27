import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:book_goals/AuthenticationServices.dart';
import 'package:book_goals/add_book.dart';
import 'package:book_goals/book.dart';
import 'package:book_goals/library.dart';
import 'package:book_goals/library_page.dart';
import 'package:book_goals/search.dart';
import 'package:book_goals/settings.dart';
import 'package:book_goals/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AuthenticationWrapper.dart';
import 'add_goal.dart';
import 'data.dart';
import 'helper_functions.dart';
import 'list_books.dart';
import 'package:confetti/confetti.dart';

Data data = Data.empty();
int bookRequiredForGoal = 0, daysRemaining = -1, booksLeft = -1;
bool update = false;
ConfettiController confettiController =
    ConfettiController(duration: const Duration(seconds: 2));
Users? user;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EasyLocalization(supportedLocales: const [
    Locale('tr'),
    Locale('en'),
  ], path: 'assets/translations', child: const MyApp()));
}

int multiplierInDays(int idx) {
  switch (idx) {
    case (0):
      return 1;
    case (1):
      return 7;
    case (2):
      return 30;
    case (3):
      return 365;
    default:
      return 0;
  }
}

int findBookFrequency() {
  if (data.goals.last.goalBooks! - data.goals.last.books!.length == 0) {
    bookRequiredForGoal = -1;
  } else {
    bookRequiredForGoal = (daysRemaining /
            (data.goals.last.goalBooks! - data.goals.last.books!.length))
        .ceil();
  }
  return bookRequiredForGoal;
}

Book readBook(Map<String, dynamic> book) {
  Book bookToAdd = Book.empty();
  book.forEach((key, value) {
    if (value != 'null') {
      switch (key) {
        case ("id"):
          bookToAdd.id = value;
          break;
        case ("title"):
          bookToAdd.title = value;
          break;
        case ("categories"):
          String catsDecoded =
              value.toString().substring(1, value.toString().length - 1);
          List<String> cats = catsDecoded.split(', ');
          for (String prsn in cats) {
            bookToAdd.categories!.add(prsn);
          }
          break;
        case ("authors"):
          String authsDecoded =
              value.toString().substring(1, value.toString().length - 1);
          List<String> auths = authsDecoded.split(', ');
          for (String auth in auths) {
            bookToAdd.authors!.add(auth);
          }
          break;
        case ("date"):
          bookToAdd.date = DateTime.parse(value);
          break;
        case ("datePublished"):
          if (value != 'null') {
            bookToAdd.datePublished = DateTime.parse(value);
          }
          break;
        case ("nOfPages"):
          bookToAdd.nOfPages = value;
          break;
        case ("rating"):
          bookToAdd.rating = value.toDouble();
          break;
        case ("imgUrl"):
          bookToAdd.imgUrl = value;
          break;
      }
    }
  });
  return bookToAdd;
}

Settings readGoal(Map<String, dynamic> saveRead) {
  Settings currGoal = Settings.empty();
  saveRead.forEach((key, value) {
    if (value != 'null') {
      switch (key) {
        case ("goalBooks"):
          currGoal.goalBooks = int.parse(value);
          break;
        case ("dateStart"):
          currGoal.dateStart = DateTime.parse(value);
          break;
        case ("dateEnd"):
          currGoal.dateEnd = DateTime.parse(value);
          break;
        case ("goalDuration"):
          currGoal.goalDuration = int.parse(value);
          break;
        case ("goalDurationType"):
          currGoal.goalDurationType = value;
          break;
        case ("books"):
          List<dynamic> booksRead = value;
          for (Map<String, dynamic> book in booksRead) {
            currGoal.books!.add(readBook(book));
          }
      }
    }
  });
  return currGoal;
}

Library readLibrary(Map<String, dynamic> saveRead) {
  Library currLib = Library.empty();
  saveRead.forEach((key, value) {
    switch (key) {
      case ("book"):
        currLib.book = readBook(value);
        break;
      case ("message"):
        currLib.message = value;
        break;
    }
  });
  return currLib;
}

Data readData(Map<String, dynamic> saveRead) {
  Data currSave = Data.empty();
  saveRead.forEach((key, value) {
    if (value != 'null') {
      switch (key) {
        case ("goals"):
          List<dynamic> savesRead = value;
          for (dynamic saveRead in savesRead) {
            currSave.goals.add(readGoal(saveRead));
          }
          break;
        case ("libs"):
          List<dynamic> savesRead = value;
          for (dynamic saveRead in savesRead) {
            currSave.libs.add(readLibrary(saveRead));
          }
          break;
      }
    }
  });
  return currSave;
}

Future<void> alertUser(BuildContext context, String title) async {
  SchedulerBinding.instance.addPostFrameCallback((_) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            alignment: Alignment.center,
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Text(
              "pleaseAddGoal".tr(),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    data.goals.add(Settings.empty());
                    writeSave();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyHomePage()));
                  },
                  child: Text("ok".tr()))
            ],
          );
        });
  });
}

Future<bool> readSave(BuildContext context) async {
  if (data.goals.isNotEmpty &&
      data.goals.last.goalBooks! > 0 &&
      data.goals.last.dateEnd != null) {
    if (data.goals.last.dateEnd!.compareTo(DateTime.now()) == -1 &&
        data.goals.last.books!.length < data.goals.last.goalBooks!) {
      await alertUser(
          context,
          "goalDateExpired".tr() +
              ' ' +
              DateFormat('yyyy-MM-dd').format(data.goals.last.dateEnd!));
    } else if ((data.goals.last.books!.length /
                data.goals.last.goalBooks! *
                100)
            .ceil() >
        99) {
      confettiController.play();
      Future.delayed(const Duration(seconds: 2), () {
        confettiController.stop();
      });
      await alertUser(context, "goalReached".tr());
    }
    if (update) {
      update = false;
    } else {
      return true;
    }
  }
  print("READ " + data.toString());
  final externalDir = await getExternalStorageDirectory();
  if (await File(externalDir!.path + '/Save.json').exists() &&
      await File(externalDir.path + "/Save.json").readAsString() != "") {
    //Transfer old save to new version
    if (jsonDecode(await File(externalDir.path + "/Save.json").readAsString())
            .runtimeType
            .toString() ==
        "List<dynamic>") {
      List<dynamic> oldSaveRead = jsonDecode(
          await File(externalDir.path + "/Save.json").readAsString());
      for (dynamic goal in oldSaveRead) {
        data.goals.add(readGoal(goal));
      }
      writeSave();
    } else {
      Map<String, dynamic> saveRead = jsonDecode(
          await File(externalDir.path + "/Save.json").readAsString());
      data = readData(saveRead);
      bookRequiredForGoal = findBookFrequency();
    }
    if (data.goals.last.goalBooks! > 0) await readSave(context);
  } else {
    await File(externalDir.path + '/Save.json').create();
  }
  if (data.goals.isNotEmpty) {
    //IF IT DIDNT GET INSERTED
    if (data.goals
        .any((element) => element.books!.any((element) => element.id == ''))) {
      await updateIdOfBooks();
    }
    return false;
  } else {
    return true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationServices>(
          create: (_) => AuthenticationServices(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationServices>().authStateChanges,
          initialData: null,
        )
      ],
      child: MaterialApp(
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.lightBlue,
            primaryColor: Colors.lightBlue,
            appBarTheme: AppBarTheme(color: Colors.lightBlue[300]),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                type: BottomNavigationBarType.shifting,
                selectedItemColor: Theme.of(context).primaryColor),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              brightness: Brightness.dark,
              secondary: Colors.teal[200],
            )),
        home: const MyHomePage(),
      ),
    );
  }
}

Future<void> alertModifyGoal(BuildContext context, bool dismissable) async {
  TextEditingController? tecGoalBooks = TextEditingController(text: ''),
      tecGoalDuration = TextEditingController(text: '1');
  List<String> durations = getDurations();
  String? goalDurationType = durations.first;
  await showDialog(
      context: context,
      barrierDismissible: dismissable,
      builder: (context) => Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
                  actionsAlignment: MainAxisAlignment.center,
                  alignment: Alignment.center,
                  title: Text(
                    'modifyGoal'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  content: SizedBox(
                    height: MediaQuery.of(context).size.height * .4,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                      hintText: "howManyBooksGoal".tr(),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2,
                                            color: Theme.of(context)
                                                .appBarTheme
                                                .backgroundColor!),
                                        borderRadius: BorderRadius.circular(15),
                                      )),
                                  keyboardType: TextInputType.number,
                                  controller: tecGoalBooks,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // Text(
                          //   "howLongGoal".tr(),
                          //   style: const TextStyle(fontSize: 16),
                          //   textAlign: TextAlign.center,
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        hintText: 'duration'.tr(),
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: Theme.of(context)
                                                  .appBarTheme
                                                  .backgroundColor!),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        )),
                                    keyboardType: TextInputType.number,
                                    controller: tecGoalDuration,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: DropdownButton<String>(
                                    alignment: AlignmentDirectional.center,
                                    value: goalDurationType,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        goalDurationType = newValue;
                                      });
                                    },
                                    items: durations
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                            child: Text('goalFinishBefore'.tr()),
                          ),
                          ElevatedButton.icon(
                              onPressed: () async {
                                if (tecGoalBooks.text == '' ||
                                    tecGoalDuration.text == '') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          backgroundColor:
                                              Theme.of(context).hintColor,
                                          content:
                                              Text('enterAllFields'.tr())));
                                } else {
                                  if (data.goals.isEmpty) {
                                    data.goals.add(Settings.empty());
                                  }
                                  data.goals.last = Settings(
                                      goalBooks: tecGoalBooks.text != ''
                                          ? int.parse(tecGoalBooks.text)
                                          : data.goals.last.goalBooks,
                                      goalDuration: tecGoalDuration.text != ''
                                          ? int.parse(tecGoalDuration.text)
                                          : data.goals.last.goalDuration,
                                      goalDurationType: goalDurationType != ""
                                          ? goalDurationType
                                          : data.goals.last.goalDurationType,
                                      books: data.goals.last.books,
                                      dateStart: DateTime.now(),
                                      dateEnd: DateTime.now().add(Duration(
                                          days: int.parse(tecGoalDuration.text) *
                                              multiplierInDays(durations
                                                  .indexWhere((element) =>
                                                      element ==
                                                      goalDurationType!)))));
                                  writeSave();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const MyHomePage()));
                                }
                              },
                              icon: const Icon(Icons.task_alt_rounded),
                              label: Text("save".tr())),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(children: [
                            const Expanded(
                                child: Divider(
                              thickness: 1,
                            )),
                            Text("or".tr()),
                            const Expanded(
                                child: Divider(
                              thickness: 1,
                            )),
                          ]),
                        ),
                        ElevatedButton.icon(
                            onPressed: () async {
                              runApp(EasyLocalization(
                                  supportedLocales: const [
                                    Locale('tr'),
                                    Locale('en'),
                                  ],
                                  path: 'assets/translations',
                                  child: const MyApp()));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const AuthenticationWrapper()));
                            },
                            icon: const Icon(Icons.import_export),
                            label: Text("restore".tr()))
                      ],
                    ),
                  ],
                );
              },
            ),
          ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentNavIdx = 0;
  @override
  void initState() {
    tryBackup();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      String? lang;
      if ((lang = prefs.getString('lang')) == null) {
        lang = Platform.localeName.split('_')[0];
      }
      if (EasyLocalization.of(context)!.locale != Locale(lang!)) {
        EasyLocalization.of(context)!.setLocale(Locale(lang));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: confettiController,
      numberOfParticles: 100,
      blastDirection: 90,
      blastDirectionality: BlastDirectionality.explosive,
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Theme.of(context).primaryColor))),
          child: BottomNavigationBar(
            showUnselectedLabels: false,
            currentIndex: currentNavIdx,
            onTap: (int idx) {
              if (currentNavIdx != idx) {
                setState(() {
                  updateNav(idx, currentNavIdx, context);
                });
              }
            },
            items: getNavs(),
          ),
        ),
        appBar: AppBar(
          title: Text('app_name'.tr()),
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('abortGoal'.tr()),
                  onTap: () {
                    Future.delayed(
                        const Duration(seconds: 0),
                        () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text(
                                    'confirmAbortGoal'.tr(),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: data.goals.last.goalBooks != 0 &&
                                          data.goals.last.books!.length /
                                                  data.goals.last.goalBooks! ==
                                              0
                                      ? const Text('')
                                      : Text(
                                          'confirmAbortGoal_1'.tr() +
                                              ' ' +
                                              (data.goals.last.books!.length /
                                                      data.goals.last
                                                          .goalBooks! *
                                                      100)
                                                  .ceil()
                                                  .toString() +
                                              '% ' +
                                              'confirmAbortGoal_2'.tr() +
                                              '...',
                                          textAlign: TextAlign.center,
                                        ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('no'.tr())),
                                    ElevatedButton(
                                        onPressed: () {
                                          data.goals.removeLast();
                                          data.goals.add(Settings.empty());
                                          writeSave();
                                          setState(() {});
                                        },
                                        child: Text('yes'.tr()))
                                  ],
                                  actionsAlignment: MainAxisAlignment.center,
                                )));
                  },
                )
              ],
            )
          ],
        ),
        drawer: getDrawer(context),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder(
                  future: readSave(context),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      if ((!snapshot.data && data.goals.last.goalBooks! > 0) ||
                          (data.goals.isNotEmpty &&
                              data.goals.last.goalBooks! > 0)) {
                        daysRemaining = data.goals.last.dateEnd!
                                .difference(DateTime.now())
                                .inDays +
                            1;
                        booksLeft = data.goals.last.goalBooks! -
                            data.goals.last.books!.length;
                        bookRequiredForGoal = findBookFrequency();
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (data.goals.last.books!.isNotEmpty) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ListBookPageSend(
                                                      idx: data.goals.length -
                                                          1)));
                                    }
                                  },
                                  child: Tooltip(
                                    message: data.goals.last.books!.length
                                            .toString() +
                                        "/" +
                                        data.goals.last.goalBooks!.toString(),
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            value:
                                                data.goals.last.books!.length /
                                                    data.goals.last.goalBooks!,
                                          ),
                                        ),
                                        Positioned(
                                            bottom: 10,
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            child: Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 4, 16, 0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          16, 16, 16, 0),
                                                      child: Text(
                                                        "maintext_1".tr(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          0, 24, 0, 16),
                                                      child: Text(
                                                        (data.goals.last.books!
                                                                        .length /
                                                                    data
                                                                        .goals
                                                                        .last
                                                                        .goalBooks! *
                                                                    100)
                                                                .ceil()
                                                                .toString() +
                                                            "%",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            shadows: [
                                                              Shadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          .3),
                                                                  offset:
                                                                      const Offset(
                                                                          5, 4),
                                                                  blurRadius:
                                                                      10)
                                                            ],
                                                            color: Colors.black,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 32),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          16, 16, 16, 0),
                                                      child: Text(
                                                        "maintext_2".tr(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                        Theme.of(context)
                                                            .primaryColor,
                                                        bookRequiredForGoal == 0
                                                            ? Colors.white
                                                            : Color.fromRGBO(
                                                                (1 /
                                                                        bookRequiredForGoal *
                                                                        255)
                                                                    .ceil(),
                                                                127,
                                                                255,
                                                                1)
                                                      ]),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .appBarTheme
                                                          .backgroundColor!),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        spreadRadius: 1,
                                                        offset: Offset(12, 5),
                                                        blurRadius: 5)
                                                  ],
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  shape: BoxShape.circle),
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            if (daysRemaining != -1)
                              ListTile(
                                leading: const Icon(
                                  Icons.date_range_sharp,
                                ),
                                title: Text(
                                  'daysRemaining'.tr() +
                                      ":    " +
                                      daysRemaining.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      wordSpacing: 3, letterSpacing: 1),
                                ),
                              ),
                            if (booksLeft != -1)
                              ListTile(
                                leading: const Icon(
                                  Icons.book,
                                ),
                                title: Text(
                                  'booksLeft'.tr() +
                                      ":    " +
                                      booksLeft.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      wordSpacing: 3, letterSpacing: 1),
                                ),
                              ),
                            if (bookRequiredForGoal != -1)
                              ListTile(
                                  leading: const Icon(Icons.lightbulb),
                                  title: Text(
                                    "goalBookFrequency_1".tr() +
                                        ' ' +
                                        bookRequiredForGoal.toString() +
                                        ' ' +
                                        "goalBookFrequency_2".tr(),
                                    style: const TextStyle(
                                        wordSpacing: 3, letterSpacing: 1),
                                    textAlign: TextAlign.center,
                                  )),
                          ],
                        );
                      } else {
                        SchedulerBinding.instance
                            .addPostFrameCallback((_) async {
                          alertModifyGoal(context, false);
                        });
                      }
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
