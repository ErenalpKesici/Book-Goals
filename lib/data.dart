import 'package:book_goals/library.dart';
import 'package:book_goals/settings.dart';

class Data{
  List<Settings> goals = List.empty(growable: true);
  List<Library> libs = List.empty(growable: true);
  Data.empty();
  Data.fromJson(Map<String, dynamic> json): 
    goals = json['goals'],
    libs = json['libs'];
  Map<String, dynamic> toJson() {
    return {
      'goals': goals,
      'libs': libs,
    };
  }
  @override
  String toString() {
    return goals.toString();
  }
}