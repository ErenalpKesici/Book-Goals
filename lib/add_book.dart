import 'dart:math';

import 'package:book_goals/main.dart';
import 'package:book_goals/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'book.dart';
import 'helper_functions.dart';

class AddBookPageSend extends StatefulWidget{
  const AddBookPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddBookPage();
  }
}
class AddBookPage extends State<AddBookPageSend>{
  TextEditingController tecBookName = TextEditingController(text: ''), tecBookNOfPages = TextEditingController(text: '');
  int? rating = 5;
  List<Color> starColors = List.filled(5, Colors.yellow);
  void setStarColors(int idx){
    for(int i=0;i<5;i++){
      if(i <= idx){
        starColors[i] = Colors.yellow;
      }
      else{
        starColors[i] = Colors.grey;
      }
    }
    rating = idx + 1;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a Book as Read"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(labelText: "Book's Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)) ),
                  controller: tecBookName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(labelText: 'Number of Pages', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)) ),
                  controller: tecBookNOfPages,
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            setStarColors(0);
                          });
                      }, color: starColors[0], icon: Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            setStarColors(1);
                          });
                      }, color: starColors[1], icon: Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            setStarColors(2);
                          });
                      }, color: starColors[2], icon: Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            setStarColors(3);
                          });
                      }, color: starColors[3], icon: Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            setStarColors(4);
                          });
                      }, color: starColors[4], icon: Icon(Icons.star),),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(onPressed: () async {
                save.books.add(Book(name: tecBookName.text, nOfPages:  tecBookNOfPages.text!=''?int.parse(tecBookNOfPages.text):0, rating: rating));
                writeSave();
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
              }, icon: const Icon(Icons.task_alt_rounded), label: const Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}