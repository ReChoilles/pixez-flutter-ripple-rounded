/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pixez/document_plugin.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/open_setting_plugin.dart';
import 'package:pixez/page/directory/save_mode_choice_page.dart';
import 'package:pixez/page/hello/setting/save_eval_page.dart';
import 'package:pixez/page/hello/setting/save_format_page.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:pixez/component/settings_list.dart';

class PlatformPage extends StatefulWidget {
  @override
  _PlatformPageState createState() => _PlatformPageState();
}

class _PlatformPageState extends State<PlatformPage> {
  String path = "";
  List<DisplayMode> modes = <DisplayMode>[];
  DisplayMode? selected;

  @override
  void initState() {
    super.initState();
    initVoid();
  }

  Future<void> fetchModes() async {
    try {
      var modeList = await FlutterDisplayMode.supported;
      setState(() {
        modes = modeList;
      });

      /// On OnePlus 7 Pro:
      /// #1 1080x2340 @ 60Hz
      /// #2 1080x2340 @ 90Hz
      /// #3 1440x3120 @ 90Hz
      /// #4 1440x3120 @ 60Hz

      /// On OnePlus 8 Pro:
      /// #1 1080x2376 @ 60Hz
      /// #2 1440x3168 @ 120Hz
      /// #3 1440x3168 @ 60Hz
      /// #4 1080x2376 @ 120Hz
      selected = await FlutterDisplayMode.preferred;
    } on PlatformException catch (e) {
      print(e);

      /// e.code =>
      /// noAPI - No API support. Only Marshmallow and above.
      /// noActivity - Activity is not available. Probably app is in background
    }
    // if (mounted) {
    //   setState(() {});
    // }
  }

  initVoid() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
    fetchModes();
    String path = (await DocumentPlugin.getPath())!;
    if (mounted) {
      setState(() {
        this.path = path;
      });
    }
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      _androidInfo = androidInfo;
    });
  }

  AndroidDeviceInfo? _androidInfo = null;

  String version = "";
  bool singleFolder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Platform Setting"),
            Text(
              "For Android",
              style: TextStyle(color: Colors.greenAccent, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Observer(builder: (_) {
        return SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(
                  leading: Icons.folder_rounded,
                  title: Text(
                    '${I18n.of(context).save_path}(${userSetting.saveMode != 0 ? (userSetting.saveMode == 2 ? I18n.of(context).old_way : 'SAF') : "Media"})',
                  ),
                  description: Text(path),
                  onPressed: (ctx) async {
                    await showPathDialog(context);
                    final path = await DocumentPlugin.getPath();
                    if (mounted) {
                      setState(() {
                        this.path = path!;
                      });
                    }
                  },
                ),
                SettingsTile(
                  leading: Icons.format_align_left_rounded,
                  title: Text(I18n.of(context).save_format),
                  description: Text(userSetting.fileNameEval == 1
                      ? "Eval"
                      : userSetting.format ?? ""),
                  onPressed: (ctx) async {
                    if (userSetting.fileNameEval == 1) {
                      Leader.push(context, SaveEvalPage());
                    } else {
                      final result = await Navigator.of(context,
                              rootNavigator: true)
                          .push(MaterialPageRoute(
                              builder: (context) => SaveFormatPage()));
                      if (result is String) {
                        userSetting.setFormat(result);
                      }
                    }
                  },
                  trailing: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    onTap: () {
                      Leader.push(context, SaveEvalPage());
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      child: userSetting.fileNameEval == 1
                          ? Text(
                              "Script",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            )
                          : Text("Script"),
                    ),
                  ),
                ),
                SettingsTile.switchTile(
                  leading: Icons.folder_shared_rounded,
                  title: Text(I18n.of(context).separate_folder),
                  description:
                      Text(I18n.of(context).separate_folder_message),
                  initialValue: userSetting.singleFolder,
                  onToggle: (value) async {
                    if (value ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("可能会造成保存等待时间过长")));
                    }
                    await userSetting.setSingleFolder(value ?? false);
                  },
                ),
                SettingsTile.switchTile(
                  leading: Icons.folder_open_rounded,
                  title: Text("Sanity Single Folder"),
                  initialValue: userSetting.overSanityLevelFolder,
                  onToggle: (value) async {
                    await userSetting
                        .setOverSanityLevelFolder(value ?? false);
                  },
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile(
                  leading: Icons.mobile_screen_share_rounded,
                  title: Text(I18n.of(context).display_mode),
                  description: Text('${selected ?? ''}'),
                  onPressed: (ctx) {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.0)),
                      ),
                      builder: (_) {
                        return SafeArea(
                          child: modes.isNotEmpty
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 20, 24, 8),
                                      child: Text(
                                        I18n.of(context)
                                            .display_mode_message,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 0, 24, 12),
                                      child: Text(
                                        I18n.of(context)
                                            .display_mode_warning,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    ...modes.asMap().entries.map(
                                      (entry) {
                                        final index = entry.key;
                                        final mode = entry.value;
                                        final isSelected =
                                            selected == mode;
                                        return InkWell(
                                          onTap: () async {
                                            await FlutterDisplayMode
                                                .setPreferredMode(mode);
                                            userSetting
                                                .setDisplayMode(index);
                                            setState(() {
                                              selected = mode;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 14),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    mode.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons
                                                        .check_circle_rounded,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                )
                              : Container(),
                        );
                      },
                    );
                  },
                ),
                SettingsTile.switchTile(
                  leading: Icons.photo_album_rounded,
                  title: InkWell(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Text(I18n.of(context).photo_picker),
                    onTap: () {
                      launchUrlString(
                          "https://developer.android.com/training/data-storage/shared/photopicker");
                    },
                  ),
                  description:
                      Text(I18n.of(context).photo_picker_subtitle),
                  initialValue: userSetting.imagePickerType == 1,
                  onToggle: (value) async {
                    await userSetting
                        .setImagePickerType(value ?? false ? 1 : 0);
                  },
                ),
              ],
            ),
            if ((_androidInfo?.version.sdkInt ?? 0) > 30)
              SettingsSection(
                tiles: [
                  SettingsTile(
                    leading: Icons.add_link_rounded,
                    title: Text(I18n.of(context).open_by_default),
                    description:
                        Text(I18n.of(context).open_by_default_subtitle),
                    onPressed: (ctx) {
                      OpenSettingPlugin.open();
                    },
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 100.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                          "assets/images/open_by_default_hint.png"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
          ],
        );
      }),
    );
  }
}
