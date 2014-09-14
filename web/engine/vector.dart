part of zengine;

class Vector {
  num x, y;

  Vector(this.x, this.y);
  Vector.empty() : this(0, 0);

  Vector operator +(Vector other) => new Vector(x + other.x, y + other.y);
  Vector operator -(Vector other) => new Vector(x - other.x, y - other.y);
  Vector operator *(num other) => new Vector(x * other, y * other);
  Vector operator /(num other) => new Vector(x / other, y / other);
  bool operator ==(Vector other) => (x == other.x && y == other.y);

  String toString() {
    return "$x/$y";
  }

  num distanceTo(Vector other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }
  
  num angleTo(Vector other) {
    return atan2(other.y - y, other.x - x) * 180 / PI;
  }
}

class Vector3 {
  num x, y, z;

  Vector3(this.x, this.y, this.z);

  Vector3 operator +(Vector3 other) => new Vector3(x + other.x, y + other.y, z + other.z);
}