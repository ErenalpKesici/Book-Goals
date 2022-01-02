import 'package:book_goals/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OldGoalsPageSend extends StatefulWidget{
  const OldGoalsPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OldGoalsPage();
  }
}
class OldGoalsPage extends State<OldGoalsPageSend>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Old Goals"),
      ),
      body: 
        ListView.builder(
          itemCount: save.length,
          itemBuilder: (context, idx){
            List<String> titles = List.empty(growable: true);
            for(int i=0;i<save[idx].books!.length;i++){
              titles.add(save[idx].books![i].title!);
            }
            String dates = '';
            if(save[idx].dateStart!=null){
              dates = DateFormat('yyyy-MM-dd').format(save[idx].dateStart!);
            }
            if(save[idx].dateEnd!=null){
              dates+= ' - ' +DateFormat('yyyy-MM-dd').format(save[idx].dateEnd!);
            }
            return Card(elevation: 1, child: 
              ListTile(
                leading: Text(dates),
                title: Text(titles.toString(), textAlign: TextAlign.center,),
              ));
          },
        ),
    );
  }
}