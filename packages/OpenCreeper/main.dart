library creeper;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'engine/engine.dart';
part 'engine/renderer.dart';
part 'engine/displayobject.dart';
part 'engine/mouse.dart';

part 'world.dart';
part 'tile.dart';
part 'game.dart';
part 'heightmap.dart';
part 'uisymbol.dart';
part 'building.dart';
part 'packet.dart';
part 'shell.dart';
part 'projectile.dart';
part 'spore.dart';
part 'ship.dart';
part 'events.dart';
part 'emitter.dart';
part 'sporetower.dart';
part 'smoke.dart';
part 'explosion.dart';
part 'vector.dart';
part 'connection.dart';
part 'route.dart';

Game game;

void main() {
  game = new Game(); 
  game.start(); // enter a number as parameter to start with a given seed
}