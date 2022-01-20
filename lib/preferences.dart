import 'package:book_goals/user.dart';
import 'package:flutter/material.dart';

class Preferences{
  String? user;
  String? backupFrequency;
  Preferences({@required this.user, @required this.backupFrequency});
  Preferences.empty();
  Preferences.fromJson(Map<String, dynamic> json): 
    user = json['user'],
    backupFrequency = json['backupFrequency'];
  Map<String, dynamic> toJson() {
    return {
      'user': user.toString(),
      'backupFrequency': backupFrequency.toString(),
    };
  }
}