enum PaymentErrorType {
  RequiresPaymentMethod,
  RequiresAction,
}

class PaymentErrorException implements Exception {
  PaymentErrorException(this.errorType, this.paymentIntentSecret);

  final PaymentErrorType errorType;
  final String paymentIntentSecret;
}
