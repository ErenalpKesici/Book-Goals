import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'book.dart';
import 'old_goal_details.dart';

class OldGoalsPageSend extends StatefulWidget {
  const OldGoalsPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OldGoalsPage();
  }
}

class OldGoalsPage extends State<OldGoalsPageSend> {
  List<List<Book>> books = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
    books = List.empty(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: Text("allGoals".tr()),
      ),
      body: ListView.builder(
        itemCount: data.goals.length,
        itemBuilder: (context, idx) {
          books.add(List.empty(growable: true));
          for (int i = 0;
              i < data.goals[data.goals.length - 1 - idx].books!.length;
              i++) {
            books[idx].add(data.goals[data.goals.length - 1 - idx].books![i]);
          }
          String dates = '';
          if (data.goals[data.goals.length - 1 - idx].dateStart != null) {
            dates = DateFormat('yyyy-MM-dd')
                .format(data.goals[data.goals.length - 1 - idx].dateStart!);
          }
          Icon? iconStatus = const Icon(Icons.not_interested);
          if (data.goals[data.goals.length - 1 - idx].dateEnd != null) {
            dates += ' - ' +
                DateFormat('yyyy-MM-dd')
                    .format(data.goals[data.goals.length - 1 - idx].dateEnd!);
            if (data.goals[data.goals.length - 1 - idx].books!.length <
                    data.goals[data.goals.length - 1 - idx].goalBooks! &&
                data.goals[data.goals.length - 1 - idx].dateEnd!
                        .compareTo(DateTime.now()) >
                    -1) {
              iconStatus = null;
            } else if (data.goals[data.goals.length - 1 - idx].goalBooks! <=
                data.goals[data.goals.length - 1 - idx].books!.length) {
              iconStatus = const Icon(
                Icons.done_outline_rounded,
                color: Colors.green,
              );
            }
          }
          return Card(
              elevation: 1,
              child: ListTile(
                onTap: books[idx].isEmpty
                    ? null
                    : () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OldGoalDetailsPageSend(
                                dates,
                                books[idx],
                                data.goals[idx].goalBooks!,
                                books[idx].length)));
                      },
                title: Text(
                  dates,
                  textAlign: TextAlign.center,
                ),
                subtitle: books.isEmpty
                    ? Text('noBooksRead'.tr())
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: books[idx].length,
                        itemBuilder: (context, index) => Text(
                              books[idx][index].title!,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            )),
                trailing: SizedBox(
                    width: 20,
                    child: iconStatus ?? const LinearProgressIndicator()),
                iconColor: Colors.red,
                isThreeLine: books[idx].isNotEmpty ? true : false,
              ));
        },
      ),
    );
  }
}
