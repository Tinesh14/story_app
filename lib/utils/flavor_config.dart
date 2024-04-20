enum FlavorType {
  free,
  paid,
}

class FlavorConfig {
  final FlavorType flavor;

  static FlavorConfig? _instance;

  FlavorConfig({this.flavor = FlavorType.free}) {
    _instance = this;
  }

  static FlavorConfig get instance => _instance ?? FlavorConfig();
}
