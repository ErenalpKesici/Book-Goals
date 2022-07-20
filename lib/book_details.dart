import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookDetailsPageSend extends StatefulWidget {
  final int idx, bookIdx;
  BookDetailsPageSend(this.idx, this.bookIdx);

  @override
  State<StatefulWidget> createState() {
    return BookDetailsPage(idx, bookIdx);
  }
}

class BookDetailsPage extends State<BookDetailsPageSend> {
  final int idx, bookIdx;
  BookDetailsPage(this.idx, this.bookIdx);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: data.goals[idx].books![bookIdx].id!,
      child: Scaffold(
        appBar: AppBar(
          title: Text(data.goals[idx].books![bookIdx].title!),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (data.goals[idx].books![bookIdx].imgUrl != '')
                  Image.network(data.goals[idx].books![bookIdx].imgUrl!),
                getBookReview(data.goals[idx].books![bookIdx]),
                ListTile(
                  leading: const Icon(Icons.title),
                  title: Text(
                    data.goals[idx].books![bookIdx].title!,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (data.goals[idx].books![bookIdx].authors!.isNotEmpty &&
                    data.goals[idx].books![bookIdx].authors![0] != '')
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text(
                      data.goals[idx].books![bookIdx].authors!
                          .toString()
                          .substring(
                              1,
                              data.goals[idx].books![bookIdx].authors!
                                      .toString()
                                      .length -
                                  1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (data.goals[idx].books![bookIdx].categories!.isNotEmpty &&
                    data.goals[idx].books![bookIdx].categories![0] != '')
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(
                      data.goals[idx].books![bookIdx].categories!
                          .toString()
                          .substring(
                              1,
                              data.goals[idx].books![bookIdx].categories!
                                      .toString()
                                      .length -
                                  1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (data.goals[idx].books![bookIdx].datePublished != null)
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: Text(
                      DateFormat('yyyy-MM-dd')
                          .format(
                              data.goals[idx].books![bookIdx].datePublished!)
                          .toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (data.goals[idx].books![bookIdx].nOfPages != null)
                  ListTile(
                    leading: const Icon(Icons.pages),
                    title: Text(
                      data.goals[idx].books![bookIdx].nOfPages!.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
