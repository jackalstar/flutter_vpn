import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';

import 'core/provider/adsProvider.dart';
import 'core/provider/purchaseProvider.dart';
import 'core/provider/uiProvider.dart';
import 'core/provider/vpnProvider.dart';
import 'core/resources/environment.dart';
import 'core/resources/warna.dart';
import 'core/utils/preferences.dart';
import 'ui/screens/introScreen.dart';
import 'ui/screens/mainScreen.dart';
import 'ui/screens/privacyPolicyScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await EasyLocalization.ensureInitialized();
  // rootBundle.loadString(key)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VpnProvider()),
        ChangeNotifierProvider(create: (context) => PurchaseProvider()),
        ChangeNotifierProvider(create: (context) => AdsProvider()),
        ChangeNotifierProvider(create: (context) => MainScreenProvider()),
        ChangeNotifierProvider(create: (context) => UIProvider()),
      ],
      child: Consumer<UIProvider>(
        builder: (context, value, child) => EasyLocalization(
          path: 'assets/languages',
          startLocale: value.selectedLocale ?? Locale("en", "US"),
          supportedLocales: value.locales!,
          useOnlyLangCode: true,
          child: Root(),
        ),
      ),
    ),
  );
}

class Root extends StatefulWidget {
  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> {
  bool ready = false;
  @override
  void initState() {
    if (Platform.isAndroid)
      InAppUpdate.checkForUpdate().then((value) {
        if (value.flexibleUpdateAllowed) return InAppUpdate.startFlexibleUpdate().then((value) => InAppUpdate.completeFlexibleUpdate());
        if (value.immediateUpdateAllowed) return InAppUpdate.performImmediateUpdate();
      });

    UIProvider.initializeLanguages(context);
    PurchaseProvider.initPurchase(context);
    VpnProvider.instance(context).initialize();
    VpnProvider.refreshInfoVPN(context);

    if (!ready)
      setState(() {
        ready = true;
      });

    Future.delayed(Duration(seconds: 8)).then((value) {
      if (!ready)
        setState(() {
          ready = true;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        theme: ThemeData(
            primaryColor: primaryColor,
            fontFamily: GoogleFonts.poppins().fontFamily,
            scaffoldBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black)),
              ),
            ),
            buttonTheme: ButtonThemeData(
              focusColor: Colors.grey.shade300,
            ),
            appBarTheme: AppBarTheme(
              color: Colors.white,
            )),
        home: ready
            ? FutureBuilder<Preferences>(
                future: Preferences.init(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!snapshot.data!.firstOpen) return IntroScreen(rootState: this);
                    if (snapshot.data!.privacyPolicy) {
                      return MainScreen();
                    } else {
                      return PrivacyPolicyIntroScreen(rootState: this);
                    }
                  } else {
                    return SplashScreen();
                  }
                },
              )
            : SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(text: "$appname ", style: GoogleFonts.poppins(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600)),
            TextSpan(text: "VPN", style: GoogleFonts.poppins(color: primaryColor, fontSize: 24, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
