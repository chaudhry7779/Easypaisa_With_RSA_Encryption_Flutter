import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart'; // For RSA encryption
import 'package:pointycastle/pointycastle.dart'; // For PEM key parsing

class EasypaisaWithRSA {
  /// The username for authenticating Easypaisa requests.
  static String? username;

  /// The password for authenticating Easypaisa requests.
  static String? password;

  /// The store ID associated with the Easypaisa Merchant account.
  static String? storeId;

  /// Flag indicating whether to use the Easypaisa sandbox environment.
  static late bool isSandbox;

  /// The type of Easypaisa account (Mobile Account or Over the Counter).
  static String? accountType = "MA";

  /// The private key in PEM format for signing requests.
  static String? privateKeyPem;

  /// The public key in PEM format for verifying responses.
  static String? publicKeyPem;

  /// Initializes the Easypaisa credentials and settings.
  ///
  /// This method must be called before making any Easypaisa requests.
  /// - [username]: The Easypaisa account username.
  /// - [password]: The Easypaisa account password.
  /// - [storeId]: The Easypaisa store ID.
  /// - [isSandbox]: A flag indicating whether to use the Easypaisa sandbox environment (default is true).
  /// - [accountType]: The type of Easypaisa account (default is AccountType.MA).
  /// - [privateKeyPem]: The private key in PEM format for signing requests.
  /// - [publicKeyPem]: The public key in PEM format for verifying responses.
  static void initialize(
    String username,
    String password,
    String storeId,
    String privateKey,
    String publicKey, {
    bool isSandbox = true,
    String accountType = "MA",
  }) {
    EasypaisaWithRSA.username = username;
    EasypaisaWithRSA.password = password;
    EasypaisaWithRSA.storeId = storeId;
    EasypaisaWithRSA.isSandbox = isSandbox;
    EasypaisaWithRSA.accountType = accountType;
    EasypaisaWithRSA.privateKeyPem = privateKey;
    EasypaisaWithRSA.publicKeyPem = publicKey;
  }

  /// Parses a private key from PEM format.
  static RSAPrivateKey _parsePrivateKeyFromPem(String pem) {
    // Remove PEM headers and footers
    var key = pem
        .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        .replaceAll('-----END RSA PRIVATE KEY-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();

    // Decode the base64-encoded key
    var bytes = base64.decode(key);

    // Parse the ASN.1 encoded key
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    // Extract the required parameters from the ASN.1 sequence
    var modulus = topLevelSeq.elements![1] as ASN1Integer;
    var privateExponent = topLevelSeq.elements![3] as ASN1Integer;
    var prime1 = topLevelSeq.elements![4] as ASN1Integer; // p
    var prime2 = topLevelSeq.elements![5] as ASN1Integer; // q

    // Convert the valueBytes to BigInt
    var modulusBigInt = _bytesToBigInt(modulus.valueBytes!);
    var privateExponentBigInt = _bytesToBigInt(privateExponent.valueBytes!);
    var prime1BigInt = _bytesToBigInt(prime1.valueBytes!);
    var prime2BigInt = _bytesToBigInt(prime2.valueBytes!);

    // Create the RSAPrivateKey object
    return RSAPrivateKey(modulusBigInt, privateExponentBigInt, prime1BigInt, prime2BigInt);
  }

  /// Parses a public key from PEM format.
  static RSAPublicKey _parsePublicKeyFromPem(String pem) {
    // Remove PEM headers and footers
    var key = pem
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('\n', '') // Remove newline characters
        .replaceAll('\r', '') // Remove carriage return characters
        .trim(); // Remove any leading or trailing whitespace

    // Decode the base64-encoded key
    var bytes = base64.decode(key);

    // Parse the ASN.1 encoded key
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    // Extract the algorithm identifier and the subjectPublicKey (BIT STRING)
    var subjectPublicKey = topLevelSeq.elements![1] as ASN1BitString;

    // Extract the raw bytes from the BIT STRING
    var rsaKeyBytes = subjectPublicKey.valueBytes!;

    // Skip the first byte (unused bits indicator, usually 0 for RSA keys)
    if (rsaKeyBytes.isNotEmpty && rsaKeyBytes[0] == 0) {
      rsaKeyBytes = rsaKeyBytes.sublist(1); // Remove the unused bits byte
    }

    // Parse the RSA key bytes to extract the modulus and exponent
    var rsaKeyParser = ASN1Parser(rsaKeyBytes);
    var rsaKeySeq = rsaKeyParser.nextObject() as ASN1Sequence;

    // Extract the modulus and public exponent
    var modulus = rsaKeySeq.elements![0] as ASN1Integer;
    var publicExponent = rsaKeySeq.elements![1] as ASN1Integer;

    // Convert the valueBytes to BigInt
    var modulusBigInt = _bytesToBigInt(modulus.valueBytes!);
    var publicExponentBigInt = _bytesToBigInt(publicExponent.valueBytes!);

    // Create the RSAPublicKey object
    return RSAPublicKey(modulusBigInt, publicExponentBigInt);
  }

  /// Helper function to convert a Uint8List to BigInt
  static BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.from(0);
    for (var i = 0; i < bytes.length; i++) {
      result = result << 8; // Shift left by 8 bits
      result += BigInt.from(bytes[i] & 0xff); // Add the current byte
    }
    return result;
  }

