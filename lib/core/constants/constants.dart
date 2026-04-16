class AppConstants {
  static const String baseUrl = 'http://localhost:5175/api';
  
  // Storage Keys
  static const String tokenKey = 'JWT_TOKEN';
  static const String userKey = 'USER_DATA';
  
  // Roles
  static const String roleAdmin = 'Admin';
  static const String roleSalesperson = 'Salesperson';
  static const String roleCustomer = 'Customer';
  
  // Brands (Hardcoded as per requirement)
  static const List<Map<String, dynamic>> hardcodedBrands = [
    {'code': 98, 'name': 'TMC'},
    {'code': 343, 'name': 'TANTOR'},
  ];
}
