import 'package:flutter/material.dart';

import 'main.dart';
import 'utils/flavor_config.dart';

void main() {
  FlavorConfig(
    flavor: FlavorType.free,
  );

  runApp(const StoryApp());
}
