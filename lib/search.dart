import 'package:book_goals/library.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'book.dart';
import 'book_action_details.dart';
import 'book_details.dart';
import 'helper_functions.dart';
import 'main.dart';

class SearchPageSend extends StatefulWidget {
  String? query;
  SearchPageSend(this.query);
  @override
  State<StatefulWidget> createState() {
    return SearchPage(query);
  }
}

class SearchPage extends State<SearchPageSend> {
  SearchPage(this.query);
  int currentNavIdx = 1;
  String? query;
  TextEditingController tecQuery = TextEditingController(text: '');
  List<Book> booksFound = List.empty(growable: true);
  Future? futureTitles;
  List<String> bookAction = List.empty();
  @override
  void initState() {
    futureTitles = queryBooks(tecQuery.text);
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        tecQuery.text = query ?? '';
        futureTitles = queryBooks(tecQuery.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusNode? focusNode;
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(top: BorderSide(color: Theme.of(context).primaryColor))),
        child: BottomNavigationBar(
          showUnselectedLabels: false,
          currentIndex: currentNavIdx,
          onTap: (int idx) {
            if (currentNavIdx != idx) {
              setState(() {
                // updateNav(idx, currentNavIdx, context);
              });
            }
          },
          items: getNavs(),
        ),
      ),
      appBar: AppBar(
        title: Text('searchBooks'.tr()),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              focusNode: focusNode,
              controller: tecQuery,
              decoration: InputDecoration(
                  labelText: 'enterQueryBook'.tr(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              onChanged: (String? value) {
                setState(() {
                  futureTitles = queryBooks(tecQuery.text);
                });
                query = tecQuery.text;
              },
            ),
          ),
          FutureBuilder(
            future: futureTitles,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                bookAction = List.filled(snapshot.data.length, '');
                return Expanded(
                  child: StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          Book book = snapshot.data[index];
                          if (book.title == null) return Container();
                          return Card(
                            child: Hero(
                              tag: book.id!,
                              child: Container(
                                decoration: BoxDecoration(
                                    image: getDecorationImage(book.imgUrl!),
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  minVerticalPadding: 10,
                                  isThreeLine: true,
                                  title: Text(book.title!),
                                  subtitle: Text(
                                      book.authors!.isNotEmpty == true
                                          ? book.authors!.first
                                          : ''),
                                  onTap: () {
                                    focusNode?.unfocus();
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            transitionDuration:
                                                const Duration(seconds: 1),
                                            pageBuilder: (_, __, ___) =>
                                                BookActionDetailsPageSend(book,
                                                    SearchPageSend(query))));
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: snapshot.data.length,
                      );
                    },
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
      drawer: getDrawer(context),
    );
  }
}
