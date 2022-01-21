import 'dart:math';

import 'package:book_goals/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'book.dart';
import 'book_action_details.dart';
import 'main.dart';

class LibraryPageSend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LibraryPage();
  }
}
class LibraryPage extends State<LibraryPageSend>{
  List<Book> goalBooks = List.empty(growable: true);
  ScrollController mainScrollController = ScrollController();
  Card getCard(int idx, Book book){
    return Card(
      child: Container(
        decoration: BoxDecoration(
          image: getDecorationImage(book.imgUrl!)
        ),
        child: Slidable(
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
               SlidableAction(
                onPressed: (BuildContext context){
                  setState(() {
                    data.libs.removeAt(idx);
                  });
                  writeSave();
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            minVerticalPadding: 10,
            isThreeLine: true,
            title: Text(book.title!, style: getCardTextStyle()),
            subtitle: Text(book.authors!.isNotEmpty==true?book.authors!.first:'', style: getCardTextStyle()),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BookActionDetailsPageSend(book)));
            },
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    for(var goal in data.goals){
      if(goal.books!=null){
        for(var book in goal.books!){
          goalBooks.add(book);
        }
      }
    }
    super.initState();
  }
  Widget getReadForGoals(){
    return 
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          controller: mainScrollController,
          itemCount: goalBooks.length,
          itemBuilder: (BuildContext context, int idx){
            return getCard(idx, goalBooks[idx]);
          },
        ),
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Library"),),
      body: Column(
        children: [
          DefaultTabController(
            length: 4,
            child: Flexible(
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on), child: FittedBox(child: Text("All"))),
                      Tab(icon: Icon(Icons.timelapse_rounded), child: FittedBox(child: Text("Reading"))),
                      Tab(icon: Icon(Icons.bookmarks_rounded), child: FittedBox(child: Text("Want to read"))),
                      Tab(icon: Icon(Icons.done_rounded), child: FittedBox(child: Text("Read"))),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          controller: mainScrollController,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: mainScrollController,
                                  itemCount: data.libs.length,
                                  itemBuilder: (BuildContext context, int idx){
                                    return getCard(idx, data.libs[idx].book!);
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Books read for set goals:"),
                              ),
                              getReadForGoals()
                            ],
                          ),
                        ),
                        ListView.builder(
                          itemCount: data.libs.length,
                          itemBuilder: (BuildContext context, int idx){
                            if(data.libs[idx].message == "Reading") {
                              return getCard(idx, data.libs[idx].book!);
                            }
                            return Container();
                          },
                        ),
                        ListView.builder(
                          itemCount: data.libs.length,
                          itemBuilder: (BuildContext context, int idx){
                            if(data.libs[idx].message == "Want to read") {
                              return getCard(idx, data.libs[idx].book!);
                            }
                            return Container();
                          },
                        ),
                        SingleChildScrollView(
                          controller: mainScrollController,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: mainScrollController,
                                  itemCount: data.libs.length,
                                  itemBuilder: (BuildContext context, int idx){
                                    if(data.libs[idx].message == "Read") {
                                      return getCard(idx, data.libs[idx].book!);
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Books read for set goals:"),
                              ),
                              getReadForGoals()
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}