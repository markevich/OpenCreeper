part of creeper;

abstract class DisplayObject {
  int layer = 0;
  bool visible = true;
}

class Rect extends DisplayObject {
  Rectangle rectangle;
  int lineWidth;
  String color;

  Rect(this.rectangle, this.lineWidth, this.color);
}

class Circle extends DisplayObject {
  Vector position;
  num radius;
  int lineWidth;
  String color;

  Circle(this.position, this.radius, this.lineWidth, this.color);
}

class Line extends DisplayObject {
  String color;
  Vector from, to;
  int lineWidth;

  Line(this.from, this.to, this.lineWidth, this.color);
}

class Sprite extends DisplayObject {
  int frame = 0;
  ImageElement image;
  Vector anchor, scale, position, size;
  num rotation = 0, alpha = 1.0;
  bool animated = false;

  Sprite(layer, this.image, this.position, width, height) {
    super.layer = layer;
    anchor = new Vector(0.0, 0.0);
    scale = new Vector(1.0, 1.0);
    size = new Vector(width, height);
  }
}