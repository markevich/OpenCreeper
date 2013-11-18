library creeper;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'world.dart';
part 'game.dart';
part 'engine.dart';
part 'heightmap.dart';
part 'uisymbol.dart';
part 'building.dart';
part 'packet.dart';
part 'shell.dart';
part 'projectile.dart';
part 'spore.dart';
part 'ship.dart';
part 'events.dart';
part 'renderer.dart';
part 'emitter.dart';
part 'sporetower.dart';
part 'smoke.dart';
part 'explosion.dart';
part 'vector.dart';
part 'displayobject.dart';
part 'connection.dart';
part 'route.dart';

Engine engine;
Game game;

void main() {
  engine = new Engine();
  engine.loadImages().then((results) => game = new Game.withSeed(4613));
}