library creeper;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'engine/engine.dart';
part 'engine/renderer.dart';
part 'engine/displayobject.dart';
part 'engine/mouse.dart';
part 'engine/userinterface.dart';
part 'engine/uisymbol.dart';
part 'engine/vector.dart';
part 'engine/route.dart';
part 'engine/node.dart';

part 'world.dart';
part 'tile.dart';
part 'game.dart';
part 'heightmap.dart';
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
part 'connection.dart';

Game game;

void main() {
  game = new Game(); 
  game.start(); // enter a number as parameter to start with a given seed
}