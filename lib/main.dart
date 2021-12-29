import 'dart:convert';
import 'dart:io';
import 'package:book_goals/add_book.dart';
import 'package:book_goals/book.dart';
import 'package:book_goals/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'add_goal.dart';
import 'helper_functions.dart';
import 'list_books.dart';

Settings save = Settings.empty();
final PathProviderWindows provider = PathProviderWindows();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
Future<bool> readSave()async{
  if(save.goalBooks! > 0 || save.books!.isNotEmpty) return true;
  final externalDir = await provider.getApplicationSupportPath();
  print(externalDir);
  if(await File(externalDir! +'/Save.json').exists() && await File(externalDir+"/Save.json").readAsString() != ""){
    Map<String, dynamic> saveRead = jsonDecode(await File(externalDir+"/Save.json").readAsString());
    saveRead.forEach((key, value) {
      switch(key){
        case("goalBooks"):
          save.goalBooks = int.parse(value);        
          break;
        case("goalDuration"):
          save.goalDuration= int.parse(value);
          break;
        case("goalDurationType"):
          save.goalDurationType=value;
          break;
        case("books"):
          var booksRead = json.decode(value);
          for(String book in booksRead){
            save.books!.add(Book(name: book.split(' - ')[0], date: DateTime.parse(book.split(' - ')[1]), nOfPages: int.parse(book.split(' - ')[2]), rating: int.parse(book.split(' - ')[3])));
          }
          break;
      }
    });
    print(save.toString());
  }
  else{
    await File(externalDir +'/Save.json').create();
  }
  return true;
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.lightBlue,
        appBarTheme: AppBarTheme(color: Colors.lightBlue[300]),
        colorScheme: ColorScheme.fromSwatch().copyWith(brightness: Brightness.dark, secondary: Colors.teal[200],)
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int bookRequiredForGoal = 0;
  int _findBookFrequency(){
    int daysTotal = 0;
    switch(save.goalDurationType){
      case ("Day(s)"):
        daysTotal = save.goalDuration!;
        break;
      case ("Month(s)"):
        daysTotal = save.goalDuration! * 30;
        break;
      case ("Year(s)"):
        daysTotal = save.goalDuration! * 365;
        break;
    }
    bookRequiredForGoal = (daysTotal/(save.goalBooks! - save.books!.length)).ceil();
    print(bookRequiredForGoal);
    return bookRequiredForGoal;
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: const Text('Book Goals'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: readSave(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if(snapshot.hasData && (save.goalBooks! > 0 || save.books!.isNotEmpty)){
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ListBookPageSend()));
                            },
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 200,height: 200,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.secondary,
                                    value: save.books!.length/save.goalBooks!,
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,left: 10,right: 10,top: 10, 
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                                      child: Column(
                                        children: [
                                          Text(save.books!.length.toString()+"/"+save.goalBooks!.toString(), textAlign: TextAlign.center,style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 24),),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                            child: Text((save.books!.length/save.goalBooks!*100).ceil().toString()+"%", textAlign: TextAlign.center,style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 24),),
                                          ),
                                           Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                            child: Text("books read", textAlign: TextAlign.center,style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontSize: 16),),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("A book needs to be finished every " + _findBookFrequency().toString() + " day(s)."),
                      )
                    ],
                  );
                }
                return GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AddGoalPageSend()));
                  },
                  child: Stack(
                    children: const [
                      SizedBox(
                        width: 100,height: 100,
                        child: LinearProgressIndicator(),
                      ),
                      Positioned(bottom: 10,left: 10,right: 10,top: 10, child: Text("Please Enter a Goal"),)
                    ],
                  ),
                );
              },
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AddGoalPageSend()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
