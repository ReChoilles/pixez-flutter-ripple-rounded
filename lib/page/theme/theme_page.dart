/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/picker/colorpicker.dart';
import 'package:pixez/component/picker/utils.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/utils/haptic_util.dart';

class ColorPickPage extends StatefulWidget {
  final Color initialColor;

  ColorPickPage({required this.initialColor});

  @override
  _ColorPickPageState createState() => _ColorPickPageState();
}

class _ColorPickPageState extends State<ColorPickPage> {
  late Color pickerColor;
  @override
  void initState() {
    pickerColor = widget.initialColor;
    super.initState();
  }

  final skinList = [
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.cyan[500],
      tabBarTheme: TabBarThemeData(indicatorColor: Colors.cyan[500]),
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.pink[500],
      tabBarTheme: TabBarThemeData(indicatorColor: Colors.pink[500]),
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green[500],
      tabBarTheme: TabBarThemeData(indicatorColor: Colors.green[600]),
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.brown[500],
      tabBarTheme: TabBarThemeData(indicatorColor: Colors.brown[600]),
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.purple[500],
      tabBarTheme: TabBarThemeData(indicatorColor: Colors.purple[600]),
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue[500],
      tabBarTheme: TabBarThemeData(indicatorColor: Colors.blue[500]),
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFFFB7299),
      tabBarTheme: TabBarThemeData(indicatorColor: Color(0xFFFB7299)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).pick_a_color),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                final TextEditingController textEditingController =
                    TextEditingController(
                        text: pickerColor.toHexString(
                            includeHashSign: true,
                            enableAlpha: false,
                            toUpperCase: false));

                String result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("16 radix RGB"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        content: TextField(
                          controller: textEditingController,
                          maxLength: 6,
                          decoration: InputDecoration(
                              prefix: Text("color(0xff"), suffix: Text(")")),
                        ),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                final result = textEditingController.text
                                    .trim()
                                    .toLowerCase();
                                if (result.length != 6) {
                                  return;
                                }
                                Navigator.of(context)
                                    .pop("color(0xff${result})");
                              },
                              child: Text(I18n.of(context).ok)),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(I18n.of(context).cancel)),
                        ],
                      );
                    });
                if (result == null) return;
                Color color = _stringToColor(result);
                setState(() {
                  pickerColor = color;
                });
              }),
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(pickerColor);
              })
        ],
      ),
      body: LayoutBuilder(builder: (context, snapshot) {
        final rowCount = max(3, (snapshot.maxWidth / 200).floor());
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ColorPicker(
                  enableAlpha: false,
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      pickerColor = color;
                    });
                  },
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
            ),
            SliverGrid.count(
              crossAxisCount: rowCount,
              children: [
                for (final i in skinList)
                  InkWell(
                    onTap: () {
                      setState(() {
                        pickerColor = i.primaryColor;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: i.primaryColor,
                      ),
                    ),
                  )
              ],
            )
          ],
        );
      }),
    );
  }

  Color _stringToColor(String colorString) {
    String valueString =
        colorString.split('(0x')[1].split(')')[0];
    int value = int.parse(valueString, radix: 16);
    Color otherColor = Color(value);
    return otherColor;
  }
}

final List<Map<String, dynamic>> _colorThemes = [
  {'color': Colors.green, 'label': '默认'},
  {'color': Colors.cyan, 'label': '青色'},
  {'color': Colors.lightBlue, 'label': '天蓝'},
  {'color': Colors.deepPurple, 'label': '深紫'},
  {'color': Colors.red, 'label': '红色'},
  {'color': Colors.amber, 'label': '琥珀'},
  {'color': Colors.lime, 'label': '酸橙'},
  {'color': Colors.brown, 'label': '棕色'},
  {'color': Colors.blueGrey, 'label': '蓝灰'},
];

class _PaletteCard extends StatefulWidget {
  final Color color;
  final bool selected;

  const _PaletteCard({
    required this.color,
    required this.selected,
  });

  @override
  State<_PaletteCard> createState() => _PaletteCardState();
}

