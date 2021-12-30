import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'book.dart';

class ListBookPageSend extends StatefulWidget{
  const ListBookPageSend({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListBookPage();
  }
}
class ListBookPage extends State<ListBookPageSend>{
  List<bool> tileSelected = List.filled(save.books!.length, false);
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
                      tileSelected = List.filled(save.books!.length, tileSelected.every((element) => element)?false:true);
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
                                  List<Book> newBooks = List.empty(growable: true);
                                  for(int i=0;i<save.books!.length;i++){
                                    if(!tileSelected[i]){
                                      newBooks.add(save.books![i]);
                                    }
                                  }
                                  setState(() {
                                    save.books = newBooks;
                                  });
                                  writeSave();
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyHomePage()));
                                },
                                child: const Text("Yes")
                              ),
                              const SizedBox(width: 5,),
                              ElevatedButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: const Text("No"),
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
      body: ListView.builder(itemCount: save.books!.length, itemBuilder: (builder, idx){
        return SizedBox(
          height: 100, 
          child: 
            Card(elevation: 1, child: 
              ListTile(
                selected: tileSelected[idx],
                onTap: (){
                  if(tileSelected.any((element) => element)) {
                    setState(() {
                      tileSelected[idx] = tileSelected[idx]?false:true;
                    });
                  }
                },
                onLongPress: (){
                  setState(() {
                    tileSelected[idx] = tileSelected[idx]?false:true;
                  });
                },
                leading: Text(DateFormat("yyyy-MM-dd").format(save.books![idx].date!)),
                title: Text(save.books![idx].title!+", "+ save.books![idx].nOfPages.toString()+" pages "),
                trailing: Text(save.books![idx].rating.toString()+" stars"),
              ),
            )
        );
      }),
    );
  }

}