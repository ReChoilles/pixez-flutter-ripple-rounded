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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:pixez/component/new_version_chip.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/constants.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/page/about/contributors.dart';
import 'package:pixez/page/about/thanks_list.dart';
import 'package:pixez/page/about/update_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  final bool? newVersion;

  const AboutPage({Key? key, this.newVersion}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late bool hasNewVersion;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];

  @override
  void initState() {
    initIap();
    hasNewVersion = widget.newVersion ?? false;
    super.initState();
  }

  initIap() async {
    if (!Constants.isGooglePlay && !Platform.isIOS) return;
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription =
        purchaseUpdated.listen(
              (purchaseDetailsList) {
                _listenToPurchaseUpdated(purchaseDetailsList);
              },
              onDone: () {
                _subscription?.cancel();
              },
              onError: (error) {},
            )
            as StreamSubscription<List<PurchaseDetails>>?;
    const Set<String> _kIds = <String>{'support', 'support1'};
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {}
    List<ProductDetails> pDetails = response.productDetails;
    products.clear();
    products.addAll(pDetails);
    if (Platform.isIOS && products.isNotEmpty) {
      try {
        var transactions = await SKPaymentQueueWrapper().transactions();
        transactions.forEach((skPaymentTransactionWrapper) {
          SKPaymentQueueWrapper().finishTransaction(
            skPaymentTransactionWrapper,
          );
        });
      } catch (e) {}
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          BotToast.showText(text: "Thanks");
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).about),
      ),
      body: _buildInfo(context),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Observer(
      builder: (context) {
        return SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                _buildPerolTile(context, colorScheme),
                _buildRightNowTile(context, colorScheme),
              ],
            ),
            SettingsSection(
              title: const Text('Contributors'),
              tiles: [
                _buildContributors(context, colorScheme),
              ],
            ),
            SettingsSection(
              title: const Text('社区'),
              tiles: [
                _buildSettingsTile(
                  leading: Icons.rate_review_rounded,
                  title: Text(I18n.of(context).rate_title),
                  subtitle: Text(I18n.of(context).rate_message),
                  onTap: () async {
                    if (Platform.isIOS) {
                      var url = 'https://apps.apple.com/cn/app/pixez/id1494435126';
                      try {
                        await launchUrlString(url);
                      } catch (e) {}
                    }
                  },
                ),
                if (Platform.isAndroid || kDebugMode) ...[                  _buildSettingsTile(
                    leading: Icons.device_hub_rounded,
                    title: Text(I18n.of(context).repo_address),
                    subtitle: const Text('github.com/Notsfsssf/pixez-flutter'),
                    trailing: Visibility(
                      child: NewVersionChip(),
                      visible: hasNewVersion,
                    ),
                    onTap: () {
                      if (!Constants.isGooglePlay)
                        _showRepoSheet(context);
                    },
                  ),
                ],
                _buildSettingsTile(
                  leading: Icons.share_rounded,
                  title: Text(I18n.of(context).share),
                  subtitle: Text(I18n.of(context).share_this_app_link),
                  onTap: () {
                    if (Platform.isIOS) {
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'https://apps.apple.com/cn/app/pixez/id1494435126',
                        ),
                      );
                    }
                  },
                ),
                _buildSettingsTile(
                  leading: FontAwesomeIcons.telegram,
                  title: const Text("Group"),
                  subtitle: const Text('t.me/PixEzChannel'),
                ),
              ],
            ),
            SettingsSection(
              title: const Text('联系与支持'),
              tiles: [
                _buildSettingsTile(
                  leading: Icons.email_rounded,
                  title: Text(I18n.of(context).feedback),
                  subtitle: const Text('PxezFeedBack@outlook.com'),
                ),
                _buildSettingsTile(
                  leading: Icons.stars_rounded,
                  title: Text(I18n.of(context).support),
                  subtitle: Text(I18n.of(context).support_message),
                ),
                _buildSettingsTile(
                  leading: Icons.favorite_rounded,
                  title: Text(I18n.of(context).thanks),
                  subtitle: const Text('感谢帮助我测试的弹幕委员会群友们\n感谢pixiv cat站主提供的图床'),
                  onTap: () {
                    if (Platform.isAndroid)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              Scaffold(appBar: AppBar(), body: ThanksList()),
                        ),
                      );
                  },
                ),
              ],
            ),
            if (Platform.isAndroid && !Constants.isGooglePlay)
              SettingsSection(
                title: const Text('捐赠'),
                tiles: [
                  _buildSettingsTile(
                    leading: Icons.volunteer_activism_rounded,
                    title: Text(I18n.of(context).donate_title),
                    subtitle: Text(I18n.of(context).donate_message),
                  ),
                  _buildSettingsTile(
                    leading: Icons.payments_rounded,
                    title: const Text('AliPay'),
                    subtitle: const Text('912756674@qq.com'),
                  ),
                  _buildSettingsTile(
                    leading: Icons.payments_rounded,
                    title: const Text('Wechat Pay'),
                    subtitle: const Text('tap'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            content: Image.asset(
                              'assets/images/weixin_qr.png',
                              width: 300,
                              height: 300,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            if (Platform.isIOS) ...[              SettingsSection(
                title: const Text('支持开发者'),
                tiles: [
                  _buildSettingsTile(
                    leading: Icons.favorite_rounded,
                    title: const Text('支持开发者工作'),
                    subtitle: const Text('如果你觉得这个应用还不错，支持一下开发者吧!'),
                    trailing: const Text('12￥'),
                    onTap: () async {
                      BotToast.showText(text: 'try to Purchase');
                      for (var p in products) {
                        if (p.id == "support") {
                          final PurchaseParam purchaseParam = PurchaseParam(
                            productDetails: p,
                          );
                          InAppPurchase.instance.buyConsumable(
                            purchaseParam: purchaseParam,
                          );
                          break;
                        }
                      }
                    },
                  ),
                  _buildSettingsTile(
                    leading: Icons.favorite_rounded,
                    title: const Text('支持开发者工作'),
                    subtitle: const Text('如果你觉得这个应用非常不错，支持一下开发者吧！'),
                    trailing: const Text('25￥'),
                    onTap: () async {
                      BotToast.showText(text: 'try to Purchase');
                      for (var p in products) {
                        if (p.id == "support1") {
                          final PurchaseParam purchaseParam = PurchaseParam(
                            productDetails: p,
                          );
                          InAppPurchase.instance.buyConsumable(
                            purchaseParam: purchaseParam,
                          );
                          break;
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
            if (!Platform.isIOS && products.isNotEmpty && Constants.isGooglePlay)
              SettingsSection(
                title: const Text('支持开发者'),
                tiles: products.map((i) {
                  return _buildSettingsTile(
                    leading: FontAwesomeIcons.mugSaucer,
                    title: Text(i.description),
                    subtitle: Text(i.price),
                    onTap: () {
                      BotToast.showText(text: 'try to Purchase');
                      final PurchaseParam purchaseParam = PurchaseParam(
                        productDetails: i,
                      );
                      InAppPurchase.instance.buyConsumable(
                        purchaseParam: purchaseParam,
                      );
                    },
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPerolTile(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (BuildContext context) {
            return InkWell(
              onTap: () {
                if (Platform.isAndroid)
                  launchUrlString(
                    Constants.isGooglePlay
                        ? "https://music.youtube.com/watch?v=qfDhiBUNzwA&feature=share"
                        : "https://music.apple.com/cn/album/intrauterine-education-single/1515096587",
                  );
              },
              child: Container(
                child: Image.asset(
                  'assets/images/liz.png',
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/me.jpg',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perol_Notsfsssf',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    I18n.of(context).perol_message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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

  Widget _buildRightNowTile(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200.0,
              child: const Center(child: Text("这里空空的，这个设计师显然没有什么话要说")),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/right_now.jpg',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Right now',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    I18n.of(context).right_now_message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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

  Widget _buildContributors(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: contributors.length,
          itemBuilder: (context, index) {
            final data = contributors[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  try {
                    if (data.onPressed == null) return;
                    await data.onPressed!(context);
                  } catch (e) {}
                },
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(data.avatar),
                        radius: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        data.content,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required dynamic leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

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
          leading,
          size: 20,
          color: colorScheme.onSecondaryContainer,
        ),
      );
    } else {
      iconWidget = leading;
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: colorScheme.onSurface),
                  child: title,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      child: subtitle,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[            const SizedBox(width: 8),
            trailing!,
          ],
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: content,
      );
    }
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: content,
    );
  }

  void _showRepoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text('Version ${Constants.tagName}'),
                subtitle: Text(I18n.of(context).go_to_project_address),
                onTap: () {
                  try {
                    launchUrlString(
                      'https://github.com/Notsfsssf/pixez-flutter',
                    );
                  } catch (e) {}
                },
                trailing: IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    try {
                      launchUrlString(
                        'https://github.com/Notsfsssf/pixez-flutter',
                      );
                    } catch (e) {}
                  },
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(I18n.of(context).check_for_updates),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UpdatePage()),
                  );
                },
                trailing: Icon(Icons.update),
              ),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://avatars1.githubusercontent.com/u/9017470?s=400&v=4',
                  ),
                ),
                title: Text('Skimige'),
                subtitle: Text(I18n.of(context).skimige_message),
              ),
            ],
          ),
        );
      },
    );
  }
}
