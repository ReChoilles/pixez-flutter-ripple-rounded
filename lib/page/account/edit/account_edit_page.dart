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

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/page/account/edit/account_edit_store.dart';
import 'package:pixez/page/webview/account_deletion_webview_page.dart';

class AccountEditPage extends StatefulWidget {
  @override
  _AccountEditPageState createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  late TextEditingController _passwordController,
      _oldPasswordController,
      _emailController,
      _accountController;
  AccountEditStore _accountEditStore = AccountEditStore();

  @override
  void initState() {
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _accountController = TextEditingController();
    _oldPasswordController = TextEditingController();
    if (accountStore.now != null) {
      if (accountStore.now!.isMailAuthorized != 1) {
        _oldPasswordController.text = accountStore.now!.passWord;
      }
      _accountController.text = accountStore.now!.account;
      _emailController.text = accountStore.now!.mailAddress;
    }

    super.initState();
  }

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).account_message),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (_oldPasswordController.text.isEmpty ||
                  _emailController.text.isEmpty) {
                return;
              }
              if (_emailController.text.isNotEmpty &&
                  !_emailController.text.contains('@')) {
                BotToast.showCustomText(
                  toastBuilder: (_) => Align(
                    alignment: Alignment(0, 0.8),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
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
                              child: Icon(Icons.error, size: 20, color: colorScheme.onSecondaryContainer),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Email format error",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                return;
              }
              bool success = await _accountEditStore.fetch(
                  (_emailController.value.text.isEmpty
                      ? null
                      : _emailController.value.text)!,
                  _passwordController.value.text.isEmpty
                      ? null
                      : _passwordController.value.text,
                  _oldPasswordController.value.text,
                  null);
              if (success) {
                if (accountStore.now != null) {
                  if (_passwordController.text.isNotEmpty) {
                    accountStore.now!.passWord = _passwordController.text;
                  }
                  if (_emailController.text.isNotEmpty) {
                    accountStore.now!.mailAddress = _emailController.text;
                  }
                  accountStore.updateSingle(accountStore.now!);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${_accountEditStore.errorString}'),
                  backgroundColor: Colors.red,
                ));
              }
            },
          )
        ],
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('账户信息'),
            tiles: [
              _buildTextFieldTile(
                context,
                controller: _accountController,
                enabled: false,
                label: I18n.of(context).account,
                icon: Icons.person_rounded,
                colorScheme: colorScheme,
              ),
              _buildTextFieldTile(
                context,
                controller: _oldPasswordController,
                label: I18n.of(context).current_password,
                icon: Icons.lock_rounded,
                colorScheme: colorScheme,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  ),
                  onPressed: _toggle,
                ),
              ),
              _buildTextFieldTile(
                context,
                controller: _passwordController,
                label: I18n.of(context).new_password,
                icon: Icons.lock_outline_rounded,
                colorScheme: colorScheme,
              ),
              _buildTextFieldTile(
                context,
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_rounded,
                colorScheme: colorScheme,
              ),
            ],
          ),
          if (accountStore.now != null &&
              accountStore.now!.isMailAuthorized == 1)
            SettingsSection(
              tiles: [
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () async {
                    Clipboard.setData(
                        ClipboardData(text: accountStore.now!.refreshToken));
                    BotToast.showText(text: I18n.of(context).copied_to_clipboard);
                  },
                  child: Padding(
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
                          child: Icon(
                            Icons.key_rounded,
                            size: 20,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Token export",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: colorScheme.onSurface),
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
                ),
              ],
            ),
          SettingsSection(
            tiles: [
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text("${I18n.of(ctx).account_deletion}?"),
                          content:
                              Text("${I18n.of(ctx).account_deletion_subtitle}"),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  await accountStore.deleteAll();
                                  await Leader.push(
                                      context, AccountDeletionPage());
                                  Navigator.of(context).pop();
                                },
                                child: Text(I18n.of(ctx).ok)),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text(I18n.of(ctx).cancel)),
                          ],
                        );
                      });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_forever_rounded,
                          size: 20,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          I18n.of(context).account_deletion,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: colorScheme.onSurface),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldTile(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                suffixIcon: suffixIcon,
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}