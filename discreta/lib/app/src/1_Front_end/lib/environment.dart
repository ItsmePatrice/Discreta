enum Environment { dev, prod }

class AppEnvironment {
  static const Environment current = Environment.prod;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://10.0.0.14:3000';
      case Environment.prod:
        return 'https://plowdoor.com'; // update later to Discreta API
    }
  }
}
