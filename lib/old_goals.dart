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
        title: const Text("Previous Goals"),
      ),
      body: 
        ListView.builder(
          itemCount: save.length,
          itemBuilder: (context, idx){
            List<String> titles = List.empty(growable: true);
            for(int i=0;i<save[save.length - 1 - idx].books!.length;i++){
              titles.add(save[save.length - 1 - idx].books![i].title!);
            }
            String dates = '';
            if(save[save.length - 1 - idx].dateStart!=null){
              dates = DateFormat('yyyy-MM-dd').format(save[save.length - 1 - idx].dateStart!);
            }
            Icon? iconStatus = Icon(Icons.not_interested);
            if(save[save.length - 1 - idx].dateEnd!=null){
              dates+= ' - ' +DateFormat('yyyy-MM-dd').format(save[save.length - 1 - idx].dateEnd!);
              if(save[save.length - 1 - idx].dateEnd!.compareTo(DateTime.now()) > -1) {
                iconStatus = null;
              } 
              else if(save[save.length - 1 - idx].dateEnd!.compareTo(DateTime.now()) < 0 && save[save.length - 1 - idx].goalBooks! <= save[save.length - 1 - idx].books!.length){
                  iconStatus = Icon(Icons.done_outline_rounded);
              }
            }
            return Card(elevation: 1, child: 
              ListTile(
                leading: Text(dates),
                title: Text(titles.isEmpty?'No books read for this goal.':titles.toString(), textAlign: TextAlign.center,),
                trailing: Container(width:  20, child: iconStatus??const LinearProgressIndicator()),
              ));
          },
        ),
    );
  }
}