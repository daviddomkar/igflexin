import 'package:cloud_functions/cloud_functions.dart';

class Server {
  static Future<void> createUserData() async {
    try {
      await CloudFunctions.instance.getHttpsCallable(functionName: 'createUserData').call();
    } on CloudFunctionsException catch (e) {
      print('createUserData call exception');
      print(e.code);
      print(e.message);
      print(e.details);

      throw e;
    }
  }

  static Future<String> createEphemeralKey({String apiVersion}) async {
    try {
      print('Creating ephemeral key');
      var result = await CloudFunctions.instance
          .getHttpsCallable(functionName: 'createEphemeralKey')
          .call(<String, dynamic>{
        'apiVersion': apiVersion,
      });
      print(result.data);
      return result.data;
    } on CloudFunctionsException catch (e) {
      print('createEphemeralKey call exception');
      print(e.code);
      print(e.message);
      print(e.details);

      throw e;
    }
  }
}
