import processing.pdf.PGraphicsPDF;
import java.util.Arrays;

class Duration {
  float start;
  float end;
  String label = "";
  Duration(float start, float end) {
    this.start = start;
    this.end = end;
  }
  Duration(float start, float end, String label) {
    this.start = start;
    this.end = end;
    this.label = label;
  }
  boolean overlaps(Duration other) {
    return this.start < other.end && other.start < this.end;
  }
  Duration add(float addend) {
    return new Duration(start + addend, end + addend);
  }
}
class Layer {
  Duration[] durs;
  float[] cuts;
  Duration[] revs;
  String label = "";
  boolean defLabel = false;
  color hue = color(0);
  Layer(Duration[] durs, float[] cuts, Duration[] revs) {
    this.durs = durs;
    this.cuts = cuts;
    this.revs = revs;
  }
  Layer(Duration[] durs, float[] cuts, Duration[] revs, String label) {
    this.durs = durs;
    this.cuts = cuts;
    this.revs = revs;
    this.label = label;
  }
  Layer(Duration[] durs, float[] cuts, Duration[] revs, String label, color hue) {
    this.durs = durs;
    this.cuts = cuts;
    this.revs = revs;
    this.label = label;
    this.hue = hue;
  }
}

float ms(int min, float sec) { return min * 60 + sec; }

// ******************************************************
// MODIFY THE STUFF HERE
// ******************************************************

final String track = "00";
final String name = "Example CS6 track";
final float duration = ms(21,38);
final Duration[][] durations = {
  {new Duration(0, ms(1,32))},
  {new Duration(0, ms(1,45))},
  {new Duration(26, ms(3,48))},
  {new Duration(ms(1,31), ms(9,5)), new Duration(ms(12,13), ms(16,21))},
  {new Duration(ms(3,43), ms(6,8))},
  {new Duration(ms(3,43), ms(6,8)), new Duration(ms(12,13), ms(14,51))},
  {new Duration(ms(3,43), ms(8,0))},
  {new Duration(ms(6,8), ms(7,14)), new Duration(ms(7,26), ms(7,52)), new Duration(ms(8,15), ms(11,50))},
  {new Duration(ms(8,0), ms(11,54))},
  {new Duration(ms(11,50), ms(12,54))},
  {new Duration(ms(12,13), ms(12,54))},
  {new Duration(ms(14,15), ms(16,23))},
  {new Duration(ms(14,15), ms(16,23)), new Duration(ms(19,2), ms(21,12))},
  {new Duration(ms(15,58), ms(21,38))},
  {new Duration(ms(17,44), ms(20,22))},
  {new Duration(ms(19,2), ms(21,38))},
  {new Duration(ms(20,7), ms(21,12))},
};
final float[][] cutoffs = {
};
final Duration[][] reverses = {
};
final Layer[] layers = {
  new Layer(durations[0], new float[0], new Duration[0], "", color(128, 255, 85)),
  new Layer(durations[1], new float[0], new Duration[0], "", color(85, 85, 170)),
  new Layer(durations[2], new float[0], new Duration[0], "", color(70, 85, 128)),
  new Layer(durations[3], new float[0], new Duration[0], "", color(85)),
  new Layer(durations[4], new float[0], new Duration[0], "", color(85, 255, 255)),
  new Layer(durations[5], new float[0], new Duration[0], "", color(255, 255, 204)),
  new Layer(durations[6], new float[0], new Duration[0], "", color(204, 170, 70)),
  new Layer(durations[7], new float[0], new Duration[0], "", color(255, 70, 255)),
  new Layer(durations[8], new float[0], new Duration[0], "", color(70, 128, 153)),
  new Layer(durations[9], new float[0], new Duration[0], "", color(51)),
  new Layer(durations[10], new float[0], new Duration[0], "", color(51, 128, 255)),
  new Layer(durations[11], new float[0], new Duration[0], "", color(255, 70, 51)),
  new Layer(durations[12], new float[0], new Duration[0], "", color(170, 255, 85)),
  new Layer(durations[13], new float[0], new Duration[0], "", color(85, 51, 255)),
  new Layer(durations[14], new float[0], new Duration[0], "", color(51, 255, 170)),
  new Layer(durations[15], new float[0], new Duration[0], "", color(0, 0, 70)),
  new Layer(durations[16], new float[0], new Duration[0], "", color(70)),
};

// ******************************************************
// AND HERE, HAVE SOME CONTROL VARIABLES TOO
// ******************************************************

final boolean showBottomLeftText = false;
final color bg = color(0, 0, 10);
final boolean showBg = false; // Includes minute markers, which btw have their own individual toggle below
final boolean showMinuteMarkers = false;
final boolean whiteTextDefault = true;
final boolean layerTextDefault = true; // Layer 1, Lyr 1, L1, etc. instead of just 1
final float gap = 4; // Text padding

// ******************************************************
// DON'T MODIFY THE STUFF PAST HERE
// ******************************************************

int[] heights = new int[layers.length];

