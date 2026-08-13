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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/new_version_chip.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/models/board_info.dart';
import 'package:pixez/page/about/about_page.dart';
import 'package:pixez/page/account/edit/account_edit_page.dart';
import 'package:pixez/page/account/select/account_select_page.dart';
import 'package:pixez/page/board/board_page.dart';
import 'package:pixez/page/book/tag/book_tag_page.dart';
import 'package:pixez/page/hello/recom/recom_manga_page.dart';
import 'package:pixez/page/hello/setting/data_export_page.dart';
import 'package:pixez/page/hello/setting/setting_quality_page.dart';
import 'package:pixez/page/history/history_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/novel/history/novel_history_page.dart';
import 'package:pixez/page/novel/novel_rail.dart';
import 'package:pixez/page/shield/shield_page.dart';
import 'package:pixez/page/task/job_page.dart';
import 'package:pixez/page/theme/theme_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    initMethod();
    fetchBoard();
  }

  bool hideEmail = true;

  bool get _effectiveHasNewVersion =>
      Updater.result == Result.yes &&
      Updater.latestVersion != userSetting.ignoreUpdateVersion;

  initMethod() async {
    if (Constants.isGooglePlay || Platform.isIOS) return;
    if (Updater.result != Result.timeout) return;
    await Updater.check();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SettingsList(
          sections: [
            Observer(builder: (context) {
              if (accountStore.now != null)
                return SettingsSection(
                  tiles: [
                    _buildUserProfile(context),
                    SettingsTile(
                      leading: Icons.account_box_rounded,
                      title: Text(I18n.of(context).account_message),
                      onPressed: (ctx) {
                        Navigator.of(ctx).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                AccountEditPage()));
                      },
                    ),
                  ],
                );
              return const SizedBox.shrink();
            }),
            SettingsSection(
              title: Text(I18n.of(context).setting),
              tiles: [
                SettingsTile(
                  leading: Icons.history_rounded,
                  title: Text(I18n.of(context).history_record),
                  onPressed: (ctx) {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                      return Constants.type == 0
                          ? HistoryPage()
                          : NovelHistory();
                    }));
                  },
                ),
                SettingsTile(
                  leading: Icons.tune_rounded,
                  title: Text(I18n.of(context).quality_setting),
                  onPressed: (ctx) {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                      return SettingQualityPage();
                    }));
                  },
                ),
                SettingsTile(
                  leading: Icons.bookmark_rounded,
                  title: Text(I18n.of(context).favorited_tag),
                  onPressed: (ctx) =>
                      Leader.pushWithScaffold(ctx, BookTagPage()),
                ),
                SettingsTile(
                  leading: Icons.block_rounded,
                  title: Text(I18n.of(context).shielding_settings),
                  onPressed: (ctx) => Leader.push(ctx, ShieldPage()),
                ),
                SettingsTile(
                  leading: Icons.download_rounded,
                  title: Text(I18n.of(context).task_progress),
                  onPressed: (ctx) => Leader.push(ctx, JobPage()),
                ),
                SettingsTile(
                  leading: Icons.folder_open_rounded,
                  title: Text(I18n.of(context).app_data),
                  onPressed: (ctx) => Leader.push(ctx, DataExportPage()),
                ),
                SettingsTile(
                  leading: Icons.palette_rounded,
                  title: Text(I18n.of(context).theme),
                  onPressed: (ctx) {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (BuildContext context) => ThemePage()));
                  },
                ),
              ],
            ),
            SettingsSection(
              title: const Text('发现'),
              tiles: [
                SettingsTile(
                  leading: Icons.library_books_rounded,
                  title: Text(I18n.of(context).manga),
                  onPressed: (ctx) => Leader.push(ctx, RecomMangaPage()),
                ),
                SettingsTile(
                  leading: Icons.menu_book_rounded,
                  title: Text(I18n.of(context).novel),
                  onPressed: (ctx) =>
                      Navigator.of(context, rootNavigator: true)
                          .pushReplacement(MaterialPageRoute(
                              builder: (context) => NovelRail())),
                ),
              ],
            ),
            SettingsSection(
              title: const Text('其他'),
              tiles: [
                SettingsTile(
                  leading: Icons.info_outline_rounded,
                  title: Text(I18n.of(context).about),
                  trailing: Observer(
                    builder: (context) {
                      return Visibility(
                        child: NewVersionChip(),
                        visible: _effectiveHasNewVersion,
                      );
                    },
                  ),
                  onPressed: (ctx) => Leader.push(
                    ctx,
                    AboutPage(newVersion: _effectiveHasNewVersion),
                  ),
                ),
                if (_needBoardSection)
                  SettingsTile(
                    leading: Icons.article_rounded,
                    title: Text(I18n.of(context).bulletin_board),
                    onPressed: (ctx) => Leader.push(
                      ctx,
                      BoardPage(
                        boardList: _boardList,
                      ),
                    ),
                  ),
                Observer(builder: (context) {
                  if (accountStore.now != null)
                    return SettingsTile(
                      leading: Icons.logout_rounded,
                      title: Text(I18n.of(context).logout),
                      onPressed: (ctx) => _showLogoutDialog(ctx),
                    );
                  else
                    return SettingsTile(
                      leading: Icons.login_rounded,
                      title: Text(I18n.of(context).login),
                      onPressed: (ctx) => Leader.push(ctx, LoginPage()),
                    );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (_) => AccountSelectPage()));
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: PainterAvatar(
                url: accountStore.now!.userImage,
                id: int.parse(accountStore.now!.userId),
                width: 48,
                height: 48,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountStore.now!.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (accountStore.now!.mailAddress.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            hideEmail = !hideEmail;
                          });
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                hideEmail
                                    ? accountStore.now!.hiddenEmail()
                                    : accountStore.now!.mailAddress,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hideEmail
                                  ? I18n.of(context).reveal
                                  : I18n.of(context).hide,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(I18n.of(context).logout),
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
        });
    switch (result) {
      case "OK":
        {
          accountStore.deleteAll();
        }
        break;
      case "CANCEL":
        {}
        break;
    }
  }

  bool _needBoardSection = false;
  List<BoardInfo> _boardList = [];

  fetchBoard() async {
    try {
      if (BoardInfo.boardDataLoaded) {
        setState(() {
          _boardList = BoardInfo.boardList;
          _needBoardSection = _boardList.isNotEmpty;
        });
        return;
      }
      final list = await BoardInfo.load();
      setState(() {
        BoardInfo.boardDataLoaded = true;
        _boardList = list;
        _needBoardSection = _boardList.isNotEmpty;
      });
    } catch (e) {}
  }
}