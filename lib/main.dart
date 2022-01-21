import 'dart:convert';
import 'dart:io';
import 'package:book_goals/AuthenticationServices.dart';
import 'package:book_goals/add_book.dart';
import 'package:book_goals/book.dart';
import 'package:book_goals/library.dart';
import 'package:book_goals/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'add_goal.dart';
import 'data.dart';
import 'helper_functions.dart';
import 'list_books.dart';

Data data = Data.empty();
int bookRequiredForGoal = 0;
bool update = false;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
int multiplierInDays(String type){
  switch(type){
    case ("Day(s)"):
      return 1;
    case ("Month(s)"):
      return 30;
    case ("Year(s)"):
      return 365;
    default:
      return 0;
  }
}
int findBookFrequency(){
  int daysTotal = data.goals.last.goalDuration! * multiplierInDays(data.goals.last.goalDurationType!);
  if(data.goals.last.goalBooks! - data.goals.last.books!.length == 0) {
    bookRequiredForGoal = -1;
  } else {
    bookRequiredForGoal = (daysTotal/(data.goals.last.goalBooks! - data.goals.last.books!.length)).ceil();
  }
  return bookRequiredForGoal;
} 
Book readBook(Map<String, dynamic> book){
  Book bookToAdd = Book.empty();
  book.forEach((key, value) {
    if(value != 'null'){
      switch(key){
        case("id"):
          bookToAdd.id = value;
          break;
        case("title"):
          bookToAdd.title = value;
          break;
        case("categories"):
          String catsDecoded = value.toString().substring(1, value.toString().length - 1);
          List<String> cats = catsDecoded.split(', ');
          for(String prsn in cats){
            bookToAdd.categories!.add(prsn);
          }
          break;
        case("authors"):
          String authsDecoded = value.toString().substring(1, value.toString().length - 1);
          List<String> auths = authsDecoded.split(', ');
          for(String auth in auths){
            bookToAdd.authors!.add(auth);
          }
          break;
        case("date"):
          bookToAdd.date = DateTime.parse(value);
          break;
        case("datePublished"):
          if(value != 'null') {
            bookToAdd.datePublished = DateTime.parse(value);
          }
          break;
        case("nOfPages"):
          bookToAdd.nOfPages = value;
          break;
        case("rating"):
          bookToAdd.rating = value;
          break;
        case("imgUrl"):
          bookToAdd.imgUrl = value;
          break;
      }
    }
  });
  return bookToAdd;
}
Settings readGoal(Map<String, dynamic> saveRead){
  Settings currGoal = Settings.empty();
  saveRead.forEach((key, value) {
    if(value !='null') {
      switch(key){
        case("goalBooks"):
          currGoal.goalBooks = int.parse(value);        
          break;
        case("dateStart"):
          currGoal.dateStart = DateTime.parse(value);        
          break;
        case("dateEnd"):
          currGoal.dateEnd = DateTime.parse(value);        
          break;
        case("goalDuration"):
          currGoal.goalDuration= int.parse(value);
          break;
        case("goalDurationType"):
          currGoal.goalDurationType=value;
          break;
        case("books"):
          List<dynamic> booksRead = value;
          for(Map<String, dynamic> book in booksRead){
            
          currGoal.books!.add(readBook(book));
        }
      }
    }
  });
  return currGoal;
}
Library readLibrary(Map<String, dynamic> saveRead){
  Library currLib = Library.empty();
  saveRead.forEach((key, value) {
    switch(key){
      case("book"):
        currLib.book = readBook(value);
        break;
      case("message"):
        currLib.message = value;
        break;
    }
  });
  return currLib;
}
Data readData(Map<String, dynamic> saveRead){
  Data currSave = Data.empty(); 
  saveRead.forEach((key, value) {
    if(value != 'null'){
      switch(key){
        case("goals"):
          List<dynamic> savesRead = value;
          for(dynamic saveRead in savesRead){
            currSave.goals.add(readGoal(saveRead));
          }
          break;
        case("libs"):
          List<dynamic> savesRead = value;
          for(dynamic saveRead in savesRead){
            currSave.libs.add(readLibrary(saveRead));
          }
          break;
      } 
    }
  });
  return currSave;
}  
Future<void> alertUser(BuildContext context, String title)async{
  SchedulerBinding.instance?.addPostFrameCallback((_) async{
    return await showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text(title, textAlign: TextAlign.center,),
        content:  const Text("Would you like to add a new goals?", textAlign: TextAlign.center,),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text("No"),
              ),
              const SizedBox(width: 5,),
              ElevatedButton(
                onPressed: (){
                  data.goals.add(Settings.empty());
                  writeSave();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
                },
                child: const Text("Yes")
              ),
            ],
          )
        ],
      );
    });
  });
}
Future<bool> readSave(BuildContext context)async{
  if(data.goals.isNotEmpty && data.goals.last.goalBooks! > 0 && data.goals.last.dateEnd != null) {
    if(data.goals.last.dateEnd!.compareTo(DateTime.now()) == -1 && data.goals.last.books!.length < data.goals.last.goalBooks!){
      await alertUser(context, "Your goals has expired on " + DateFormat('yyyy-MM-dd').format(data.goals.last.dateEnd!));
    }
    else if((data.goals.last.books!.length/data.goals.last.goalBooks!*100).ceil() > 99){
      await alertUser(context, "You have reached your current goals!");
    }
    if(update){
      update = false;
    }
    else {
      return true;
    }
  }
  print("READ " + data.toString());
  final externalDir = await getExternalStorageDirectory();
  if(await File(externalDir!.path +'/Save.json').exists() && await File(externalDir.path+"/Save.json").readAsString() != ""){
    //Transfer old save to new version
    if(jsonDecode(await File(externalDir.path+"/Save.json").readAsString()).runtimeType.toString() == "List<dynamic>"){
      List<dynamic> oldSaveRead = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
      for(dynamic goal in oldSaveRead){
        data.goals.add(readGoal(goal));
      }
      writeSave();
    }
    else{
      Map<String, dynamic> saveRead = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
      data = readData(saveRead);
      bookRequiredForGoal = findBookFrequency();
    }
    if(data.goals.last.goalBooks! > 0) await readSave(context);
  }
  else{
    await File(externalDir.path +'/Save.json').create();
  }
  if(data.goals.isNotEmpty) {
    //IF ID DIDNT GET INSERTED
    if(data.goals.any((element) => element.books!.any((element) => element.id == ''))){
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
          create: (context) => context.read<AuthenticationServices>().authStateChanges, initialData: null,
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.lightBlue,
          primaryColor: Colors.lightBlue,
          appBarTheme: AppBarTheme(color: Colors.lightBlue[300]),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.blueGrey),
          colorScheme: ColorScheme.fromSwatch().copyWith(brightness: Brightness.dark, secondary: Colors.teal[200],)
        ),
        home: const MyHomePage(),
      ),
    );
  }
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
    if(data.goals.isNotEmpty){
      bookRequiredForGoal = findBookFrequency();
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentNavIdx,
        onTap: (int idx){
          if(currentNavIdx != idx) {
            setState(() {
              updateNav(idx, currentNavIdx, context);
            });
          }
        },
        items: getNavs(),
      ),
      appBar: AppBar(
        title: const Text('Book Goals'),
      ),
      drawer: getDrawer(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                future: readSave(context),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.hasData){
                    if((!snapshot.data && data.goals.last.goalBooks! > 0) || (data.goals.isNotEmpty && data.goals.last.goalBooks! > 0)){
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ListBookPageSend(idx: data.goals.length - 1)));
                                },
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 200, height: 200,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.secondary,
                                        value: data.goals.last.books!.length/data.goals.last.goalBooks!,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10, left: 10, right: 10, top: 10, 
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                                          child: Column(
                                            children: [
                                              Text(data.goals.last.books!.length.toString()+"/"+data.goals.last.goalBooks!.toString(), textAlign: TextAlign.center,style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 24),),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                                child: Text((data.goals.last.books!.length/data.goals.last.goalBooks!*100).ceil().toString()+"%", textAlign: TextAlign.center,style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 24),),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                                child: Text("books read", textAlign: TextAlign.center,style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 16),),
                                              ),
                                            ],
                                          ) ,
                                        ),
                                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),)
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if(bookRequiredForGoal != -1)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text("A book needs to be finished every " + bookRequiredForGoal.toString() + " day(s)."),
                            ),            
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.secondary),
                                icon: const Icon(Icons.book),
                                onPressed: () async{
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AddBookPageSend()));
                                  writeSave();
                                }, label: const Text('Add a Book',),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.sports_score_rounded),
                              label: const Text('Modify the Goal',),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Scaffold(appBar: AppBar(), body: const SingleChildScrollView(child: AddGoalPageSend()))));
                              },
                            ),
                        ],
                      );
                    }
                    else{
                      return const AddGoalPageSend();
                    }
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
