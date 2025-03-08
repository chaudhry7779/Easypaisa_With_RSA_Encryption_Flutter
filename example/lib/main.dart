// example/lib/main.dart

import 'package:easypaisa_with_rsa_encryption/easypaisa_with_rsa_encryption.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize EasypaisaWithRSA with your credentials
  String privateKey =
      await rootBundle.loadString('assets/keys/merchant_private_key.pem');
  String publicKey =
      await rootBundle.loadString('assets/keys/easypaisa_public_key.pem');
  EasypaisaWithRSA.initialize(
    'username',
    'password',
    'storeId',
    privateKey,
    publicKey,
    isSandbox: false, // Use sandbox environment for testing
  );
  runApp(const EasypaisaExampleApp());
}

class EasypaisaExampleApp extends StatelessWidget {
  const EasypaisaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easypaisa with RSA Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _emailController = TextEditingController();

  String _responseCode = '';
  String _responseDesc = '';
  String _transactionId = '';
  bool _isSignatureValid = false;
  bool _isLoading = false;

  Future<void> _requestPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _responseCode = '';
        _responseDesc = '';
        _transactionId = '';
        _isSignatureValid = false;
      });

      try {
        final result = await EasypaisaWithRSA.requestPayment(
          amount: _amountController.text.trim(),
          accountNo: _accountNoController.text.trim(),
          email: _emailController.text.trim(),
        );

        setState(() {
          _responseDesc = result.response['responseDesc'] ?? 'Unknown';
          _responseCode = result.response['responseCode'] ?? 'Unknown';
          _transactionId = result.response['transactionId'] ?? 'N/A';
          _isSignatureValid = result.isSignatureValid;
        });
      } catch (e) {
        setState(() {
          _responseDesc = 'Error: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easypaisa RSA Payment Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _accountNoController,
                decoration: const InputDecoration(labelText: 'Account Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _requestPayment,
                      child: const Text('Request Payment'),
                    ),
              const SizedBox(height: 20),
              if (_responseDesc.isNotEmpty)
                Column(
                  children: [
                    Text('Transaction Code: $_responseCode'),
                    Text('Transaction Desc: $_responseDesc'),
                    Text('Transaction ID: $_transactionId'),
                    Text('Is Signature Valid: $_isSignatureValid'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNoController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
