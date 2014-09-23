library creeper;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'engine/zei.dart' as Zei;

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
part 'userinterface.dart';
part 'uisymbol.dart';

Game game;

void main() {
  game = new Game().start(
      friendly: true // disables enemies
      //seed: 1 // use seed
      );
}