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

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/app_widget_plugin.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/er/prefer.dart';
import 'package:pixez/er/updater.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/about/languages.dart';
import 'package:pixez/page/hello/setting/copy_text_page.dart';
import 'package:pixez/page/hello/setting/setting_cross_adapter_page.dart';
import 'package:pixez/page/network/network_page.dart';
import 'package:pixez/page/platform/platform_page.dart';
import 'package:pixez/store/welcome_page_type.dart';
import 'package:pixez/utils/haptic_util.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:pixez/component/settings_list.dart';

class SettingQualityPage extends StatefulWidget {
  @override
  _SettingQualityPageState createState() => _SettingQualityPageState();
}

class _SettingQualityPageState extends State<SettingQualityPage>
    with TickerProviderStateMixin {
  final _typeList = ["recom", "rank", "follow_illust"];
  int _widgetTypeIndex = -1;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    final type = await Prefer.getString("widget_illust_type") ?? "recom";
    int index = _typeList.indexOf(type);
    final normalizedType = index == -1 ? "recom" : type;
    if (index != -1) {
      setState(() {
        _widgetTypeIndex = index;
      });
    } else {
      setState(() {
        _widgetTypeIndex = 0;
      });
    }
    await _saveWidgetIllustType(normalizedType);
  }

  Future<void> _saveWidgetIllustType(String type) async {
    await Prefer.setString("widget_illust_type", type);
    try {
      await AppWidgetPlugin.setRecommendType(type);
    } catch (e) {}
  }

  String _welcomePageLabel(BuildContext context, WelcomePageType type) {
    switch (type) {
      case WelcomePageType.home:
        return I18n.of(context).home;
      case WelcomePageType.rank:
        return I18n.of(context).rank;
      case WelcomePageType.quickView:
        return I18n.of(context).quick_view;
      case WelcomePageType.search:
        return I18n.of(context).search;
      case WelcomePageType.setting:
        return I18n.of(context).setting;
      case WelcomePageType.news:
        return I18n.of(context).news;
      case WelcomePageType.bookmark:
        return I18n.of(context).bookmark;
      case WelcomePageType.followed:
        return I18n.of(context).followed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).quality_setting)),
      body: Observer(
        builder: (context) {
          return SettingsList(
            sections: [
              SettingsSection(
                tiles: [
                  if (Platform.isAndroid)
                    SettingsTile(
                      leading: Icons.android_rounded,
                      title: Text(I18n.of(context).platform_special_setting),
                      description: Text(
                        "For Android",
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: (ctx) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlatformPage(),
                          ),
                        );
                      },
                    ),
                  SettingsTile(
                    leading: Icons.network_check_rounded,
                    title: Text(I18n.of(context).network),
                    onPressed: (ctx) => Leader.push(
                      context,
                      NetworkPage(automaticallyImplyLeading: true),
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.info_outline_rounded,
                    title: Text(I18n.of(context).share_info_format),
                    onPressed: (ctx) => Leader.push(context, CopyTextPage()),
                  ),
                  _buildLanguageSelect(),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile(
                    leading: Icons.feed_rounded,
                    title: Text(I18n.of(context).feed_preview_quality),
                    trailing: SettingSelectMenu(
                      index: userSetting.feedPreviewQuality,
                      items: [
                        I18n.of(context).medium,
                        I18n.of(context).large,
                        I18n.of(context).source,
                      ],
                      onChange: (index) {
                        userSetting.changeFeedPreviewQuality(index);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.photo_rounded,
                    title: Text(
                      I18n.of(context).illustration_detail_page_quality,
                    ),
                    trailing: SettingSelectMenu(
                      index: userSetting.pictureQuality,
                      items: [
                        I18n.of(context).medium,
                        I18n.of(context).large,
                        I18n.of(context).source,
                      ],
                      onChange: (index) {
                        userSetting.setPictureQuality(index);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.photo_album_rounded,
                    title: Text(I18n.of(context).manga_detail_page_quality),
                    trailing: SettingSelectMenu(
                      index: userSetting.mangaQuality,
                      items: [
                        I18n.of(context).medium,
                        I18n.of(context).large,
                        I18n.of(context).source,
                      ],
                      onChange: (index) {
                        userSetting.setMangaQuality(index);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.zoom_out_map_rounded,
                    title: Text(I18n.of(context).large_preview_zoom_quality),
                    trailing: SettingSelectMenu(
                      index: userSetting.zoomQuality,
                      items: [I18n.of(context).large, I18n.of(context).source],
                      onChange: (index) {
                        userSetting.change(index);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.home_rounded,
                    title: Text(I18n.of(context).welcome_page),
                    trailing: SettingSelectMenu(
                      index: userSetting.materialWelcomePageIndex,
                      items: userSetting.materialWelcomePages
                          .map((type) => _welcomePageLabel(context, type))
                          .toList(),
                      onChange: (index) {
                        userSetting.setMaterialWelcomePageIndex(index);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.layers_outlined_rounded,
                    title: Text(I18n.of(context).layout_mode),
                    trailing: SettingSelectMenu(
                      index: userSetting.padMode,
                      items: ["V:H", "V:V", "H:H"],
                      onChange: (index) {
                        userSetting.setPadMode(index);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.stay_primary_portrait_rounded,
                    title: Text(I18n.of(context).crosscount),
                    trailing: SettingSelectMenu(
                      index: userSetting.crossAdapt
                          ? 3
                          : userSetting.crossCount - 2,
                      items: ['2', '3', '4', "Adapt"],
                      onChange: (index) async {
                        if (index == 3) {
                          await userSetting.setCrossAdapt(true);
                          Leader.push(
                            context,
                            SettingCrossAdpaterPage(h: false),
                          );
                          return;
                        }
                        await userSetting.setCrossAdapt(false);
                        await userSetting.setCrossCount(index + 2);
                        BotToast.showText(
                          text: I18n.of(context).need_to_restart_app,
                        );
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.stay_primary_landscape_rounded,
                    title: Text(I18n.of(context).crosscount),
                    trailing: SettingSelectMenu(
                      index: userSetting.hCrossAdapt
                          ? 3
                          : userSetting.hCrossCount - 2,
                      items: ['2', '3', '4', "Adapt"],
                      onChange: (index) async {
                        if (index == 3) {
                          await userSetting.setHCrossAdapt(true);
                          Leader.push(
                            context,
                            SettingCrossAdpaterPage(h: true),
                          );
                          return;
                        }
                        userSetting.setHCrossCount(index + 2);
                        BotToast.showText(
                          text: I18n.of(context).need_to_restart_app,
                        );
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icons.task_rounded,
                    title:
                        Text(I18n.of(context).max_download_task_running_count),
                    trailing: SettingSelectMenu(
                      index: userSetting.maxRunningTask - 1,
                      items: [
                        ...List<String>.generate(10, (i) => "${i + 1}")
                            .toList(),
                      ],
                      onChange: (index) {
                        userSetting.setMaxRunningTask(index + 1);
                      },
                    ),
                  ),
                  if (_widgetTypeIndex != -1)
                    SettingsTile(
                      leading: Icons.widgets_rounded,
                      title: Text(I18n.of(context).appwidget_recommend_type),
                      trailing: SettingSelectMenu(
                        index: _widgetTypeIndex,
                        items: [
                          I18n.of(context).recommend,
                          I18n.of(context).rank,
                          I18n.of(context).news,
                        ],
                        onChange: (index) async {
                          final type = _typeList[index];
                          setState(() {
                            _widgetTypeIndex = index;
                          });
                          await _saveWidgetIllustType(type);
                        },
                      ),
                    ),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile.switchTile(
                    leading: Icons.screen_rotation_alt_rounded,
                    title: Text(I18n.of(context).special_shaped_screen),
                    initialValue: userSetting.isBangs,
                    onToggle: (value) =>
                        userSetting.setIsBangs(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.save_alt_rounded,
                    title: Text(I18n.of(context).long_press_save_confirm),
                    initialValue: userSetting.longPressSaveConfirm,
                    onToggle: (value) => userSetting
                        .setLongPressSaveConfirm(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.block_rounded,
                    title: Text('H是不行的！'),
                    initialValue: userSetting.hIsNotAllow,
                    onToggle: (value) {
                      if (!(value ?? false)) {
                        BotToast.showText(text: 'H是可以的！(ˉ﹃ˉ)');
                      }
                      userSetting.setHIsNotAllow(value ?? false);
                    },
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.exit_to_app_rounded,
                    title: Text(I18n.of(context).return_again_to_exit),
                    initialValue: userSetting.isReturnAgainToExit,
                    onToggle: (value) =>
                        userSetting.setIsReturnAgainToExit(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.swipe_rounded,
                    title: Text(I18n.of(context).swipe_to_switch_artworks),
                    initialValue: userSetting.swipeChangeArtwork,
                    onToggle: (value) =>
                        userSetting.setSwipeChangeArtwork(value ?? false),
                  ),
                  if (Platform.isAndroid || Platform.isIOS)
                    SettingsTile.switchTile(
                      leading: Icons.vibration_rounded,
                      title: Text(I18n.of(context).haptic_feedback),
                      initialValue: userSetting.hapticFeedback,
                      onToggle: (value) {
                        userSetting.setHapticFeedback(value ?? false);
                        if (value ?? false) HapticUtil.medium();
                      },
                    ),
                  if (Platform.isAndroid || Platform.isIOS)
                    SettingsTile.switchTile(
                      leading: Icons.security_rounded,
                      title: Text(
                        Platform.isIOS
                            ? I18n.of(context).recent_screen_mask
                            : I18n.of(context).secure_window,
                      ),
                      initialValue: userSetting.nsfwMask,
                      onToggle: (value) =>
                          userSetting.changeNsfwMask(value ?? false),
                    ),
                  if (!Platform.isIOS)
                    SettingsTile.switchTile(
                      leading: Icons.open_in_browser_rounded,
                      title:
                          Text(I18n.of(context).open_saucenao_using_webview),
                      initialValue: userSetting.useSaunceNaoWebview,
                      onToggle: (value) => userSetting
                          .setUseSaunceNaoWebview(value ?? false),
                    ),
                  SettingsTile.switchTile(
                    leading: Icons.skip_next_rounded,
                    title:
                        Text(I18n.of(context).illust_detail_save_skip_confirm),
                    initialValue: userSetting.illustDetailSaveSkipLongPress,
                    onToggle: (value) => userSetting
                        .setIllustDetailSaveSkipLongPress(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.auto_awesome_rounded,
                    title: Text(I18n.of(context).show_feed_ai_badge),
                    initialValue: userSetting.feedAIBadge,
                    onToggle: (value) =>
                        userSetting.setFeedAIBadge(value ?? false),
                  ),
                  if (!Constants.isGooglePlay && !Platform.isIOS)
                    SettingsTile.switchTile(
                      leading: Icons.system_update_rounded,
                      title:
                          Text(I18n.of(context).ignore_current_version_update),
                      initialValue: Updater.result == Result.yes &&
                          Updater.latestVersion != null &&
                          userSetting.ignoreUpdateVersion ==
                              Updater.latestVersion,
                      onToggle: (value) async {
                        if (value ?? false) {
                          if (Updater.latestVersion == null) {
                            await Updater.check();
                          }
                          if (Updater.result == Result.yes &&
                              Updater.latestVersion != null) {
                            await userSetting.setIgnoreUpdateVersion(
                              Updater.latestVersion,
                            );
                          }
                        } else {
                          await userSetting.setIgnoreUpdateVersion(null);
                        }
                      },
                    ),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile.switchTile(
                    leading: Icons.star_border_rounded,
                    title: Text(I18n.of(context).follow_after_star),
                    initialValue: userSetting.followAfterStar,
                    onToggle: (value) =>
                        userSetting.setFollowAfterStar(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.lock_outline_rounded,
                    title: Text(I18n.of(context).private_like_by_default),
                    initialValue: userSetting.defaultPrivateLike,
                    onToggle: (value) =>
                        userSetting.setDefaultPrivateLike(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.download_rounded,
                    title: Text(
                      I18n.of(context).automatically_download_when_bookmarking,
                    ),
                    initialValue: userSetting.saveAfterStar,
                    onToggle: (value) =>
                        userSetting.setSaveAfterStar(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.bookmark_border_rounded,
                    title: Text(
                      I18n.of(context).automatically_bookmark_when_downloading,
                    ),
                    initialValue: userSetting.starAfterSave,
                    onToggle: (value) =>
                        userSetting.setStarAfterSave(value ?? false),
                  ),
                  SettingsTile.switchTile(
                    leading: Icons.label_outline_rounded,
                    title: Text(
                      I18n.of(context).automatically_tag_when_bookmarking,
                    ),
                    initialValue: userSetting.autoTagWhenStar,
                    onToggle: (value) =>
                        userSetting.setAutoTagWhenStar(value ?? false),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelect() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final langsponsors = Languages[userSetting.languageNum].sponsors ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.translate_rounded,
                    size: 20, color: colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text("Language",
                    style: textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onSurface)),
              ),
              SettingSelectMenu(
                index: userSetting.languageNum,
                items: [...Languages.map((e) => e.language).toList()],
                onChange: (index) async {
                  await userSetting.setLanguageNum(index);
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Languages.map((e) => e.language)
                    .toList()[userSetting.languageNum],
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              if (langsponsors.isNotEmpty)
                Row(
                  children: langsponsors
                      .map(
                        (langsponsor) => InkWell(
                          borderRadius: BorderRadius.circular(28.0),
                          onTap: () {
                            try {
                              if (Platform.isAndroid &&
                                  !Constants.isGooglePlay) {
                                if (langsponsor.uri.isNotEmpty) {
                                  launchUrlString(langsponsor.uri);
                                }
                              }
                            } catch (e) {}
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircleAvatar(
                                  backgroundImage:
                                      (langsponsor.avatar.isNotEmpty)
                                          ? NetworkImage(langsponsor.avatar)
                                          : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  langsponsor.name ?? '',
                                  style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  }

class SettingSelectMenu extends StatefulWidget {
  final int index;
  final List<String> items;
  final FutureOr<void> Function(int) onChange;
  const SettingSelectMenu({
    super.key,
    required this.index,
    required this.items,
    required this.onChange,
  });

  @override
  State<SettingSelectMenu> createState() => _SettingSelectMenuState();
}

class _SettingSelectMenuState extends State<SettingSelectMenu> {
  int _index = 0;
  late List<String> _items;
  @override
  void initState() {
    _items = widget.items;
    _index = widget.index;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SettingSelectMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.items != widget.items) {
      setState(() {
        _index = widget.index;
        _items = widget.items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () async {
          final renderBox = context.findRenderObject() as RenderBox;
          var local = renderBox.localToGlobal(Offset.zero);
          var size = MediaQuery.of(context).size;
          final selected = await showMenu<int>(
            context: context,
            position: RelativeRect.fromLTRB(
              local.dx - 20,
              local.dy,
              local.dx + size.width - 20,
              size.height + local.dy,
            ),
            items: <PopupMenuEntry<int>>[
              for (int i = 0; i < _items.length; i++)
                if (i != _index)
                  PopupMenuItem(value: i, child: Text(_items[i])),
            ],
          );
          if (selected == null || selected == _index) {
            return;
          }
          setState(() {
            _index = selected;
          });
          await widget.onChange(selected);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [SizedBox(width: 8.0), Text("${_items[_index]}")],
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
            constraints: BoxConstraints(minWidth: 90),
          ),
        ),
      ),
    );
  }
}