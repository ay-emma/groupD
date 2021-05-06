// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gallery/studies/shrine/app.dart';
import 'package:gallery/studies/shrine/model/providers.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/layout/letter_spacing.dart';
import 'package:gallery/studies/shrine/colors.dart';
import 'package:gallery/studies/shrine/expanding_bottom_sheet.dart';
import 'package:gallery/studies/shrine/model/app_state_model.dart';
import 'package:gallery/studies/shrine/model/product.dart';
import 'package:gallery/studies/shrine/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _startColumnWidth = 60.0;
const _ordinalSortKeyName = 'shopping_cart';

class ShoppingCartPage extends StatefulHookWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  List<Widget> _createShoppingCartRows(AppStateModel model) {
    //* is a function to create the added shopping cart row to a list
    return model.productsInCart.keys
        .map(
          (id) => ShoppingCartRow(
            // create a row for the product choosen
            product: model.getProductById(id),
            quantity: model.productsInCart[id],
            onPressed: () {
              model.removeItemFromCart(id);
            },
            onAddPressed: () {
              model.addProductToCart(id);
            },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final getUid = useProvider(authProvider);
    final localTheme = Theme.of(context);
    return Scaffold(
      backgroundColor: shrinePink50,
      body: SafeArea(
        child: Container(
          child: ScopedModelDescendant<AppStateModel>(
            builder: (context, child, model) {
              return Stack(
                children: [
                  ListView(
                    // list of
                    children: [
                      Semantics(
                        sortKey:
                            const OrdinalSortKey(0, name: _ordinalSortKeyName),
                        child: Row(
                          children: [
                            SizedBox(
                              width: _startColumnWidth,
                              child: IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down),
                                onPressed: () =>
                                    ExpandingBottomSheet.of(context).close(),
                                tooltip: GalleryLocalizations.of(context)
                                    .shrineTooltipCloseCart,
                              ),
                            ),
                            Text(
                              GalleryLocalizations.of(context)
                                  .shrineCartPageCaption,
                              style: localTheme.textTheme.subtitle1
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              GalleryLocalizations.of(context)
                                  .shrineCartItemCount(
                                model.totalCartQuantity,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Semantics(
                        sortKey:
                            const OrdinalSortKey(1, name: _ordinalSortKeyName),
                        child: Column(
                          // this is the function that adds the row
                          children: _createShoppingCartRows(model),
                        ),
                      ),
                      Semantics(
                        sortKey:
                            const OrdinalSortKey(2, name: _ordinalSortKeyName),
                        child: ShoppingCartSummary(model: model),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                  PositionedDirectional(
                    bottom: 16,
                    start: 16,
                    end: 16,
                    child: Semantics(
                      sortKey:
                          const OrdinalSortKey(3, name: _ordinalSortKeyName),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const BeveledRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                          ),
                          primary: shrinePink100,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'CHECKOUT',
                            style: TextStyle(
                                letterSpacing:
                                    letterSpacingOrNone(largeLetterSpacing)),
                          ),
                        ),
                        onPressed: () async {
                          // * we before checking out we if the
                          //* user has an accout . if not we ask them to create an account
                          // model.clearCart();
                          await getUid.getCurrentUser().then((value) {
                            print(value);
                            if (value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please sign up or login before checking out'),
                                  duration: Duration(seconds: 6),
                                ),
                              );
                            } else {
                              Navigator.of(context)
                                  .restorablePushNamed(ShrineApp.paymentRoute);
                            }
                          });

                          //ExpandingBottomSheet.of(context).close();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ShoppingCartSummary extends StatelessWidget {
  const ShoppingCartSummary({this.model});

  final AppStateModel model;

  @override
  Widget build(BuildContext context) {
    final smallAmountStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(color: shrineBrown600);
    final largeAmountStyle = Theme.of(context)
        .textTheme
        .headline4
        .copyWith(letterSpacing: letterSpacingOrNone(mediumLetterSpacing));
    final formatter = NumberFormat.simpleCurrency(
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    );

    return Row(
      children: [
        const SizedBox(width: _startColumnWidth),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Column(
              children: [
                MergeSemantics(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        GalleryLocalizations.of(context).shrineCartTotalCaption,
                      ),
                      Expanded(
                        child: Text(
                          '₦${model.totalCost}',
                          style: largeAmountStyle,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                MergeSemantics(
                  child: Row(
                    children: [
                      Text(
                        GalleryLocalizations.of(context)
                            .shrineCartSubtotalCaption,
                      ),
                      Expanded(
                        child: Text(
                          '₦${model.subtotalCost}',
                          style: smallAmountStyle,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                MergeSemantics(
                  child: Row(
                    children: [
                      Text(
                        GalleryLocalizations.of(context)
                            .shrineCartShippingCaption,
                      ),
                      Expanded(
                        child: Text(
                          '₦${model.shippingCost}',
                          style: smallAmountStyle,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                MergeSemantics(
                  child: Row(
                    children: [
                      Text(
                        GalleryLocalizations.of(context).shrineCartTaxCaption,
                      ),
                      Expanded(
                        child: Text(
                          '₦${model.tax}',
                          style: smallAmountStyle,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ShoppingCartRow extends StatelessWidget {
  const ShoppingCartRow({
    @required this.product,
    @required this.quantity,
    this.onPressed,
    this.onAddPressed,
  });

  final Product product;
  final int quantity;
  final VoidCallback onPressed;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.simpleCurrency(
      decimalDigits: 0,
      locale: Localizations.localeOf(context).toString(),
    );
    final localTheme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        key: ValueKey<int>(product.id),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Semantics(
                container: true,
                label: GalleryLocalizations.of(context)
                    .shrineScreenReaderRemoveProductButton(
                        product.name(context)),
                button: true,
                enabled: true,
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: _startColumnWidth,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: onPressed,
                      tooltip: GalleryLocalizations.of(context)
                          .shrineTooltipRemoveItem,
                    ),
                  ),
                ),
              ),
              Semantics(
                container: true,
                label: GalleryLocalizations.of(context)
                    .shrineScreenReaderRemoveProductButton(
                        product.name(context)),
                button: true,
                enabled: true,
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: _startColumnWidth,
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: onAddPressed,
                      tooltip: GalleryLocalizations.of(context)
                          .shrineTooltipRemoveItem,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        product.assetName,
                        package: product.assetPackage,
                        fit: BoxFit.cover,
                        width: 75,
                        height: 75,
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MergeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MergeSemantics(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        GalleryLocalizations.of(context)
                                            .shrineProductQuantity(quantity),
                                      ),
                                    ),
                                    Text('₦ ${product.price}'),
                                  ],
                                ),
                              ),
                              Text(
                                product.name(context),
                                style: localTheme.textTheme.subtitle1
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    color: shrineBrown900,
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//* <<<<<<<<<<NAIRA>>>>>>>> ₦
