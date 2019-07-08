import 'package:cloud_functions/cloud_functions.dart';

class Server {
  static Future<void> createUserData() async {
    try {
      await CloudFunctions.instance.getHttpsCallable(functionName: 'createUserData').call();
    } catch (e) {
      print('createUserData call exception');
      throw e;
    }
  }

  static Future<dynamic> createEphemeralKey({String apiVersion}) async {
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
}
