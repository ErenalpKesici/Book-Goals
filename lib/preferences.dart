import 'package:book_goals/user.dart';
import 'package:flutter/material.dart';

class Preferences {
  String? user;
  int? backupFrequencyIdx;
  Preferences({@required this.user, @required this.backupFrequencyIdx});
  Preferences.empty();
  Preferences.fromJson(Map<String, dynamic> json)
      : user = json['user'],
        backupFrequencyIdx = json['backupFrequencyIdx'];
  Map<String, dynamic> toJson() {
    return {
      'user': user.toString(),
      'backupFrequency': backupFrequencyIdx.toString(),
    };
  }
}
