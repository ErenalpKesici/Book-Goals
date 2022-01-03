import 'package:book_goals/helper_functions.dart';
import 'package:book_goals/main.dart';
import 'package:flutter/material.dart';

import 'book.dart';

class BookDetailsPageSend extends StatefulWidget{
  final int idx, bookIdx;
  BookDetailsPageSend(this.idx, this.bookIdx);

  @override
  State<StatefulWidget> createState() {
    return BookDetailsPage(idx, bookIdx);
  }
}
class BookDetailsPage extends State<BookDetailsPageSend>{
  final int idx, bookIdx;
  BookDetailsPage(this.idx, this.bookIdx);
  List<Color> starColors = List.filled(5, Colors.grey);
  @override
  void initState() {
    for(int i=0;i<save[idx].books![bookIdx].rating!;i++){
      starColors[i] = Colors.yellow;
    }
    super.initState();
  }
  void setStarColors(int idx){
    for(int i=0;i<5;i++){
      if(i <= idx){
        starColors[i] = Colors.yellow;
      }
      else{
        starColors[i] = Colors.grey;
      }
    }
  }
  void updateRating(int starIdx){
    setState(() {
      setStarColors(starIdx);
    });
    save[idx].books![bookIdx].rating = starIdx + 1;
    writeSave();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(save[idx].books![bookIdx].title!),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(save[idx].books![bookIdx].imgUrl!='')
                Image.network(save[idx].books![bookIdx].imgUrl!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          updateRating(0);
                      }, color: starColors[0], icon: const Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          updateRating(1);
                      }, color: starColors[1], icon: Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          updateRating(2);
                      }, color: starColors[2], icon: Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          updateRating(3);
                      }, color: starColors[3], icon: Icon(Icons.star),),
                    ),
                    FittedBox(
                      child: IconButton(
                        onPressed: (){
                          updateRating(4);
                      }, color: starColors[4], icon: Icon(Icons.star),),
                    ),
                  ],
                ),
                
              ListTile(
                leading: const Icon(Icons.title),
                title: Text(save[idx].books![bookIdx].title!, textAlign: TextAlign.center,),
              ),
              if(save[idx].books![bookIdx].authors!.isNotEmpty && save[idx].books![bookIdx].authors![0] != '')
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(save[idx].books![bookIdx].authors!.toString().substring(1, save[idx].books![bookIdx].authors!.toString().length - 1), textAlign: TextAlign.center,),
                ),
              if(save[idx].books![bookIdx].categories!.isNotEmpty && save[idx].books![bookIdx].categories![0] != '')
                ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(save[idx].books![bookIdx].categories!.toString().substring(1, save[idx].books![bookIdx].categories!.toString().length - 1), textAlign: TextAlign.center,),
                ),
              if(save[idx].books![bookIdx].datePublished != null)
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(DateUtils.dateOnly(save[idx].books![bookIdx].datePublished!).toString(), textAlign: TextAlign.center,),
                ),
              if(save[idx].books![bookIdx].nOfPages != null)
                ListTile(
                  leading: const Icon(Icons.pages),
                  title: Text(save[idx].books![bookIdx].nOfPages!.toString(), textAlign: TextAlign.center,),
                ),
            ],
          ),
        ),
      ),
    );
  }
}