import 'package:book_goals/book_details.dart';
import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'book.dart';

class ListBookPageSend extends StatefulWidget{
  final int? idx;
  ListBookPageSend({Key? key, this.idx}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListBookPage(this.idx);
  }
}
class ListBookPage extends State<ListBookPageSend>{
  int? idx;
  List<bool> tileSelected = List.empty();
  ListBookPage(this.idx);
  TextStyle getTextStyle(){
    return const TextStyle(
      letterSpacing: 0.5,
      shadows: <Shadow>[
        Shadow(
          offset: Offset(0.0, 0.0),
          blurRadius: 10.0,
          color: Colors.black,
        ),
        Shadow(
          offset: Offset(0.0, 0.0),
          blurRadius: 10.0,
          color: Colors.black,
        ),
      ],
    );
  }
  @override
  void initState() {
    print(idx);
    tileSelected = List.filled(data.goals[idx!].books!.length, false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books Read"),
        actions: [
          if(tileSelected.any((element) => element))
            Row(
              children: [
                IconButton(icon: const Icon(Icons.select_all), 
                  onPressed: (){
                    setState(() {
                      tileSelected = List.filled(data.goals[idx!].books!.length, tileSelected.every((element) => element)?false:true);
                    });
                  },
                ),
                IconButton(icon: const Icon(Icons.delete_outline_rounded), 
                  onPressed: () async{
                    return await showDialog(context: context, builder: (context){
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Are you sure you wish to delete selected item(s)?"),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: const Text("No"),
                              ),
                              const SizedBox(width: 5,),
                              ElevatedButton(
                                onPressed: (){
                                  List<Book> newBooks = List.empty(growable: true);
                                  for(int i=0;i<data.goals[idx!].books!.length;i++){
                                    if(!tileSelected[i]){
                                      newBooks.add(data.goals[idx!].books![i]);
                                    }
                                  }
                                  setState(() {
                                    data.goals[idx!].books = newBooks;
                                  });
                                  writeSave();
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyHomePage()));
                                },
                                child: const Text("Yes")
                              ),
                            ],
                          )
                        ],
                      );
                    });
                  },
                ),
              ],
            )
        ],
      ),
      body: ListView.builder(itemCount: data.goals[idx!].books!.length, itemBuilder: (builder, innerIdx){
        return SizedBox(
          height: 100, 
          child: 
            Card(elevation: 1, 
            child: 
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover, 
                    image: NetworkImage(data.goals[idx!].books![innerIdx].imgUrl!)
                  ),
                ),
                child:  ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  leading: /*data.books![idx].imgUrl!=''?Image.network(data.books![idx].imgUrl!):*/Text(DateFormat("yyyy-MM-dd").format(data.goals[idx!].books![innerIdx].date!), style: getTextStyle(),),
                  title: Text(data.goals[idx!].books![innerIdx].title!, style: getTextStyle(),),
                  subtitle: Text(data.goals[idx!].books![innerIdx].authors != null ? data.goals[idx!].books![innerIdx].authors!.first:''),
                  trailing: Text(data.goals[idx!].books![innerIdx].nOfPages.toString() + " pages ", style: getTextStyle(),),
                   isThreeLine: true,
                  selected: tileSelected[innerIdx],
                  onTap: (){
                    if(tileSelected.any((element) => element)) {
                      setState(() {
                        tileSelected[innerIdx] = tileSelected[innerIdx]?false:true;
                      });
                    }
                    else{
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> BookDetailsPageSend(idx!, innerIdx)));
                    }
                  },
                  onLongPress: (){
                    setState(() {
                      tileSelected[innerIdx] = tileSelected[innerIdx]?false:true;
                    });
                  },
                ),
              ),
            )
        );
      }),
    );
  }

}