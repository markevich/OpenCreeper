part of creeper;

void onResize(evt) {
  // delay the resizing to avoid it being called multiple times
  if (Zei.resizeTimer != null)
    Zei.resizeTimer.cancel();
  Zei.resizeTimer = new Timer(new Duration(milliseconds: 250), doneResizing);
}

void doneResizing() {
  var width = window.innerWidth;
  var height = window.innerHeight;

  Zei.renderer["main"].updateRect(width, height);
  Zei.renderer["levelfinal"].updateRect(width, height);
  Zei.renderer["collection"].updateRect(width, height);
  Zei.renderer["creeper"].updateRect(width, height);

  Zei.renderer["gui"].top = Zei.renderer["gui"].view.offsetTop;
  Zei.renderer["gui"].left = Zei.renderer["gui"].view.offsetLeft;

  if (game != null) {
    game.world.copyTiles();
    game.world.drawCollection();
    game.world.drawCreeper();
  }
}