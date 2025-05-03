import 'package:yaml_writer/yaml_writer.dart';

/// Helper class for generating standardized YAML-formatted responses.
class YamlHelper {
  /// Generates a standardized YAML response with status code, message, result, and errors.
  ///
  /// - [statusCode] HTTP status code (e.g., 200, 400, 404)
  /// - [message] Descriptive message about the result
  /// - [result] Optional data payload to include in the response
  /// - [errors] Optional error details to return
  ///
  /// Returns formatted YAML string ready to be sent as HTTP response body
  static String generateResponse({
    required int statusCode,
    required String message,
    dynamic result,
    dynamic errors,
  }) {
    final response = {'status_code': statusCode, 'message': message};
    if (result != null) response['result'] = result;
    if (errors != null) response['errors'] = errors;
    return YamlWriter().write(response);
  }
}
