import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

/// A utility class for handling RSA encryption, decryption, signing, and verification.
/// This class provides methods to parse RSA keys from PEM format, sign data,
/// and verify signatures using the PointyCastle library.
class RSAUtils {
  /// Parses an RSA private key from a PEM-encoded string.
  ///
  /// - [pem]: The PEM-encoded private key string.
  ///
  /// Returns an [RSAPrivateKey] object.
  static RSAPrivateKey parsePrivateKeyFromPem(String pem) {
    final keyBytes = _decodePem(pem, 'RSA PRIVATE KEY');
    final asn1Parser = ASN1Parser(keyBytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    final modulus = topLevelSeq.elements![1] as ASN1Integer;
    final privateExponent = topLevelSeq.elements![3] as ASN1Integer;
    final prime1 = topLevelSeq.elements![4] as ASN1Integer;
    final prime2 = topLevelSeq.elements![5] as ASN1Integer;

    return RSAPrivateKey(
      _bytesToBigInt(modulus.valueBytes!),
      _bytesToBigInt(privateExponent.valueBytes!),
      _bytesToBigInt(prime1.valueBytes!),
      _bytesToBigInt(prime2.valueBytes!),
    );
  }

  /// Parses an RSA public key from a PEM-encoded string.
  ///
  /// - [pem]: The PEM-encoded public key string.
  ///
  /// Returns an [RSAPublicKey] object.
  static RSAPublicKey parsePublicKeyFromPem(String pem) {
    final keyBytes = _decodePem(pem, 'PUBLIC KEY');
    final asn1Parser = ASN1Parser(keyBytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    final subjectPublicKey = topLevelSeq.elements![1] as ASN1BitString;
    var rsaKeyBytes = subjectPublicKey.valueBytes!;

    // Remove leading zero byte if present
    if (rsaKeyBytes.isNotEmpty && rsaKeyBytes[0] == 0) {
      rsaKeyBytes = rsaKeyBytes.sublist(1);
    }

    final rsaKeyParser = ASN1Parser(rsaKeyBytes);
    final rsaKeySeq = rsaKeyParser.nextObject() as ASN1Sequence;

    final modulus = rsaKeySeq.elements![0] as ASN1Integer;
    final publicExponent = rsaKeySeq.elements![1] as ASN1Integer;

    return RSAPublicKey(
      _bytesToBigInt(modulus.valueBytes!),
      _bytesToBigInt(publicExponent.valueBytes!),
    );
  }

  /// Signs the provided data using the given RSA private key.
  ///
  /// - [data]: The data to sign.
  /// - [privateKeyPem]: The PEM-encoded RSA private key.
  ///
  /// Returns a base64-encoded signature string.
  static String signData(String data, String privateKeyPem) {
    final privateKey = parsePrivateKeyFromPem(privateKeyPem);
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
      ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final signature =
        signer.generateSignature(Uint8List.fromList(utf8.encode(data)));
    return base64Encode(signature.bytes);
  }

  /// Verifies the signature of the provided data using the given RSA public key.
  ///
  /// - [data]: The original data that was signed.
  /// - [signatureBase64]: The base64-encoded signature to verify.
  /// - [publicKeyPem]: The PEM-encoded RSA public key.
  ///
  /// Returns `true` if the signature is valid, otherwise `false`.
  static bool verifySignature(
      String data, String signatureBase64, String publicKeyPem) {
    final publicKey = parsePublicKeyFromPem(publicKeyPem);
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201')
      ..init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

    final signatureBytes = base64Decode(signatureBase64);
    final signature = RSASignature(signatureBytes);

    return verifier.verifySignature(
        Uint8List.fromList(utf8.encode(data)), signature);
  }

  /// Decodes a PEM-encoded key string into its raw bytes.
  ///
  /// - [pem]: The PEM-encoded key string.
  /// - [keyType]: The type of key (e.g., "RSA PRIVATE KEY" or "PUBLIC KEY").
  ///
  /// Returns the decoded key as a [Uint8List].
  static Uint8List _decodePem(String pem, String keyType) {
    final key = pem
        .replaceAll('-----BEGIN $keyType-----', '')
        .replaceAll('-----END $keyType-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();

    return base64.decode(key);
  }

  /// Converts a byte array (Uint8List) to a BigInt.
  ///
  /// - [bytes]: The byte array to convert.
  ///
  /// Returns a [BigInt] representing the byte array.
  static BigInt _bytesToBigInt(Uint8List bytes) {
    return bytes.fold(
        BigInt.from(0), (result, byte) => (result << 8) + BigInt.from(byte));
  }
}
