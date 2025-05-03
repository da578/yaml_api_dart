import 'package:shelf_router/shelf_router.dart';
import 'package:yaml_api_dart/controllers/contact_controller.dart';

/// Creates and configures a Shelf Router for contact-related endpoints.
///
/// Returns a fully configured [Router] instance with all contact routes
Router getContactRouter() {
  final router = Router();
  final controller = ContactController();

  router.get('/', controller.readContacts);
  router.get('/<id>', controller.readContactById);
  router.post('/create', controller.createContact);
  router.put('/<id>/update', controller.updateContact);
  router.delete('/<id>/delete', controller.deleteContact);

  return router;
}
