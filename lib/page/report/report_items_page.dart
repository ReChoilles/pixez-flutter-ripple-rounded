import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/i18n.dart';

class ReportItemsPage extends StatefulWidget {
  final FutureFunc onSubmit;
  const ReportItemsPage({super.key, required this.onSubmit});

  @override
  State<ReportItemsPage> createState() => _ReportItemsPageState();
}

class Reporter {
  static Future<void> show(BuildContext context, FutureFunc onSubmit) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ReportItemsPage(onSubmit: onSubmit)));
  }
}

class _ReportItemsPageState extends State<ReportItemsPage> {
  final items = [
    "Sexual Content and Profanity",
    "Hate Speech",
    "Terrorist Content",
    "Dangerous Organizations and Movements",
    "Sensitive Events",
    "Bullying and Harassment",
    "Dangerous Products",
    "Marijuana",
    "Tobacco and Alcohol",
  ]; //政策合规问题，应该不需要翻译，或者说翻译有风险

  var _selectItem = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(I18n.of(context).report)),
      body: Stack(
        children: [
          SettingsList(
            sections: [
              SettingsSection(
                title: Text(I18n.of(context).report),
                tiles: List.generate(items.length, (index) {
                  final isSelected = index == _selectItem;
                  return SettingsTile(
                    leading: Icons.report_rounded,
                    title: Text(items[index]),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onPressed: (ctx) {
                      setState(() {
                        _selectItem = index;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  BotToast.showLoading();
                  await widget.onSubmit();
                  BotToast.closeAllLoading();
                  Navigator.of(context).pop();
                  BotToast.showText(
                      text: I18n.ofContext().thanks_for_your_feedback);
                },
                child: Text(I18n.ofContext().submit),
              ),
            ),
          )
        ],
      ),
    );
  }
}