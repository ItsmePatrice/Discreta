enum Environment { dev, prod, staging }

class AppEnvironment {
  static const Environment current = Environment.staging;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://10.0.0.14:3000';
      case Environment.prod:
        return 'https://discreta.ca';
      case Environment.staging:
        return 'https://staging-api.discreta.ca';
    }
  }
}
