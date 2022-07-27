import 'package:book_goals/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'book.dart';
import 'helper_functions.dart';
import 'main.dart';

class StatsPageSend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StatsPage();
  }
}

class StatsData {
  StatsData(this.date, this.booksRead);
  final DateTime date;
  final int booksRead;
}

class StatsPage extends State<StatsPageSend> {
  int totalBooks = 0, totalPages = 0;
  List<String> periods = List.empty();
  int periodIdx = 0;
  double finishedRatio = 0;
  late List<StatsData> stats;
  @override
  void initState() {
    periods = getPeriods();
    _calculateStats();
    super.initState();
  }

  DateTime _getStartDate() {
    switch (periodIdx) {
      case (0):
        return DateTime(
            DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
      case (1):
        return DateTime(
            DateTime.now().year, DateTime.now().month - 3, DateTime.now().day);
      case (2):
        return DateTime(
            DateTime.now().year, DateTime.now().month - 6, DateTime.now().day);
      case (3):
        return DateTime(
            DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
    }
    return DateTime.now();
  }

  void _calculateStats() {
    totalPages = 0;
    totalBooks = 0;
    stats = List.empty(growable: true);
    DateTime start = _getStartDate();
    for (Settings goal in data.goals) {
      //from goals
      if (goal.books != null) {
        int bookCnt = 0;
        for (Book book in goal.books!) {
          if (book.date != null && book.date!.compareTo(start) > 0) {
            totalPages += book.nOfPages ?? 0;
            totalBooks++;
            bookCnt++;
            int statsIdx = -1;
            if ((statsIdx = stats.indexWhere((element) =>
                    element.date.difference(book.date!).inDays == 0)) !=
                -1) {
              stats[statsIdx] = StatsData(
                  stats[statsIdx].date, stats[statsIdx].booksRead + bookCnt);
            } else {
              stats.add(StatsData(book.date!, bookCnt));
            }
          }
        }
      }
    }
    for (var lib in data.libs) {
      if (lib.book != null) {
        int bookCnt = 0;
        if (lib.message == "Read") {
          if (lib.book!.date != null && lib.book!.date!.compareTo(start) > 0) {
            totalPages += lib.book!.nOfPages ?? 0;
            totalBooks++;
            bookCnt++;
            int statsIdx = -1;
            if ((statsIdx = stats.indexWhere((element) =>
                    (element.date.difference(lib.book!.date!).inDays == 0))) !=
                -1) {
              stats[statsIdx] = StatsData(
                  stats[statsIdx].date, stats[statsIdx].booksRead + bookCnt);
            } else {
              stats.add(StatsData(lib.book!.date!, bookCnt));
            }
          }
        }
      }
    }
    stats.sort((a, b) => a.date.compareTo(b.date));
    List totGoals, succGoals;
    totGoals = data.goals
        .where((element) =>
            (element.dateEnd != null && element.dateEnd!.compareTo(start) > -1))
        .toList();
    succGoals = totGoals
        .where((element) => (element.books!.length >= element.goalBooks!))
        .toList();
    finishedRatio = (succGoals.length / totGoals.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: Text("statistics".tr()),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              alignment: AlignmentDirectional.center,
              value: periods[periodIdx],
              onChanged: (String? newValue) {
                if (newValue != periods[periodIdx]) {
                  setState(() {
                    periodIdx =
                        periods.indexWhere((element) => element == newValue);
                  });
                  _calculateStats();
                }
              },
              items: periods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SfCartesianChart(
              title: ChartTitle(text: 'numberOfReadBooks'.tr()),
              primaryXAxis: CategoryAxis(),
              series: <ChartSeries<StatsData, String>>[
                LineSeries<StatsData, String>(
                    dataSource: stats,
                    xValueMapper: (StatsData stats, _) =>
                        DateFormat('yyyy-MM-dd')
                            .format(DateUtils.dateOnly(stats.date)),
                    yValueMapper: (StatsData stats, _) => stats.booksRead)
              ]),
          Card(
              child: ListTile(
            leading: const Icon(Icons.pages),
            title: Text("totalPagesRead".tr()),
            trailing: Text(totalPages.toString()),
          )),
          Card(
              child: ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: Text("totalBooksRead".tr()),
            trailing: Text(totalBooks.toString()),
          )),
          Card(
              child: ListTile(
            leading: const Icon(Icons.done_all),
            title: Text("ratioGoalsFinished".tr()),
            trailing: Text((finishedRatio).toStringAsFixed(2) + "%"),
          ))
        ],
      ),
    );
  }
}
