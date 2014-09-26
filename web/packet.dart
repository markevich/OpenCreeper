part of creeper;

class Packet extends Zei.GameObject {
  String type;
  bool flagRemove = false;
  num velocityMultiplier = 1;
  Building target, currentTarget;
  Zei.Sprite sprite;
  static num baseSpeed = 3;

  Packet(this.currentTarget, this.target, this.type) {
    sprite = Zei.Sprite.create("main", "packet", Zei.images["packet_" + type], currentTarget.position, 16, 16, visible: false, anchor: new Zei.Vector2(0.5, 0.5));
  }
     
  void update() {
    if (!game.paused) {
      if (flagRemove) {
        Zei.renderer["main"].removeDisplayObject(sprite);
        Zei.GameObject.remove(this);
      }
      else
        move();
    }
  }
  
  static void removeWithTarget(building) {
    for (var packet in Zei.GameObject.gameObjects) {
      if (packet is Packet) {
        if (packet.currentTarget == building || packet.target == building) {
          packet.flagRemove = true;
        }
      }
    }
    for (int i = Building.base.queue.length - 1; i >= 0; i--) {
      if (Building.base.queue[i].currentTarget == building || Building.base.queue[i].target == building) {
        Building.base.queue.remove(Building.base.queue[i]);
      }
    }
  }

  void send() {
    Zei.GameObject.add(this);
    sprite.visible = true;
  }
  
  void move() {  
    sprite.position += ((currentTarget.position - sprite.position).normalize() * Packet.baseSpeed * game.speed * velocityMultiplier).clamp(currentTarget.position - sprite.position);

    if (sprite.position == currentTarget.position) {
      
      // if the final node was reached deliver and remove
      if (currentTarget == target) {
        flagRemove = true;
        // deliver package
        if (type == "health") {
          target.health += 1;
          target.healthBar.visible = true;
          target.healthBar.size.x = ((target.size * Tile.size - 4) / target.maxHealth) * target.health;
          target.healthRequests--;
          if (target.health >= target.maxHealth) {
            target.health = target.maxHealth;
            target.healthBar.visible = false;
            if (!target.built) {
              target.built = true;
              target.sprite.alpha = 1.0;
              Connection.activate(target);
              if (target.cannon != null)
                target.cannon.alpha = 1.0;
              if (target.type == "collector") {
                target.updateCollection("add");
                Zei.Audio.play("energy", target.position, game.scroller.scroll, game.zoom);
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
          target.energy = Zei.clamp(target.energy, 0, target.maxEnergy);
        } else if (type == "collection") {
          Building.base.energy += 1;
          Building.base.energy = Zei.clamp(Building.base.energy, 0, Building.base.maxEnergy);
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
    var next = Zei.Route.find(currentTarget, target);

    // if a route is left set the second element as the next node for the packet
    if (next != null) {

      // adjust speed if packet is travelling between relays
      if (next.gameObject.type == "relay") {
        velocityMultiplier = 2;
      } else {
        velocityMultiplier = 1;
      }

      // reduce speed for collection
      if (type == "collection")
        velocityMultiplier /= 4;

      currentTarget = next.gameObject;
      return true;
    } else {

      currentTarget = null;

      // reduce target requests
      if (type == "energy") {
        target.energyRequests -= 4;
        target.energyRequests = Zei.clamp(target.energyRequests, 0, 100);
      } else if (type == "health") {
        target.healthRequests--;
        target.healthRequests = Zei.clamp(target.healthRequests, 0, 100);
      }
      flagRemove = true;
      return false;
    }
  }
}