part of creeper;

class Renderer {
  CanvasElement view;
  CanvasRenderingContext2D context;
  int top, left, bottom, right;
  List<Sprite> sprites = new List<Sprite>();

  Renderer(this.view, width, height) {
    updateRect(width, height);
    view.style.position = "absolute";
    context = view.getContext('2d');
  }

  void clear() {
    context.clearRect(0, 0, view.width, view.height);
  }

  void updateRect(int width, int height) {
    view.width = width;
    view.height = height;
    top = view.offset.top;
    left = view.offset.left;
    bottom = view.offset.top + view.offset.height;
    right = view.offset.left + view.offset.width;
  }

  void addSprite(Sprite sprite) {
    sprites.add(sprite);
    sprites.sort((Sprite a, Sprite b) {
      return a.layer - b.layer;
    });
  }

  void removeSprite(Sprite sprite) {
    sprites.removeAt(sprites.indexOf(sprite));
  }

  void draw() {
    for (var sprite in sprites) {
      if (sprite.visible) {
        Vector realPosition = sprite.position.real2screen();

        if (engine.isVisible(realPosition, new Vector(sprite.size.x * game.zoom, sprite.size.y * game.zoom))) {

          if (sprite.alpha != 1.0)
            context.globalAlpha = sprite.alpha;

          if (sprite.rotation != 0) {
            context.save();
            context.translate(realPosition.x, realPosition.y);
            context.rotate(engine.deg2rad(sprite.rotation));
            if (sprite.animated)
              context.drawImageScaledFromSource(sprite.image,
              (sprite.frame % 8) * sprite.size.x,
              (sprite.frame ~/ 8) * sprite.size.y,
              sprite.size.x,
              sprite.size.y,
              -sprite.size.x * sprite.anchor.x * sprite.scale.x * game.zoom,
              -sprite.size.y * sprite.anchor.y * sprite.scale.y * game.zoom,
              sprite.size.x * sprite.scale.x * game.zoom,
              sprite.size.y * sprite.scale.y * game.zoom);
            else
              context.drawImageScaled(sprite.image,
              -sprite.size.x * sprite.anchor.x * game.zoom,
              -sprite.size.y * sprite.anchor.y * game.zoom,
              sprite.size.x * game.zoom,
              sprite.size.y * game.zoom);
            context.restore();
          } else {
            if (sprite.animated)
              context.drawImageScaledFromSource(sprite.image,
              (sprite.frame % 8) * sprite.size.x,
              (sprite.frame ~/ 8) * sprite.size.y,
              sprite.size.x,
              sprite.size.y,
              realPosition.x - sprite.size.x * sprite.anchor.x * sprite.scale.x * game.zoom,
              realPosition.y - sprite.size.y * sprite.anchor.y * sprite.scale.y * game.zoom,
              sprite.size.x * sprite.scale.x * game.zoom,
              sprite.size.y * sprite.scale.y * game.zoom);
            else
              context.drawImageScaled(sprite.image,
              realPosition.x - sprite.size.x * sprite.anchor.x * game.zoom,
              realPosition.y - sprite.size.y * sprite.anchor.y * game.zoom,
              sprite.size.x * game.zoom,
              sprite.size.y * game.zoom);
          }

          if (sprite.alpha != 1.0)
            context.globalAlpha = 1.0;
        }
      }
    }
  }
}