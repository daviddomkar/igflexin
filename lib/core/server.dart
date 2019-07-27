import 'package:cloud_functions/cloud_functions.dart';

class Server {
  static Future<void> purchaseSubscription({
    String paymentMethodId,
    String subscriptionType,
    String subscriptionInterval,
  }) async {
    try {
      await CloudFunctions.instance
          .getHttpsCallable(functionName: 'purchaseSubscription')
          .call(<String, dynamic>{
        'paymentMethodId': paymentMethodId,
        'subscriptionType': subscriptionType,
        'subscriptionInterval': subscriptionInterval,
      });
    } catch (e) {
      print((e as CloudFunctionsException).code);
      print('purchaseSubscription call exception');
      throw e;
    }
  }

  static Future<void> createUserData() async {
    try {
      await CloudFunctions.instance
          .getHttpsCallable(functionName: 'createUserData')
          .call();
    } catch (e) {
      print('createUserData call exception');
      throw e;
    }
  }

  static Future<dynamic> createEphemeralKey({
    String apiVersion,
  }) async {
    try {
      print('Creating ephemeral key');
      var result = await CloudFunctions.instance
          .getHttpsCallable(functionName: 'createEphemeralKey')
          .call(<String, dynamic>{
        'apiVersion': apiVersion,
      });
      print(result.data);
      return result.data;
    } catch (e) {
      print('createEphemeralKey call exception');
      throw e;
    }
  }

  static Future<void> addAccount({
    String username,
    String password,
  }) async {
    try {
      await CloudFunctions.instance
          .getHttpsCallable(functionName: 'addAccount')
          .call(<String, dynamic>{
        'username': username,
        'password': password,
      });
    } catch (e) {
      print((e as CloudFunctionsException).code);
      print('addAccount call exception');
      throw e;
    }
  }
}
