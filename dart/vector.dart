part of creeper;

class Vector {
  num x, y;

  Vector(this.x, this.y);
  Vector.empty() : this(0, 0);

  Vector operator +(Vector other) => new Vector(x + other.x, y + other.y);
  Vector operator -(Vector other) => new Vector(x - other.x, y - other.y);
  bool operator ==(Vector other) => (x == other.x && y == other.y);

  String toString() {
    return "$x/$y";
  }

  num distanceTo(Vector other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }

// converts tile coordinates to canvas coordinates
  Vector tiled2screen() {
    return new Vector(
        engine.halfWidth + (x - game.scroll.x) * game.tileSize * game.zoom,
        engine.halfHeight + (y - game.scroll.y) * game.tileSize * game.zoom);
  }

// converts full coordinates to canvas coordinates
  Vector real2screen() {
    return new Vector(
        engine.halfWidth + (x - game.scroll.x * game.tileSize) * game.zoom,
        engine.halfHeight + (y - game.scroll.y * game.tileSize) * game.zoom);
  }

// converts full coordinates to tile coordinates
  Vector real2tiled() {
    return new Vector(
        x ~/ game.tileSize,
        y ~/ game.tileSize);
  }
}

class Vector3 {
  num x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) => new Vector3(x + other.x, y + other.y, z + other.z);
}