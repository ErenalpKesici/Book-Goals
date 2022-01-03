import 'dart:convert';
import 'dart:io';
import 'package:book_goals/AuthenticationServices.dart';
import 'package:book_goals/add_book.dart';
import 'package:book_goals/book.dart';
import 'package:book_goals/settings.dart';
import 'package:book_goals/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'add_goal.dart';
import 'helper_functions.dart';
import 'list_books.dart';
import 'old_goals.dart';

List<Settings> save = List.empty(growable: true);
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
int _findBookFrequency(){
  int daysTotal = save.last.goalDuration! * multiplierInDays(save.last.goalDurationType!);
  if(save.last.goalBooks! - save.last.books!.length == 0) {
    bookRequiredForGoal = -1;
  } else {
    bookRequiredForGoal = (daysTotal/(save.last.goalBooks! - save.last.books!.length)).ceil();
  }
  return bookRequiredForGoal;
  } 
Settings readForEach(Map<String, dynamic> saveRead){
  Settings currSave = Settings.empty();
  saveRead.forEach((key, value) {
    if(value != 'null'){
      switch(key){
        case("goalBooks"):
          currSave.goalBooks = int.parse(value);        
          break;
        case("dateStart"):
          currSave.dateStart = DateTime.parse(value);        
          break;
        case("dateEnd"):
          currSave.dateEnd = DateTime.parse(value);        
          break;
        case("goalDuration"):
          currSave.goalDuration= int.parse(value);
          break;
        case("goalDurationType"):
          currSave.goalDurationType=value;
          break;
        case("books"):
          List<dynamic> booksRead = value;
          for(Map<String, dynamic> book in booksRead){
            Book bookToAdd = Book.empty();
            book.forEach((key, value) {
              switch(key){
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
            });
          currSave.books!.add(bookToAdd);
        }
      }
    }
  });
  return currSave;
}  
Future<bool> readSave(BuildContext context)async{
  if(save.isNotEmpty) {
    if(save.last.goalBooks! > 0 && (save.last.books!.length/save.last.goalBooks!*100).ceil() > 99){
      SchedulerBinding.instance?.addPostFrameCallback((_) async{
        return await showDialog(context: context, builder: (context){
          return AlertDialog(
            title: const Text("You have reached your current goal!", textAlign: TextAlign.center,),
            content: const Text("Would you like to add a new goal?", textAlign: TextAlign.center,),
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
                      save.add(Settings.empty());
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
    if(update){
      update = false;
    }
    else {
      return true;
    }
  }
  print("READ " + save.toString());
  final externalDir = await getExternalStorageDirectory();
  if(await File(externalDir!.path +'/Save.json').exists() && await File(externalDir.path+"/Save.json").readAsString() != ""){
    print(await File(externalDir.path+"/Save.json").readAsString());
      //Old version save merge:
    if(jsonDecode(await File(externalDir.path+"/Save.json").readAsString()).runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>'){
      Map<String, dynamic> saveRead = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
      save.add(readForEach(saveRead));
      writeSave();
    }
    else{
      List<dynamic> savesRead = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
      for(dynamic saveRead in savesRead){
        save.add(readForEach(saveRead));
      }
    }
    bookRequiredForGoal = _findBookFrequency();
    print(save.length);
    print(save.toString());
    if(save.last.goalBooks! > 0 && (save.last.books!.length/save.last.goalBooks!*100).ceil() > 99)await readSave(context);
  }
  else{
    await File(externalDir.path +'/Save.json').create();
  }
  if(save.isNotEmpty)
  return false;
  else
  return true;
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
          appBarTheme: AppBarTheme(color: Colors.lightBlue[300]),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Goals'),
        actions: [
          if(save.isNotEmpty && save.last.goalBooks! < 1)
            ElevatedButton.icon(
              onPressed: (){
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel),
              label: Text('Cancel adding goal'),
            ),
        ],
      ),
      drawer: Drawer(
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>MyHomePage()));
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>OldGoalsPageSend()));
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
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder(
                future: readSave(context),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.hasData){
                    if((!snapshot.data && save.last.goalBooks! > 0) || (save.isNotEmpty && save.last.goalBooks! > 0)){
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ListBookPageSend(idx: save.length - 1)));
                                },
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 200, height: 200,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.secondary,
                                        value: save.last.books!.length/save.last.goalBooks!,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10, left: 10, right: 10, top: 10, 
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                                          child: Column(
                                            children: [
                                              Text(save.last.books!.length.toString()+"/"+save.last.goalBooks!.toString(), textAlign: TextAlign.center,style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 24),),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                                child: Text((save.last.books!.length/save.last.goalBooks!*100).ceil().toString()+"%", textAlign: TextAlign.center,style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 24),),
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
                              padding: const EdgeInsets.all(8.0),
                              child: Text("A book needs to be finished every " + bookRequiredForGoal.toString() + " day(s)."),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height/8,),            
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.secondary),
                              icon: const Icon(Icons.book),
                              onPressed: () async{
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AddBookPageSend()));
                                writeSave();
                              }, label: const Text('Add a Book',),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height/15,),
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
                      return AddGoalPageSend();
                    }
                  }
                  return Stack(
                    children: const [
                      SizedBox(
                        width: 100,height: 100,
                        child: LinearProgressIndicator(),
                      ),
                      Positioned(bottom: 10,left: 10,right: 10,top: 10, child: Text("Please Enter Goal and books.", textAlign: TextAlign.center,),)
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
