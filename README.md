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
final response = await EasypaisaWithRSA.requestPayment(
amount: '10.5', // Amount to charge
accountNo: '03451234567', // User account number
email: 'test@email.com', // User email address
);
print(response.body); // to print response body

} catch (e) {
print(e.toString()) // to print exception details
}
```
## : Response

   ```dart

{
"signature": "YJhvJwQnfTX5ydbSnQydNeWIzN5U8/TSkRiCi1UwGOdbI/b6KiCEX7/1911NzdrdsF5+CoM8OwBAhhBpLYb1kIHh4+a3s5mS2u4z0Vf2khEOLbNv4nb/o4HDBYcdqAAlHkM3akmeXHjZXdOVofz3QBdyNgKwcqlcmw2oycFqzZQB9DY9JaqUHDe6F+UVERIqtdulaLy9uSEsqZX4akPvERlS5fVmQvHDEolkym1aLyomPgOFIIGqzHRw1wYijfmITgLbDsFnkbRUf+atttmmBFdb6v9g6C/vL10+c61CcpEjdwQqzoGiWK5TXq1Z59HT0wtOadcAR6Yd29BaR49N+g==",
"response": {
"orderId": "1741212891871",
"storeId": storeId,
"transactionId": "34018398193",
"transactionDateTime": "06/03/2025 03:15 AM",
"responseCode": "0000",
"responseDesc": "SUCCESS"
  }
}

```
