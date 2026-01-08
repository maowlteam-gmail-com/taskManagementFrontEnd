import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maowl/util/dio_config.dart';

class ForgotPasswordService {
  final dio = DioConfig.getDio();

  // Request OTP by sending API request
  // Email is stored in backend, so no need to pass it
  Future<bool> requestOTP() async {
    try {
      final response = await dio.post(
        '${dotenv.env['BASE_URL']}/api/forgot-password',
        data: {
          "email": "maowltech@gmail.com",
        },
        // No need to send email from frontend
        // Backend will use the email associated with the account
      );
      print("Status Code: "+response.statusCode.toString());

      return response.statusCode == 200;
    } catch (e) {
      print("Error requesting OTP: ${e}");
      return false;
    }
  }

  // Verify the OTP entered by user
  Future<bool> verifyOTP(String otp) async {
    try {
      final response = await dio.post(
        '${dotenv.env['BASE_URL']}/api/verify-otp',
        data: {
          "otp": otp,
          // No need to send email from frontend
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

  // Reset password with new password
  Future<bool> resetPassword(String newPassword) async {
    try {
      final response = await dio.post(
        '${dotenv.env['BASE_URL']}/api/reset-password',
        data: {
          "newPassword": newPassword,
          // No need to send email from frontend
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error resetting password: $e");
      return false;
    }
  }
}
