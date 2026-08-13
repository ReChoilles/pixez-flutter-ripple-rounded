import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/utils/haptic_util.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key, required this.sections, this.maxWidth = 1000});
  final List<Widget> sections;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: sections.length,
      itemBuilder: (context, index) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: sections[index],
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.tiles,
    this.title,
    this.bottomInfo,
    this.margin,
  });
  final List<Widget> tiles;
  final Widget? title;
  final Widget? bottomInfo;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DefaultTextStyle.merge(
                style: textTheme.titleSmall
                    ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                child: title!,
              ),
            ),
          SettingsSplitGroup(children: tiles),
          if (bottomInfo != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DefaultTextStyle.merge(
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                child: bottomInfo!,
              ),
            ),
        ],
      ),
    );
  }
}

class SettingsSplitGroup extends StatelessWidget {
  const SettingsSplitGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayTiles = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      final isFirst = i == 0;
      final isLast = i == children.length - 1;
      final hasDivider = !isLast;
      displayTiles.add(
        _SplitRow(
          isFirst: isFirst,
          isLast: isLast,
          hasDivider: hasDivider,
          child: children[i],
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: displayTiles,
        ),
      ),
    );
  }
}

class _SplitRow extends StatefulWidget {
  const _SplitRow({
    required this.isFirst,
    required this.isLast,
    required this.hasDivider,
    required this.child,
  });
  final bool isFirst;
  final bool isLast;
  final bool hasDivider;
  final Widget child;

  @override
  State<_SplitRow> createState() => _SplitRowState();
}

class _SplitRowState extends State<_SplitRow> {
  double _radius = 4.0;
  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _pressed = true;
      _radius = 24.0;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _pressed = false;
      _radius = 4.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _pressed = false;
      _radius = 4.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: _pressed ? 4 : 0),
      decoration: BoxDecoration(
        color: _pressed
            ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.child,
          if (widget.hasDivider && !_pressed)
            Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
        ],
      ),
    );
  }
}

enum _TileKind { plain, toggle, radio }

class SettingsTile<T> extends StatelessWidget {
  final _TileKind _kind;

  final Widget title;
  final Widget? leading;
  final Widget? description;
  final Widget? trailing;
  final T? value;
  final void Function(BuildContext context)? onPressed;
  final bool enabled;

  // Switch
  final bool? initialValue;
  final void Function(bool?)? onToggle;

  // Radio
  final T? radioValue;

  const SettingsTile({
    super.key,
    required this.title,
    this.leading,
    this.description,
    this.trailing,
    this.value,
    this.onPressed,
    this.enabled = true,
  })  : _kind = _TileKind.plain,
        onToggle = null,
        initialValue = null,
        radioValue = null;

  const SettingsTile.switchTile({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onToggle,
    this.leading,
    this.description,
    this.enabled = true,
  })  : _kind = _TileKind.toggle,
        trailing = null,
        value = null,
        onPressed = null,
        radioValue = null;

  const SettingsTile.radioTile({
    super.key,
    required this.title,
    required this.radioValue,
    this.leading,
    this.description,
    this.enabled = true,
  })  : _kind = _TileKind.radio,
        trailing = null,
        value = null,
        onPressed = null,
        initialValue = null,
        onToggle = null;

  @override
  Widget build(BuildContext context) {
    switch (_kind) {
      case _TileKind.toggle:
        return _SettingsTileSwitch(
          title: title,
          leading: leading,
          description: description,
          enabled: enabled,
          initialValue: initialValue ?? false,
          onToggle: onToggle,
        );
      case _TileKind.radio:
        return _SettingsTileRadio<T>(
          title: title,
          leading: leading,
          description: description,
          enabled: enabled,
          radioValue: radioValue,
        );
      case _TileKind.plain:
        return _SettingsTilePlain(
          title: title,
          leading: leading,
          description: description,
          trailing: trailing,
          enabled: enabled,
          onPressed: onPressed,
        );
    }
  }
}

