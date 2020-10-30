// Include code from:
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

import processing.sound.*;

ArrayList<Firework> fireworks;

final PVector gravity = new PVector(0, 0.2);
final PVector resistance = new PVector(0.02, 0.0);

final int background = 1;
final int seedWeight = 16;
final int explodeeWeight = 8;

OPC opc;
final String fcServerHost = "127.0.0.1";
final int fcServerPort = 7890;

final int boxesAcross = 2;
final int boxesDown = 2;
final int ledsAcross = 8;
final int ledsDown = 8;
// initialized in setup()
float spacing;

int x0;
int y0;

int exitTimer = 0; // Run forever unless set by command line
String filename = "data/default_rockets.csv";

int deckXstart;
int deckXend;
int deckYlevel;

float velocityYMin;
float velocityYMax;

ArrayList<LaunchControl> cntrlData;
int cntrlDataIndex = 0;
int startMillisecond = -1;
int nextMillisecond = 0;

// SoundFile array to hold samples
SoundFile[] sample;

void setup() {

  apply_cmdline_args();

  size(640, 360, P2D);
  colorMode(HSB, 359, 255, 255);
  background(background);

  fireworks = new ArrayList<Firework>();

  cntrlData = loadData(filename);

  //  for (LaunchControl cntrl: cntrlData) {
  //    cntrl.dump();
  //  }

  // saveData(cntrlData, filename);

  // Connect to an instance of fcserver
  opc = new OPC(this, fcServerHost, fcServerPort);
  opc.showLocations(false);

  spacing = (float)min(height / (boxesDown * ledsDown + 1), width / (boxesAcross * ledsAcross + 1));
  x0 = (int)(width - spacing * (boxesAcross * ledsAcross - 1)) / 2;
  y0 = (int)(height - spacing * (boxesDown * ledsDown - 1)) / 2;

  final int boxCentre = (int)((ledsAcross - 1) / 2.0 * spacing); // probably using the centre in the ledGrid8x8 method
  int ledCount = 0;
  for (int y = 0; y < boxesDown; y++) {
    for (int x = 0; x < boxesAcross; x++) {
      opc.ledGrid8x8(ledCount, x0 + spacing * x * ledsAcross + boxCentre, y0 + spacing * y * ledsDown + boxCentre, spacing, 0, false, false);
      ledCount += ledsAcross * ledsDown;
    }
  }

  deckXstart = x0;
  deckXend = x0 + (int)(spacing * (boxesAcross * ledsAcross - 1));
  deckYlevel = y0 + (int)(spacing * (boxesDown * ledsDown - 1));

  velocityYMax = sqrt(2*gravity.y*(spacing * (boxesDown * ledsDown - 1)));
  velocityYMin = 0.5 * velocityYMax;

    // Create a new firework sample array and populate it with some samples
  sample = new SoundFile[5];
  sample[0] = new SoundFile(this, "bang1.wav");
  sample[1] = new SoundFile(this, "bang_fizz1.wav");
  sample[2] = new SoundFile(this, "bang_fizz2.wav");
  sample[3] = new SoundFile(this, "bang_bang1.wav");
  sample[4] = new SoundFile(this, "fizz_bang1.wav");
}

void draw() {

  int m = millis();
  if (startMillisecond == -1) {
    startMillisecond = m;
  }

  if ((m - startMillisecond) > nextMillisecond) {
    int sequenceDuration = 0;
    do {

      LaunchControl cntrl = cntrlData.get(cntrlDataIndex++);
      if (sequenceDuration == 0) {
        sequenceDuration = cntrl.durationMilliS;
      }

      int count = cntrl.numLauched;
      if (count <= 0) {
        count = (int)(random(1, 9));
      }

      for (int x = 0; x < count; x++) {
        fireworks.add(new Firework(cntrl));
      }

      if (cntrlDataIndex < cntrlData.size()) {
        if (cntrlData.get(cntrlDataIndex).durationMilliS > 0) {
          break;
        }
      }
    } while (cntrlDataIndex < cntrlData.size());

    if (cntrlDataIndex == cntrlData.size()) { // return to the start causing the whole sequence to loop
      cntrlDataIndex = 0;
    }

    nextMillisecond += sequenceDuration;
  }

  fill(background, 50);
  noStroke();
  rect(0,0,width,height);
  //background(255, 20);

  for (int i = fireworks.size()-1; i >= 0; i--) {
    Firework f = fireworks.get(i);
    f.run();
    int randomSampleIndex = int(random(sample.length));
    if (f.done()) {
      fireworks.remove(i);
      sample[randomSampleIndex].stop();
    }
    if (f.exploded()) {
      //println("bang!");
      // Play a random filework sample
      sample[randomSampleIndex].play();
    }
  }

  fill(128);
  text(String.format("%5.1f fps", frameRate), 5, 15);

  check_exit();
}

void apply_cmdline_args() {

  if (args == null) {
    return;
  }

  for (String exp: args) {
    String[] comp = exp.split("=");
    switch (comp[0]) {
    case "file":
      filename = "data/" + comp[1];
      println("use filename " + filename);
      break;
    case "exit":
      exitTimer = parseInt(comp[1], 10);
      println("exit after " + exitTimer + "s");
      break;
    }
  }
}

void check_exit() {

  if (exitTimer == 0) { // skip if not run from cmd line
    return;
  }

  int m = millis();
  if (m / 1000 >= exitTimer) {
    println(String.format("average %.1f fps", (float)frameCount / exitTimer));
    exit();
  }
}
