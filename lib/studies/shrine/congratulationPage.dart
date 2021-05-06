import 'package:flutter/material.dart';

import 'app.dart';

class CongratulationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 82,
              ),
              const SizedBox(
                height: 40,
              ),
              const Text('Congratulation Your purchase has been made.',
                  style: TextStyle(
                    fontSize: 42,
                  )),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  child: const Text('Go Back Home'),
                  onPressed: () {
                    Navigator.of(context)
                        .restorablePushNamed(ShrineApp.paymentRoute);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
