# Easypaisa Payment Gateway with RSA 2048 Encryption for Flutter

A Flutter package to integrate Easypaisa payment gateway using RSA 2048 encryption for secure transactions. This package simplifies the process of integrating Easypaisa payments into your Flutter applications, supporting both sandbox and live environments.

## Features

- **RSA 2048 Encryption**: Securely sign and verify payment requests and responses using RSA 2048 encryption.
- **Sandbox and Live Environments**: Supports both sandbox (testing) and live (production) environments.
- **Mobile Account (MA) Transactions**: Facilitates transactions using Easypaisa Mobile Accounts.
- **Easy Integration**: Simple initialization and payment request methods for seamless integration.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  easypaisa_with_rsa_encryption: latest_version
```

##  RSA Keys Path
Both Private Key and Easypaisa Public Key Should Placed in assets/keys folder
/// merchant_private_key.pem
/// easypaisa_public_key.pem

## :hammer: Initialization
initialize in main.dart
```dart
String privateKey = await rootBundle.loadString('assets/keys/merchant_private_key.pem');
String publicKey = await rootBundle.loadString('assets/keys/easypaisa_public_key.pem');

EasypaisaWithRSA.initialize(
'username', //merchant account username
'password', //merchant account password
'storeId', //merchant storeId
privateKey, // Merchant Private Key
publicKey, // Easypaisa public key
isSandbox: true, //is testing account or not
);
```
## : Usage
>
> All requested parameters are String type
## : Make a payment
```dart
try {
// Request payment
final result = await EasypaisaWithRSA.requestPayment(
amount: '1', // Amount to charge
accountNo: '03451234567', // User account number
email: 'test@email.com', // User email address
);

// Accessing the result properties
print('API Response: ${result.response}');
print('Signature: ${result.signature}');
print('Is Signature Valid: ${result.isSignatureValid}'); // based on signature validation transaction can be marked as verified or suspicious.

} catch (e) {
print(e.toString()) // to print exception details
}
```
## : Response

   ```dart

{
"response": {
"orderId": "1741454647255",
"storeId": "123456",
"transactionId": "34823788570",
"transactionDateTime": "08/03/2025 10: 24 PM",
"responseCode": "0000",
"responseDesc": "SUCCESS"
},
"signature": "a1b2c3d4e5f6g7h8i9j0...",
"isSignatureValid": true
}

```

## : Inquire previous payment
```dart
try {
      final result = await EasypaisaWithRSA.inquirePayment(
        orderId: '123456...', //order id that was used for payment
        accountNum: '2154878', //user account number
      );

      print(result.response['responseCode']);
      print(result.response['responseDesc']);
      print(result.response['transactionStatus']);
}
catch(e){

}

```
## : Response

   ```dart

{
  "response": {
    "orderId": "1741535434963",
    "accountNum": "123456...",
    "storeId": 41253,
    "storeName": "Store Name",
    "transactionStatus": "PAID",
    "transactionAmount": 100,
    "transactionDateTime": "09/03/2025 11:15 PM",
    "msisdn": "03123456789",
    "paymentMode": "MA",
    "responseCode": "0000",
    "responseDesc": "SUCCESS",
    "settlementStatus": "RECON_FAILED"
  },
  "signature": "vn2lGKr4AOHz4YbgkF4Ru5Q=="
}

```

## Support the package

If you find this package useful, you can support it for free by giving it a thumbs up at the top of this page. Here's another option to support the package:

## <p align='center'><a href="https://www.buymeacoffee.com/abosaad"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=abosaad&button_colour=FFDD00&font_colour=000000&font_family=Poppins&outline_colour=000000&coffee_colour=ffffff" /></a></p>