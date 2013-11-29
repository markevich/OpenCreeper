part of creeper;

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