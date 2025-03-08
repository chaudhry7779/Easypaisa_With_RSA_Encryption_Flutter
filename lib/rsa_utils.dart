import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class RSAUtils {
  static RSAPrivateKey parsePrivateKeyFromPem(String pem) {
    var key = pem
        .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        .replaceAll('-----END RSA PRIVATE KEY-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();
    var bytes = base64.decode(key);
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    var modulus = topLevelSeq.elements![1] as ASN1Integer;
    var privateExponent = topLevelSeq.elements![3] as ASN1Integer;
    var prime1 = topLevelSeq.elements![4] as ASN1Integer;
    var prime2 = topLevelSeq.elements![5] as ASN1Integer;
    var modulusBigInt = _bytesToBigInt(modulus.valueBytes!);
    var privateExponentBigInt = _bytesToBigInt(privateExponent.valueBytes!);
    var prime1BigInt = _bytesToBigInt(prime1.valueBytes!);
    var prime2BigInt = _bytesToBigInt(prime2.valueBytes!);
    return RSAPrivateKey(modulusBigInt, privateExponentBigInt, prime1BigInt, prime2BigInt);
  }

  static RSAPublicKey parsePublicKeyFromPem(String pem) {
    var key =
        pem.replaceAll('-----BEGIN PUBLIC KEY-----', '').replaceAll('-----END PUBLIC KEY-----', '').replaceAll('\n', '').replaceAll('\r', '').trim();
    var bytes = base64.decode(key);
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    var subjectPublicKey = topLevelSeq.elements![1] as ASN1BitString;
    var rsaKeyBytes = subjectPublicKey.valueBytes!;
    if (rsaKeyBytes.isNotEmpty && rsaKeyBytes[0] == 0) {
      rsaKeyBytes = rsaKeyBytes.sublist(1);
    }
    var rsaKeyParser = ASN1Parser(rsaKeyBytes);
    var rsaKeySeq = rsaKeyParser.nextObject() as ASN1Sequence;
    var modulus = rsaKeySeq.elements![0] as ASN1Integer;
    var publicExponent = rsaKeySeq.elements![1] as ASN1Integer;
    var modulusBigInt = _bytesToBigInt(modulus.valueBytes!);
    var publicExponentBigInt = _bytesToBigInt(publicExponent.valueBytes!);
    return RSAPublicKey(modulusBigInt, publicExponentBigInt);
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.from(0);
    for (var i = 0; i < bytes.length; i++) {
      result = result << 8;
      result += BigInt.from(bytes[i] & 0xff);
    }
    return result;
  }

  static String signData(String data, String privateKeyPem) {
    var privateKey = parsePrivateKeyFromPem(privateKeyPem);
    var signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    var bytes = Uint8List.fromList(utf8.encode(data));
    var signature = signer.generateSignature(bytes);
    return base64Encode(signature.bytes);
  }

  static bool verifySignature(String data, String signatureBase64, String publicKeyPem) {
    var publicKey = parsePublicKeyFromPem(publicKeyPem);
    var verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
    var bytes = Uint8List.fromList(utf8.encode(data));
    var signatureBytes = base64Decode(signatureBase64);
    var signature = RSASignature(signatureBytes);
    return verifier.verifySignature(bytes, signature);
  }
}
