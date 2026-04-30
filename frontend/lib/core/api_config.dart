/// URL base de la API (Nest). En web, definir `--dart-define=API_BASE_URL=...` si no es local.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
}
