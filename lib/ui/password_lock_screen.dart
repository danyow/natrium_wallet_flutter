import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nanodart/nanodart.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/bus/fcm_update_event.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';

class AppPasswordLockScreen extends StatefulWidget {
  @override
  _AppPasswordLockScreenState createState() => _AppPasswordLockScreenState();
}

class _AppPasswordLockScreenState extends State<AppPasswordLockScreen> {
  FocusNode enterPasswordFocusNode;
  TextEditingController enterPasswordController;

  String passwordError;

  @override
  void initState() {
    super.initState();
    this.enterPasswordFocusNode = FocusNode();
    this.enterPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: StateContainer.of(context).curTheme.backgroundDark,
        width: double.infinity,
        child: SafeArea(
          minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035,
          ),
          child: Column(
            children: <Widget>[
              // Logout button
              Container(
                margin: EdgeInsetsDirectional.only(start: 16, top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      onPressed: () {
                        AppDialogs.showConfirmDialog(
                            context,
                            CaseChange.toUpperCase(
                                AppLocalization.of(context).warning, context),
                            AppLocalization.of(context).logoutDetail,
                            AppLocalization.of(context)
                                .logoutAction
                                .toUpperCase(), () {
                          // Show another confirm dialog
                          AppDialogs.showConfirmDialog(
                              context,
                              AppLocalization.of(context).logoutAreYouSure,
                              AppLocalization.of(context).logoutReassurance,
                              CaseChange.toUpperCase(
                                  AppLocalization.of(context).yes, context),
                              () {
                            // Unsubscribe from notifications
                            sl
                                .get<SharedPrefsUtil>()
                                .setNotificationsOn(false)
                                .then((_) {
                              FirebaseMessaging().getToken().then((fcmToken) {
                                EventTaxiImpl.singleton()
                                    .fire(FcmUpdateEvent(token: fcmToken));
                                // Delete all data
                                sl.get<Vault>().deleteAll().then((_) {
                                  sl
                                      .get<SharedPrefsUtil>()
                                      .deleteAll()
                                      .then((result) {
                                    StateContainer.of(context).logOut();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/',
                                            (Route<dynamic> route) => false);
                                  });
                                });
                              });
                            });
                          });
                        });
                      },
                      highlightColor:
                          StateContainer.of(context).curTheme.text15,
                      splashColor: StateContainer.of(context).curTheme.text30,
                      padding: EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Icon(AppIcons.logout,
                                size: 16,
                                color:
                                    StateContainer.of(context).curTheme.text),
                            Container(
                              margin: EdgeInsetsDirectional.only(start: 4),
                              child: Text(AppLocalization.of(context).logout,
                                  style:
                                      AppStyles.textStyleLogoutButton(context)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                children: <Widget>[
                  Container(
                    child: Icon(
                      AppIcons.lock,
                      size: 80,
                      color: StateContainer.of(context).curTheme.primary,
                    ),
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                  ),
                  Container(
                    child: Text(
                      CaseChange.toUpperCase(
                          AppLocalization.of(context).locked, context),
                      style: AppStyles.textStyleHeaderColored(context),
                    ),
                    margin: EdgeInsets.only(top: 10),
                  ),
                  // Enter your password Text Field
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.105,
                      right: MediaQuery.of(context).size.width * 0.105,
                      top: 30,
                    ),
                    padding: EdgeInsetsDirectional.only(start: 16, end: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          focusNode: enterPasswordFocusNode,
                          controller: enterPasswordController,
                          cursorColor:
                              StateContainer.of(context).curTheme.primary,
                          textInputAction: TextInputAction.go,
                          onChanged: (String newText) {
                            if (passwordError != null) {
                              setState(() {
                                passwordError = null;
                              });
                            }
                          },
                          // Temporary function END
                          maxLines: 1,
                          autocorrect: false,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText:
                                AppLocalization.of(context).enterPasswordHint,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'NunitoSans',
                              color: StateContainer.of(context).curTheme.text60,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                            color: StateContainer.of(context).curTheme.primary,
                            fontFamily: 'NunitoSans',
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Error Container
                  Container(
                    alignment: AlignmentDirectional(0, 0),
                    margin: EdgeInsets.only(top: 3),
                    child: Text(
                        this.passwordError == null ? "" : this.passwordError,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: StateContainer.of(context).curTheme.primary,
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              )),
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                      context,
                      AppButtonType.PRIMARY,
                      AppLocalization.of(context).unlock,
                      Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                    try {
                      String decryptedSeed = NanoHelpers.byteToHex(
                          NanoCrypt.decrypt(await sl.get<Vault>().getSeed(),
                              enterPasswordController.text));
                      StateContainer.of(context).setEncryptedSecret(
                          NanoHelpers.byteToHex(NanoCrypt.encrypt(decryptedSeed,
                              await sl.get<Vault>().getSessionKey())));
                      _goHome();
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          passwordError =
                              AppLocalization.of(context).invalidPassword;
                        });
                      }
                    }
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goHome() async {
    if (StateContainer.of(context).wallet != null) {
      StateContainer.of(context).reconnect();
    } else {
      await NanoUtil()
          .loginAccount(await StateContainer.of(context).getSeed(), context);
    }
    StateContainer.of(context).requestUpdate();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_transition', (Route<dynamic> route) => false);
  }
}
