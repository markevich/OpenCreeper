part of creeper;

void onMouseMove(MouseEvent evt) {
  engine.updateMouse(evt);
  
  if (game != null) {
    game.mouseScrolling = new Vector.empty();
    if (engine.mouse.position.x == 0) game.mouseScrolling.x = -1;
    else if (engine.mouse.position.x == engine.width - 1) game.mouseScrolling.x = 1;   
    if (engine.mouse.position.y == 0) game.mouseScrolling.y = -1;
    else if (engine.mouse.position.y == engine.height - 1) game.mouseScrolling.y = 1;
  }
  
  // flag for terraforming
  if (engine.mouse.buttonPressed == 1) {
    if (game.mode == "TERRAFORM") { 
      if (game.world.contains(game.hoveredTile)) {
        
        Rectangle currentRect = new Rectangle(game.hoveredTile.x * game.tileSize,
                                              game.hoveredTile.y * game.tileSize,
                                              game.tileSize - 1,
                                              game.tileSize - 1); 
        
        // check for building/emitter/sporetower on that position
        if (!Building.collision(currentRect) &&
            !Emitter.collision(currentRect) &&
            !Sporetower.collision(currentRect)) {
          game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].flagTerraform(game.hoveredTile * game.tileSize);
        }
      }
    }
  }
}

void onMouseMoveGUI(MouseEvent evt) {
  UISymbol.checkHovered(evt);
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
    engine.renderer["main"].view.style.cursor = "url('images/Normal.cur') 2 2, pointer";
  }

  if (evt.keyCode == KeyCode.LEFT)
    game.keyScrolling.x = -1;
  if (evt.keyCode == KeyCode.UP)
    game.keyScrolling.y = -1;
  if (evt.keyCode == KeyCode.RIGHT)
    game.keyScrolling.x = 1;
  if (evt.keyCode == KeyCode.DOWN)
    game.keyScrolling.y = 1;

  // DEBUG: add explosion
  if (evt.keyCode == KeyCode.V) {
    Explosion.add(new Vector(game.hoveredTile.x * game.tileSize + 8, game.hoveredTile.y * game.tileSize + 8));
    engine.playSound("explosion", game.hoveredTile);
  }
  
  // DEBUG: lower terrain
  if (evt.keyCode == KeyCode.N) {
    if (game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height > -1) {
      game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height--;
      List tilesToRedraw = new List();
      tilesToRedraw
        ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y))
        ..add(new Vector(game.hoveredTile.x - 1, game.hoveredTile.y))
        ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y - 1))
        ..add(new Vector(game.hoveredTile.x + 1, game.hoveredTile.y))
        ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y + 1));
      game.redrawTerrain(tilesToRedraw);
    }
  }

  // DEBUG: raise terrain
  if (evt.keyCode == KeyCode.M) {
    if (game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height < 9) {
      game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height++;
      List tilesToRedraw = new List();
      tilesToRedraw
        ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y))
        ..add(new Vector(game.hoveredTile.x - 1, game.hoveredTile.y))
        ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y - 1))
        ..add(new Vector(game.hoveredTile.x + 1, game.hoveredTile.y))
        ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y + 1));
      game.redrawTerrain(tilesToRedraw);
    }
  }

  // DEBUG: clear terrain
  if (evt.keyCode == KeyCode.B) {
    game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height = -1;
    List tilesToRedraw = new List();
    tilesToRedraw
      ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y))
      ..add(new Vector(game.hoveredTile.x - 1, game.hoveredTile.y))
      ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y - 1))
      ..add(new Vector(game.hoveredTile.x + 1, game.hoveredTile.y))
      ..add(new Vector(game.hoveredTile.x, game.hoveredTile.y + 1));
    game.redrawTerrain(tilesToRedraw);
  }

  // DEBUG: add creeper
  if (evt.keyCode == KeyCode.X) {
    if (game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].height > -1) {
      game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep++;
      World.creeperDirty = true;
    }
  }

  // DEBUG: remove creeper
  if (evt.keyCode == KeyCode.C) {
    if (game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep > 0) {
      game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep--;
      if (game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep < 0)
        game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].creep = 0;
      World.creeperDirty = true;
    }
  }

  // select height for terraforming
  if (game.mode == "TERRAFORM") {

    // remove terraform
    if (evt.keyCode == KeyCode.DELETE) {
      game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].unflagTerraform();
    }

    // set terraform value
    if (evt.keyCode >= 48 && evt.keyCode <= 57) {
      game.terraformingHeight = evt.keyCode - 49;
      if (game.terraformingHeight == -1) {
        game.terraformingHeight = 9;
      }
      game.tfNumber.frame = game.terraformingHeight;
    }

  }

}

void onKeyUp(KeyboardEvent evt) {
  if (evt.keyCode == KeyCode.LEFT || evt.keyCode == KeyCode.RIGHT)
    game.keyScrolling.x = 0;
  if (evt.keyCode == KeyCode.UP || evt.keyCode == KeyCode.DOWN)
    game.keyScrolling.y = 0;
}

void onEnter(evt) {
  engine.mouse.overCanvas = true;
}

void onLeave(evt) {
  engine.mouse.overCanvas = false;
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
  engine.mouse.buttonPressed = evt.which;
  
  if (evt.which == 1) {   
    
    if (engine.mouse.dragStart == null) {
      engine.mouse.dragStart = game.hoveredTile;
    }  
    
    // flag for terraforming 
    if (game.mode == "TERRAFORM") {
      if (game.world.contains(game.hoveredTile)) {
        
        Rectangle currentRect = new Rectangle(game.hoveredTile.x * game.tileSize,
            game.hoveredTile.y * game.tileSize,
                                              game.tileSize - 1,
                                              game.tileSize - 1); 
        
        // check for building/emitter/sporetower on that position
        if (!Building.collision(currentRect) &&
            !Emitter.collision(currentRect) &&
            !Sporetower.collision(currentRect)) {
          game.world.tiles[game.hoveredTile.x][game.hoveredTile.y].flagTerraform(game.hoveredTile * game.tileSize);
        }
      }
    }
  }
}

void onMouseUp(MouseEvent evt) {
  engine.mouse.buttonPressed = 0;
  
  if (evt.which == 1) {

    Ship.control(game.hoveredTile);
    Building.reposition(game.hoveredTile);
    Building.select();

    engine.mouse.dragStart = null;

    // when there is an active symbol place building
    if (UISymbol.activeSymbol != null) {
      String type = UISymbol.activeSymbol.building.type.substring(0, 1).toUpperCase() + UISymbol.activeSymbol.building.type.substring(1);
      
      // if at least one ghost can be placed play matching sound
      bool soundSuccess = false;
      for (int i = 0; i < game.ghosts.length; i++) {
        if (game.canBePlaced(game.ghosts[i], UISymbol.activeSymbol.building)) {
          Building.add(game.ghosts[i], UISymbol.activeSymbol.building.type);
          soundSuccess = true;
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

  engine.renderer["main"].updateRect(width, height);
  engine.renderer["levelfinal"].updateRect(width, height);
  engine.renderer["buffer"].updateRect(width, height);
  engine.renderer["collection"].updateRect(width, height);
  engine.renderer["creeperbuffer"].updateRect(width, height);
  engine.renderer["creeper"].updateRect(width, height);

  engine.renderer["gui"].top = engine.renderer["gui"].view.offsetTop;
  engine.renderer["gui"].left = engine.renderer["gui"].view.offsetLeft;

  if (game != null) {
    game.copyTerrain();
    game.drawCollection();
    game.drawCreeper();
  }
}