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
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).about),
        ),
        body: _buildInfo(context),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Observer(
      builder: (context) {
        return SettingsList(
          sections: [
            SettingsSection(
              tiles: [
                _buildPerolTile(context),
                _buildRightNowTile(context),
              ],
            ),
            SettingsSection(
              title: const Text('Contributors'),
              tiles: [
                _buildContributors(context),
              ],
            ),
            SettingsSection(
              title: const Text('社区'),
              tiles: [
                SettingsTile(
                  leadingWidget: _tileIcon(context, Icons.rate_review_rounded),
                  title: Text(I18n.of(context).rate_title),
                  description: Text(I18n.of(context).rate_message),
                  onPressed: (ctx) async {
                    if (Platform.isIOS) {
                      var url = 'https://apps.apple.com/cn/app/pixez/id1494435126';
                      try {
                        await launchUrlString(url);
                      } catch (e) {}
                    }
                  },
                ),
                if (Platform.isAndroid || kDebugMode) [
                  SettingsTile(
                    leadingWidget: _tileIcon(context, Icons.device_hub_rounded),
                    title: Text(I18n.of(context).repo_address),
                    description: const Text('github.com/Notsfsssf/pixez-flutter'),
                    trailing: Visibility(
                      child: NewVersionChip(),
                      visible: hasNewVersion,
                    ),
                    onPressed: (ctx) {
                      if (!Constants.isGooglePlay)
                        _showRepoSheet(ctx);
                    },
                  ),
                ],
                SettingsTile(
                  leadingWidget: _tileIcon(context, Icons.share_rounded),
                  title: Text(I18n.of(context).share),
                  description: Text(I18n.of(context).share_this_app_link),
                  onPressed: (ctx) {
                    if (Platform.isIOS) {
                      SharePlus.instance.share(
                        ShareParams(
                          text: 'https://apps.apple.com/cn/app/pixez/id1494435126',
                        ),
                      );
                    }
                  },
                ),
                SettingsTile(
                  leadingWidget: _tileIcon(context, FontAwesomeIcons.telegram),
                  title: const Text("Group"),
                  description: const Text('t.me/PixEzChannel'),
                ),
              ],
            ),
            SettingsSection(
              title: const Text('联系与支持'),
              tiles: [
                SettingsTile(
                  leadingWidget: _tileIcon(context, Icons.email_rounded),
                  title: Text(I18n.of(context).feedback),
                  description: const Text('PxezFeedBack@outlook.com'),
                ),
                SettingsTile(
                  leadingWidget: _tileIcon(context, Icons.stars_rounded),
                  title: Text(I18n.of(context).support),
                  description: Text(I18n.of(context).support_message),
                ),
                SettingsTile(
                  leadingWidget: _tileIcon(context, Icons.favorite_rounded),
                  title: Text(I18n.of(context).thanks),
                  description: const Text('感谢帮助我测试的弹幕委员会群友们\n感谢pixiv cat站主提供的图床'),
                  onPressed: (ctx) {
                    if (Platform.isAndroid)
                      Navigator.of(ctx).push(
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
                  SettingsTile(
                    leadingWidget: _tileIcon(context, Icons.volunteer_activism_rounded),
                    title: Text(I18n.of(context).donate_title),
                    description: Text(I18n.of(context).donate_message),
                  ),
                  SettingsTile(
                    leadingWidget: _tileIcon(context, Icons.payments_rounded),
                    title: const Text('AliPay'),
                    description: const Text('912756674@qq.com'),
                  ),
                  SettingsTile(
                    leadingWidget: _tileIcon(context, Icons.payments_rounded),
                    title: const Text('Wechat Pay'),
                    description: const Text('tap'),
                    onPressed: (ctx) {
                      showDialog(
                        context: ctx,
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
            if (Platform.isIOS) [
              SettingsSection(
                title: const Text('支持开发者'),
                tiles: [
                  SettingsTile(
                    leadingWidget: _tileIcon(context, Icons.favorite_rounded),
                    title: const Text('支持开发者工作'),
                    description: const Text('如果你觉得这个应用还不错，支持一下开发者吧!'),
                    trailing: const Text('12￥'),
                    onPressed: (ctx) async {
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
                  SettingsTile(
                    leadingWidget: _tileIcon(context, Icons.favorite_rounded),
                    title: const Text('支持开发者工作'),
                    description: const Text('如果你觉得这个应用非常不错，支持一下开发者吧！'),
                    trailing: const Text('25￥'),
                    onPressed: (ctx) async {
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
                  return SettingsTile(
                    leadingWidget: _tileIcon(context, FontAwesomeIcons.mugSaucer),
                    title: Text(i.description),
                    description: Text(i.price),
                    onPressed: (ctx) {
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

  Widget _buildPerolTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsTile(
      leadingWidget: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/images/me.jpg',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        'Perol_Notsfsssf',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      description: Text(I18n.of(context).perol_message),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      onPressed: (ctx) {
        showModalBottomSheet(
          context: ctx,
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
    );
  }

  Widget _buildRightNowTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsTile(
      leadingWidget: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/images/right_now.jpg',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        'Right now',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      description: Text(I18n.of(context).right_now_message),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      onPressed: (ctx) {
        showModalBottomSheet(
          context: ctx,
          builder: (BuildContext context) {
            return Container(
              height: 200.0,
              child: const Center(child: Text("这里空空的，这个设计师显然没有什么话要说")),
            );
          },
        );
      },
    );
  }

  Widget _buildContributors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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

  Widget _tileIcon(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 20,
        color: colorScheme.onSecondaryContainer,
      ),
    );
  }

  void _showRepoSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SettingsTile(
                leadingWidget: _tileIcon(context, Icons.link_rounded),
                title: Text('Version ${Constants.tagName}'),
                description: Text(I18n.of(context).go_to_project_address),
                onPressed: (ctx) {
                  try {
                    launchUrlString(
                      'https://github.com/Notsfsssf/pixez-flutter',
                    );
                  } catch (e) {}
                },
              ),
              SettingsTile(
                leadingWidget: _tileIcon(context, Icons.update_rounded),
                title: Text(I18n.of(context).check_for_updates),
                onPressed: (ctx) {
                  Navigator.of(ctx).push(
                    MaterialPageRoute(builder: (_) => UpdatePage()),
                  );
                },
              ),
              SettingsTile(
                leadingWidget: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://avatars1.githubusercontent.com/u/9017470?s=400&v=4',
                  ),
                ),
                title: Text('Skimige'),
                description: Text(I18n.of(context).skimige_message),
              ),
            ],
          ),
        );
      },
    );
  }
}