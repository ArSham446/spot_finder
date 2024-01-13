// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:spot_finder/widgets/stripe_id.dart';

// class PaymentPage extends StatefulWidget {
//   const PaymentPage({super.key});

//   @override
//   PaymentPageState createState() => PaymentPageState();
// }

// class PaymentPageState extends State<PaymentPage> {
//   void showProgress() {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stripe Payment'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             makePayment(context, '100');
//           },
//           child: const Text('Pay with Stripe'),
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic>? paymentIntentData;
//   Future<void> makePayment(dynamic data, String total) async {
//     try {
//       paymentIntentData = await createPaymentIntent(total, 'USD');
//       await Stripe.instance
//           .initPaymentSheet(
//               paymentSheetParameters: SetupPaymentSheetParameters(
//                   paymentIntentClientSecret:
//                       paymentIntentData!['client_secret'],

//                   ///  allowsDelayedPaymentMethods: true,
//                   merchantDisplayName: 'ANNIE'))
//           .then((value) async {
//         await displayPaymentSheet(data);
//       });
//     } catch (e) {
//       debugPrint('exception:$e');
//     }
//   }

//   displayPaymentSheet(dynamic data) async {
//     try {
//       await Stripe.instance
//           .initPaymentSheet(
//               paymentSheetParameters: SetupPaymentSheetParameters(
//                   paymentIntentClientSecret:
//                       paymentIntentData!['client_secret'],
//                   customFlow: true,
//                   merchantDisplayName: 'ANNIE'))
//           .then((value) async {
//         paymentIntentData = null;
//         debugPrint('paid');

//         showProgress();
//       });
//     } catch (e) {
//       debugPrint('exception1:$e');
//     }
//   }

//   createPaymentIntent(String total, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': total,
//         'currency': currency,
//         'payment_method_types[]': 'card'
//       };
//       debugPrint(body.toString());

//       var response = await http.post(
//           Uri.parse('https://api.stripe.com/v1/payment_intents'),
//           body: body,
//           headers: {
//             'Authorization': 'Bearer $stripeSecretKey',
//             'Content-Type': 'application/x-www-form-urlencoded'
//           });

//       return jsonDecode(response.body);
//     } catch (e) {
//       debugPrint('expton:$e');
//     }
//   }
// }
