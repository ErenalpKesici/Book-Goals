import 'dart:convert';
import 'dart:math';

import 'package:book_goals/main.dart';
import 'package:book_goals/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'helper_functions.dart';
import 'book.dart';

class AddBookPageSend extends StatefulWidget{
  const AddBookPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddBookPage();
  }
}
class AddBookPage extends State<AddBookPageSend>{
  TextEditingController tecBookNOfPages = TextEditingController(text: '');
  int? rating = 5;
  List<Color> starColors = List.filled(5, Colors.yellow);
  Book bookSelected = Book.empty();
  List<Book>? books;
  
  Widget getStars(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 128, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: IconButton(
              onPressed: (){
                setState(() {
                  setStarColors(0);
                });
            }, color: starColors[0], icon: const Icon(Icons.star),),
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
    );
  }
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
                child: Autocomplete<String>(
                  onSelected: (String selected){
                    bookSelected = books!.firstWhere(((element) => element.title==selected));
                  },
                  fieldViewBuilder: (BuildContext context,TextEditingController textEditingController,FocusNode focusNode,VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(labelText: 'Book Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)) ),
                      onFieldSubmitted: (String value) {
                        focusNode.unfocus();
                      },
                    );
                  },
                optionsBuilder: (TextEditingValue textEditingValue) async{
                  bookSelected.title = textEditingValue.text;
                  books = await getTitles(textEditingValue.text);
                  if(books!.isNotEmpty){
                    List<String> ret = List.empty(growable: true);
                    for(Book book in books!){
                      ret.add(book.title!);
                    }
                    return ret;
                  }
                  return const Iterable.empty();
                  },
                )
              ),
              getStars(),
              SizedBox(height: MediaQuery.of(context).size.height/10,),
              ElevatedButton.icon(onPressed: () async {
                if(bookSelected.title == ''){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Theme.of(context).hintColor, content: const Text('Please enter the title of the book.')));
                }
                else{
                  bookSelected.rating = rating;
                  data.goals.last.books!.add(bookSelected);
                  print(bookSelected.toString());
                  writeSave();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
                }
              }, icon: const Icon(Icons.task_alt_rounded), label: const Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}