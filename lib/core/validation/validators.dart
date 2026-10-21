String? requiredValue(String? value, {String label = 'This field'}) => value == null || value.trim().isEmpty ? '$label is required' : null;
String? usernameValue(String? value) => value == null || value.trim().length < 3 ? 'Enter a valid username' : null;
String? passwordValue(String? value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null;
String? phoneValue(String? value) => value == null || value.trim().replaceAll(RegExp(r'[^0-9+]'), '').length < 7 ? 'Enter a valid phone number' : null;
