import 'dart:core';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:igflexin/model/instagram_response.dart';

class Server {
  static Future<dynamic> purchaseSubscription({
    String paymentMethodId,
    String subscriptionType,
    String subscriptionInterval,
  }) async {
    try {
      final result = await CloudFunctions.instance
          .getHttpsCallable(functionName: 'purchaseSubscription')
          .call(<String, dynamic>{
        'paymentMethodId': paymentMethodId,
        'subscriptionType': subscriptionType,
        'subscriptionInterval': subscriptionInterval,
      });

      return result.data;
    } catch (e) {
      print((e as CloudFunctionsException).code);
      print((e as CloudFunctionsException).message);
      print((e as CloudFunctionsException).details);
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

  static Future<InstagramResponse> addAccount({
    String username,
    String password,
  }) async {
    try {
      final result = await CloudFunctions.instance
          .getHttpsCallable(functionName: 'addAccount')
          .call(<String, dynamic>{
        'username': username,
        'password': password,
      });

      print(result.data);

      return InstagramResponse(
        message: result.data['message'],
        checkpoint: result.data['checkpoint'],
      );
    } catch (e) {
      print(e);
      print((e as CloudFunctionsException).code);
      print('addAccount call exception');
      throw e;
    }
  }

  static Future<InstagramResponse> editAccount({
    String username,
    String password,
    String id,
  }) async {
    try {
      final result = await CloudFunctions.instance
          .getHttpsCallable(functionName: 'editAccount')
          .call(<String, dynamic>{
        'username': username,
        'password': password,
        'id': id,
      });

      print(result.data);

      return InstagramResponse(
        message: result.data['message'],
        checkpoint: result.data['checkpoint'],
      );
    } catch (e) {
      print(e);
      print((e as CloudFunctionsException).code);
      print('editAccount call exception');
      throw e;
    }
  }

  static Future<InstagramResponse> sendSecurityCode({
    String username,
    String securityCode,
  }) async {
    try {
      final result = await CloudFunctions.instance
          .getHttpsCallable(functionName: 'sendSecurityCode')
          .call(<String, dynamic>{
        'username': username,
        'securityCode': securityCode,
      });

      print(result.data);

      return InstagramResponse(
        message: result.data['message'],
        checkpoint: result.data['checkpoint'],
      );
    } catch (e) {
      print(e);
      print((e as CloudFunctionsException).code);
      print('sendSecurityCode call exception');
      throw e;
    }
  }

  static Future<InstagramResponse> sendTwoFactorAuthCode({
    String username,
    String securityCode,
  }) async {
    try {
      final result = await CloudFunctions.instance
          .getHttpsCallable(functionName: 'sendTwoFactorAuthCode')
          .call(<String, dynamic>{
        'username': username,
        'securityCode': securityCode,
      });

      print(result.data);

      return InstagramResponse(
        message: result.data['message'],
        checkpoint: result.data['checkpoint'],
      );
    } catch (e) {
      print(e);
      print((e as CloudFunctionsException).code);
      print('sendTwoFactorAuthCode call exception');
      throw e;
    }
  }
}
