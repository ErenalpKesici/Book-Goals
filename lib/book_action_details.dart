import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/library_page.dart';
import 'package:book_goals/list_books.dart';
import 'package:book_goals/main.dart';
import 'package:book_goals/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import 'book.dart';
import 'library.dart';

class BookActionDetailsPageSend extends StatefulWidget {
  final Book book;
  final Widget sender;
  BookActionDetailsPageSend(this.book, this.sender);

  @override
  State<StatefulWidget> createState() {
    return BookActionDetailsPage(book, sender);
  }
}

class BookActionDetailsPage extends State<BookActionDetailsPageSend> {
  final Book book;
  final Widget sender;
  int btnSelected = -1;
  int? idx;
  List<String> actions = ["Reading", "Want to Read", "Read", "Just Read"];
  List<String> actionsTranslated = [
    "reading".tr(),
    "wantToRead".tr(),
    "read".tr(),
    "justRead".tr()
  ];
  BookActionDetailsPage(this.book, this.sender);
  @override
  void initState() {
    idx = data.libs.indexWhere((element) => element.book!.id == book.id);
    if (idx != -1) {
      btnSelected =
          actions.indexWhere((element) => element == data.libs[idx!].message);
    } else if (data.goals.any(
        (element) => element.books!.any((element) => element.id == book.id))) {
      btnSelected = 2;
    }
    super.initState();
  }

  void updateLibs(String message) {
    if (btnSelected != -1) {
      if (idx == null || idx == -1) {
        if (message == 'Just Read' &&
            data.goals.last.dateEnd != null &&
            DateTime.now().compareTo(data.goals.last.dateEnd!) < 1 &&
            !data.goals.last.books!.any((element) => element.id == book.id)) {
          data.goals.last.books!.add(book);
        } else {
          data.libs.add(Library(book: book, message: message));
        }
      } else {
        data.libs.removeAt(idx!);
        if (message == 'Just Read' &&
            data.goals.last.dateEnd != null &&
            DateTime.now().compareTo(data.goals.last.dateEnd!) < 1 &&
            !data.goals.last.books!.any((element) => element.id == book.id)) {
          data.goals.last.books!.add(book);
        } else {
          data.libs.add(Library(book: book, message: message));
        }
      }
    }
    writeSave();
  }

  @override
  Widget build(BuildContext context) {
    print(book.date);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => sender));
        return false;
      },
      child: Hero(
        tag: book.id!,
        child: Scaffold(
          appBar: AppBar(
            title: Text(book.title!),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (book.imgUrl != '')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(book.imgUrl!),
                    ),
                  if (sender.runtimeType != ListBookPageSend)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            onPressed: btnSelected != 0
                                ? () {
                                    setState(() {
                                      btnSelected = 0;
                                    });
                                    updateLibs(actions[0]);
                                  }
                                : null,
                            icon: const Icon(Icons.timelapse_rounded),
                            label: Text(actionsTranslated[0])),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton.icon(
                            onPressed: btnSelected != 1
                                ? () {
                                    setState(() {
                                      btnSelected = 1;
                                    });
                                    updateLibs(actions[1]);
                                  }
                                : null,
                            icon: const Icon(Icons.bookmarks_rounded),
                            label: Text(actionsTranslated[1])),
                      ],
                    ),
                  if (sender.runtimeType != ListBookPageSend)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            onPressed: btnSelected != 2
                                ? () {
                                    setState(() {
                                      btnSelected = 2;
                                    });
                                    updateLibs(actions[2]);
                                  }
                                : null,
                            icon: const Icon(Icons.done_rounded),
                            label: Text(actionsTranslated[2])),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton.icon(
                            onPressed: btnSelected != 3
                                ? () {
                                    setState(() {
                                      btnSelected = 3;
                                    });
                                    updateLibs(actions[3]);
                                  }
                                : null,
                            icon: const Icon(Icons.done_outline),
                            label: Text(actionsTranslated[3])),
                      ],
                    ),
                  btnSelected != -1 && btnSelected != 1
                      ? getBookReview(book)
                      : Container(),
                  ListTile(
                    leading: const Icon(Icons.title),
                    title: Text(
                      book.title!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (book.authors!.isNotEmpty && book.authors![0] != '')
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: Text(
                        book.authors!
                            .toString()
                            .substring(1, book.authors!.toString().length - 1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (book.categories!.isNotEmpty && book.categories![0] != '')
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: Text(
                        book.categories!.toString().substring(
                            1, book.categories!.toString().length - 1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (book.datePublished != null)
                    ListTile(
                      leading: const Icon(Icons.date_range),
                      title: Text(
                        DateFormat('yyyy-MM-dd')
                            .format(book.datePublished!)
                            .toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (book.nOfPages != null)
                    ListTile(
                      leading: const Icon(Icons.pages),
                      title: Text(
                        book.nOfPages!.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
