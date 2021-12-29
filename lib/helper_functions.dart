import 'dart:convert';
import 'dart:io';



import 'package:path_provider_windows/path_provider_windows.dart';

import 'main.dart';

void writeSave() async{
  final PathProviderWindows provider = PathProviderWindows();
  final externalDir = await provider.getApplicationSupportPath();
  await File(externalDir! + "/Save.json").writeAsString(jsonEncode(save));
}