class _PaletteCardState extends State<_PaletteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    if (widget.selected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_PaletteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.forward();
    } else if (!widget.selected && oldWidget.selected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 64,
      height: 64,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: widget.selected
              ? BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                )
              : BorderSide.none,
        ),
        color: colorScheme.surfaceContainerHighest,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipOval(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: widget.color.withValues(alpha: 0.7),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              color: widget.color
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: widget.color
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.selected)
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colorScheme.surfaceContainerLow,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final MenuController _menuController = MenuController();

  void _setTheme(Color? color) {
    if (color == null) {
      userSetting.setThemeData(Colors.green);
    } else {
      userSetting.setThemeData(color);
    }
    topStore.setTop("main");
  }

  void _resetTheme() {
    userSetting.setThemeData(Colors.green);
    topStore.setTop("main");
  }

  void _updateThemeMode(String theme) async {
    ThemeMode newMode;
    if (theme == 'dark') {
      newMode = ThemeMode.dark;
    } else if (theme == 'light') {
      newMode = ThemeMode.light;
    } else {
      newMode = ThemeMode.system;
    }
    await userSetting.setThemeMode(ThemeMode.values.indexOf(newMode));
    setState(() {});
  }

  void _updateOledEnhance() {
    userSetting.setIsAMOLED(userSetting.isAMOLED);
    topStore.setTop("main");
  }

  String _getThemeModeLabel() {
    switch (userSetting.themeMode) {
      case ThemeMode.system:
        return I18n.of(context).system;
      case ThemeMode.light:
        return I18n.of(context).light;
      case ThemeMode.dark:
        return I18n.of(context).dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).theme)),
      body: Observer(builder: (_) {
        return SettingsList(
          sections: [
            SettingsSection(
              title: const Text('外观'),
              tiles: [
                SettingsTile(
                  leading: Icons.dark_mode_rounded,
                  title: const Text('深色模式'),
                  value: Text(
                    _getThemeModeLabel(),
                  ),
                  onPressed: (_) {
                    _showThemeModeBottomSheet();
                  },
                ),
                SettingsTile(
                  leading: Icons.palette_rounded,
                  enabled: !userSetting.useDynamicColor,
                  title: const Text('配色方案'),
                  onPressed: (_) => _showColorPickerDialog(),
                ),
                SettingsTile.switchTile(
                  leading: Icons.colorize_rounded,
                  enabled: !Platform.isIOS,
                  initialValue: userSetting.useDynamicColor,
                  onToggle: (value) async {
                    await userSetting.setUseDynamicColor(value ?? false);
                    topStore.setTop("main");
                  },
                  title: const Text('动态配色'),
                  description: const Text('支持安卓 12 及以上和桌面平台'),
                ),
              ],
              bottomInfo: const Text('关闭动态配色后可自定义主题色'),
            ),
            SettingsSection(
              title: const Text('显示'),
              tiles: [
                SettingsTile.switchTile(
                  leading: Icons.contrast_rounded,
                  initialValue: userSetting.isAMOLED,
                  onToggle: (value) async {
                    await userSetting.setIsAMOLED(value ?? false);
                    _updateOledEnhance();
                  },
                  title: const Text('OLED 优化'),
                  description: const Text('深色模式下使用纯黑背景'),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '配色方案',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          content: StatefulBuilder(builder:
              (BuildContext context, StateSetter setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._colorThemes.map(
                        (e) {
                          final color = e['color'] as Color;
                          final index = _colorThemes.indexOf(e);
                          final isCustom =
                              !_colorThemes.any((t) => t['color'] == userSetting.seedColor);
                          final selected = isCustom
                              ? false
                              : userSetting.seedColor.value == color.value;
                          return GestureDetector(
                            onTap: () {
                              if (index == 0) {
                                _resetTheme();
                              } else {
                                _setTheme(color);
                              }
                              Navigator.of(context).pop();
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _PaletteCard(
                                  color: color,
                                  selected: selected,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  e['label'],
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pickColor();
                      },
                      icon: const Icon(Icons.colorize_rounded, size: 18),
                      label: const Text('自定义颜色'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  void _showThemeModeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildThemeModeOption(
                  context,
                  icon: Icons.brightness_auto_rounded,
                  label: I18n.of(context).system,
                  mode: ThemeMode.system,
                ),
                _buildThemeModeOption(
                  context,
                  icon: Icons.light_mode_rounded,
                  label: I18n.of(context).light,
                  mode: ThemeMode.light,
                ),
                _buildThemeModeOption(
                  context,
                  icon: Icons.dark_mode_rounded,
                  label: I18n.of(context).dark,
                  mode: ThemeMode.dark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
  }) {
    final selected = userSetting.themeMode == mode;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticUtil.selectionClick();
            _updateThemeMode(
                mode == ThemeMode.system
                    ? 'system'
                    : mode == ThemeMode.light
                        ? 'light'
                        : 'dark');
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _pickColor() async {
    Color? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            ColorPickPage(initialColor: userSetting.seedColor)));
    if (result != null) {
      await userSetting.setThemeData(result);
      topStore.setTop("main");
    }
  }
}
