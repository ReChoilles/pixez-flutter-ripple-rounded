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

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/about/last_release.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    initData();
  }

  LastRelease? lastRelease;
  dynamic error;

  initData() async {
    try {
      Response response = await _dio.get(
        'https://api.github.com/repos/Notsfsssf/pixez-flutter/releases/latest',
      );
      final result = LastRelease.fromJson(response.data);
      setState(() {
        lastRelease = result;
      });
    } catch (e) {
      setState(() {
        error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).update)),
      body: lastRelease == null
          ? Builder(
              builder: (_) {
                return error == null
                    ? Container(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Container(child: Center(child: Text(error.toString())));
              },
            )
          : SettingsList(
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile(
                      title: Text(I18n.of(context).latest_version),
                      description: Text(lastRelease!.tagName ?? ''),
                    ),
                    SettingsTile(
                      title: Text(I18n.of(context).download_address),
                      description: SelectableText(
                        lastRelease!.assets?.first.browserDownloadUrl ?? '',
                      ),
                      onPressed: (ctx) {
                        try {
                          launchUrlString(
                            lastRelease!.assets?.first.browserDownloadUrl ??
                                '',
                          );
                        } catch (e) {}
                      },
                    ),
                    SettingsTile(
                      title:
                          Text(I18n.of(context).new_version_update_information),
                      description: Text(lastRelease!.body ?? ''),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            error = null;
            lastRelease = null;
          });
          initData();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}