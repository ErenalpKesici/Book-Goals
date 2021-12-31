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
  TextEditingController? tecGoalBooks = TextEditingController(text:  save.goalBooks==0?'':save.goalBooks.toString()), tecGoalDuration = TextEditingController(text: save.goalDuration==0?'':save.goalDuration.toString());
  String? goalDurationType = save.goalDurationType!=""?save.goalDurationType:'Day(s)';
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const MyHomePage()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Modify the Goal"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  child: Text(" books in "),
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
                  save = Settings(goalBooks:  tecGoalBooks?.text!=''?int.parse(tecGoalBooks!.text):save.goalBooks, goalDuration: tecGoalDuration?.text!=''?int.parse(tecGoalDuration!.text):save.goalDuration, goalDurationType: goalDurationType!=""?goalDurationType:save.goalDurationType, books: save.books);
                  writeSave();
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MyHomePage()));
                }, icon: const Icon(Icons.task_alt_rounded), label: const Text("Save"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}