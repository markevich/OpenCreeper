part of creeper;

abstract class DisplayObject {
  Layer layer;
  bool visible = true;
}

class Rect extends DisplayObject {
  Vector position, size;
  int lineWidth;
  String color;
  Vector anchor;

  Rect(layer, this.position, this.size, this.lineWidth, this.color) {
    super.layer = layer;
    anchor = new Vector.empty();
  }
}

class Circle extends DisplayObject {
  Vector position;
  num radius;
  int lineWidth;
  String color;
  num scale;

  Circle(layer, this.position, this.radius, this.lineWidth, this.color) {
    super.layer = layer;
    scale = 1.0;
  }
}

class Line extends DisplayObject {
  String color;
  Vector from, to;
  int lineWidth;

  Line(layer, this.from, this.to, this.lineWidth, this.color) {
    super.layer = layer;
  }
}

class Sprite extends DisplayObject {
  int frame = 0;
  ImageElement image;
  Vector anchor, scale, position, size;
  num rotation = 0, alpha = 1.0;
  bool animated = false;

  Sprite(layer, this.image, this.position, width, height) {
    super.layer = layer;
    anchor = new Vector.empty();
    scale = new Vector(1.0, 1.0);
    size = new Vector(width, height);
  }
}

// Layer Enum: http://stackoverflow.com/questions/15854549/how-can-i-build-an-enum-with-dart
class Layer {
  final int _value;
  const Layer._internal(this._value);

  int operator -(Layer other) => _value - other._value;
  
  static const SPORE = const Layer._internal(7);
  static const PROJECTILE = const Layer._internal(7);
  static const SHELL = const Layer._internal(7);
  
  static const SHIP = const Layer._internal(6);
  static const SMOKE = const Layer._internal(6);
  static const EXPLOSION = const Layer._internal(6);
  
  static const PACKET = const Layer._internal(5);
  
  static const CANNONGUN = const Layer._internal(4);
  
  static const EMITTER = const Layer._internal(3);
  static const SPORETOWER = const Layer._internal(3);
  static const BUILDING = const Layer._internal(3);
  
  static const CONNECTION = const Layer._internal(2);
  
  static const CONNECTIONBORDER = const Layer._internal(1);
  
  static const TARGETSYMBOL = const Layer._internal(0);
  static const SELECTEDCIRCLE = const Layer._internal(0);
  static const TERRAFORM = const Layer._internal(0);
}