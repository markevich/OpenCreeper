part of creeper;

class World extends Zei.GameObject {
  List<List<Tile>> tiles;
  Zei.Vector2 size;
  int creeperCounter, terraformingHeight = 0;
  static bool creeperDirty = true;
  Zei.Line tfLine1, tfLine2, tfLine3, tfLine4;
  Zei.Sprite tfNumber;
  List<Zei.Vector2> ghosts = new List<Zei.Vector2>();
  List<Zei.DisplayObject> ghostDisplayObjects = new List<Zei.DisplayObject>();
  Zei.Vector2 oldHoveredTile = new Zei.Vector2.empty(), hoveredTile = new Zei.Vector2.empty();
  double zoom = 1.0;
  
  World(int seed) {
    size = new Zei.Vector2(Zei.randomInt(64, 127, seed), Zei.randomInt(64, 127, seed));
    creeperCounter = 0;
    
    // create terraform lines and number used when terraforming is enabled
    tfLine1 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    tfLine2 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    tfLine3 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    tfLine4 = Zei.Line.create("main", "terraform", new Zei.Vector2.empty(), new Zei.Vector2.empty(), 1, new Zei.Color.white(), visible: false);
    
    tfNumber = Zei.Sprite.create("main", "terraform", Zei.images["numbers"], new Zei.Vector2.empty(), 16, 16, animated: true, frame: terraformingHeight, visible: false);
    tfNumber.stopAnimation();
    
    int width = window.innerWidth;
    int height = window.innerHeight;
    
    for (int i = 0; i < 10; i++) {
      Zei.Renderer.create("level$i", 128 * 16, 128 * 16, autodraw: false);
    }
    Zei.Renderer.create("levelbuffer", 128 * 16, 128 * 16, autodraw: false);
    Zei.Renderer.create("levelfinal", width, height, container: "body", autodraw: false);
    
    Zei.Renderer.create("collection", width, height, container: "body", autodraw: false);
    
    Zei.Renderer.create("creeper", width, height, container: "body", autodraw: false);
  }
  
  /**
  * Creates a random world with base, emitters and sporetowers.
  */
  void create() {
    createRandomLandscape();

    // create random base
    Zei.Vector2 randomPosition = new Zei.Vector2(
      Zei.randomInt(4, size.x - 5, game.seed + 1),
      Zei.randomInt(4, size.y - 5, game.seed + 1));

    game.scroller.scroll = randomPosition;
    Zei.renderer["main"].updatePosition(new Zei.Vector2(game.scroller.scroll.x * Tile.size, game.scroller.scroll.y * Tile.size));

    Building building = Building.add(randomPosition, "base");
    makeFlatSurface(building.position, 9);

    if (!game.friendly) {
      // create random emitters
      int amount = Zei.randomInt(2, 3, game.seed);
      for (var i = 0; i < amount; i++) {    
         randomPosition = new Zei.Vector2(
             Zei.randomInt(1, size.x - 2, game.seed + Zei.randomInt(1, 1000, game.seed + i)) * Tile.size + 8,
             Zei.randomInt(1, size.y - 2, game.seed + Zei.randomInt(1, 1000, game.seed + 1 + i)) * Tile.size + 8);
   
        Emitter emitter = Emitter.add(randomPosition, 25);
        makeFlatSurface(emitter.sprite.position, 3);    
      }
 
      // create random sporetowers
      amount = Zei.randomInt(1, 2, game.seed + 1);
      for (var i = 0; i < amount; i++) {
        randomPosition = new Zei.Vector2(
           Zei.randomInt(1, size.x - 2, game.seed + 3 + Zei.randomInt(1, 1000, game.seed + 2 + i)) * Tile.size + 8,
           Zei.randomInt(1, size.y - 2, game.seed + 3 + Zei.randomInt(1, 1000, game.seed + 3 + i)) * Tile.size + 8);
   
        Sporetower sporetower = Sporetower.add(randomPosition);
        makeFlatSurface(sporetower.sprite.position, 3);
      }
    }
  }
  
  void createRandomLandscape() {
    tiles = new List(size.x);
    for (int i = 0; i < size.x; i++) {
      tiles[i] = new List<Tile>(size.y);
      for (int j = 0; j < size.y; j++) {
        tiles[i][j] = new Tile(i, j);
      }
    }

    var heightmap = new HeightMap(game.seed, 129, 0, 90);
    heightmap.run();

    for (int i = 0; i < size.x; i++) {
      for (int j = 0; j < size.y; j++) {
        int height = (heightmap.map[i][j] / 10).round();
        if (height > 10)
          height = 10;
        tiles[i][j].height = height;
      }
    }
  }
  
