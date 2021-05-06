// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gallery/studies/shrine/model/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:gallery/data/gallery_options.dart';
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/layout/adaptive.dart';
import 'package:gallery/layout/text_scale.dart';
import 'package:gallery/studies/shrine/app.dart';
import 'package:gallery/studies/shrine/colors.dart';
import 'package:gallery/studies/shrine/model/app_state_model.dart';
import 'package:gallery/studies/shrine/model/product.dart';
import 'package:gallery/studies/shrine/page_status.dart';
import 'package:gallery/studies/shrine/triangle_category_indicator.dart';

double desktopCategoryMenuPageWidth({
  BuildContext context,
}) {
  return 232 * reducedTextScale(context);
}

class CategoryMenuPage extends StatefulHookWidget {
  const CategoryMenuPage({
    Key key,
    this.onCategoryTap,
  }) : super(key: key);

  final VoidCallback onCategoryTap;

  @override
  _CategoryMenuPageState createState() => _CategoryMenuPageState();
}

class _CategoryMenuPageState extends State<CategoryMenuPage> {
  Widget _buttonText(String caption, TextStyle style) {
    // A function that resturns a styled botton

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        caption,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _divider({BuildContext context}) {
    return Container(
      width: 56 * GalleryOptions.of(context).textScaleFactor(context),
      height: 1,
      color: const Color(0xFF8F716D),
    );
  }

  Widget _buildCategory(Category category, BuildContext context) {
    final isDesktop = isDisplayDesktop(context);

    final categoryString = category.name(context);

    final selectedCategoryTextStyle = Theme.of(context)
        .textTheme
        .bodyText1
        .copyWith(fontSize: isDesktop ? 17 : 19);

    final unselectedCategoryTextStyle = selectedCategoryTextStyle.copyWith(
        color: shrineBrown900.withOpacity(0.6));

    final indicatorHeight = (isDesktop ? 28 : 30) *
        GalleryOptions.of(context).textScaleFactor(context);
    final indicatorWidth = indicatorHeight * 34 / 28;

    return ScopedModelDescendant<AppStateModel>(
      builder: (context, child, model) => Semantics(
        selected: model.selectedCategory == category,
        button: true,
        enabled: true,
        child: GestureDetector(
          onTap: () {
            model.setCategory(category);
            if (widget.onCategoryTap != null) {
              widget.onCategoryTap();
            }
          },
          child: model.selectedCategory == category
              ? CustomPaint(
                  painter: TriangleCategoryIndicator(
                    indicatorWidth,
                    indicatorHeight,
                  ),
                  child: _buttonText(categoryString, selectedCategoryTextStyle),
                )
              : _buttonText(categoryString, unselectedCategoryTextStyle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authManager = useProvider(authProvider).aUid;
    final isDesktop = isDisplayDesktop(context);

    final logoutTextStyle = Theme.of(context).textTheme.bodyText1.copyWith(
          fontSize: isDesktop ? 17 : 19,
          color: shrineBrown900.withOpacity(0.6),
        );

    if (isDesktop) {
      return AnimatedBuilder(
        animation: PageStatus.of(context).cartController,
        builder: (context, child) => ExcludeSemantics(
          excluding: !menuPageIsVisible(context),
          child: Material(
            child: Container(
              color: shrinePink100,
              width: desktopCategoryMenuPageWidth(context: context),
              child: Column(
                children: [
                  const SizedBox(height: 64),
                  Image.asset(
                    'packages/shrine_images/diamond.png',
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    container: true,
                    child: Text(
                      'SHRINE-GroupD',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  const Spacer(),
                  for (final category in categories)
                    _buildCategory(category, context),
                  _divider(context: context),
                  Semantics(
                    // Logout Button
                    button: true,
                    enabled: true,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .restorablePushNamed(ShrineApp.loginRoute);
                      },
                      child: _buttonText(
                        GalleryLocalizations.of(context)
                            .shrineLogoutButtonCaption,
                        logoutTextStyle,
                      ),
                    ),
                  ),
                  authManager == null
                      ? Semantics(
                          // Here we show sign up or loggged acct if they have log in
                          button: true,
                          enabled: true,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .restorablePushNamed(ShrineApp.signUpRoute);
                            },
                            child: _buttonText(
                              'SIGNUP',
                              logoutTextStyle,
                            ),
                          ),
                        )
                      : Container(
                          // ignore: prefer_const_constructors
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person),
                            Text('You are logged In')
                          ],
                        )),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip:
                        GalleryLocalizations.of(context).shrineTooltipSearch,
                    onPressed: () {
                      Navigator.of(context)
                          .restorablePushNamed(ShrineApp.paymentRoute);
                      // Map<String, String> gtbb = {
                      //   'category': 'categoryHome',
                      //   'id': '10',
                      //   'isFeatured': 'false',
                      //   'name': 'shrineProductCopperWireRack',
                      //   'price': '23',
                      //   'assetAspectRatio': '1.3373',
                      // };
                      // final dbstuff =
                      //     FirebaseFirestore.instance.collection('products');

                      // dbstuff.add(
                      //   gtbb,
                      // );
                    },
                  ),
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return AnimatedBuilder(
        animation: PageStatus.of(context).cartController,
        builder: (context, child) => AnimatedBuilder(
          animation: PageStatus.of(context).menuController,
          builder: (context, child) => ExcludeSemantics(
            excluding: !menuPageIsVisible(context),
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 40),
                color: shrinePink100,
                child: ListView(
                  children: [
                    for (final category in categories)
                      _buildCategory(category, context),
                    Center(
                      child: _divider(context: context),
                    ),
                    Semantics(
                      button: true,
                      enabled: true,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onCategoryTap != null) {
                            widget.onCategoryTap();
                          }
                          Navigator.of(context)
                              .restorablePushNamed(ShrineApp.loginRoute);
                        },
                        child: _buttonText(
                          GalleryLocalizations.of(context)
                              .shrineLogoutButtonCaption,
                          logoutTextStyle,
                        ),
                      ),
                    ),
                    authManager == null
                        ? Semantics(
                            // Here we show sign up or loggged acct if they have log in
                            button: true,
                            enabled: true,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .restorablePushNamed(ShrineApp.signUpRoute);
                              },
                              child: _buttonText(
                                'SIGNUP',
                                logoutTextStyle,
                              ),
                            ),
                          )
                        : Container(
                            // ignore: prefer_const_constructors
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person),
                              Text('You are logged In')
                            ],
                          )),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
