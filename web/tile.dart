part of creeper;

class Tile {
  static final int size = 16;
  num creep, newcreep;
  Building collector;
  int height, index, terraformTarget, terraformProgress;
  Zei.Sprite terraformNumber;

  Tile() {
    index = -1; // TODO: unused, maybe remove
    creep = 0;
    newcreep = 0;
    collector = null;
    terraformTarget = -1;
    terraformProgress = 0;
    terraformNumber = null;
  }
  
  void flagTerraform(Zei.Vector2 position) {   
    if (height != game.terraformingHeight) {
      terraformTarget = game.terraformingHeight;
      terraformProgress = 0;
      
      if (terraformNumber == null) {
        terraformNumber = new Zei.Sprite("buffer", "terraform", Zei.images["numbers"], position, 16, 16);
        terraformNumber.animated = true;
        terraformNumber.frame = terraformTarget;
      } else {
        terraformNumber.frame = terraformTarget;
      }
    }
  }
  
  void unflagTerraform() {    
    terraformProgress = 0;
    terraformTarget = -1;
    if (terraformNumber != null) {
      Zei.renderer["buffer"].removeDisplayObject(terraformNumber); // alternatively it could just be set to 'visible = false'
      terraformNumber = null;
    }
  }
  
  static Zei.Vector2 position(Zei.Vector2 vector) {
    return new Zei.Vector2(
           vector.x ~/ size,
           vector.y ~/ size);
  }
}