import 'dart:convert';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/tags.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                leading: Icons.file_upload_outlined,
                title: Text("Export tag history"),
                onPressed: (ctx) {
                  final tags = tagHistoryStore.tags;
                  List<TagsPersist> tagsPersist = tags.toList();
                  String json = jsonEncode(tagsPersist);
                  final data = Uint8List.fromList(json.codeUnits);
                  DocumentPlugin.openSave(data, "export_tag_history.json");
                },
              ),
              SettingsTile(
                leading: Icons.file_download_outlined,
                title: Text("Import tag history"),
                onPressed: (ctx) async {
                  Uint8List uint8list = Uint8List(10);
                  String json = String.fromCharCodes(uint8list);
                  List<TagsPersist> tagsPersist = jsonDecode(json);
                  for (var element in tagsPersist) {
                    await tagHistoryStore.insert(element);
                  }
                  BotToast.showText(text: "Ok");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}