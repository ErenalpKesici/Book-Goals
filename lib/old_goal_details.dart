import 'package:book_goals/book_action_details.dart';
import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/main.dart';
import 'package:book_goals/old_goals.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'book.dart';

class OldGoalDetailsPageSend extends StatefulWidget {
  final String dates;
  final List<Book> books;
  final int required, finished;
  const OldGoalDetailsPageSend(
      this.dates, this.books, this.required, this.finished);

  @override
  State<StatefulWidget> createState() {
    return OldGoalDetailsPage(dates, books, required, finished);
  }
}

class OldGoalDetailsPage extends State<OldGoalDetailsPageSend> {
  final String dates;
  final List<Book> books;
  final int required, finished;
  OldGoalDetailsPage(this.dates, this.books, this.required, this.finished);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => OldGoalsPageSend()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(dates + ' ' + 'goal'.tr())),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: [
              ListTile(
                trailing:
                    Text(finished.toString() + " / " + required.toString()),
                leading: Icon(Icons.sports_score_rounded),
                title: Text(
                  'goalStatus'.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
              Card(
                elevation: 1,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: books.length,
                    itemBuilder: ((context, index) => ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BookActionDetailsPageSend(
                                    books[index],
                                    OldGoalDetailsPageSend(
                                        dates, books, required, finished))));
                          },
                          leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (books[index].imgUrl != '')
                                  ? Image.network(
                                      books[index].imgUrl!,
                                      width: 36,
                                    )
                                  : Opacity(
                                      opacity: .75,
                                      child: Image.asset(
                                        'assets/imgs/logo.png',
                                        width: 36,
                                      ),
                                    )),
                          title: Text(books[index].title!),
                          subtitle: Text('finishedDate'.tr() +
                              ': ' +
                              DateFormat('yyyy-MM-dd')
                                  .format(books[index].date!)),
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
