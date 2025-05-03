import 'dart:io';

import 'package:yaml_api_dart/routes/contact_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

/// Main entry point for the API server application.
///
/// Starts the Shelf HTTP server and mounts all contact-related routes under `/api/contacts`.
void main() async {
  /// Configure the router with base path `/api/contacts`
  final router = Router()..mount('/api/contacts', getContactRouter().call);

  /// Setup middleware pipeline
  /// - [logRequests()] logs incoming HTTP requests to the console
  final handler = Pipeline()
      .addMiddleware(logRequests()) // Log all incoming requests
      .addHandler(router.call); // Attach the configured router

  /// Determine the port to listen on.
  ///
  /// Tries to read from environment variable `PORT`, defaults to `8080` if not set.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  /// Start the HTTP server
  ///
  /// Listens on localhost at the specified port
  final server = await serve(handler, 'localhost', port);
  print('Server running on http://localhost:${server.port}');
}
