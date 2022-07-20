import 'dart:convert';
import 'dart:io';
import 'package:book_goals/main.dart';
import 'package:book_goals/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';

import 'helper_functions.dart';

class AddGoalPageSend extends StatefulWidget {
  const AddGoalPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddGoalPage();
  }
}

class AddGoalPage extends State<AddGoalPageSend> {
  TextEditingController? tecGoalBooks = TextEditingController(text: ''),
      tecGoalDuration = TextEditingController(text: '');
  List<String> durations = getDurations();
  String? goalDurationType;
  @override
  void initState() {
    goalDurationType = durations.first;
    if (data.goals.isEmpty) {
      data.goals.add(Settings.empty());
    }
    tecGoalBooks!.text = data.goals.last.goalBooks != 0
        ? data.goals.last.goalBooks.toString()
        : '';
    tecGoalDuration!.text = data.goals.last.goalDuration != 0
        ? data.goals.last.goalDuration.toString()
        : '';
    goalDurationType = data.goals.last.goalDurationType == ''
        ? durations.first
        : data.goals.last.goalDurationType;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16, 32, 16),
                child: Text(
                  "howManyBooksGoal".tr(),
                  style: TextStyle(fontSize: 16),
                )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 32, 0),
                child: TextField(
                  decoration: InputDecoration(
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor!),
                        borderRadius: BorderRadius.circular(15),
                      )),
                  keyboardType: TextInputType.number,
                  controller: tecGoalBooks,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .1,
        ),
        Text(
          "howLongGoal".tr(),
          style: const TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 48,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor!),
                        borderRadius: BorderRadius.circular(15),
                      )),
                  keyboardType: TextInputType.number,
                  controller: tecGoalDuration,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: DropdownButton<String>(
                    alignment: AlignmentDirectional.center,
                    value: goalDurationType,
                    onChanged: (String? newValue) {
                      setState(() {
                        goalDurationType = newValue;
                      });
                    },
                    items:
                        durations.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 10,
        ),
        ElevatedButton.icon(
            onPressed: () async {
              if (tecGoalBooks!.text == '' || tecGoalDuration!.text == '') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Theme.of(context).hintColor,
                    content: const Text('Please enter all fields.')));
              } else {
                data.goals.last = Settings(
                    goalBooks: tecGoalBooks?.text != ''
                        ? int.parse(tecGoalBooks!.text)
                        : data.goals.last.goalBooks,
                    goalDuration: tecGoalDuration?.text != ''
                        ? int.parse(tecGoalDuration!.text)
                        : data.goals.last.goalDuration,
                    goalDurationType: goalDurationType != ""
                        ? goalDurationType
                        : data.goals.last.goalDurationType,
                    books: data.goals.last.books,
                    dateStart: DateTime.now(),
                    dateEnd: DateTime.now().add(Duration(
                        days: int.parse(tecGoalDuration!.text) *
                            multiplierInDays(durations.indexWhere(
                                (element) => element == goalDurationType!)))));
                writeSave();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MyHomePage()));
              }
            },
            icon: const Icon(Icons.task_alt_rounded),
            label: Text("save".tr()))
      ],
    );
  }
}
