import 'dart:convert';
import 'dart:io';
import 'package:book_goals/main.dart';
import 'package:book_goals/settings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'helper_functions.dart';

class AddGoalPageSend extends StatefulWidget{
  const AddGoalPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddGoalPage();
  }
}
class AddGoalPage extends State<AddGoalPageSend>{
  TextEditingController? tecGoalBooks = TextEditingController(text: ''), tecGoalDuration = TextEditingController(text: '');
  String? goalDurationType = 'Day(s)';
  @override
  void initState() {
    if(save.isEmpty){
      save.add(Settings.empty());
    }
    tecGoalBooks!.text = save.last.goalBooks != 0?save.last.goalBooks.toString():''; 
    tecGoalDuration!.text = save.last.goalDuration != 0?save.last.goalDuration.toString():'';
    goalDurationType = save.last.goalDurationType==''?'Day(s)':save.last.goalDurationType;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("I want to read", style: TextStyle(fontSize: 16),)
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: tecGoalBooks,
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(" books in ", style: TextStyle(fontSize: 16),)
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: tecGoalDuration,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    alignment: AlignmentDirectional.center,
                    value: goalDurationType,
                    onChanged: (String? newValue) {
                      setState(() {
                        goalDurationType = newValue;
                      });
                    },
                    items: <String>['Day(s)', 'Month(s)', 'Year(s)'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height/10,),
          ElevatedButton.icon(onPressed: () async {
            if(save.last.goalBooks == 0){   
              save.last = Settings(goalBooks:  tecGoalBooks?.text!=''?int.parse(tecGoalBooks!.text):save.last.goalBooks, goalDuration: tecGoalDuration?.text!=''?int.parse(tecGoalDuration!.text):save.last.goalDuration, goalDurationType: goalDurationType!=""?goalDurationType:save.last.goalDurationType, books: save.last.books, dateStart: DateTime.now(), dateEnd: DateTime.now().add(Duration(days: int.parse(tecGoalDuration!.text) * multiplierInDays(goalDurationType!))));
            }
            else {
              save.last = Settings(goalBooks:  tecGoalBooks?.text!=''?int.parse(tecGoalBooks!.text):save.last.goalBooks, goalDuration: tecGoalDuration?.text!=''?int.parse(tecGoalDuration!.text):save.last.goalDuration, goalDurationType: goalDurationType!=""?goalDurationType:save.last.goalDurationType, books: save.last.books);
            }
            writeSave();
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
          }, icon: const Icon(Icons.task_alt_rounded), label: const Text("Save"))
        ],
      ),
    );
  }
}