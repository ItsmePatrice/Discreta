enum Environment { dev, prod }

class AppEnvironment {
  static const Environment current = Environment.prod;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://192.168.0.15:3000';
      case Environment.prod:
        return 'https://discreta.ca';
    }
  }
}