  // makes a flat surface for base, emitters and spore towers when creating the world
  void makeFlatSurface(position, size) {
    int height = game.world.getTile(position).height;
    if (height < 0)
      height = 0;
    for (int i = -size ~/ 2; i <= size ~/ 2; i++) {
      for (int j = -size ~/ 2; j <= size ~/ 2; j++) {
        game.world.getTile(position + new Zei.Vector2(i * Tile.size, j * Tile.size)).height = height;
      }
    }
  }
  
  void hideRangeBoxes() {
    for (int i = 0; i < size.x; i++) {
      for (int j = 0; j < size.y; j++) {
        tiles[i][j].rangeBox.visible = false;
      }
    }
  }
  
  /**
   * Checks if a given [position] in world coordinates is contained within the world
   */
  bool contains(Zei.Vector2 position) {
    return (position.x > -1 && position.x < size.x && position.y > -1 && position.y < size.y);
  }
  
  Tile getTile(Zei.Vector2 position) {
    return tiles[position.x ~/ Tile.size][position.y ~/ Tile.size];
  }  
  
  void update() {
    // update creeper
    creeperCounter += 1 * game.speed;
    if (creeperCounter >= 25) {
      creeperCounter -= 25;
      creeperDirty = true;
      
      // synchronize new creep with old creep
      for (int i = 0; i < size.x; i++) {
        for (int j = 0; j < size.y; j++) {
          tiles[i][j].newcreep = tiles[i][j].creep;
        }
      }

      for (int i = 0; i < size.x; i++) {
        for (int j = 0; j < size.y; j++) {

          // right neighbour
          if (i + 1 < size.x) {
            transferCreeper(tiles[i][j], tiles[i + 1][j]);
          }
          // left neighbour
          if (i - 1 > -1) {
            transferCreeper(tiles[i][j], tiles[i - 1][j]);
          }
          // bottom neighbour
          if (j + 1 < size.y) {
            transferCreeper(tiles[i][j], tiles[i][j + 1]);
          }
          // top neighbour
          if (j - 1 > -1) {
            transferCreeper(tiles[i][j], tiles[i][j - 1]);
          }

        }
      }
      
      // clamp creeper
      for (int i = 0; i < size.x; i++) {
        for (int j = 0; j < size.y; j++) {
          if (tiles[i][j].newcreep > 10)
            tiles[i][j].newcreep = 10;
          else if (tiles[i][j].newcreep < .01)
            tiles[i][j].newcreep = 0;
          tiles[i][j].creep = tiles[i][j].newcreep;
        }
      }

    }
    
    if (creeperDirty) {
      game.world.drawCreeper();
      creeperDirty = false;
    }
    
    game.world.drawCollection();
    
    // update terraform display objects
    if (contains(game.world.hoveredTile)) {   
      if (game.mode == "TERRAFORM") {
        Zei.Vector2 drawPosition = game.world.hoveredTile * Tile.size;
        tfLine1 // first horizontal line
          ..from = new Zei.Vector2(0, drawPosition.y)
          ..to = new Zei.Vector2(size.y * Tile.size, drawPosition.y)
          ..visible = true;
        tfLine2 // second horizontal line
          ..from = new Zei.Vector2(0, drawPosition.y + Tile.size)
          ..to = new Zei.Vector2(size.y * Tile.size, drawPosition.y + Tile.size)
          ..visible = true;
        tfLine3 // first vertical line
          ..from = new Zei.Vector2(drawPosition.x, 0)
          ..to = new Zei.Vector2(drawPosition.x, size.y * Tile.size)
          ..visible = true;
        tfLine4 // second vertical line
          ..from = new Zei.Vector2(drawPosition.x + Tile.size, 0)
          ..to = new Zei.Vector2(drawPosition.x + Tile.size, size.y * Tile.size)
          ..visible = true;
        tfNumber
          ..position = game.world.hoveredTile * Tile.size
          ..visible = true;       
      } else {
        tfLine1.visible = false;
        tfLine2.visible = false;
        tfLine3.visible = false;
        tfLine4.visible = false;
        tfNumber.visible = false;
      }      
    } else {
      tfLine1.visible = false;
      tfLine2.visible = false;
      tfLine3.visible = false;
      tfLine4.visible = false;
      tfNumber.visible = false;
    }
    
    // update ghosts
    updateGhosts();
  }

  /**
   * Transfers creeper from one tile to another.
   */ 
  static void transferCreeper(Tile source, Tile target) {
    num transferRate = .2;

    if (source.height > -1 && target.height > -1) {
      num sourceCreeper = source.creep;     
      //num targetCreeper = target.creep;
      if (sourceCreeper > 0 /*|| targetCreeper > 0*/) {
        num sourceTotal = source.height + source.creep;
        num targetTotal = target.height + target.creep;
        num delta = 0;
        if (sourceTotal > targetTotal) {
          delta = sourceTotal - targetTotal;
          if (delta > sourceCreeper)
            delta = sourceCreeper;
          num adjustedDelta = delta * transferRate;
          source.newcreep -= adjustedDelta;
          target.newcreep += adjustedDelta;
        }
      }
    }
  }
  
