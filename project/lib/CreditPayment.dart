// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:stripe_sdk/stripe_sdk_ui.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(), // 追加
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   GlobalKey<FormState> formKey = GlobalKey<FormState>(); // 変更
//   StripeCard card = StripeCard(); // 変更

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("テスト"), // 修正
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             CardForm(card: card, formKey: formKey), // クレジットカード入力欄を表示します。
//             FlatButton(
//               child: Text("決済する"),
//               onPressed: () async {
//                 if (formKey.currentState!.validate()) {
//                   formKey.currentState!.save();

//                   final CreditCard _creditCard = CreditCard(
//                     number: card.number,
//                     expMonth: card.expMonth,
//                     expYear: card.expYear,
//                   );

//                   try {
//                     final token = await Stripe.instance.createTokenWithCard(
//                         _creditCard); // StripePaymentは使われていないため、Stripe.instanceを使用します

//                     if (token != null) {
//                       // APIに処理を渡します。
//                       final url =
//                           'http://127.0.0.1/api/sample_stripe'; // 適切なURLに修正する必要があります
//                       await http.post(
//                         url,
//                         body: {
//                           'stripeToken': token.id,
//                         },
//                       );
//                     } else {
//                       print('トークンの作成に失敗しました。');
//                     }
//                   } catch (e) {
//                     print('エラーが発生しました: $e');
//                   }
//                 } else {
//                   print('処理が通りませんでした。');
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