class _SettingsTilePlain extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? description;
  final Widget? trailing;
  final bool enabled;
  final void Function(BuildContext context)? onPressed;

  const _SettingsTilePlain({
    required this.title,
    this.leading,
    this.description,
    this.trailing,
    this.enabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget iconWidget;
    if (leading is IconData) {
      iconWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          leading as IconData,
          size: 20,
          color: colorScheme.onSecondaryContainer,
        ),
      );
    } else if (leading != null) {
      iconWidget = leading!;
    } else {
      iconWidget = const SizedBox.shrink();
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (leading != null) ...[
            iconWidget,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: textTheme.bodyLarge?.copyWith(
                    color: enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  child: title,
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: DefaultTextStyle.merge(
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      child: description!,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          if (onPressed != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );

    if (onPressed != null) {
      return InkWell(
        onTap: enabled ? () => onPressed!(context) : null,
        borderRadius: BorderRadius.circular(4),
        child: content,
      );
    }
    return content;
  }
}

class _SettingsTileSwitch extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? description;
  final bool enabled;
  final bool initialValue;
  final void Function(bool?)? onToggle;

  const _SettingsTileSwitch({
    required this.title,
    this.leading,
    this.description,
    this.enabled = true,
    required this.initialValue,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget iconWidget;
    if (leading is IconData) {
      iconWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          leading as IconData,
          size: 20,
          color: colorScheme.onTertiaryContainer,
        ),
      );
    } else if (leading != null) {
      iconWidget = leading!;
    } else {
      iconWidget = const SizedBox.shrink();
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[
            iconWidget,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: textTheme.bodyLarge?.copyWith(
                    color: enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  child: title,
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: DefaultTextStyle.merge(
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      child: description!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: Switch.adaptive(
              value: initialValue,
              onChanged: enabled ? onToggle : null,
            ),
          ),
        ],
      ),
    );

    if (onToggle != null) {
      return InkWell(
        onTap: enabled
            ? () {
                onToggle!(!initialValue);
              }
            : null,
        borderRadius: BorderRadius.circular(4),
        child: content,
      );
    }
    return content;
  }
}

class _SettingsTileRadio<T> extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? description;
  final bool enabled;
  final T? radioValue;

  const _SettingsTileRadio({
    required this.title,
    this.leading,
    this.description,
    this.enabled = true,
    required this.radioValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget iconWidget;
    if (leading is IconData) {
      iconWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          leading as IconData,
          size: 20,
          color: colorScheme.onSecondaryContainer,
        ),
      );
    } else if (leading != null) {
      iconWidget = leading!;
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[
            iconWidget,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: textTheme.bodyLarge?.copyWith(
                    color: enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  child: title,
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: DefaultTextStyle.merge(
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      child: description!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 22,
            width: 22,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.onSurfaceVariant,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsRadioSection<T> extends StatelessWidget {
  final Widget title;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final List<Widget> tiles;

  const SettingsRadioSection({
    super.key,
    required this.title,
    required this.groupValue,
    required this.tiles,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final wrappedTiles = tiles.map((tile) {
      if (tile is _SettingsTileRadio<T>) {
        final isSelected = tile.radioValue == groupValue;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => onChanged?.call(tile.radioValue),
            child: Row(
              children: [
                if (tile.leading != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tile.leading is IconData ? (tile.leading as IconData) : Icons.circle,
                      size: 20,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                if (tile.leading != null) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTextStyle.merge(
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                        child: tile.title,
                      ),
                      if (tile.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: DefaultTextStyle.merge(
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            child: tile.description,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 22,
                  width: 22,
                  child: isSelected
                      ? Icon(Icons.radio_button_checked_rounded,
                          color: colorScheme.primary, size: 22)
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.onSurfaceVariant,
                              width: 2,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      }
      return tile;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DefaultTextStyle.merge(
            style: textTheme.labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            child: title,
          ),
        ),
        ...wrappedTiles,
      ],
    );
  }
}

class SettingsCategoryTile extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final Widget? description;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final Color? iconBackground;

  const SettingsCategoryTile({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.trailing,
    this.onPressed,
    this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground ?? colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  child: title,
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: DefaultTextStyle.merge(
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      child: description!,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );

    if (onPressed != null) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: content,
      );
    }
    return content;
  }
}

class SettingsSliderTile extends StatelessWidget {
  final Widget title;
  final IconData? leading;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double>? onChanged;
  final int? divisions;
  final String Function(double)? displayValue;

  const SettingsSliderTile({
    super.key,
    required this.title,
    this.leading,
    required this.min,
    required this.max,
    required this.value,
    this.onChanged,
    this.divisions,
    this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget iconWidget;
    if (leading != null) {
      iconWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          leading,
          size: 20,
          color: colorScheme.onTertiaryContainer,
        ),
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                iconWidget,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: DefaultTextStyle.merge(
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                  child: title,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayValue?.call(value) ?? value.toStringAsFixed(0),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: leading != null ? 56 : 0),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.surfaceContainerHighest,
                thumbColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withValues(alpha: 0.12),
              ),
              child: Slider(
                min: min,
                max: max,
                value: value,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}