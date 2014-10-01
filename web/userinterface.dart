part of creeper;

class UserInterface extends Zei.GameObject {
  Zei.Renderer renderer;
  Zei.Rect tileHeight, creeperHeight;
  Zei.Text totalCreeper;
  Stopwatch stopwatch = new Stopwatch();
  //bool hovered = false;
  Zei.Vector2 mousePosition = new Zei.Vector2.empty();

  UserInterface() {
    renderer = Zei.Renderer.create("gui", 780, 110, container: "#gui");
    renderer.setLayers(["default"]);
    renderer.updatePosition(new Zei.Vector2(390, 55));

    setupSymbols();
    tileHeight = Zei.Rect.create("gui", "default", new Zei.Vector2(555, 110), new Zei.Vector2(25, 0), 0, new Zei.Color(205, 133, 63), null);
    creeperHeight = Zei.Rect.create("gui", "default", new Zei.Vector2(555, 110), new Zei.Vector2(25, 0), 0, new Zei.Color(100, 150, 255), null);
    totalCreeper = Zei.Text.create("gui", "default", new Zei.Vector2(605, 10), 9, "px", "Verdana" , new Zei.Color.white(), null, "0.00");

    for (var i = 0; i < 10; i++) {
      Zei.Text.create("gui", "default", new Zei.Vector2(550, 110 - i * 10), 9, "px", "Verdana" , new Zei.Color.white(), null, (i + 1).toString(), align: "right");
      Zei.Line.create("gui", "default", new Zei.Vector2(555, 110 - i * 10), new Zei.Vector2(580, 110 - i * 10), 1, new Zei.Color.white());
    }

    var oneSecond = new Duration(seconds: 1);
    new Timer.periodic(oneSecond, updateStopwatch);
    querySelector('#time').innerHtml = 'Time: 00:00';

    querySelector("#seed").innerHtml = "Seed: ${game.seed}";
    querySelector('#win').style.display = 'none';

    updateElement("energy");
    updateElement("speed");
    stopwatch.reset();
    stopwatch.start();

    querySelector('#terraform').onClick.listen((event) => game.world.toggleTerraform());
    querySelector('#continue').onClick.listen((event) => game.resume());
    querySelector('#restart').onClick.listen((event) => game.restart());
    querySelector('#restart2').onClick.listen((event) => game.restart());
    querySelector('#disable').onClick.listen((event) => Building.disable());
    querySelector('#enable').onClick.listen((event) => Building.enable());
  }

  void setupSymbols() {
    UISymbol.add(new Zei.Vector2(0, 0), new Building.template("cannon"), KeyCode.Q);
    UISymbol.add(new Zei.Vector2(81, 0), new Building.template("collector"), KeyCode.W);
    UISymbol.add(new Zei.Vector2(2 * 81, 0), new Building.template("reactor"), KeyCode.E);
    UISymbol.add(new Zei.Vector2(3 * 81, 0), new Building.template("storage"), KeyCode.R);
    UISymbol.add(new Zei.Vector2(4 * 81, 0), new Building.template("shield"), KeyCode.T);
    UISymbol.add(new Zei.Vector2(5 * 81, 0), new Building.template("analyzer"), KeyCode.Z);
    UISymbol.add(new Zei.Vector2(0, 56), new Building.template("relay"), KeyCode.A);
    UISymbol.add(new Zei.Vector2(81, 56), new Building.template("mortar"), KeyCode.S);
    UISymbol.add(new Zei.Vector2(2 * 81, 56), new Building.template("beam"), KeyCode.D);
    UISymbol.add(new Zei.Vector2(3 * 81, 56), new Building.template("bomber"), KeyCode.F);
    UISymbol.add(new Zei.Vector2(4 * 81, 56), new Building.template("terp"), KeyCode.G);
  }

  void update() {
    if (game.world.contains(game.world.hoveredTile)) {
      tileHeight.position.y = 110 - game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height * 10;
      tileHeight.size.y = game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height * 10;

      creeperHeight.position.y = 110 - game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].height * 10 - game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep * 10;
      creeperHeight.size.y = game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep * 10;

      totalCreeper.text = game.world.tiles[game.world.hoveredTile.x][game.world.hoveredTile.y].creep.toStringAsFixed(2);
    }
  }

  void updateElement(String elementName) {
    var text;

    switch (elementName) {
      case 'energy':
        if (Building.base != null)
          text = "Energy: ${Building.base.energy.toString()}/${Building.base.maxEnergy.toString()}";
        break;
      case 'speed':
        text = "Speed: ${game.speed.toString()}x";
        break;
      default:
        text = "";
    }

    querySelector("#${elementName}").innerHtml = text;
  }

  void updateStopwatch(Timer _) {
    var s = stopwatch.elapsedMilliseconds~/1000;
    var m = 0;

    if (s >= 60) { m = s ~/ 60; s = s % 60; }

    String minute = (m <= 9) ? '0$m' : '$m';
    String second = (s <= 9) ? '0$s' : '$s';
    querySelector('#time').innerHtml = 'Time: $minute:$second';
  }

  void onMouseEvent(evt) {
    if (evt.type == "mousemove") {
      if (renderer.isHovered)
        UISymbol.checkHovered(renderer);
      else
        UISymbol.dehover();
    }
    else if (evt.type == "click") {
      if (renderer.isHovered) {
        Building.deselect();
        Ship.deselect();
        UISymbol.mouseSelect();
        Zei.Audio.play("click");
      }
    }
  }

  void onKeyEvent(evt, String type) {
    UISymbol.keySelect(evt);
  }
}