import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/glance_illust_persist.dart';
import 'package:pixez/page/history/history_store.dart';

class DataExportPage extends HookConsumerWidget {
  const DataExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).app_data)),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('标签搜索历史'),
            tiles: [
              SettingsTile(
                leading: Icons.upload_rounded,
                title: Text(I18n.of(context).export_title),
                description: Text(I18n.of(context).export_tag_history),
                onPressed: (ctx) async {
                  try {
                    await tagHistoryStore.exportData(ctx);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              SettingsTile(
                leading: Icons.download_rounded,
                title: Text(I18n.of(context).import_title),
                description: Text(I18n.of(context).import_tag_history),
                onPressed: (ctx) async {
                  try {
                    await tagHistoryStore.importData();
                  } catch (e) {
                    print(e);
                    BotToast.showText(text: e.toString());
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('收藏标签'),
            tiles: [
              SettingsTile(
                leading: Icons.upload_rounded,
                title: Text(I18n.of(context).export_title),
                description: Text(I18n.of(context).export_bookmark_tag),
                onPressed: (ctx) async {
                  try {
                    await bookTagStore.exportData(ctx);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              SettingsTile(
                leading: Icons.download_rounded,
                title: Text(I18n.of(context).import_title),
                description: Text(I18n.of(context).import_bookmark_tag),
                onPressed: (ctx) async {
                  try {
                    await bookTagStore.importData();
                  } catch (e) {
                    print(e);
                    BotToast.showText(text: e.toString());
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('浏览历史（插画）'),
            tiles: [
              SettingsTile(
                leading: Icons.upload_rounded,
                title: Text(I18n.of(context).export_title),
                description: Text(I18n.of(context).export_illust_history),
                onPressed: (ctx) async {
                  try {
                    await ref.read(historyProvider.notifier).fetch();
                    await ref.read(historyProvider.notifier).exportData(ctx);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              SettingsTile(
                leading: Icons.download_rounded,
                title: Text(I18n.of(context).import_title),
                description: Text(I18n.of(context).import_illust_history),
                onPressed: (ctx) async {
                  try {
                    await ref.read(historyProvider.notifier).fetch();
                    await ref.read(historyProvider.notifier).importData();
                  } catch (e) {
                    print(e);
                    BotToast.showText(text: e.toString());
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('浏览历史（小说）'),
            tiles: [
              SettingsTile(
                leading: Icons.upload_rounded,
                title: Text(I18n.of(context).export_title),
                description: Text(I18n.of(context).export_novel_history),
                onPressed: (ctx) async {
                  try {
                    await novelHistoryStore.fetch();
                    await novelHistoryStore.exportData(ctx);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              SettingsTile(
                leading: Icons.download_rounded,
                title: Text(I18n.of(context).import_title),
                description: Text(I18n.of(context).import_novel_history),
                onPressed: (ctx) async {
                  try {
                    await novelHistoryStore.fetch();
                    await novelHistoryStore.importData();
                  } catch (e) {
                    print(e);
                    BotToast.showText(text: e.toString());
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('屏蔽数据'),
            tiles: [
              SettingsTile(
                leading: Icons.upload_rounded,
                title: Text(I18n.of(context).export_title),
                description: Text(I18n.of(context).export_mute_data),
                onPressed: (ctx) async {
                  try {
                    await muteStore.export(ctx);
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              SettingsTile(
                leading: Icons.download_rounded,
                title: Text(I18n.of(context).import_title),
                description: Text(I18n.of(context).import_mute_data),
                onPressed: (ctx) async {
                  try {
                    await muteStore.importFile();
                  } catch (e) {
                    print(e);
                    BotToast.showText(text: e.toString());
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('数据管理'),
            tiles: [
              SettingsTile(
                leading: Icons.cleaning_services_rounded,
                title: Text(I18n.of(context).clear_all_cache),
                onPressed: (ctx) async {
                  try {
                    await _showClearCacheDialog(ctx);
                  } catch (e) {}
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(I18n.of(context).clear_all_cache),
          actions: <Widget>[
            TextButton(
              child: Text(I18n.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop("CANCEL");
              },
            ),
            TextButton(
              child: Text(I18n.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop("OK");
              },
            ),
          ],
        );
      },
      context: context,
    );
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
            cleanGlanceData();
          } catch (e) {}
        }
        break;
    }
  }

  void cleanGlanceData() async {
    GlanceIllustPersistProvider glanceIllustPersistProvider =
        GlanceIllustPersistProvider();
    await glanceIllustPersistProvider.open();
    await glanceIllustPersistProvider.deleteAll();
    await glanceIllustPersistProvider.close();
  }
}