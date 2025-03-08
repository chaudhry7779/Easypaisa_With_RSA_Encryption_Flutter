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
