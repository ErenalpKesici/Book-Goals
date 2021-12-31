import 'dart:convert';
import 'dart:math';

import 'package:book_goals/main.dart';
import 'package:book_goals/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

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
  TextEditingController tecBookNOfPages = TextEditingController(text: '');
  int? rating = 5;
  List<Color> starColors = List.filled(5, Colors.yellow);
  Book bookSelected = Book.empty();
  List<Book>? books;
  Future<List<Book>> _getTitles(String query)async{ 
    Response r = await get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=title:'+query+':&key=AIzaSyDLoyAOZDuFluC26GIEFsEhj1ogF_EnsSQ'));
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
      DateTime datePublished = DateTime.now();
      if(volumeInfo['publishedDate'] != null && !volumeInfo['publishedDate'].toString().contains('?')){
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
      Book book = Book(title: volumeInfo['title'], categories: categories, authors: authors, date: DateTime.now(), nOfPages: volumeInfo['pageCount'], rating: 5, datePublished: datePublished);
       ret.add(book);
    }
    return ret;
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
                  if(textEditingValue.text == 'a')Focus.maybeOf(context)?.unfocus();
                  bookSelected.title = textEditingValue.text;
                  books = await _getTitles(textEditingValue.text);
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
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     decoration: InputDecoration(labelText: 'Number of Pages', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)) ),
              //     controller: tecBookNOfPages,
              //     keyboardType: TextInputType.number,
              //   ),
              // ),
              Padding(
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
              ),
              SizedBox(height: MediaQuery.of(context).size.height/10,),
              ElevatedButton.icon(onPressed: () async {
                bookSelected.rating = rating;
                save.books!.add(bookSelected);
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