part of creeper;

class Packet {
  Vector speed = new Vector(0, 0);
  String type;
  bool remove = false;
  num speedMultiplier = 1;
  Building target, currentTarget;
  Sprite sprite;
  static num baseSpeed = 3;

  Packet(position, imageID, this.type) {
    sprite = new Sprite(2, engine.images[imageID], position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);

    if (type == "collection")
      sprite.scale = new Vector(1.5, 1.5);

    engine.canvas["buffer"].addSprite(sprite);
  }

  void move() {
    calculateVector();
    
    sprite.position += speed;

    Vector centerTarget = currentTarget.getCenter();
    if (sprite.position.x > centerTarget.x - 1 && sprite.position.x < centerTarget.x + 1 && sprite.position.y > centerTarget.y - 1 && sprite.position.y < centerTarget.y + 1) {
      sprite.position = centerTarget;

      // if the final node was reached deliver and remove
      if (currentTarget == target) {
        remove = true;
        // deliver package
        if (type == "health") {
          target.health += 1;
          target.healthRequests--;
          if (target.health >= target.maxHealth) {
            target.health = target.maxHealth;
            if (!target.built) {
              target.built = true;
              if (target.imageID == "collector") {
                game.updateCollection(target, "add");
                engine.playSound("energy", target.position);
              }
              if (target.imageID == "storage")
                game.maxEnergy += 20;
              if (target.imageID == "speed")
                Packet.baseSpeed *= 1.01;
              if (target.imageID == "bomber") {
                Ship ship = new Ship(new Vector(target.position.x * game.tileSize, target.position.y * game.tileSize), "bombership", "Bomber", target);
                target.ship = ship;
                game.ships.add(ship);
              }
            }
          }
        } else if (type == "energy") {
          target.energy += 4;
          target.energyRequests -= 4;
          if (target.energy > target.maxEnergy)
            target.energy = target.maxEnergy;
        } else if (type == "collection") {
          game.currentEnergy += 1;
          if (game.currentEnergy > game.maxEnergy)
            game.currentEnergy = game.maxEnergy;
          game.updateEnergyElement();
        }
      } else {
        game.findRoute(this);
      }
    }
  }

  void calculateVector() {
    Vector targetPosition = currentTarget.getCenter();
    Vector delta = new Vector(targetPosition.x - sprite.position.x, targetPosition.y - sprite.position.y);
    num distance = sprite.position.distanceTo(targetPosition);

    speed.x = (delta.x / distance) * Packet.baseSpeed * game.speed * speedMultiplier;
    speed.y = (delta.y / distance) * Packet.baseSpeed * game.speed * speedMultiplier;

    if (speed.x.abs() > delta.x.abs())
      speed.x = delta.x;
    if (speed.y.abs() > delta.y.abs())
      speed.y = delta.y;
  }
}