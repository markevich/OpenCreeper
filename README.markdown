# Open Creeper

![](screenshot/screenshot.png)

## How to play

Open Creeper can be played right here: http://alexanderzeillinger.github.com/OpenCreeper/

## About

Open Creeper is an open source game ~~heavily inspired~~ ripped of by Creeper World 3 by Knuckle Cracker.
Don't cry out loud, though. I only implemented the basic gameplay elements and it is by far not a professional
work. I have talked with the creator of CW3 and he is fine with this project. CW3 is a lot better
and more fun to play so please buy it and support this great game.

## Motivation

I am a big fan of Creeper World 1 by Knuckle Cracker and when game 3 was announced I was
as excited as everyone else and couldn't wait to play it. I knew it would take a lot of
time until it gets released so I thought to myself why not recreate the game myself and kill
some time until I can play the original.
When I like a game I'm often interested in how things internally work, in this case it was
mostly the pathfinding algorithm and also the terrain texturing and auto-tiling, combined zooming
and scrolling was also fun to figure out.

So I went ahead writing this in JavaScript using the HTML5 canvas and also improving my coding
skills along the way. Later on I switched to Dart where the game not only runs a lot faster but also
developing is a lot easier and more productive. You can play it in Dart natively with
Dartium (http://www.dartlang.org/tools/dartium/) or play the dart2js version, which is the Dart
version compiled to JavaScript.

## Differences

Apart from the graphics which are obviously crappy, most buildings behave the same as in CW3
as good as I could observe from images and videos. Of course all technical things like speeds,
energy income are just guesses and probably a lot off.

- Base: there's only one
- Cannon: rotates to random closest target, shoots projectile (no difference)
- Collector: collector area is simplified compared to CW3, also energy is sent back to base as packets
- Reactor: produces some energy
- Storage: works like in CW1, in CW3 it works different
- Shield: simplified, does not push back creeper, but removes it instantly
- Relay: longer distance, faster speeds (no difference)
- Mortar: fires shells (no difference)
- Beam: shoots spores (no difference)
- Bomber: very simplified, no attack vectors, no falling bombs but instant damage
- Terp: targets highest marked terraforming tile (no difference)
- Analyzer: this is unique to OpenCreeper and can't be found in CW3

Everything else in CW3, and that is a lot more, has not been implemented.

About the Analyzer:
Unlike CW3 where enemy structures are destroyed with a Nullifier I decided to use a different
idea which is the Analyzer. In CW3 a Nullifier needs a lot of energy to destroy its target and
then gets destroyed itself and no more resources (energy) is needed. This allows the player
to build up more and more momentum. In OpenCreeper I want it to be more like a constant struggle
so every Emitter needs to be bound by an Analyzer to win the game. Only when all Emitters are
each bound by an Analyzer the game ends. Every Analyzer needs a lot of energy to work so the more
you have (and NEED to have) the harder energy management gets, which makes everything else
harder as the game progresses.

## Development

I have stopped adding features and gameplay elements to the game since CW3 has been released but I'm
still doing some changes in the general code layout, trying different things, refactoring and optimizing.
There is a lot that could be done, though, whether it be more gameplay elements, a decent UI, details like ballistic
trajectories of projectiles or even using WebGL as rendering target. At the very least a lot of bugfixes.

## Browser Compatibility and Performance

Please use Dartium for the best experience, or the latest version of either Chrome, Firefox or Internet Explorer
which I hope should all work fine. I only tested this with Chrome.

## Legal stuff

All images used are self made with Adobe Fireworks, see the "assets" folder.
Some stuff is not by myself and credited below:

Terrain generator credits:
https://github.com/baxter/csterrain

Smoke image credits:
http://gushh.net/blog/free-game-sprites-smoke-1/

Explosion image credits:
http://april-young.com/home/spritesheet-for-explosion/

Cursor image credits:
http://ozzy8031.deviantart.com/art/Polar-Cursor-Set-for-Windows-123943236

Ship image credits:
http://opengameart.org/content/modular-ships#

Shot sound:
http://www.freesound.org/people/nthompson/sounds/47252/

Explosion sound:
http://www.freesound.org/people/smcameron/sounds/51464/

Click sound:
http://www.freesound.org/people/TicTacShutUp/sounds/406/

Music:
http://www.vorbis.com/music/ - Epoq - Lepidoptera

Background image:
http://webtreatsetc.deviantart.com/art/Classic-Nebula-Space-Patterns-141741066

Failure sound:
http://freesound.org/people/fins/sounds/173958/

Energy sound:
http://freesound.org/people/fins/sounds/146727/

Laser sound:
http://freesound.org/people/fins/sounds/146725/