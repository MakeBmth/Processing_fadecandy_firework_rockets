
# Processing fadecandy firework rockets

## New Features!

  - Support playing sound files for the rocket explosions
  - 2D array of firework sequence data in sketch

## Firework launch control sequence data

* [duration] fireworks sequence (milliseconds), 0 = add to previous
* [deck position min] 0 - 100% (left to right)
* [deck position max] 0 - 100%, different values gives random min to max
* [launch angle] 0 - 180 degrees, -1 = random 60 to 120
* [launch velocity min] 0 - 100%
* [launch velocity max] 0 - 100%, different values gives random min to max
* [number to launch] N, -1, 0 = random 1 to 8
* [hue] colour wheel 0 - 360, -1 = random 0 to 359
* [number explodees] 50 - 500


## Command Line


rem Windows

    path %PATH%;D:\Apps\processing-3.5.4
    processing-java.exe --sketch=%cd%\Processing_fadecandy_firework_rockets --run file=_rockets.csv exit=60

\# raspi (vnc)

    processing-java --sketch=./Processing_fadecandy_firework_rockets --run file=_rockets.csv exit=60

\# raspi (ssh i.e. headless)

    xvfb-run processing-java --sketch=./Processing_fadecandy_firework_rockets --run file=_rockets.csv exit=60


## Thanks to

Daniel Shiffman, CC_027_FireWorks_2D: http://codingtra.in, http://patreon.com/codingtrain
