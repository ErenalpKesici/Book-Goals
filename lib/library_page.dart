import 'dart:math';

import 'package:book_goals/helper_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'book.dart';
import 'book_action_details.dart';
import 'library.dart';
import 'main.dart';

class LibraryPageSend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LibraryPage();
  }
}

class LibraryPage extends State<LibraryPageSend> {
  List<Book> goalBooks = List.empty(growable: true);
  ScrollController mainScrollController = ScrollController();
  int currentNavIdx = 2;

  Widget getList(String message) {
    int length = data.libs.length;
    length += (message == '' || message == 'Read') && goalBooks.isNotEmpty
        ? goalBooks.length
        : 0;
    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        controller: mainScrollController,
        itemCount: length,
        reverse: true,
        itemBuilder: (BuildContext context, int idx) {
          if (idx < data.libs.length) {
            if (message == "" ||
                idx < data.libs.length && data.libs[idx].message == message) {
              return getCard(idx, data.libs[idx].book!);
            }
          } else {
            return getCard(idx, goalBooks[idx - data.libs.length]);
          }
          return Container();
        },
      ),
    );
  }

  Widget getReadForGoals() {
    if (goalBooks.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
          controller: mainScrollController,
          itemCount: goalBooks.length,
          itemBuilder: (BuildContext context, int idx) {
            int reverseIdx = goalBooks.length - 1 - idx;
            return getCard(reverseIdx, goalBooks[reverseIdx]);
          },
        ),
      );
    }
    return Expanded(
      child: Container(),
    );
  }

  Card getCard(int idx, Book book) {
    return Card(
      child: Hero(
        tag: book.id!,
        child: Material(
          child: Container(
            decoration: BoxDecoration(
                image: getDecorationImage(book.imgUrl!),
                borderRadius: BorderRadius.circular(10)),
            child: Slidable(
              startActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (BuildContext context) {
                      setState(() {
                        if (idx < data.libs.length) {
                          data.libs.removeAt(idx);
                        } else {
                          for (var element in data.goals) {
                            element.books?.removeWhere((element) =>
                                element == goalBooks[idx - data.libs.length]);
                          }
                          goalBooks.removeAt(idx - data.libs.length);
                        }
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
                subtitle: Text(
                    book.authors!.isNotEmpty == true ? book.authors!.first : '',
                    style: getCardTextStyle()),
                onTap: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          transitionDuration: const Duration(seconds: 1),
                          pageBuilder: (_, __, ___) =>
                              BookActionDetailsPageSend(
                                  book, LibraryPageSend())));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    for (var goal in data.goals) {
      if (goal.books != null) {
        for (var book in goal.books!) {
          goalBooks.add(book);
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const MyHomePage()));
        return false;
      },
      child: DefaultTabController(
        length: 4,
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
            title: Text("myLibrary".tr()),
            bottom: TabBar(
              tabs: [
                Tab(
                    icon: Icon(Icons.grid_on),
                    child: Text(
                      "all".tr(),
                      textAlign: TextAlign.center,
                    )),
                Tab(
                    icon: Icon(Icons.timelapse_rounded),
                    child: Text(
                      "reading".tr(),
                      textAlign: TextAlign.center,
                    )),
                Tab(
                    icon: Icon(Icons.bookmarks_rounded),
                    child: Text(
                      "wantToRead".tr(),
                      textAlign: TextAlign.center,
                    )),
                Tab(
                    icon: Icon(Icons.done_rounded),
                    child: Text(
                      "read".tr(),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
          body: Column(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        children: [
                          getList(""),
                          getList("Reading"),
                          getList("Want to Read"),
                          getList("Read"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
