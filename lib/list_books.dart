import 'package:book_goals/book_action_details.dart';
import 'package:book_goals/book_details.dart';
import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'book.dart';

class ListBookPageSend extends StatefulWidget {
  final int? idx;
  ListBookPageSend({Key? key, this.idx}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListBookPage(this.idx);
  }
}

class ListBookPage extends State<ListBookPageSend> {
  int? idx;
  List<bool> tileSelected = List.empty();
  ListBookPage(this.idx);
  @override
  void initState() {
    tileSelected = List.filled(data.goals[idx!].books!.length, false);
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
      child: Scaffold(
        appBar: AppBar(
          title: Text("readForGoal".tr()),
          actions: [
            if (tileSelected.any((element) => element))
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () {
                      setState(() {
                        tileSelected = List.filled(
                            data.goals[idx!].books!.length,
                            tileSelected.every((element) => element)
                                ? false
                                : true);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      return await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("confirm".tr()),
                              content: Text("confirmDeleteBook".tr()),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("no".tr()),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          List<Book> newBooks =
                                              List.empty(growable: true);
                                          for (int i = 0;
                                              i <
                                                  data.goals[idx!].books!
                                                      .length;
                                              i++) {
                                            if (!tileSelected[i]) {
                                              newBooks.add(
                                                  data.goals[idx!].books![i]);
                                            }
                                          }
                                          setState(() {
                                            data.goals[idx!].books = newBooks;
                                          });
                                          writeSave();
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MyHomePage()));
                                        },
                                        child: Text("yes".tr())),
                                  ],
                                )
                              ],
                            );
                          });
                    },
                  ),
                ],
              )
          ],
        ),
        body: ListView.builder(
            itemCount: data.goals[idx!].books!.length,
            itemBuilder: (builder, innerIdx) {
              return SizedBox(
                  height: 100,
                  child: Card(
                    elevation: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          image: getDecorationImage(
                              data.goals[idx!].books![innerIdx].imgUrl!),
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(
                          data.goals[idx!].books![innerIdx].title!,
                          style: getCardTextStyle(),
                        ),
                        subtitle: Text(data.goals[idx!].books![innerIdx]
                                .authors!.isNotEmpty
                            ? data.goals[idx!].books![innerIdx].authors!.first
                            : ''),
                        isThreeLine: true,
                        selected: tileSelected[innerIdx],
                        onTap: () {
                          if (tileSelected.any((element) => element)) {
                            setState(() {
                              tileSelected[innerIdx] =
                                  tileSelected[innerIdx] ? false : true;
                            });
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BookActionDetailsPageSend(
                                    data.goals[idx!].books![innerIdx],
                                    ListBookPageSend(idx: idx))));
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            tileSelected[innerIdx] =
                                tileSelected[innerIdx] ? false : true;
                          });
                        },
                      ),
                    ),
                  ));
            }),
      ),
    );
  }
}
