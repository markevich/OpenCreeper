part of zei;

class Audio {
  static Map<String, List> sounds = new Map();
  static int channels = 0;

  static void clear() {
    sounds.clear();
    channels = 0;
  }

  /**
   * Sets the number of available channels with a given [number].
   */
  static void setChannels(int number) {
    channels = number;
  }

  /**
   * Loads a list of [filenames].
   */
  static void load(List filenames) {
    if (channels != 0) {
      filenames.forEach((filename) {
        var name = filename.split(".")[0];
        sounds[name] = new List();
        for (int j = 0; j < channels; j++) {
          sounds[name].add(new AudioElement("sounds/" + filename));
        }
      });
    }
  }

  /**
   * Plays a sound with a given [name] and optionally [position],
   * [center] and [zoom] to control the volume.
   */
  static void play(String name, [Vector2 position]) { // position is in real coordinates
    num volume = 1;

    // given a position adjust sound volume based on it and the current zoom
    if (position != null && scroller.position != null && zoomer.zoom != null) {
      num distance = position.distanceTo(scroller.position * 16);
      volume = (zoomer.zoom / pow(distance / 200, 2)).clamp(0, 1);
    }

    for (int i = 0; i < channels; i++) {
      if (sounds[name][i].ended == true || sounds[name][i].currentTime == 0) {
        sounds[name][i].volume = volume;
        sounds[name][i].play();
        return;
      }
    }
  }
}