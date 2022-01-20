import 'package:book_goals/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class StatsPageSend extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return StatsPage();
  }
}
class StatsPage extends State<StatsPageSend>{
  int totalBooks = 0, totalPages = 0;
  @override
  void initState() {
    for(var goal in data.goals){
      if(goal.books != null){
        totalBooks += goal.books!.length;
        for(var book in goal.books!){
          if(book.nOfPages != null) {
            totalPages += book.nOfPages!;
          }
        }
      }
    }
    for(var lib in data.libs){
      if(lib.book != null){
        if(lib.message == "Read"){
          totalBooks++;
          if(lib.book!.nOfPages != null) {
            totalPages += lib.book!.nOfPages!;
          }
        }
      }
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics"),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(leading: const Text("Total books read"), trailing: Text(totalBooks.toString()),),
          ListTile(leading: const Text("Total pages read"), trailing: Text(totalPages.toString()),)
        ],
      ),
    );
  }
}