float time(float time) { return map(time, 0, duration, 0, width); }
float layerY(float level) { return map(level, 0, max(heights) + 1, 0, height); }

PFont bold;
PFont reg;
PGraphics pg;

void setup() {
  size(1500, 200, P2D);
  colorMode(HSB, 360, 100, 100, 100);
  pixelDensity(2);
  
  for (int i = 0; i < layers.length; i++) {
    if (layers[i].label == "") { layers[i].label = str(i + 1); layers[i].defLabel = true; }
    if (layers[i].hue == color(0)) { layers[i].hue = color(map(i, 0, layers.length, 0, 360), 50, 100); }
    boolean done = false;
    while (done == false) {
      done = true;
      for (int ii = 0; ii <= i; ii++) {
        for (Duration d : layers[i].durs) {
          for (Duration dd : layers[ii].durs) {
            if (d.overlaps(dd) && i != ii && heights[i] == heights[ii]) {
              if (done) { heights[i]++; }
              done = false;
            }
          }
        }
      }
    }
  }
  bold = createFont("tahomabold.ttf", 100);
  reg = createFont("tahoma.ttf", 100);
  pg = createGraphics(width, height, P2D);
}
boolean noDraw = false;
void draw() {
  pg.beginDraw();
  pg.textFont(bold);
  pg.textSize(layerY(0.75));
  if (showBg) {
    pg.background(bg);
    if (showMinuteMarkers) {
      for (int i = 0; i < duration; i += 60) {
        pg.strokeWeight(2);
        pg.stroke(0, 0, 100, 25);
        pg.line(map(i, 0, duration, 0, width), 0, map(i, 0, duration, 0, width), height);
      }
    }
  }
  println("bg");
  for (int i = 0; i < layers.length; i++) {
    Layer l = layers[i];
    pg.noStroke();
    pg.rectMode(CORNERS);
    pg.textAlign(LEFT, CENTER);
    pg.fill(l.hue);
    for (Duration d : l.durs) {
      pg.rect(time(d.start), layerY(heights[i]), time(d.end), layerY(heights[i] + 1));
    }
    pg.fill(0, 0, 100, 25);
    for (Duration r : l.revs) {
      pg.rect(time(r.start), layerY(heights[i]), time(r.end), layerY(heights[i] + 1));
    }
    pg.fill(bg);
    for (float c : l.cuts) {
      for (int ii = round(layerY(heights[i])); ii < layerY(heights[i] + 1); ii++) {
        if (ii % 12 < 4) { pg.rect(time(c) - 1, ii, time(c) + 1, ii + 1); }
      }
    }
    pg.rectMode(CORNER);
    for (Duration d : l.durs) {
      float hue = hue(l.hue);
      float sinhue = 2 * pow(sin((hue / (180.0 / PI)) / 2 + PI / 4), 6) - 1;
      String label = l.label;
      float ii = 0.75;
      //float s;
      pg.textSize(layerY(ii));
      if (l.defLabel && layerTextDefault) {
        label = "Layer " + l.label;
        if (pg.textWidth(label) + gap * 2 > time(d.end) - time(d.start)) { label = "Lyr " + l.label; println("trunclyr"); }
        if (pg.textWidth(label) + gap * 2 > time(d.end) - time(d.start)) { label = "Lr " + l.label; println("trunclr"); }
        if (pg.textWidth(label) + gap * 2 > time(d.end) - time(d.start)) { label = "L" + l.label; println("truncl"); }
        if (pg.textWidth(label) + gap * 2 > time(d.end) - time(d.start)) { label = l.label; println("trunc"); }
      }
      while (pg.textWidth(label) + gap * 2 > time(d.end) - time(d.start) && ii > 0.05) { ii -= 0.01; pg.textSize(layerY(ii)); }
      //s = pg.textWidth(label);
      pg.fill(l.hue);
      pg.rect(time(d.start), layerY(heights[i]), pg.textWidth(label), layerY(heights[i] + 1) - layerY(heights[i]));
      if (whiteTextDefault) {
        if (brightness(l.hue) > -30 * sinhue + 50 && saturation(l.hue) < 25 * sinhue + 50) { pg.fill(0); } else { pg.fill(255); }
      } else {
        if (brightness(l.hue) < 40) { pg.fill(255); } else { pg.fill(0); }
      }
      pg.text(label, time(d.start) + gap, layerY(heights[i] + 0.5));
    }
    println("lyr" + (i + 1));
  }
  println("lyrs");
  if (showBottomLeftText) {
    pg.fill(0, 0, 100, 50);
    pg.textAlign(LEFT, BOTTOM);
    pg.textSize(30);
    float w = pg.textWidth(track);
    pg.text(track, 2, height - 2);
    pg.textFont(reg);
    pg.textSize(20);
    pg.text(name, w + 10, height - 4);
  }
  println("finish");
  pg.endDraw();
  image(pg, width, height);
}
void mouseClicked() {
  pg.save(track + " " + name + " layer graph.png");
}
