part of creeper;

class Renderer {
  CanvasElement view;
  CanvasRenderingContext2D context;
  int top, left, bottom, right;
  List<DisplayObject> displayObjects = new List<DisplayObject>();

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

  void addDisplayObject(DisplayObject displayObject) {
    displayObjects.add(displayObject);
    displayObjects.sort((Sprite a, Sprite b) {
      return a.layer - b.layer;
    });
  }

  void removeDisplayObject(DisplayObject displayObject) {
    displayObjects.removeAt(displayObjects.indexOf(displayObject));
  }

  void draw() {
    for (var displayObject in displayObjects) {
      if (displayObject.visible) {

        // render sprite
        if (displayObject is Sprite) {
          Vector realPosition = displayObject.position.real2screen();

          if (engine.isVisible(realPosition, new Vector(displayObject.size.x * game.zoom, displayObject.size.y * game.zoom))) {

            if (displayObject.alpha != 1.0)
              context.globalAlpha = displayObject.alpha;

            if (displayObject.rotation != 0) {
              context.save();
              context.translate(realPosition.x, realPosition.y);
              context.rotate(engine.deg2rad(displayObject.rotation));
              if (displayObject.animated)
                context.drawImageScaledFromSource(displayObject.image,
                (displayObject.frame % 8) * displayObject.size.x,
                (displayObject.frame ~/ 8) * displayObject.size.y,
                displayObject.size.x,
                displayObject.size.y,
                -displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * game.zoom,
                -displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * game.zoom,
                displayObject.size.x * displayObject.scale.x * game.zoom,
                displayObject.size.y * displayObject.scale.y * game.zoom);
              else
                context.drawImageScaled(displayObject.image,
                -displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * game.zoom,
                -displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * game.zoom,
                displayObject.size.x * displayObject.scale.x * game.zoom,
                displayObject.size.y * displayObject.scale.y * game.zoom);
              context.restore();
            } else {
              if (displayObject.animated)
                context.drawImageScaledFromSource(displayObject.image,
                (displayObject.frame % 8) * displayObject.size.x,
                (displayObject.frame ~/ 8) * displayObject.size.y,
                displayObject.size.x,
                displayObject.size.y,
                realPosition.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * game.zoom,
                realPosition.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * game.zoom,
                displayObject.size.x * displayObject.scale.x * game.zoom,
                displayObject.size.y * displayObject.scale.y * game.zoom);
              else
                context.drawImageScaled(displayObject.image,
                realPosition.x - displayObject.size.x * displayObject.anchor.x * displayObject.scale.x * game.zoom,
                realPosition.y - displayObject.size.y * displayObject.anchor.y * displayObject.scale.y * game.zoom,
                displayObject.size.x * displayObject.scale.x * game.zoom,
                displayObject.size.y * displayObject.scale.y * game.zoom);
            }

            if (displayObject.alpha != 1.0)
              context.globalAlpha = 1.0;
          }
        }

        // render rectangle
        else if (displayObject is Rect) {

        }

        // render circle
        else if (displayObject is Circle) {

        }

        // render line
        else if (displayObject is Line) {

        }
      }
    }
  }
}