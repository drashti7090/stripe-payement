import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  "pk_test_51NiaF7SGk2kvVicl49b1pAronBF6iEIxAZbpALCgSmphf31WQsOAlF87JCleWOpLEcNDi2aWykxUAi2pgGZ65pVz00K7ekmjMD";
  await Stripe.instance.applySettings();

  runApp(
    MaterialApp(
  debugShowCheckedModeBanner: false,
        home: MyHome()), // use MaterialApp
  );
}

class MyHome extends StatefulWidget {
  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     floatingActionButton: FloatingActionButton(onPressed: () {
       makePayment(5);
     },child: Icon(Icons.add)),
    );
  }
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(num amount) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, 'INR');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              style: ThemeMode.dark,
              customerId: paymentIntentData!['customer'],
              paymentIntentClientSecret:
              paymentIntentData!['client_secret'],
              customerEphemeralKeySecret:
              paymentIntentData!['ephemeralKey'],
              merchantDisplayName: 'MEMETHOD-FITNESS'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet(videoPrice: amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet({num? videoPrice}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        print('payment intent${paymentIntentData!['id']}');
        print('payment intent${paymentIntentData!['client_secret']}');
        print('payment intent${paymentIntentData!['amount']}');
        print('payment intent$paymentIntentData');
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(num amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer sk_test_51NiaF7SGk2kvViclTf55O7LhkepdnewOP6Ql2HNOZrM4x7BjnHCgZOrv1uxVDGUdEt6t2hMvOKynbZ6qYpmDRoQ200TdVwl1K6',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(num amount) {
    final a = (amount) * 100;
    return a.toString();
  }
}
