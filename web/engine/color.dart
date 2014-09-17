part of zei;

class Color {
  int r, g, b;
  double a;
  
  Color(this.r, this.g, this.b, [this.a = 1.0]) {}
  Color.white() : r = 255, g = 255, b = 255, a = 1.0;
  Color.black() : r = 0, g = 0, b = 0, a = 1.0;
  Color.red() : r = 255, g = 0, b = 0, a = 1.0;
  Color.green() : r = 0, g = 255, b = 0, a = 1.0;
  Color.blue() : r = 0, g = 0, b = 255, a = 1.0;
  
  String get rgba  => 'rgba($r, $g, $b, $a)';
}