  /// Signs the given data using the provided private key in PEM format.
  static String _signData(String data, String privateKeyPem) {
    var privateKey = _parsePrivateKeyFromPem(privateKeyPem);
    var signer = RSASigner(SHA256Digest(), '0609608648016503040201'); // SHA-256 with RSA
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    var bytes = Uint8List.fromList(utf8.encode(data));
    var signature = signer.generateSignature(bytes);

    return base64Encode(signature.bytes);
  }

  /// Verifies the signature of the given data using the provided public key in PEM format.
  static bool _verifySignature(String data, String signatureBase64, String publicKeyPem) {
    var publicKey = _parsePublicKeyFromPem(publicKeyPem);
    var verifier = RSASigner(SHA256Digest(), '0609608648016503040201'); // SHA-256 with RSA
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

    var bytes = Uint8List.fromList(utf8.encode(data));
    var signatureBytes = base64Decode(signatureBase64);
    var signature = RSASignature(signatureBytes);

    return verifier.verifySignature(bytes, signature);
  }

  /// Initiates a payment request with Easypaisa.
  ///
  /// - [amount]: The transaction amount.
  /// - [accountNo]: The account or mobile number associated with the transaction.
  /// - [email]: The email address associated with the transaction.
  /// Returns a [Future] containing the HTTP response.
  static Future<http.Response> requestPayment({
    required String amount,
    required String accountNo,
    required String email,
  }) async {
    /// Check if required credentials are initialized.
    if (username == null || password == null || storeId == null) {
      throw Exception('Username, password, and storeId must be initialized first.');
    }

    /// Check if RSA keys are initialized.
    if (privateKeyPem == null || publicKeyPem == null) {
      throw Exception('Private key and public key must be initialized first.');
    }

    /// Prepare the request body for Mobile Account (MA) transaction.
    var requestBody = {
      "orderId": "${DateTime.now().millisecondsSinceEpoch}",
      "storeId": storeId,
      "transactionAmount": amount,
      "transactionType": 'MA',
      "mobileAccountNo": accountNo,
      "emailAddress": email,
    };

    /// Determine the transaction URL based on the environment (sandbox/live).
    String sandBoxTransactionUrl = 'https://easypaystg.easypaisa.com.pk/easypay-service/rest/v5/initiate-ma-transaction';
    String liveTransactionUrl = 'https://easypay.easypaisa.com.pk/easypay-service/rest/v5/initiate-ma-transaction';

    String url = isSandbox ? sandBoxTransactionUrl : liveTransactionUrl;

    /// Encode the request body to JSON.
    var requestJson = jsonEncode(requestBody);

    /// Sign the request data using the private key.
    var signature = _signData(requestJson, privateKeyPem!);

    /// Prepare the final payload with the request and signature.
    var jsonPayload = {
      'request': requestBody,
      'signature': signature,
    };

    var jsonString = jsonEncode(jsonPayload);

    /// Make the HTTP POST request to initiate the transaction.
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Credentials": base64.encode(utf8.encode('$username:$password')),
        "Content-Type": "application/json",
      },
      body: jsonString,
    );

    /// Handle API response errors.
    if (response.statusCode != 200) {
      throw Exception('API request failed: ${response.statusCode}. Response: ${response.body}');
    }

    /// Decode the API response.
    var apiResponse = jsonDecode(response.body);
    var responseJson = jsonEncode(apiResponse['response']);

    /// Verify the response signature.
    var isSignatureValid = _verifySignature(responseJson, apiResponse['signature'], publicKeyPem!);
    if (!isSignatureValid) {
      throw Exception('Invalid response signature.');
    }

    /// Return the API response.
    return response;
  }
}
