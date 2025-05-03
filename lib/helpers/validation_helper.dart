/// Utility class for validating user input data.
class ValidationHelper {
  /// Validates an email address using a regular expression.
  ///
  /// Returns null if valid, or an error message if invalid.
  ///
  /// - [value] The email string to validate
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  /// Validates a phone number format.
  ///
  /// Checks if the phone number contains only allowed characters and has valid length.
  ///
  /// - [value] The phone number string to validate
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[0-9\s\-]{8,15}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Invalid phone number format';
    }

    return null;
  }

  /// Validates the length of a given string field.
  ///
  /// Checks minimum and maximum character limits.
  ///
  /// - [value] The string value to validate
  /// - [fieldName] Name of the field (used in error message)
  /// - [minLength] Minimum number of characters (default: 1)
  /// - [maxLength] Maximum number of characters (default: 255)
  ///
  /// Returns null if valid, or error message if invalid
  static String? validateLength({
    required String value,
    required String fieldName,
    int minLength = 1,
    int maxLength = 255,
  }) {
    if (value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validates all fields required for creating/updating a contact.
  ///
  /// Performs validation on name, phone number, email, and address fields.
  ///
  /// - [name] Contact's full name
  /// - [phoneNumber] Phone number of the contact
  /// - [email] Optional email address
  /// - [address] Optional physical address
  ///
  /// Returns a map of field errors. If empty, validation passed.
  static Map<String, String> validateContactFields({
    required String name,
    required String phoneNumber,
    String? email,
    String? address,
  }) {
    final errors = <String, String>{};

    final nameError = validateLength(value: name, fieldName: 'Name');
    if (nameError != null) errors['name'] = nameError;

    final phoneError = validatePhoneNumber(phoneNumber);
    if (phoneError != null) errors['phone_number'] = phoneError;

    if (email != null && email.isNotEmpty) {
      final emailError = validateEmail(email);
      if (emailError != null) errors['email'] = emailError;
    }

    if (address != null && address.isNotEmpty) {
      final addressError = validateLength(value: address, fieldName: 'Address');
      if (addressError != null) errors['address'] = addressError;
    }

    return errors;
  }
}
