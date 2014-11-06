part of zei;

class Zoomer {
  double zoom = 1.0, zoomPercentage, min = 0.1, max = 10.0;
  int doZoom = 0;
  bool hasChanged = false;

  Zoomer(this.zoom, this.min, this.max) {
    zoomPercentage = 10.0;
    Renderer.setZoom(zoom);
  }

  void update() {
    hasChanged = false;
    if (doZoom != 0) {
      if (doZoom == 1) {
        if (zoom * (1 + zoomPercentage / 100) < max) {
          zoom *= (1 + zoomPercentage / 100);
        }
      }
      else if (doZoom == -1) {
        if (zoom / (1 + zoomPercentage / 100) > min) {
          zoom /= (1 + zoomPercentage / 100);
        }
      }
      doZoom = 0;
      zoom = double.parse(zoom.toStringAsFixed(2));
      Renderer.setZoom(zoom);
      hasChanged = true;
    }
  }

  void onMouseEvent(evt) {
    if (evt.type == "mousewheel") {
      if (evt.deltaY > 0) { // scroll down
        doZoom = -1;
      } else { // scroll up
        doZoom = 1;
      }
      //prevent page fom scrolling
      evt.preventDefault();
    }
  }

  void onKeyEvent(evt, String type) {}

}