// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/layout/adaptive.dart';
import 'package:gallery/layout/image_placeholder.dart';
import 'package:gallery/layout/letter_spacing.dart';
import 'package:gallery/layout/text_scale.dart';
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/studies/shrine/app.dart';
import 'package:gallery/studies/shrine/colors.dart';
import 'package:gallery/studies/shrine/model/authentication.dart';
import 'package:gallery/studies/shrine/model/providers.dart';
import 'package:gallery/studies/shrine/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _horizontalPadding = 24.0;

double desktopLoginScreenMainAreaWidth({BuildContext context}) {
  return min(
    360 * reducedTextScale(context),
    MediaQuery.of(context).size.width - 2 * _horizontalPadding,
  );
}

class LoginPage extends StatefulHookWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final emailEditingController = TextEditingController();
    final passwordEditingController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final useAuth = useProvider(authProvider);
    final node = FocusScope.of(context);

    Widget _userNamefield() {
      // this function is our username field;
      return PrimaryColorOverride(
        color: shrineBrown900,
        child: Container(
          child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            controller: emailEditingController,
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
            restorationId: 'email_text_field',
            cursorColor: colorScheme.onSurface,
            decoration: InputDecoration(
              labelText: 'email',
              labelStyle: TextStyle(
                  letterSpacing: letterSpacingOrNone(mediumLetterSpacing)),
            ),
          ),
        ),
      );
    }

    Widget _passwordTextField() {
      // this function is our password field
      return PrimaryColorOverride(
        color: shrineBrown900,
        child: Container(
          child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onEditingComplete: () => node.unfocus(),
            controller: passwordEditingController,
            restorationId: 'password_text_field',
            cursorColor: colorScheme.onSurface,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'password',
              labelStyle: TextStyle(
                  letterSpacing: letterSpacingOrNone(mediumLetterSpacing)),
            ),
          ),
        ),
      );
    }

    void _callBackAction() {
      //

      print(emailEditingController.text);
      print(passwordEditingController.text);
      //context.read(authProvider)
      if (_formKey.currentState.validate() == false) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing Data'),
          ),
        );
      }

      showbuttomShit(context);
      useAuth
          .login(
        email: emailEditingController.text,
        password: passwordEditingController.text,
      )
          .then(
        (value) {
          if (value == true) {
            // Navigator.pop(context);
            //showDialogBox(context);
            Navigator.of(context).restorablePushNamed(ShrineApp.homeRoute);
          } else {
            print('error');
          }
        },
      );
    }

    return ApplyTextOptions(
      child: isDesktop
          ? LayoutBuilder(builder: (context, constraints) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Container(
                      width: desktopLoginScreenMainAreaWidth(context: context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ShrineLogo(),
                            const SizedBox(height: 40),
                            _userNamefield(),
                            const SizedBox(height: 16),
                            _passwordTextField(),
                            const SizedBox(height: 24),
                            _CancelAndNextButtons(
                              konPressed: () {
                                _callBackAction();
                              },
                            ),
                            const SizedBox(height: 62),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
          : Scaffold(
              appBar: AppBar(backgroundColor: Colors.white),
              body: SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    restorationId: 'signUp_list_view',
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    children: [
                      const SizedBox(height: 80),
                      _ShrineLogo(),
                      const SizedBox(height: 120),
                      _userNamefield(),
                      const SizedBox(height: 12),
                      _passwordTextField(),
                      _CancelAndNextButtons(
                        konPressed: () {
                          _callBackAction();
                          // context.read(authentication)
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // * ALART BOX
  void showDialogBox(BuildContext context) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vefication'),
          content: const Text(
              'We just sent you a mail, please go check your mail for verifacation purposes. All you have to do is to just follow the instruction. After that click Next, which takes you to login page'),
          actions: [
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.of(context).restorablePushNamed(ShrineApp.loginRoute);
              },
            )
          ],
        );
      },
    );
  }

  void showbuttomShit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Consumer(
            builder: (context, watch, child) {
              final courseProviderstate = watch(authProvider);
              return Column(
                children: [
                  //* i know you could be confused here
                  // * just take your time,
                  courseProviderstate.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  courseProviderstate.isSuccessful
                      ? Container()
                      : courseProviderstate.error == null
                          ? Container()
                          : Text(
                              '${courseProviderstate.error}',
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.red),
                            ),

                  courseProviderstate.error != null
                      ? ElevatedButton(
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      : Container(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ShrineLogo extends StatelessWidget {
  _ShrineLogo();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        children: [
          FadeInImagePlaceholder(
            image: const AssetImage('packages/shrine_images/diamond.png'),
            placeholder: Container(
              width: 34,
              height: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SHRINE - LOGIN',
            style: Theme.of(context).textTheme.headline5,
          ),
        ],
      ),
    );
  }
}

class _CancelAndNextButtons extends HookWidget {
  final VoidCallback konPressed;

  const _CancelAndNextButtons({Key key, this.konPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isDesktop = isDisplayDesktop(context);

    final buttonTextPadding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
        : EdgeInsets.zero;

    return Wrap(
      children: [
        ButtonBar(
          buttonPadding: isDesktop ? EdgeInsets.zero : null,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
              ),
              child: Padding(
                padding: buttonTextPadding,
                child: Text(
                  GalleryLocalizations.of(context).shrineCancelButtonCaption,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              onPressed: () {
                // The login screen is immediately displayed on top of
                // the Shrine home screen using onGenerateRoute and so
                // rootNavigator must be set to true in order to get out
                // of Shrine completely.
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 8,
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
              ),
              child: Padding(
                padding: buttonTextPadding,
                child: Text(
                  GalleryLocalizations.of(context).shrineNextButtonCaption,
                  style: TextStyle(
                      letterSpacing: letterSpacingOrNone(largeLetterSpacing)),
                ),
              ),
              onPressed: konPressed,
              // () {
              //   Navigator.of(context).restorablePushNamed(ShrineApp.homeRoute);
              // },
            ),
          ],
        ),
      ],
    );
  }
}

class PrimaryColorOverride extends StatelessWidget {
  PrimaryColorOverride({Key key, this.color, this.child}) : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}


//class LoginPage 