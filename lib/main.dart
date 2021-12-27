import 'dart:convert';
import 'dart:io';
import 'package:book_goals/add_book.dart';
import 'package:book_goals/book.dart';
import 'package:book_goals/settings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'add_goal.dart';
import 'helper_functions.dart';
import 'list_books.dart';

Settings save = Settings.empty();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
Future<bool> readSave()async{
  if(save.goalBooks! > 0 || save.books.isNotEmpty) return true;
  final externalDir = await getExternalStorageDirectory();
  if(await File(externalDir!.path +'/Save.json').exists() && await File(externalDir.path+"/Save.json").readAsString() != ""){
    Map<String, dynamic> saveRead = jsonDecode(await File(externalDir.path+"/Save.json").readAsString());
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
            save.books.add(Book(name: book.split(' - ')[0], nOfPages: int.parse(book.split(' - ')[1]), rating: int.parse(book.split(' - ')[2])));
          }
          break;
      }
    });
    print(save.toString());
  }
  else{
    await File(externalDir.path +'/Save.json').create();
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
        appBarTheme: AppBarTheme(color: Colors.lightBlue[300])
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Goals'),
        actions: [
          ElevatedButton.icon(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AddGoalPageSend()));
          }, icon: const Icon(Icons.task), label: const Text("Add or Change Goal"))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: readSave(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if(snapshot.hasData && (save.goalBooks! > 0 || save.books.isNotEmpty)){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ListBookPageSend()));
                        },
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 100,height: 100,
                              child: CircularProgressIndicator(
                                value: save.books.length/save.goalBooks!,
                              ),
                            ),
                            Positioned(bottom: 10,left: 10,right: 10,top: 10, 
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(save.books.length.toString()+"/"+save.goalBooks!.toString()+"                   "+(save.books.length/save.goalBooks!*100).toString()+"%", textAlign: TextAlign.center,style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic),),
                                ),
                                decoration: BoxDecoration(color: Colors.white60, shape: BoxShape.circle),)
                              )
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Stack(
                  children: [
                    SizedBox(
                      width: 100,height: 100,
                      child: CircularProgressIndicator(),
                    ),
                    Positioned(bottom: 10,left: 10,right: 10,top: 10, child: Text("Please Enter a Goal"),)
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width/3,
        child: FloatingActionButton(
          isExtended: true,
          child: Row(
            children: const[
              Padding(
                padding: EdgeInsets.all(4.0),
                child: FittedBox(child: Icon(Icons.book_rounded),),
              ),
              Expanded(
                child: Text('Add a Book',),
              ),
            ],
          ),
          onPressed: () async{
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AddBookPageSend()));
            writeSave();
          },
        ),
      ),
    );
  }
}
