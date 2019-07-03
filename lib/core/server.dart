import 'package:cloud_functions/cloud_functions.dart';

class Server {
  static Future<void> createUserData() async {
    try {
      await CloudFunctions.instance.getHttpsCallable(functionName: 'createUserData').call();
    } on CloudFunctionsException catch (e) {
      print(e.code);
      print(e.message);
      print(e.details);
    }
  }
}
