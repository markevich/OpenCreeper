part of zei;

abstract class DisplayObject {
  String layer;
  bool visible = true;
}

class Text extends DisplayObject {
  Vector2 position;
  String sizeUnit, text, font, align, verticalAlign;
  num size, rotation = 0;
  Color fillColor, strokeColor;
  String rendererName;
  
  Text(rendererName, layer, this.position, this.size, this.sizeUnit, this.font, this.fillColor, this.strokeColor, this.text, {String align: "left", String verticalAlign: "alphabetic", bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    this.align = align;
    this.verticalAlign = verticalAlign;
    this.rendererName = rendererName;
    renderer[rendererName].addDisplayObject(this);
  }
  
  /**
   * Creates a text display object.
   */
  static Text create(rendererName, layer, position, size, sizeUnit, font, fillColor, strokeColor, text, {String align: "left", String verticalAlign: "alphabetic", bool visible: true}) {
    return new Text(rendererName, layer, position, size, sizeUnit, font, fillColor, strokeColor, text, align: align, verticalAlign: verticalAlign, visible: visible);
  }
  
  /**
   * Rotates the text by a given [angle] in degrees.
   */
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    return false; // TODO
  }
}

class Rect extends DisplayObject {
  Vector2 position, size;
  int lineWidth;
  Color fillColor, strokeColor;
  num rotation = 0;
  Vector2 anchor = new Vector2.empty();
  Vector2 scale = new Vector2(1.0, 1.0);
  String rendererName;

  Rect(rendererName, layer, this.position, this.size, this.lineWidth, this.fillColor, this.strokeColor, {bool visible: true, Vector2 anchor}) {
    super.layer = layer;
    super.visible = visible;
    if (anchor != null) this.anchor = anchor;
    this.rendererName = rendererName;
    renderer[rendererName].addDisplayObject(this);
  }
  
  /**
   * Creates a rect display object.
   */
  static Rect create(rendererName, layer, position, size, lineWidth, fillColor, strokeColor, {bool visible: true, Vector2 anchor}) {
    return new Rect(rendererName, layer, position, size, lineWidth, fillColor, strokeColor, visible: visible, anchor: anchor);  
  }
  
  /**
   * Rotates the rect by a given [angle] in degrees.
   */
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    Vector2 relativePosition = renderer[rendererName].relativePosition(this.position);
    return (renderer[rendererName].relativeMousePosition.x >= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom &&
            renderer[rendererName].relativeMousePosition.x <= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom + this.size.x * this.scale.x * renderer[rendererName].zoom &&
            renderer[rendererName].relativeMousePosition.y >= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom &&
            renderer[rendererName].relativeMousePosition.y <= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom + this.size.y * this.scale.y * renderer[rendererName].zoom);
  }
}

class Circle extends DisplayObject {
  Vector2 position;
  num radius;
  int lineWidth;
  Color fillColor, strokeColor;
  num rotation = 0;
  int degrees = 360;
  num scale = 1.0;
  String rendererName;

  Circle(rendererName, layer, this.position, this.radius, this.lineWidth, this.fillColor, this.strokeColor, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    this.rendererName = rendererName;  
    renderer[rendererName].addDisplayObject(this);
  }
  
  /**
   * Creates a circle display object.
   */
  static Circle create(rendererName, layer, position, radius, lineWidth, fillColor, strokeColor, {bool visible: true}) {
    return new Circle(rendererName, layer, position, radius, lineWidth, fillColor, strokeColor, visible: visible);
  }
  
  /**
   * Rotates the circle by a given [angle] in degrees.
   */
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    Vector2 relativePosition = renderer[rendererName].relativePosition(this.position);
    return (renderer[rendererName].relativeMousePosition.distanceTo(relativePosition) <= this.radius * renderer[rendererName].zoom);
  }
}

class Line extends DisplayObject {
  Color color;
  Vector2 from, to;
  int lineWidth;

  Line(rendererName, layer, this.from, this.to, this.lineWidth, this.color, {bool visible: true}) {
    super.layer = layer;
    super.visible = visible;
    renderer[rendererName].addDisplayObject(this);
  }
  
  /**
   * Creates a line display object.
   */
  static Line create(rendererName, layer, from, to, lineWidth, color, {bool visible: true}) {
    return new Line(rendererName, layer, from, to, lineWidth, color, visible: visible);
  }
  
  String toString() {
    return "$from - $to";
  }
}

class Sprite extends DisplayObject {
  int frame;
  ImageElement image;
  Vector2 anchor = new Vector2.empty(), position, size;
  Vector2 scale = new Vector2(1.0, 1.0);
  num rotation, alpha;
  bool animated; // animated sprites should be in 8 columns in the spritesheet
  String rendererName;
  Timer animationTimer;
  int animationFPS;

  Sprite(rendererName, layer, this.image, this.position, width, height, {int frame: 0, bool animated: false, animationFPS: 30, bool visible: true, Vector2 anchor, num alpha: 1.0, num rotation: 0, Vector2 scale}) {
    super.layer = layer;
    super.visible = visible;
    this.alpha = alpha;
    this.rotation = rotation;
    this.animated = animated;
    this.frame = frame;
    this.animationFPS = animationFPS;
    if (anchor != null) this.anchor = anchor;
    if (scale != null) this.scale = scale;
    size = new Vector2(width, height);
    renderer[rendererName].addDisplayObject(this);
    this.rendererName = rendererName;
    if (animated)
      startAnimation();
  }
  
  /**
   * Creates a sprite display object.
   */
  static Sprite create(rendererName, layer, image, position, width, height, {int frame: 0, bool animated: false, animationFPS: 30, bool visible: true, Vector2 anchor, num alpha: 1.0, num rotation: 0, Vector2 scale}) {
    return new Sprite(rendererName, layer, image, position, width, height, frame: frame, animated: animated, animationFPS: animationFPS, visible: visible, anchor: anchor, alpha: alpha, rotation: rotation, scale: scale);
  }
  
  void stopAnimation() {
    animationTimer.cancel();
  }
  
  void startAnimation() {
    animationTimer = new Timer.periodic(new Duration(milliseconds: (1000 / animationFPS).floor()), (Timer timer) => animate());
  }
  
  void animate() {
    frame++;    
  }
  
  /**
   * Rotates the sprite by a given [angle] in degrees.
   */
  void rotate(num angle) {
    rotation += angle;
    if (rotation >= 360)
      rotation -= 360;
    else if (rotation < 0)
      rotation += 360; 
  }
  
  bool isHovered() {
    Vector2 relativePosition = renderer[rendererName].relativePosition(this.position);
    return (renderer[rendererName].relativeMousePosition.x >= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom &&
            renderer[rendererName].relativeMousePosition.x <= relativePosition.x - this.size.x * this.scale.x * this.anchor.x * renderer[rendererName].zoom + this.size.x * this.scale.x * renderer[rendererName].zoom &&
            renderer[rendererName].relativeMousePosition.y >= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom &&
            renderer[rendererName].relativeMousePosition.y <= relativePosition.y - this.size.y * this.scale.y * this.anchor.y * renderer[rendererName].zoom + this.size.y * this.scale.y * renderer[rendererName].zoom);
  }
}