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
part 'emitter.dart';
part 'sporetower.dart';
part 'smoke.dart';
part 'explosion.dart';
part 'connection.dart';
part 'userinterface.dart';
part 'uisymbol.dart';
part 'scroller.dart';

Game game;

void main() {
  game = new Game().start(
      friendly: false // disables enemies
      //seed: 1 // use seed
      );
}