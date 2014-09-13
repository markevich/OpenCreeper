part of creeper;

class Packet extends GameObject {
  Vector speed = new Vector(0, 0);
  String type;
  bool remove = false;
  num speedMultiplier = 1;
  Building target, currentTarget;
  Sprite sprite;
  static num baseSpeed = 3;

  Packet(this.currentTarget, this.target, this.type) {
    sprite = new Sprite("buffer", Layer.PACKET, game.engine.images["packet_" + type], currentTarget.position, 16, 16);
    sprite.anchor = new Vector(0.5, 0.5);
    sprite.visible = false;
  }
     
  void update() {
    if (!game.paused) {
      if (remove) {
        game.engine.renderer["buffer"].removeDisplayObject(sprite);
        game.engine.removeGameObject(this);
      }
      else
        move();
    }
  }
  
  static void removeWithTarget(building) {
    for (var packet in game.engine.gameObjects) {
      if (packet is Packet) {
        if (packet.currentTarget == building || packet.target == building) {
          packet.remove = true;
        }
      }
    }
    for (int i = Building.queue.length - 1; i >= 0; i--) {
      if (Building.queue[i].currentTarget == building || Building.queue[i].target == building) {
        Building.queue.remove(Building.queue[i]);
      }
    }
  }

  void send() {
    game.engine.addGameObject(this);
    sprite.visible = true;
  }
  
  void move() {  
    sprite.position += game.engine.calculateVelocity(sprite.position, currentTarget.position, Packet.baseSpeed * game.speed * speedMultiplier);

    if (sprite.position == currentTarget.position) {
      
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
              target.sprite.alpha = 1.0;
              Connection.activate(target);
              if (target.cannon != null)
                target.cannon.alpha = 1.0;
              if (target.type == "collector") {
                target.updateCollection("add");
                game.engine.playSound("energy", target.position, game.scroll, game.zoom);
              }
              if (target.type == "storage")
                Building.base.maxEnergy += 20;
              if (target.type == "speed")
                Packet.baseSpeed *= 1.01;
              if (target.type == "bomber") {
                target.ship = Ship.add(target.position, "bombership", "Bomber", target);           
              }
            }
          }
        } else if (type == "energy") {
          target.energy += 4;
          target.energyRequests -= 4;
          if (target.energy > target.maxEnergy)
            target.energy = target.maxEnergy;
        } else if (type == "collection") {
          Building.base.energy += 1;
          if (Building.base.energy > Building.base.maxEnergy)
            Building.base.energy = Building.base.maxEnergy;
          game.updateEnergyElement();
        }
      } else {
        findRoute();
      }
    }
  }

  /**
   * Find a route for this packet
   */
  bool findRoute() {
    //Route route = Route.find(currentTarget, target);
    var next = Route.find(currentTarget, target);

    // if a route is left set the second element as the next node for the packet
    if (next != null) {

      // adjust speed if packet is travelling between relays
      if (next.gameObject.type == "relay") {
        speedMultiplier = 2;
      } else {
        speedMultiplier = 1;
      }

      // reduce speed for collection
      if (type == "collection")
        speedMultiplier /= 4;

      currentTarget = next.gameObject;
      return true;
    } else {

      currentTarget = null;

      // reduce target requests
      if (type == "energy") {
        target.energyRequests -= 4;
        if (target.energyRequests < 0)
          target.energyRequests = 0;
      } else if (type == "health") {
        target.healthRequests--;
        if (target.healthRequests < 0)
          target.healthRequests = 0;
      }
      remove = true;
      return false;
    }
  }
}