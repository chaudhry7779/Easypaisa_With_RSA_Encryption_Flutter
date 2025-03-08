class PaymentRequest {
  final String orderId;
  final String storeId;
  final String transactionAmount;
  final String transactionType;
  final String mobileAccountNo;
  final String emailAddress;

  PaymentRequest({
    required this.orderId,
    required this.storeId,
    required this.transactionAmount,
    required this.transactionType,
    required this.mobileAccountNo,
    required this.emailAddress,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'storeId': storeId,
        'transactionAmount': transactionAmount,
        'transactionType': transactionType,
        'mobileAccountNo': mobileAccountNo,
        'emailAddress': emailAddress,
      };
}
