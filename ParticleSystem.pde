// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for:

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles

class Firework {

  ArrayList<Particle> particles;    // An arraylist for all the particles
  Particle firework;
  int hue;
  int numExplodees;
  Boolean alreadyExploded = false;
  int soundTrack = -1;

  Firework() {
    particles = new ArrayList<Particle>();   // Initialize the arraylist
  }

  Firework(LaunchControl cntrl) {
    this();

    int deckMin = min(cntrl.deckPosMin, cntrl.deckPosMax);
    int deckMax = max(cntrl.deckPosMax, cntrl.deckPosMin);
    int deckPos = (deckMin == deckMax) ? deckMin : deckMin + (int)random(deckMax - deckMin + 1);
    int launchX = deckXstart + deckPos * (deckXend - deckXstart) / 100;
    int launchY = deckYlevel + seedWeight;
    int angle = cntrl.launchAngle;
    if (angle < 0 || angle > 180) {
      angle = (int)random(60, 120 + 1);
    }
    int velMin = min(cntrl.launchVelMin, cntrl.launchVelMax);
    int velMax = max(cntrl.launchVelMax, cntrl.launchVelMin);
    int velPercent = (velMin == velMax) ? velMin : velMin + (int)random(velMax - velMin + 1);
    float velocity = -(velocityYMin + velPercent * (velocityYMax - velocityYMin) / 100);
    hue = (cntrl.hue >= 0) ? cntrl.hue : (int)random(360);
    this.numExplodees = cntrl.numExplodees;

    firework = new Particle(launchX, launchY, angle, velocity, hue);
    this.firework.setWeight(seedWeight);
  }

  boolean done() {
    if (firework == null && particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

  boolean exploded() {
    if (firework == null && !alreadyExploded) {
      alreadyExploded = true;
      return true;
    } else {
      return false;
    }
  }

  void run() {
    if (firework != null) {
      fill(hue,255,255);
      firework.applyForce(gravity);
      firework.applyWind(resistance);
      firework.update();
      firework.display();

      if (firework.explode()) {
        for (int i = 0; i < numExplodees; i++) {
          particles.add(new Particle(firework.location, hue));    // Add "num" amount of particles to the arraylist
        }
        firework = null;
      }
    }

    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.applyForce(gravity);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }


  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

  void setSoundTrack(int i) {
    soundTrack = i;
  }

  int getSoundTrack() {
    return soundTrack;
  }
}