  /**
   * Draws the world tiles.
   * This method is only called ONCE at the start of the game.
   */
  void drawTiles() {
    // 1st pass - draw masks
    for (int i = 0; i < size.x; i++) {
      for (int j = 0; j < size.y; j++) {
        int indexAbove = -1;
        for (int k = 9; k > -1; k--) {
        
          if (k <= tiles[i][j].height) {

            // calculate index
            int up = 0, down = 0, left = 0, right = 0;
            if (j - 1 < 0)
              up = 0;
            else if (tiles[i][j - 1].height >= k)
              up = 1;
            if (j + 1 > size.y - 1)
              down = 0;
            else if (tiles[i][j + 1].height >= k)
              down = 1;
            if (i - 1 < 0)
              left = 0;
            else if (tiles[i - 1][j].height >= k)
              left = 1;
            if (i + 1 > size.x - 1)
              right = 0;
            else if (tiles[i + 1][j].height >= k)
              right = 1;

            // save index
            int index = (8 * down) + (4 * left) + (2 * up) + right;
            if (k == tiles[i][j].height)
              tiles[i][j].index = index;
            
            if (k < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            indexAbove = index;
           
            Zei.renderer["level$k"].context.drawImageScaledFromSource(Zei.images["mask"], index * (Tile.size + 6) + 3, (Tile.size + 6) + 3, Tile.size, Tile.size, i * Tile.size, j * Tile.size, Tile.size, Tile.size);
          }
        }
      }
    }

    // 2nd pass - draw textures
    for (int i = 0; i < 10; i++) {
      CanvasPattern pattern = Zei.renderer["level$i"].context.createPatternFromImage(Zei.images["level$i"], 'repeat');
      Zei.renderer["level$i"].context.globalCompositeOperation = 'source-in';
      Zei.renderer["level$i"].context.fillStyle = pattern;
      Zei.renderer["level$i"].context.fillRect(0, 0, Zei.renderer["level$i"].view.width, Zei.renderer["level$i"].view.height);
      Zei.renderer["level$i"].context.globalCompositeOperation = 'source-over';
    }

    // 3rd pass - draw borders
    for (int i = 0; i < size.x; i++) {
      for (int j = 0; j < size.y; j++) {
        int indexAbove = -1;
        for (int k = 9; k > -1; k--) {
           
          if (k <= tiles[i][j].height) {

            // calculate index
            int up = 0, down = 0, left = 0, right = 0;
            if (j - 1 < 0)
              up = 0;
            else if (tiles[i][j - 1].height >= k)
              up = 1;
            if (j + 1 > size.y - 1)
              down = 0;
            else if (tiles[i][j + 1].height >= k)
              down = 1;
            if (i - 1 < 0)
              left = 0;
            else if (tiles[i - 1][j].height >= k)
              left = 1;
            if (i + 1 > size.x - 1)
              right = 0;
            else if (tiles[i + 1][j].height >= k)
              right = 1;
            
            int index = (8 * down) + (4 * left) + (2 * up) + right;
          
            if (k < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            indexAbove = index;
  
            Zei.renderer["level$k"].context.drawImageScaledFromSource(Zei.images["borders"], index * (Tile.size + 6) + 2, 2, Tile.size + 2, Tile.size + 2, i * Tile.size, j * Tile.size, (Tile.size + 2), (Tile.size + 2));       
          }
        }
      }
    }

    Zei.renderer["levelbuffer"].clear();
    for (int k = 0; k < 10; k++) {
      Zei.renderer["levelbuffer"].context.drawImage(Zei.renderer["level$k"].view, 0, 0);
    }
    querySelector('#loading').style.display = 'none';
  }
  
  /**
   * Takes a list of [tiles] and redraws them.
   * This is used when the terrain height of a tile has been changed by a Terp.
   */
  void redrawTiles(List redrawtiles) {
    List tempCanvas = [];
    List tempContext = [];
    for (int t = 0; t < 10; t++) {
      tempCanvas.add(new CanvasElement());
      tempCanvas[t].width = Tile.size;
      tempCanvas[t].height = Tile.size;
      tempContext.add(tempCanvas[t].getContext('2d'));
    }

    for (int i = 0; i < redrawtiles.length; i++) {

      int iS = redrawtiles[i].x;
      int jS = redrawtiles[i].y;

      if (contains(new Zei.Vector2(iS, jS))) {
        // recalculate index
        int index = -1;
        int indexAbove = -1;
        for (int t = 9; t > -1; t--) {
          if (t <= tiles[iS][jS].height) {
    
            int up = 0, down = 0, left = 0, right = 0;
            if (jS - 1 < 0)
              up = 0;
            else if (tiles[iS][jS - 1].height >= t)
              up = 1;
            if (jS + 1 > size.y - 1)
              down = 0;
            else if (tiles[iS][jS + 1].height >= t)
              down = 1;
            if (iS - 1 < 0)
              left = 0;
            else if (tiles[iS - 1][jS].height >= t)
              left = 1;
            if (iS + 1 > size.x - 1)
              right = 0;
            else if (tiles[iS + 1][jS].height >= t)
              right = 1;
    
            // save index for later use
            index = (8 * down) + (4 * left) + (2 * up) + right;
          }
              
          //if (index > -1) {
            tempContext[t].clearRect(0, 0, Tile.size, Tile.size);
            
            // redraw mask          
            if (t < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            tempContext[t].drawImageScaledFromSource(Zei.images["mask"], index * (Tile.size + 6) + 3, (Tile.size + 6) + 3, Tile.size, Tile.size, 0, 0, Tile.size, Tile.size);
  
            // redraw pattern
            var pattern = tempContext[t].createPatternFromImage(Zei.images["level$t"], 'repeat');
  
            tempContext[t].globalCompositeOperation = 'source-in';
            tempContext[t].fillStyle = pattern;
  
            tempContext[t].save();
            Zei.Vector2 translation = new Zei.Vector2((iS * Tile.size).floor(), (jS * Tile.size).floor());
            tempContext[t].translate(-translation.x, -translation.y);
  
            tempContext[t].fillRect(translation.x, translation.y, Tile.size, Tile.size);
            tempContext[t].restore();
  
            tempContext[t].globalCompositeOperation = 'source-over';
  
            // redraw borders
            if (t < 9) {
              // skip tiles that are identical to the one above
              if (index == indexAbove)
                continue;
              // skip tiles that are not visible
              if (indexAbove == 5 || indexAbove == 7 || indexAbove == 10 || indexAbove == 11 ||
                  indexAbove == 13 || indexAbove == 14 || indexAbove == 15)
                continue;
            }
            
            tempContext[t].drawImageScaledFromSource(Zei.images["borders"], index * (Tile.size + 6) + 2, 2, Tile.size + 2, Tile.size + 2, 0, 0, (Tile.size + 2), (Tile.size + 2));         
          //}
          
          // set above index
          indexAbove = index;
        }
  
        Zei.renderer["levelbuffer"].context.clearRect(iS * Tile.size, jS * Tile.size, Tile.size, Tile.size);
        for (int t = 0; t < 10; t++) {
          Zei.renderer["levelbuffer"].context.drawImageScaledFromSource(tempCanvas[t], 0, 0, Tile.size, Tile.size, iS * Tile.size, jS * Tile.size, Tile.size, Tile.size);
        }
      }
    }
    copyTiles();
  }

  /**
   * After scrolling, zooming, or tile redrawing the terrain is copied from the "levelbuffer" to "levelfinal" renderer
   * to the "main" renderer.
   */
  void copyTiles() {
    Zei.renderer["levelfinal"].clear();

    var targetLeft = 0;
    var targetTop = 0;
    var sourceLeft = game.scroller.scroll.x * Tile.size - Zei.renderer["main"].view.width / 2 / game.world.zoom;
    var sourceTop = game.scroller.scroll.y * Tile.size - Zei.renderer["main"].view.height / 2 / game.world.zoom;
    if (sourceLeft < 0) {
      targetLeft = -sourceLeft * game.world.zoom;
      sourceLeft = 0;
    }
    if (sourceTop < 0) {
      targetTop = -sourceTop * game.world.zoom;
      sourceTop = 0;
    }

    var targetWidth = Zei.renderer["main"].view.width;
    var targetHeight = Zei.renderer["main"].view.height;
    var sourceWidth = Zei.renderer["main"].view.width / game.world.zoom;
    var sourceHeight = Zei.renderer["main"].view.height / game.world.zoom;
    if (sourceLeft + sourceWidth > size.x * Tile.size) {
      targetWidth -= (sourceLeft + sourceWidth - size.x * Tile.size) * game.world.zoom;
      sourceWidth = size.x * Tile.size - sourceLeft;
    }
    if (sourceTop + sourceHeight > size.y * Tile.size) {
      targetHeight -= (sourceTop + sourceHeight - size.y * Tile.size) * game.world.zoom;
      sourceHeight = size.y * Tile.size - sourceTop;
    }
    Zei.renderer["levelfinal"].context.drawImageScaledFromSource(Zei.renderer["levelbuffer"].view, sourceLeft, sourceTop, sourceWidth, sourceHeight, targetLeft, targetTop, targetWidth, targetHeight);
  }
  
  /**
   * Draws the green collection areas of collectors.
   */
  void drawCollection() {
    Zei.renderer["collection"].clear();


    int timesX = (Zei.renderer["collection"].view.width / 2 / Tile.size / game.world.zoom).ceil();
    int timesY = (Zei.renderer["collection"].view.height / 2 / Tile.size / game.world.zoom).ceil();

    for (int i = -timesX; i <= timesX; i++) {
      for (int j = -timesY; j <= timesY; j++) {

        Zei.Vector2 position = new Zei.Vector2(i + game.scroller.scroll.x, j + game.scroller.scroll.y);

        if (contains(position)) {
          if (tiles[position.x][position.y].collector != null) {
            
            Zei.renderer["collection"].context.save();
            Zei.renderer["collection"].context.globalAlpha = tiles[position.x][position.y].collectionAlpha; //.25;
            
            int up = 0, down = 0, left = 0, right = 0;
            if (position.y - 1 < 0)
              up = 0;
            else
              up = tiles[position.x][position.y - 1].collector != null ? 1 : 0;
            if (position.y + 1 > size.y - 1)
              down = 0;
            else
              down = tiles[position.x][position.y + 1].collector != null ? 1 : 0;
            if (position.x - 1 < 0)
              left = 0;
            else
              left = tiles[position.x - 1][position.y].collector != null ? 1 : 0;
            if (position.x + 1 > size.x - 1)
              right = 0;
            else
              right = tiles[position.x + 1][position.y].collector != null ? 1 : 0;

            int index = (8 * down) + (4 * left) + (2 * up) + right;
            Zei.renderer["collection"].context.drawImageScaledFromSource(Zei.images["mask"], index * (Tile.size + 6) + 3, (Tile.size + 6) + 3, Tile.size, Tile.size, Zei.renderer["main"].view.width / 2 + i * Tile.size * game.world.zoom, Zei.renderer["main"].view.height / 2 + j * Tile.size * game.world.zoom, Tile.size * game.world.zoom, Tile.size * game.world.zoom);
          
            Zei.renderer["collection"].context.restore();
          }
        }
      }
    }
    
  }
  
  void drawCreeper() {
    Zei.renderer["creeper"].clear();

    int timesX = (Zei.renderer["creeper"].view.width / 2 / Tile.size / game.world.zoom).ceil();
    int timesY = (Zei.renderer["creeper"].view.height / 2 / Tile.size / game.world.zoom).ceil();

    for (int i = -timesX; i <= timesX; i++) {
      for (int j = -timesY; j <= timesY; j++) {

        Zei.Vector2 position = new Zei.Vector2(i + game.scroller.scroll.x, j + game.scroller.scroll.y);
       
        if (contains(position)) {
         
          int height = tiles[position.x][position.y].height;
         
          // TODO: don't redraw everything each frame
          for (var t = 0; t <= 9; t++) {

            if (tiles[position.x][position.y].creep > t) {
             
              int up = 0, down = 0, left = 0, right = 0;
              if (position.y - 1 < 0)
                up = 0;
              else if (tiles[position.x][position.y - 1].creep > t || tiles[position.x][position.y - 1].height > height)
                up = 1;
              if (position.y + 1 > size.y - 1)
                down = 0;
              else if (tiles[position.x][position.y + 1].creep > t || tiles[position.x][position.y + 1].height > height)
                down = 1;
              if (position.x - 1 < 0)
                left = 0;
              else if (tiles[position.x - 1][position.y].creep > t || tiles[position.x - 1][position.y].height > height)
                left = 1;
              if (position.x + 1 > size.x - 1)
                right = 0;
              else if (tiles[position.x + 1][position.y].creep > t || tiles[position.x + 1][position.y].height > height)
                right = 1;
 
              int index = (8 * down) + (4 * left) + (2 * up) + right;
              Zei.renderer["creeper"].context.drawImageScaledFromSource(Zei.images["creeper"], index * Tile.size, 0, Tile.size, Tile.size, Zei.renderer["main"].view.width / 2 + i * Tile.size * game.world.zoom, Zei.renderer["main"].view.height / 2 + j * Tile.size * game.world.zoom, Tile.size * game.world.zoom, Tile.size * game.world.zoom);
              continue;
            }
           
            if (t < 9) {
              int ind = tiles[position.x][position.y].index;
              bool indexOk = (ind != 5 && ind != 7 && ind != 10 && ind != 11 && ind != 13 && ind != 14 && ind != 14);
              int up = 0, down = 0, left = 0, right = 0;
              if (position.y - 1 < 0)
                up = 0;
              else if (tiles[position.x][position.y - 1].creep > t && indexOk && tiles[position.x][position.y - 1].height < height)
                up = 1;
              if (position.y + 1 > size.y - 1)
                down = 0;
              else if (tiles[position.x][position.y + 1].creep > t && indexOk && tiles[position.x][position.y + 1].height < height)
                down = 1;
              if (position.x - 1 < 0)
                left = 0;
              else if (tiles[position.x - 1][position.y].creep > t && indexOk && tiles[position.x - 1][position.y].height < height)
                left = 1;
              if (position.x + 1 > size.x - 1)
                right = 0;
              else if (tiles[position.x + 1][position.y].creep > t && indexOk && tiles[position.x + 1][position.y].height < height)
                right = 1;
 
              int index = (8 * down) + (4 * left) + (2 * up) + right;
              if (index != 0)
                Zei.renderer["creeper"].context.drawImageScaledFromSource(Zei.images["creeper"], index * Tile.size, 0, Tile.size, Tile.size, Zei.renderer["main"].view.width / 2 + i * Tile.size * game.world.zoom, Zei.renderer["main"].view.height / 2 + j * Tile.size * game.world.zoom, Tile.size * game.world.zoom, Tile.size * game.world.zoom);
            }
          }
        }
       
      }
    }
  }
  
  void clearGhosts() {
    ghosts.clear();
    // remove current ghost display objects
    for (var i = 0; i < ghostDisplayObjects.length; i++) {
      Zei.renderer["main"].removeDisplayObject(ghostDisplayObjects[i]);
    }
    ghostDisplayObjects.clear();
  }
  
  // recalculate ghosts (semi-transparent placeholders when placing a new building)
  void updateGhosts() {
    if (!game.ui.renderer.isHovered && UISymbol.activeSymbol != null) {
    //if (game.hoveredTile != game.oldHoveredTile) {
               
      clearGhosts();
           
      // calculate multiple ghosts when dragging
      if (Zei.mouse.dragStart != null) {
        
        Zei.Vector2 start = Zei.mouse.dragStart;
        Zei.Vector2 end = game.world.hoveredTile;
        Zei.Vector2 delta = end - start;
        num distance = start.distanceTo(end);
        
        num buildingDistance = 3;
        if (UISymbol.activeSymbol.building.type == "collector")
          buildingDistance = 9;
        else if (UISymbol.activeSymbol.building.type == "relay")
          buildingDistance = 18;
        
        num times = distance ~/ buildingDistance + 1;
        
        ghosts.add(start);
        
        for (int i = 1; i < times; i++) {
          Zei.Vector2 ghostPosition = new Zei.Vector2(
              (start.x + (delta.x / distance) * i * buildingDistance).floor(),
              (start.y + (delta.y / distance) * i * buildingDistance).floor());
          
          if (contains(ghostPosition)) {
            ghosts.add(ghostPosition);
          }
        }
        if (contains(end)) {
          ghosts.add(end);
        }
      } else { // single ghost at cursor position
        //if (Zei.mouse.overCanvas) {
          if (contains(game.world.hoveredTile)) {
            ghosts.add(game.world.hoveredTile);
          }
        //}
      }
      
      if (UISymbol.activeSymbol != null) {
        game.world.hideRangeBoxes();
        // create new ghost sprites
        for (var i = 0; i < ghosts.length; i++) {
          
          UISymbol.activeSymbol.building.updateRangeBoxes(ghosts[i]);
          
          Zei.Vector2 ghostCenter = ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2);
          
          ghostDisplayObjects.add(Zei.Sprite.create("main", "terraform", Zei.images[UISymbol.activeSymbol.building.type], ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2), UISymbol.activeSymbol.building.size * Tile.size, UISymbol.activeSymbol.building.size * Tile.size, alpha: 0.5, anchor: new Zei.Vector2(0.5, 0.5)));
          if (UISymbol.activeSymbol.building.type == "cannon")
            ghostDisplayObjects.add(Zei.Sprite.create("main", "terraform", Zei.images["cannongun"], ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2), UISymbol.activeSymbol.building.size * Tile.size, UISymbol.activeSymbol.building.size * Tile.size, alpha: 0.5, anchor: new Zei.Vector2(0.5, 0.5)));
        
          // create colored red or green box
          bool ghostCanBePlaced = UISymbol.activeSymbol.building.canBePlaced(ghosts[i]);
  
          Zei.Color color;
          if (ghostCanBePlaced) {
            color = new Zei.Color(0, 255, 0, 0.5);
          } else {
            color = new Zei.Color(255, 0, 0, 0.5);
          }
          ghostDisplayObjects.add(Zei.Rect.create("main", "terraform", ghosts[i] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2), new Zei.Vector2(UISymbol.activeSymbol.building.size * Tile.size, UISymbol.activeSymbol.building.size * Tile.size), 4, null, color, anchor: new Zei.Vector2(0.5, 0.5)));
          
          if (ghostCanBePlaced) {
            // create lines to other buildings
            for (var building in Zei.GameObject.gameObjects) {
              if (building is Building && building.active) {
                if (UISymbol.activeSymbol.building.type == "collector" || UISymbol.activeSymbol.building.type == "relay" ||
                  building.type == "collector" || building.type == "relay" || building.type == "base") {
    
                  int allowedDistance = 10 * Tile.size;
                  if (building.type == "relay" && UISymbol.activeSymbol.building.type == "relay") {
                    allowedDistance = 20 * Tile.size;
                  }
    
                  if (ghostCenter.distanceTo(building.position) <= allowedDistance) {
                    ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, building.position, 3, new Zei.Color(0, 0, 0, 0.5)));
                    ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, building.position, 2, new Zei.Color(0, 255, 0, 0.5)));
                  }
                }
              }
            }
            
