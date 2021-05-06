// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:gallery/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/pages/backdrop.dart';
import 'package:gallery/pages/splash.dart';
import 'package:gallery/themes/gallery_theme_data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
export 'package:gallery/data/demos.dart' show pumpDeferredLibraries;

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GalleryApp());
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({
    Key key,
    this.initialRoute,
    this.isTestMode = false,
  }) : super(key: key);

  final bool isTestMode;
  final String initialRoute;

  @override
  _GalleryAppState createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Text(
        'Error Something went wrong',
        style: TextStyle(
          color: Colors.red,
          fontSize: 50,
        ),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return const CircularProgressIndicator();
    }

    return ModelBinding(
      initialModel: GalleryOptions(
        themeMode: ThemeMode.system,
        textScaleFactor: systemTextScaleFactorOption,
        customTextDirection: CustomTextDirection.localeBased,
        locale: null,
        timeDilation: timeDilation,
        platform: defaultTargetPlatform,
        isTestMode: widget.isTestMode,
      ),
      child: Builder(
        builder: (context) {
          return ProviderScope(
            child: MaterialApp(
              restorationScopeId: 'GroupD',
              title: 'Group D',
              debugShowCheckedModeBanner: false,
              themeMode: GalleryOptions.of(context).themeMode,
              theme: GalleryThemeData.lightThemeData.copyWith(
                platform: GalleryOptions.of(context).platform,
              ),
              darkTheme: GalleryThemeData.darkThemeData.copyWith(
                platform: GalleryOptions.of(context).platform,
              ),
              localizationsDelegates: const [
                ...GalleryLocalizations.localizationsDelegates,
                LocaleNamesLocalizationsDelegate()
              ],
              initialRoute: widget.initialRoute,
              supportedLocales: GalleryLocalizations.supportedLocales,
              locale: GalleryOptions.of(context).locale,
              localeResolutionCallback: (locale, supportedLocales) {
                deviceLocale = locale;
                return locale;
              },
              onGenerateRoute: RouteConfiguration.onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ApplyTextOptions(
      child: SplashPage(
        child: Backdrop(),
      ),
    );
  }
}