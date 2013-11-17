part of creeper;

void onMouseMove(MouseEvent evt) {
  engine.updateMouse(evt);
  
  if (game != null) {
    game.scrollingLeft = (engine.mouse.position.x == 0);
    game.scrollingRight = (engine.mouse.position.x == engine.width -1);  
    game.scrollingUp = (engine.mouse.position.y == 0);
    game.scrollingDown = (engine.mouse.position.y == engine.height -1);
  }
}

void onMouseMoveGUI(MouseEvent evt) {
  engine.updateMouseGUI(evt);
  UISymbol.checkHovered();
}

void onKeyDown(KeyboardEvent evt) {
  // select uisymbol
  UISymbol.select(evt);
  
  // increase game speed
  if (evt.keyCode == KeyCode.F1) {
    game.faster();
    evt.preventDefault();
  }
  
  // decrease game speed
  if (evt.keyCode == KeyCode.F2) {
    game.slower();
    evt.preventDefault();
  }

  // delete building
  if (evt.keyCode == KeyCode.DELETE) {
    Building.removeSelected();
  }

  // pause/resume
  if (evt.keyCode == KeyCode.PAUSE || evt.keyCode == KeyCode.TAB) {
    if (game.paused)
      game.resume();
    else
      game.pause();
  }

  // deselect all
  if (evt.keyCode == KeyCode.ESC || evt.keyCode == KeyCode.SPACE) {
    UISymbol.deselect();
    Building.deselect();
    Ship.deselect();
    engine.canvas["main"].view.style.cursor = "url('images/Normal.cur') 2 2, pointer";
  }

  if (evt.keyCode == KeyCode.LEFT)
    game.scrollingLeft = true;
  if (evt.keyCode == KeyCode.UP)
    game.scrollingUp = true;
  if (evt.keyCode == KeyCode.RIGHT)
    game.scrollingRight = true;
  if (evt.keyCode == KeyCode.DOWN)
    game.scrollingDown = true;

  Vector position = game.getHoveredTilePosition();

  // DEBUG: add explosion
  if (evt.keyCode == KeyCode.V) {
    Explosion.add(new Explosion(new Vector(position.x * game.tileSize + 8, position.y * game.tileSize + 8)));
    engine.playSound("explosion", position);
  }
  
  // DEBUG: lower terrain
  if (evt.keyCode == KeyCode.N) {
    if (game.world.tiles[position.x][position.y].height > -1) {
      game.world.tiles[position.x][position.y].height--;
      List tilesToRedraw = new List();
      tilesToRedraw
        ..add(new Vector(position.x, position.y))
        ..add(new Vector(position.x - 1, position.y))
        ..add(new Vector(position.x, position.y - 1))
        ..add(new Vector(position.x + 1, position.y))
        ..add(new Vector(position.x, position.y + 1));
      game.redrawTerrain(tilesToRedraw);
    }
  }

  // DEBUG: raise terrain
  if (evt.keyCode == KeyCode.M) {
    if (game.world.tiles[position.x][position.y].height < 9) {
      game.world.tiles[position.x][position.y].height++;
      List tilesToRedraw = new List();
      tilesToRedraw
        ..add(new Vector(position.x, position.y))
        ..add(new Vector(position.x - 1, position.y))
        ..add(new Vector(position.x, position.y - 1))
        ..add(new Vector(position.x + 1, position.y))
        ..add(new Vector(position.x, position.y + 1));
      game.redrawTerrain(tilesToRedraw);
    }
  }

  // DEBUG: clear terrain
  if (evt.keyCode == KeyCode.B) {
    game.world.tiles[position.x][position.y].height = -1;
    List tilesToRedraw = new List();
    tilesToRedraw
      ..add(new Vector(position.x, position.y))
      ..add(new Vector(position.x - 1, position.y))
      ..add(new Vector(position.x, position.y - 1))
      ..add(new Vector(position.x + 1, position.y))
      ..add(new Vector(position.x, position.y + 1));
    game.redrawTerrain(tilesToRedraw);
  }

  // DEBUG: add creeper
  if (evt.keyCode == KeyCode.X) {
    if (game.world.tiles[position.x][position.y].height > -1) {
      game.world.tiles[position.x][position.y].creep++;
      game.world.tiles[position.x][position.y].newcreep++;
      game.creeperDirty = true;
    }
  }

  // DEBUG: remove creeper
  if (evt.keyCode == KeyCode.C) {
    if (game.world.tiles[position.x][position.y].creep > 0) {
      game.world.tiles[position.x][position.y].creep--;
      if (game.world.tiles[position.x][position.y].creep < 0)
        game.world.tiles[position.x][position.y].creep = 0;
      game.world.tiles[position.x][position.y].newcreep--;
      if (game.world.tiles[position.x][position.y].newcreep < 0)
        game.world.tiles[position.x][position.y].newcreep = 0;
      game.creeperDirty = true;
    }
  }

  // select height for terraforming
  if (game.mode == "TERRAFORM") {

    // remove terraform
    if (evt.keyCode == KeyCode.DELETE) {
      game.world.tiles[position.x][position.y].terraformTarget = -1;
      game.world.tiles[position.x][position.y].terraformProgress = 0;
    }

    // set terraform value
    if (evt.keyCode >= 48 && evt.keyCode <= 57) {
      game.terraformingHeight = evt.keyCode - 49;
      if (game.terraformingHeight == -1)
        game.terraformingHeight = 9;
    }

  }

}

