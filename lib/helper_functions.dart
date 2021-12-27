import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'main.dart';

void writeSave() async{
  final externalDir = await getExternalStorageDirectory();
  await File(externalDir!.path + "/Save.json").writeAsString(jsonEncode(save));
}