part of creeper;

class Sprite {
  int layer, frame = 0;
  ImageElement image;
  Vector anchor, scale, position, size;
  num rotation = 0, alpha = 1.0;
  bool animated = false, visible = true;

  Sprite(this.layer, this.image, this.position, width, height) {
    anchor = new Vector(0.0, 0.0);
    scale = new Vector(1.0, 1.0);
    size = new Vector(width, height);
  }
}