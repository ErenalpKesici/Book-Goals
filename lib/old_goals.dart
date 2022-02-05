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
          itemCount: data.goals.length,
          itemBuilder: (context, idx){
            List<String> titles = List.empty(growable: true);
            for(int i=0;i<data.goals[data.goals.length - 1 - idx].books!.length;i++){
              titles.add(data.goals[data.goals.length - 1 - idx].books![i].title!);
            }
            String dates = '';
            if(data.goals[data.goals.length - 1 - idx].dateStart!=null){
              dates = DateFormat('yyyy-MM-dd').format(data.goals[data.goals.length - 1 - idx].dateStart!);
            }
            Icon? iconStatus = const Icon(Icons.not_interested);
            if(data.goals[data.goals.length - 1 - idx].dateEnd!=null){
              dates+= ' - ' +DateFormat('yyyy-MM-dd').format(data.goals[data.goals.length - 1 - idx].dateEnd!);
              if(data.goals[data.goals.length - 1 - idx].books!.length < data.goals[data.goals.length - 1 - idx].goalBooks! && data.goals[data.goals.length - 1 - idx].dateEnd!.compareTo(DateTime.now()) > -1) {
                iconStatus = null;
              } 
              else if(data.goals[data.goals.length - 1 - idx].goalBooks! <= data.goals[data.goals.length - 1 - idx].books!.length){
                  iconStatus = const Icon(Icons.done_outline_rounded, color: Colors.green,);
              }
            }
            return Card(elevation: 1, child: 
              ListTile(
                title: Text(dates),
                subtitle: Text(titles.isEmpty?'No books have been read for this goals.':titles.toString().substring(1, titles.toString().length - 1), textAlign: TextAlign.center,),
                trailing: SizedBox(width:  20, child: iconStatus??const LinearProgressIndicator()),
                iconColor: Colors.red,
                isThreeLine: true,
              ));
          },
        ),
    );
  }
}