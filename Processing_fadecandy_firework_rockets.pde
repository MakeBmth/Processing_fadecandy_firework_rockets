// Include code from:
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

ArrayList<Firework> fireworks;

PVector gravity = new PVector(0, 0.2);

final int background = 1;
final int numExplodees = 50;
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

int deckXstart;
int deckXend;
int deckYlevel;

float fireworkVelXMin;
float fireworkVelXMax;

void setup() {

  apply_cmdline_args();

  size(640, 360, P2D);
  colorMode(HSB);
  background(background);

  fireworks = new ArrayList<Firework>();

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

  fireworkVelXMax = sqrt(2*gravity.y*(spacing * (boxesDown * ledsDown - 1)));
  fireworkVelXMin = 0.5 * fireworkVelXMax;
}

void draw() {
  if (random(1) < 0.08) {
    fireworks.add(new Firework(seedWeight, explodeeWeight, numExplodees));
  }
  fill(background, 50);
  noStroke();
  rect(0,0,width,height);
  //background(255, 20);

  for (int i = fireworks.size()-1; i >= 0; i--) {
    Firework f = fireworks.get(i);
    f.run();
    if (f.done()) {
      fireworks.remove(i);
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
