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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/painter_avatar.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/models/account.dart';
import 'package:pixez/page/login/login_page.dart';

class AccountSelectPage extends StatefulWidget {
  @override
  _AccountSelectPageState createState() => _AccountSelectPageState();
}

class _AccountSelectPageState extends State<AccountSelectPage> {
  @override
  void initState() {
    accountStore.fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Observer(builder: (context) {
      return Scaffold(
        body: SettingsList(
          sections: [
            SettingsSection(
              tiles: List.generate(accountStore.accounts.length, (index) {
                AccountPersist accountPersist = accountStore.accounts[index];
                final isCurrent =
                    accountStore.accounts.indexOf(accountStore.now) == index;
                return InkWell(
                  onTap: isCurrent
                      ? null
                      : () async {
                          await accountStore.select(index);
                          setState(() {});
                        },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        PainterAvatar(
                          url: accountStore.accounts[index].userImage,
                          id: int.parse(
                              accountStore.accounts[index].userId),
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
                                ),
                                child: Text(accountPersist.name),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: DefaultTextStyle.merge(
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  child: Text(accountPersist.mailAddress),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          Icon(Icons.check, color: colorScheme.primary)
                        else ...[
                          IconButton(
                            icon: Icon(Icons.delete, size: 20),
                            onPressed: () {
                              accountStore.deleteSingle(accountPersist.id!);
                            },
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        appBar: AppBar(
          title: Text(I18n.of(context).account_change),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (_) => LoginPage())),
            )
          ],
        ),
      );
    });
  }
}