void onKeyUp(KeyboardEvent evt) {
  if (evt.keyCode == KeyCode.LEFT)
    game.scrollingLeft = false;
  if (evt.keyCode == KeyCode.UP)
    game.scrollingUp = false;
  if (evt.keyCode == KeyCode.RIGHT)
    game.scrollingRight = false;
  if (evt.keyCode == KeyCode.DOWN)
    game.scrollingDown = false;
}

void onEnter(evt) {
  engine.mouse.active = true;
}

void onLeave(evt) {
  engine.mouse.active = false;
}

void onLeaveGUI(evt) {
  UISymbol.dehover();
}

void onClickGUI(MouseEvent evt) {
  Building.deselect();
  Ship.deselect();
  UISymbol.setActive();
  engine.playSound("click");
}

void onDoubleClick(MouseEvent evt) {
  Ship.select();
}

void onMouseDown(MouseEvent evt) {
  if (evt.which == 1) {
    // left mouse button
    Vector position = game.getHoveredTilePosition();

    if (engine.mouse.dragStart == null) {
      engine.mouse.dragStart = new Vector(position.x, position.y);
    }
  }
}

void onMouseUp(MouseEvent evt) {
  if (evt.which == 1) {

    Vector position = game.getHoveredTilePosition();

    // set terraforming target
    if (game.mode == "TERRAFORM") {
      game.world.tiles[position.x][position.y].terraformTarget = game.terraformingHeight;
      game.world.tiles[position.x][position.y].terraformProgress = 0;
    }

    Ship.control(position);
    Building.reposition(position);
    Building.select();

    engine.mouse.dragStart = null;

    // when there is an active symbol place building
    if (UISymbol.activeSymbol != null) {
      String type = UISymbol.activeSymbol.imageID.substring(0, 1).toUpperCase() + UISymbol.activeSymbol.imageID.substring(1);
      bool soundSuccess = false;
      for (int i = 0; i < game.ghosts.length; i++) {
        if (game.canBePlaced(game.ghosts[i], UISymbol.activeSymbol.size, null)) {
          soundSuccess = true;
          Building.add(game.ghosts[i], UISymbol.activeSymbol.imageID);
        }
      }
      if (soundSuccess)
        engine.playSound("click");
      else
        engine.playSound("failure");
    }
  } else if (evt.which == 3) {
    game.mode = "DEFAULT";
    Building.deselect();
    Ship.deselect();
    UISymbol.reset();
    querySelector("#terraform").attributes['value'] = "Terraform Off";
  }
}

void onMouseScroll(WheelEvent evt) {
  if (evt.deltaY > 0) {
  //scroll down
    game.zoomOut();
  } else {
  //scroll up
    game.zoomIn();
  }
  //prevent page fom scrolling
  evt.preventDefault();
}

void onResize(evt) {
  // delay the resizing to avoid it being called multiple times
  if (engine.resizeTimer != null)
    engine.resizeTimer.cancel();
  engine.resizeTimer = new Timer(new Duration(milliseconds: 250), doneResizing);
}

void doneResizing() {
  var width = window.innerWidth;
  var height = window.innerHeight;
  engine.width = width;
  engine.height = height;
  engine.halfWidth = width ~/ 2;
  engine.halfHeight = height ~/ 2;

  engine.canvas["main"].updateRect(width, height);
  engine.canvas["levelfinal"].updateRect(width, height);
  engine.canvas["buffer"].updateRect(width, height);
  engine.canvas["collection"].updateRect(width, height);
  engine.canvas["creeperbuffer"].updateRect(width, height);
  engine.canvas["creeper"].updateRect(width, height);

  engine.canvas["gui"].top = engine.canvas["gui"].view.offsetTop;
  engine.canvas["gui"].left = engine.canvas["gui"].view.offsetLeft;

  if (game != null) {
    game.copyTerrain();
    game.drawCollection();
    game.drawCreeper();
  }
}