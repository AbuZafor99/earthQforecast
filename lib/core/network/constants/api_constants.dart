class ApiConstants {
  /// [Base Configuration]
  // static const String baseDomain = 'https://karlfive223-backend.onrender.com';

  static const String baseDomain = 'http://10.10.5.88:5002';
  static const String baseUrl = '$baseDomain/api/v1';

  /// Optional Google Maps API key. Leave empty to use simulated addresses.
  /// Add your API key here when you want real geocoding.
  static const String googleMapsApiKey = '';

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
    // Content-Type will be set automatically for multipart
  };

  /// [Endpoint Groups]
  static AuthEndpoints get auth => AuthEndpoints();

  static UserEndpoints get user => UserEndpoints();
  static NotificationEndpoints get notification => NotificationEndpoints();

  static TeamEndpointcs get team => TeamEndpointcs();
  static LeagueEndpoints get league => LeagueEndpoints();
  static LoadEndpoints get load => LoadEndpoints();

  static GetProfile get getProfile => GetProfile();
  
  static PlanEndpoints get plan => PlanEndpoints();
  
  static PaymentEndpoints get payment => PaymentEndpoints();
}

/// [Authentication Endpoints]
class AuthEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/auth';

  final String login = '$_base/login';

  final String register = '$_base/register';
  final String forgotPass = '$_base/forget';
  final String resrtPass = '$_base/reset-password';
  final String verifyMailOtp = '$_base/verify-otp';

  final String refreshToken = '$_base/refresh-token';

  final String setNewPass = '$_base/reset-password';

  final String changePass = '$_base/change-password';
}

class GetProfile {
  static const String _baseUrl = ApiConstants.baseUrl;
  
  // Single endpoint for all roles - backend handles role-based logic
  String fetchProfileByRole(String role) {
    return '$_baseUrl/user/profile';
  }
  
  
  String updateProfileByRole(String role) {
    return '$_baseUrl/user/update-profile';
  }
  
  
  // Legacy endpoints for backward compatibility
  final String fetchProfile = '$_baseUrl/user/profile';
  final String updateProfile = '$_baseUrl/user/update-profile';
}

class UserEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/user';
  final String updateProfile = '$_base/update-profile';
  final String getUserProfile = '$_base/profile';

  // final String create = '$_base/create';
}

class NotificationEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/notification';

  final String getnotifications = '$_base/getnotifications';
}

class TeamEndpointcs {
  static const String _base = '${ApiConstants.baseUrl}/team';

  final String create = '$_base/create';
}

class LeagueEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/league';

  final String getAllLeagues = '$_base/all-league';
}

class LoadEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/load';

  final String getLoads = _base;
  String getById(String id) => '$_base/$id';
  String priceAction(String id) => '$_base/$id/price-action';
  String askPrice(String id) => '$_base/$id/ask-price';
}

class PlanEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/plan';

  final String getPlans = _base;
}

class PaymentEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/payment';

  final String createPayment = '$_base/create-payment';
  final String confirmPayment = '$_base/confirm-payment';
}

class AskPriceEndpoints{
  static const String _base = '${ApiConstants.baseUrl}/load';

  String askPrice(String id) => '$_base/$id/ask-price';
}
