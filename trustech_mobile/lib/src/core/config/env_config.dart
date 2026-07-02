import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';

/// Runtime environment, loaded from the bundled `.env` at startup.
///
/// [clientId] identifies this build to the backend (web / mobile-student /
/// mobile-staff each carry a distinct id) and is sent as the `X-Client-ID`
/// header on every request and in the login/register body.
class Env {
  const Env({
    required this.baseUrl,
    required this.clientId,
    this.apiKey = '',
  });

  final String baseUrl;
  final String clientId;
  final String apiKey;

  factory Env.fromSystem() {
    return Env(
      baseUrl: ApiConfig.baseUrl,
      clientId: dotenv.env['CLIENT_ID'] ?? 'trustech_app',
      apiKey: dotenv.env['API_KEY'] ?? '',
    );
  }
}

final envProvider = Provider<Env>((ref) => Env.fromSystem());
