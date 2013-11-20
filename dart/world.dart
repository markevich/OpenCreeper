part of creeper;

class World {
  List tiles;
  Vector size;
  
  World(int seed) {
    size = new Vector(engine.randomInt(64, 127, seed), engine.randomInt(64, 127, seed));
  }
  
  /**
   * Checks if a given [position] in world coordinates is contained within the world
   */
  bool contains(Vector position) {
    return (position.x > -1 && position.x < size.x && position.y > -1 && position.y < size.y);
  }
  
  Tile getTile(Vector position) {
    return tiles[position.x ~/ 16][position.y ~/ 16];
  }  
}

class Tile {
  num creep, newcreep;
  Building collector;
  int height, index, terraformTarget, terraformProgress;
  Sprite terraformNumber;

  Tile() {
    index = -1; // TODO: unused, maybe remove
    creep = 0;
    newcreep = 0;
    collector = null;
    terraformTarget = -1;
    terraformProgress = 0;
    terraformNumber = null;
  }
  
  void flagTerraform(Vector position) {   
    if (height != game.terraformingHeight) {
      terraformTarget = game.terraformingHeight;
      terraformProgress = 0;
      
      if (terraformNumber == null) {
        terraformNumber = new Sprite(Layer.TERRAFORM, engine.images["numbers"], position, 16, 16);
        terraformNumber.animated = true;
        terraformNumber.frame = terraformTarget;
        engine.renderer["buffer"].addDisplayObject(terraformNumber);
      } else {
        terraformNumber.frame = terraformTarget;
      }
    }
  }
  
  void unflagTerraform() {    
    terraformProgress = 0;
    terraformTarget = -1;
    if (terraformNumber != null) {
      engine.renderer["buffer"].removeDisplayObject(terraformNumber); // alternatively it could just be set to 'visible = false'
      terraformNumber = null;
    }
  }
}