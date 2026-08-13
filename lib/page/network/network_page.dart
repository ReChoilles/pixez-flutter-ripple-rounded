import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pixez/component/pixiv_image.dart';
import 'package:pixez/component/settings_list.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/network_mode.dart';

class NetworkPage extends StatefulWidget {
  final bool? automaticallyImplyLeading;

  const NetworkPage({Key? key, this.automaticallyImplyLeading})
      : super(key: key);

  @override
  _NetworkPageState createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  late bool _automaticallyImplyLeading;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController(
      text: userSetting.pictureSource,
    );
    _automaticallyImplyLeading = widget.automaticallyImplyLeading ?? false;
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                automaticallyImplyLeading: _automaticallyImplyLeading,
                elevation: 0.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  I18n.of(context).network,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  I18n.of(context).network_tip,
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildNetworkModeSetting(context),
              ),
              Visibility(
                visible: userSetting.networkMode.allowsImageSource,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsSection(
                      title: Text(I18n.of(context).image_site),
                      tiles: [
                        SettingsTile(
                          leading: Icons.refresh_rounded,
                          title: Text(I18n.of(context).image_site),
                          description: Text(I18n.of(context).default_title),
                          onPressed: (ctx) async {
                            userSetting.setPictureSource(ImageHost);
                            splashStore.setHost(ImageHost);
                            splashStore.helloWord = "= w =";
                            splashStore.maybeFetch();
                          },
                        ),
                        SettingsTile(
                          leading: Icons.image_rounded,
                          title: Text(ImageCatHost),
                          onPressed: (ctx) async {
                            userSetting.setPictureSource(ImageCatHost);
                            splashStore.setHost(ImageCatHost);
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              I18n.of(context).custom_host,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: TextField(
                              maxLines: 1,
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                hintText: 'Host',
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (_textEditingController.text.isEmpty)
                                      return;
                                    if (_textEditingController.text
                                        .trim()
                                        .contains(" ")) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("illegal"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    final host = _textEditingController.text
                                        .trim();
                                    await userSetting.setPictureSource(host);
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                  },
                                  icon: Icon(Icons.check, color: Colors.black),
                                ),
                                labelText: I18n.of(context).custom_host,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNetworkModeSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsRadioSection<NetworkMode>(
          title: Text(I18n.of(context).network_mode_oauth),
          groupValue: userSetting.oauthNetworkMode,
          onChanged: (value) {
            if (value != null) {
              userSetting.setOAuthNetworkMode(value);
            }
          },
          tiles: NetworkMode.selectableValues.map((mode) {
            return SettingsTile.radioTile(
              leading: _networkModeIcon(mode),
              title: Text(_networkModeTitle(context, mode)),
              description: Text(_networkModeMessage(context, mode)),
              radioValue: mode,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        SettingsRadioSection<NetworkMode>(
          title: Text(I18n.of(context).network_mode_api_service),
          groupValue: userSetting.networkMode,
          onChanged: (value) {
            if (value != null) {
              userSetting.setNetworkMode(value);
            }
          },
          tiles: NetworkMode.selectableValues.map((mode) {
            return SettingsTile.radioTile(
              leading: _networkModeIcon(mode),
              title: Text(_networkModeTitle(context, mode)),
              description: Text(_networkModeMessage(context, mode)),
              radioValue: mode,
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _networkModeIcon(NetworkMode mode) {
    switch (mode) {
      case NetworkMode.compat:
        return Icons.bolt_rounded;
      case NetworkMode.ech:
        return Icons.lock_rounded;
      case NetworkMode.standard:
        return Icons.public_rounded;
    }
  }

  String _networkModeTitle(BuildContext context, NetworkMode mode) {
    switch (mode) {
      case NetworkMode.compat:
        return I18n.of(context).network_mode_compat;
      case NetworkMode.ech:
        return I18n.of(context).network_mode_ech;
      case NetworkMode.standard:
        return I18n.of(context).network_mode_standard;
    }
  }

  String _networkModeMessage(BuildContext context, NetworkMode mode) {
    switch (mode) {
      case NetworkMode.compat:
        return 'bypass sni,doh';
      case NetworkMode.ech:
        return 'ech';
      case NetworkMode.standard:
        return 'standard';
    }
  }
}