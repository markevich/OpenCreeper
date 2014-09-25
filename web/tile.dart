part of creeper;

class Tile {
  static final int size = 16;
  num creep, newcreep;
  Building collector;
  int height, index, terraformTarget, terraformProgress;
  Zei.Sprite terraformNumber;
  Zei.Rect rangeBox;
  Zei.Vector2 pos;

  Tile(x, y) {
    index = -1; // TODO: unused, maybe remove
    creep = 0;
    newcreep = 0;
    collector = null;
    terraformTarget = -1;
    terraformProgress = 0;
    terraformNumber = null;
    pos = new Zei.Vector2(x * size, y * size);
    
    rangeBox = Zei.Rect.create("buffer", "terraform", pos, new Zei.Vector2(size, size), 0, new Zei.Color(255, 255, 255, 0.35), null, visible: false);
  }
    
  void flagTerraform(Zei.Vector2 position) {   
    if (height != game.terraformingHeight) {
      terraformTarget = game.terraformingHeight;
      terraformProgress = 0;
      
      if (terraformNumber == null) {
        terraformNumber = Zei.Sprite.create("buffer", "terraform", Zei.images["numbers"], position, 16, 16);
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