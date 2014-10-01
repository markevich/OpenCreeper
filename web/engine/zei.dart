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
Mouse mouse;

void init({int TPS: 60, bool debug: false}) {
  TPS = TPS;
  debug = debug;

  // disable context menu
  document.onContextMenu.listen((event) => event.preventDefault());

  document
        ..onKeyDown.listen((event) => onKeyEvent(event, "down"))
        ..onKeyUp.listen((event) => onKeyEvent(event, "up"));
}

/**
 * Enables the mouse
 */
void enableMouse([String cursor]) {
  mouse = new Mouse();
  if (cursor != null)
    mouse.setCursor(cursor);

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

void onKeyEvent(KeyboardEvent evt, String type) {
  for (int i = 0; i < GameObject.gameObjects.length; i++) {
    GameObject.gameObjects[i].onKeyEvent(evt, type);
  }
}

void onMouseEvent(MouseEvent evt) {
  if (evt.type == "mousemove") {
    mouse.update(evt);
  }

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
  Renderer.setRelativeMousePosition();
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
  for (Renderer renderer in Renderer.renderers) {
    renderer.clear();
  }
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

// thx to http://www.skytopia.com/project/articles/compsci/clipping.html
bool LiangBarsky (num edgeLeft, num edgeRight, num edgeBottom, num edgeTop,
                  num x0src, num y0src, num x1src, num y1src) {

  num t0 = 0.0;
  num t1 = 1.0;
  num xdelta = x1src-x0src;
  num ydelta = y1src-y0src;
  num p,q,r;

  for(int edge=0; edge<4; edge++) {   // Traverse through left, right, bottom, top edges.
    if (edge==0) {  p = -xdelta;    q = -(edgeLeft-x0src);  }
    if (edge==1) {  p = xdelta;     q =  (edgeRight-x0src); }
    if (edge==2) {  p = -ydelta;    q = -(edgeBottom-y0src);}
    if (edge==3) {  p = ydelta;     q =  (edgeTop-y0src);   }
    r = q/p;
    if(p==0 && q<0) return false;   // (parallel line outside)

    if(p<0) {
      if(r>t1) return false;
      else if(r>t0) t0=r;
    } else if(p>0) {
      if(r<t0) return false;
      else if(r<t1) t1=r;
    }
  }

  return true;
}