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
    displayObjects.sort((DisplayObject a, DisplayObject b) {
      return a.layer - b.layer;
    });
  }

  void removeDisplayObject(DisplayObject displayObject) {
    displayObjects.removeAt(displayObjects.indexOf(displayObject));
  }
  
  /**
   * Checks if an object with a given [position] and [size]
   * is visible in the renderer view. Returns true or false.
   */
  bool isVisible(Vector position, Vector size) {
    Rectangle object = new Rectangle(position.x, position.y, size.x, size.y);    
    Rectangle myview = new Rectangle(0, 0, view.width, view.height);   
    return myview.intersects(object);
  }

  void draw() {
    
    context.save();
    context.shadowBlur = 5;
    context.shadowColor = "#222";
    context.shadowOffsetX = 5;
    context.shadowOffsetY = 5;
    
    for (var displayObject in displayObjects) {
      if (displayObject.visible) {

        // render sprite
        if (displayObject is Sprite) {
          Vector realPosition = displayObject.position.real2screen();

          if (isVisible(realPosition, new Vector(displayObject.size.x * game.zoom, displayObject.size.y * game.zoom))) {

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
          Vector realPosition = displayObject.position.real2screen();

          if (isVisible(realPosition, displayObject.size * game.zoom)) {
            context.lineWidth = displayObject.lineWidth;
            context.fillStyle = displayObject.color;
            context.fillRect(realPosition.x - displayObject.size.x * displayObject.anchor.x * game.zoom,
                             realPosition.y - displayObject.size.y * displayObject.anchor.y * game.zoom,
                             displayObject.size.x * game.zoom,
                             displayObject.size.y * game.zoom);
          }
        }

        // render circle
        else if (displayObject is Circle) {
          Vector realPosition = displayObject.position.real2screen();

          if (isVisible(realPosition, new Vector(displayObject.radius * displayObject.scale * game.zoom, displayObject.radius * displayObject.scale * game.zoom))) {
            context.lineWidth = displayObject.lineWidth;
            context.strokeStyle = displayObject.color;
            context.beginPath();
            context.arc(realPosition.x, realPosition.y, displayObject.radius * displayObject.scale * game.zoom, 0, PI * 2, true);
            context.closePath();
            context.stroke();
          }
        }

        // render line
        else if (displayObject is Line) {
          Vector realPositionFrom = displayObject.from.real2screen();
          Vector realPositionTo = displayObject.to.real2screen();

          context.lineWidth = displayObject.lineWidth;
          context.strokeStyle = displayObject.color;

          context.beginPath();
          context.moveTo(realPositionFrom.x, realPositionFrom.y);
          context.lineTo(realPositionTo.x, realPositionTo.y);
          context.stroke();
        }
      }
    }
    
    context.restore();
  }
}