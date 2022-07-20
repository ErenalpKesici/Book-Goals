import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'book.dart';

class OldGoalDetailsPageSend extends StatefulWidget {
  final String dates;
  final List<Book> books;
  const OldGoalDetailsPageSend(this.dates, this.books);

  @override
  State<StatefulWidget> createState() {
    return OldGoalDetailsPage(dates, books);
  }
}

class OldGoalDetailsPage extends State<OldGoalDetailsPageSend> {
  final String dates;
  final List<Book> books;
  OldGoalDetailsPage(this.dates, this.books);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dates + ' | ' + 'goal'.tr())),
      body: ListView.builder(
          itemCount: books.length,
          itemBuilder: ((context, index) => Card(
                elevation: 1,
                child: ListTile(
                  leading: (books[index].imgUrl != '')
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(books[index].imgUrl!),
                        )
                      : null,
                  title: Text(books[index].title!),
                  subtitle: Text('finished'.tr() +
                      ': ' +
                      DateFormat('yyyy-MM-dd').format(books[index].date!)),
                ),
              ))),
    );
  }
}
