library zei;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'renderer.dart';
part 'displayobject.dart';
part 'mouse.dart';
part 'vector.dart';
part 'route.dart';
part 'gameobject.dart';
part 'color.dart';
part 'audio.dart';

num animationRequest;
int TPS = 60; // ticks per second
Timer running;
Map<String, Renderer> renderer = new Map();
Map<String, ImageElement> images = new Map();
bool debug = false;

void init({int TPS: 60, bool debug: false}) {
  TPS = TPS;
  debug = debug;
  
  // disable context menu
  document.onContextMenu.listen((event) => event.preventDefault());
  
  document
        ..onKeyDown.listen((event) => onKeyEvent(event))
        ..onKeyUp.listen((event) => onKeyEvent(event));
  
  document
    ..onMouseMove.listen((event) => onMouseEvent(event))
    ..onMouseEnter.listen((event) => onMouseEvent(event))
    ..onMouseLeave.listen((event) => onMouseEvent(event))
    ..onClick.listen((event) => onMouseEvent(event))
    ..onMouseWheel.listen((event) => onMouseEvent(event))
    ..onDoubleClick.listen((event) => onMouseEvent(event))
    ..onMouseDown.listen((event) => onMouseEvent(event))
    ..onMouseUp.listen((event) => onMouseEvent(event));
}

void onKeyEvent(KeyboardEvent evt) {
  for (int i = 0; i < GameObject.gameObjects.length; i++) {
    GameObject.gameObjects[i].onKeyEvent(evt);
  }
}

void onMouseEvent(MouseEvent evt) {
  for (int i = 0; i < GameObject.gameObjects.length; i++) {
    GameObject.gameObjects[i].onMouseEvent(evt);
  }
}

void run() {
  running = new Timer.periodic(new Duration(milliseconds: (1000 / TPS).floor()), (Timer timer) => update());
  animationRequest = window.requestAnimationFrame(draw);
}

void stop() {
  running.cancel();
  window.cancelAnimationFrame(animationRequest);
}

/**
 * Main update function
 */
void update() {
  GameObject.updateAll();
}

/**
 * Main drawing function which instructs all Renderers.
 * Is called by requestAnimationFrame every frame.
 */
void draw(num _) {  
  for (Renderer renderer in Renderer.renderers) {
    if (renderer.autodraw) {
      renderer.clear();
      renderer.draw();
    }
  }
  window.requestAnimationFrame(draw);
}

/**
 * Clear engine of all game objects and display objects.
 */
void clear() {
  GameObject.clear();
  //Audio.clear();
  Renderer.clearDisplayObjects();
}

/**
 * Loads all images.
 *
 * Uses a future to indicate when all images have been loaded.
 */
Future loadImages(List filenames) {
  var completer = new Completer();
   
  int loadedImages = 0;

  filenames.forEach((filename) {
    images[filename] = new ImageElement(src: "images/" + filename + ".png");
    images[filename].onLoad.listen((event) {
      if (++loadedImages == filenames.length) {
        completer.complete();
      }
    });
  });
  return completer.future; 
}

/**
 * Returns a random element of a given [list].
 */
Object randomElementOfList(List list) {
  return list[randomInt(0, list.length - 1)];
}

/**
 * Clamps a value to a [min] and [max] value.
 */
num clamp(num value, num min, num max) {
  return (value < min ? min : (value > max) ? max : value);
}

/**
 * Returns a random int in the range [from] to [to], optionally with a [seed].
 */
int randomInt(int from, int to, [int seed]) {
  var random = new Random(seed);
  return (random.nextInt(to - from + 1) + from);
}

/**
 * Returns a random double in the range [from] to [to], optionally with a [seed].
 */
int randomDouble(double from, double to, [int seed]) {
    var random = new Random(seed);
    return (random.nextDouble() * (to - from) + from);
  }

/**
 * Converts an [angle] in radians to degrees.
 */
num radToDeg(num angle) {
  return angle * 57.29577951308232;
}

/**
 * Converts an [angle] in degrees to radians.
 */
num degToRad(num angle) {
  return angle * .017453292519943295;
}

/**
 * Converts an [angle] (in degrees) to a Vector2 representation
 */ 
Vector2 convertToVector(num angle) {
  return new Vector2(cos(degToRad(angle)), sin(degToRad(angle)));
}