            // create lines to other ghosts
            for (int j = 0; j < ghosts.length; j++) {
              if (j != i) {
                if (UISymbol.activeSymbol.building.type == "collector" || UISymbol.activeSymbol.building.type == "relay") {
    
                  int allowedDistance = 10 * Tile.size;
                  if (UISymbol.activeSymbol.building.type == "relay") {
                    allowedDistance = 20 * Tile.size;
                  }
    
                  Zei.Vector2 ghostJCenter = ghosts[j] * Tile.size + new Zei.Vector2(Tile.size / 2, Tile.size / 2);
                  if (ghostCenter.distanceTo(ghostJCenter) <= allowedDistance) {
                    ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, ghostJCenter, 2, new Zei.Color(0, 0, 0, 0.5)));
                    ghostDisplayObjects.add(Zei.Line.create("main", "connection", ghostCenter, ghostJCenter, 1, new Zei.Color(255, 255, 255, 0.5)));
                  }
                }
              }
            }
          }
          
        }
      }
    }
  }
  
  void onMouseEvent(evt) {
    if (evt.type == "mousemove") {
        
      if (game != null) {
        game.world.oldHoveredTile = game.world.hoveredTile;
        game.world.hoveredTile = new Zei.Vector2(
              ((Zei.mouse.position.x - Zei.renderer["main"].view.width / 2) / (Tile.size * game.world.zoom)).floor() + game.scroller.scroll.x,
              ((Zei.mouse.position.y - Zei.renderer["main"].view.height / 2) / (Tile.size * game.world.zoom)).floor() + game.scroller.scroll.y);
      }
      
      // flag for terraforming
      if (evt.which == 1 /*Zei.mouse.buttonPressed == 1*/) {
        if (game.mode == "TERRAFORM") { 
          if (game.world.contains(game.world.hoveredTile)) {
            
            Rectangle currentRect = new Rectangle(game.world.hoveredTile.x * Tile.size,
                                                  game.world.hoveredTile.y * Tile.size,
                                                  Tile.size - 1,
                                                  Tile.size - 1); 
            
            // check for building/emitter/sporetower on that position
            if (!Building.intersect(currentRect) &&
                !Emitter.intersect(currentRect) &&
                !Sporetower.intersect(currentRect)) {
              game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].flagTerraform(game.world.hoveredTile * Tile.size);
            }
          }
        }
      }
    }
    else if (evt.type == "mouseenter") {
      //Zei.mouse.overCanvas = true;
    }
    else if (evt.type == "mouseleave") {
      //Zei.mouse.overCanvas = false;
    }
    else if (evt.type == "mousewheel") {
      if (evt.deltaY > 0) {
        //scroll down
        doZoom(-.2);
      } else {
        //scroll up
        doZoom(.2);
      }
      //prevent page fom scrolling
      evt.preventDefault();
    }
    else if (evt.type == "mousedown") {
      Zei.mouse.buttonPressed = evt.which;
        
      if (evt.which == 1) {   
        
        if (Zei.mouse.dragStart == null) {
          Zei.mouse.dragStart = game.world.hoveredTile;
        }  
        
        // flag for terraforming 
        if (game.mode == "TERRAFORM") {
          if (game.world.contains(game.world.hoveredTile)) {
            
            Rectangle currentRect = new Rectangle(game.world.hoveredTile.x * Tile.size,
                                                  game.world.hoveredTile.y * Tile.size,
                                                  Tile.size - 1,
                                                  Tile.size - 1); 
            
            // check for building/emitter/sporetower on that position
            if (!Building.intersect(currentRect) &&
                !Emitter.intersect(currentRect) &&
                !Sporetower.intersect(currentRect)) {
              game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].flagTerraform(game.world.hoveredTile * Tile.size);
            }
          }
        }
      }
    }
    else if (evt.type == "mouseup") {
      Zei.mouse.buttonPressed = 0;
        
      if (evt.which == 1) {
        Ship.control(game.world.hoveredTile);
        Building.reposition(game.world.hoveredTile);
        Building.select();
  
        Zei.mouse.dragStart = null;
  
        // when there is an active symbol place building
        if (UISymbol.activeSymbol != null) {
          String type = UISymbol.activeSymbol.building.type.substring(0, 1).toUpperCase() + UISymbol.activeSymbol.building.type.substring(1);
          
          // if at least one ghost can be placed play matching sound
          bool soundSuccess = false;
          for (int i = 0; i < game.world.ghosts.length; i++) {
            if (UISymbol.activeSymbol.building.canBePlaced(game.world.ghosts[i])) {
              Building.add(game.world.ghosts[i], UISymbol.activeSymbol.building.type);
              soundSuccess = true;
            }
          }
          if (soundSuccess)
            Zei.Audio.play("click");
          else
            Zei.Audio.play("failure");
        }
      } else if (evt.which == 3) {
        game.mode = "DEFAULT";
        Building.deselect();
        Ship.deselect();
        UISymbol.reset();
        querySelector("#terraform").attributes['value'] = "Terraform Off";
        game.world.clearGhosts();
      }
    }
  }
   
  void doZoom(zoomAmount) {
    zoom = Zei.clamp(zoom += zoomAmount, .4, 1.6);
    zoom = double.parse(zoom.toStringAsFixed(2));
          
    Zei.Renderer.setZoom(zoom);
    copyTiles();
    drawCollection();
    drawCreeper();
  }
  
  void toggleTerraform() {
    if (game.mode == "TERRAFORM") {
      game.mode = "DEFAULT";
      querySelector("#terraform").attributes['value'] = "Terraform Off";
      tfNumber.visible = false;
    } else {
      game.mode = "TERRAFORM";
      querySelector("#terraform").attributes['value'] = "Terraform On";
      tfNumber.visible = true;
    }
  }
  
  void onKeyEvent(evt) {  
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
      Zei.mouse.showCursor();
    }
    
    // DEBUG: add explosion
    if (evt.keyCode == KeyCode.V) {
      Explosion.add(new Zei.Vector2(game.world.hoveredTile.x * Tile.size + 8, game.world.hoveredTile.y * Tile.size + 8));
      Zei.Audio.play("explosion", game.world.hoveredTile * Tile.size, game.scroller.scroll, game.world.zoom);
    }
    
    // DEBUG: lower terrain
    if (evt.keyCode == KeyCode.N) {
      if (game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height > -1) {
        game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height--;
        List tilesToRedraw = new List();
        tilesToRedraw
          ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y))
          ..add(new Zei.Vector2(game.world.hoveredTile.x - 1, game.world.hoveredTile.y))
          ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y - 1))
          ..add(new Zei.Vector2(game.world.hoveredTile.x + 1, game.world.hoveredTile.y))
          ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y + 1));
        game.world.redrawTiles(tilesToRedraw);
      }
    }
    
    // DEBUG: raise terrain
    if (evt.keyCode == KeyCode.M) {
      if (game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height < 9) {
        game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height++;
        List tilesToRedraw = new List();
        tilesToRedraw
          ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y))
          ..add(new Zei.Vector2(game.world.hoveredTile.x - 1, game.world.hoveredTile.y))
          ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y - 1))
          ..add(new Zei.Vector2(game.world.hoveredTile.x + 1, game.world.hoveredTile.y))
          ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y + 1));
        game.world.redrawTiles(tilesToRedraw);
      }
    }
    
    // DEBUG: clear terrain
    if (evt.keyCode == KeyCode.B) {
      game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height = -1;
      List tilesToRedraw = new List();
      tilesToRedraw
        ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y))
        ..add(new Zei.Vector2(game.world.hoveredTile.x - 1, game.world.hoveredTile.y))
        ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y - 1))
        ..add(new Zei.Vector2(game.world.hoveredTile.x + 1, game.world.hoveredTile.y))
        ..add(new Zei.Vector2(game.world.hoveredTile.x, game.world.hoveredTile.y + 1));
      game.world.redrawTiles(tilesToRedraw);
    }
    
    // DEBUG: add creeper
    if (evt.keyCode == KeyCode.X) {
      if (game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height > -1) {
        game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep++;
        World.creeperDirty = true;
      }
    }
    
    // DEBUG: remove creeper
    if (evt.keyCode == KeyCode.C) {
      if (game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep > 0) {
        game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep--;
        if (game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep < 0)
          game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep = 0;
        World.creeperDirty = true;
      }
    }
    
    // select height for terraforming
    if (game.mode == "TERRAFORM") {
    
      // remove terraform
      if (evt.keyCode == KeyCode.DELETE) {
        game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].unflagTerraform();
      }
    
      // set terraform value
      if (evt.keyCode >= 48 && evt.keyCode <= 57) {
        game.world.terraformingHeight = evt.keyCode - 49;
        if (game.world.terraformingHeight == -1) {
          game.world.terraformingHeight = 9;
        }
        game.world.tfNumber.frame = game.world.terraformingHeight;
      }
    
    }
  }

}