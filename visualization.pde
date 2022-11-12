import ddf.minim.analysis.*;
import ddf.minim.*;

final int headX = 737;
final int headY = 998;

Minim minim;
AudioPlayer[] files;
int fileIdx;
FFT fft_bass, fft_mid, fft_treble;
float len;
float[] values;
int time;
float theta;
color start, end;
PGraphics pg;
PImage[] images;
int tintValue;

void setup() {
  size(2560, 1440);
  pg = createGraphics(width, height);
  pgSetup();
  
  images = new PImage[17];
  for (int i = 0; i != 17; i++) images[i] = loadImage("images/"+i+".png");
  tintValue = 0;
  
  minim = new Minim(this);
  files = new AudioPlayer[file_list.length];
  for (int i = 0; i != file_list.length; i++) files[i] = minim.loadFile("music/"+file_list[i], sampling_num);
  fileIdx = 0;
  selectColor();
  
  samplerSetup();
  
  w_bass = new float[9];
  w_mid = new float[9];
  w_treble = new float[9];
  
  calculateWeight();
  
  values = new float[i_bass.length+i_mid.length+i_treble.length];
  
  files[fileIdx].play();
}

void draw() {
  background(0);
  tint(255, 255);
  image(images[16], 0, 0);
  if (files[fileIdx].isPlaying()) {
    if (tintValue < 255) tintValue += 15;
    fft_bass.forward(files[fileIdx].mix);
    fft_mid.forward(files[fileIdx].mix);
    fft_treble.forward(files[fileIdx].mix);
    for (int i = 0; i != i_bass.length; i++) {
      values[i] = fft_bass.getBand(i_bass[i]) * w_bass[i];
    }
    for (int i = 0; i != i_mid.length; i++) {
      values[i+i_bass.length] = fft_mid.getAvg(i_mid[i]) * w_mid[i];
    }
    for (int i = 0; i != i_treble.length; i++) {
      values[i+i_bass.length+i_mid.length] = fft_treble.getAvg(i_treble[i]) * w_treble[i];
    }
    
    boolean printing = false;
    if (time != files[fileIdx].position()) {
      time = files[fileIdx].position();
      printing = true;
    }
    theta = map(time, 0, len, 0, -2*PI);
    for (int i = 0; i != 9; i++) {
      circle(headX, headY, (i+1)*25, theta, values[i], printing);
    }
    for (int i = 0; i != 9; i++) {
      circle(headX - 1000/3, headY - 1000/3, (i+1)*20, theta, values[i+i_bass.length], printing);
    }
    for (int i = 0; i != 9; i++) {
      circle(headX + 1000/3, headY - 1000/3, (i+1)*20, theta, values[i+i_bass.length+i_mid.length], printing);
    }
  }
  else {
    if (tintValue > 0) tintValue -= 15;
    else {
      files[fileIdx].rewind();
      fileIdx++;
      if (fileIdx == file_list.length) fileIdx = 0;
      selectColor();
      pgSetup();
      samplerSetup();
      calculateWeight();
      files[fileIdx].play();
    }
  }
  tint(255, tintValue);
  image(pg, 0, 0);
  image(images[fileIdx], 0, 0);
}

void mouseClicked() {
  files[fileIdx].pause();
}

void pgSetup() {
  pg.beginDraw();
  pg.noStroke();
  pg.clear();
  pg.endDraw();
  strokeWeight(2);
  theta = 0;
}

void samplerSetup() {
  fft_bass = new FFT(files[fileIdx].bufferSize(), files[fileIdx].sampleRate());
  fft_mid = new FFT(files[fileIdx].bufferSize(), files[fileIdx].sampleRate());
  fft_mid.linAverages((sampling_num/2)/avg_num_mid);
  fft_treble = new FFT(files[fileIdx].bufferSize(), files[fileIdx].sampleRate());
  fft_treble.linAverages((sampling_num/2)/avg_num_treble);
  
  time = -1;
  len = files[fileIdx].length();
}

void circle(int x, int y, float d, float t, float r, boolean p) {
  float centerX = x - d*sin(t);
  float centerY = y - d*cos(t);
  color c = lerpColor(color(start), color(end), -sin(t/2));
  if (p) {
    pg.beginDraw();
    pg.fill(c, 10);
    pg.ellipse(centerX, centerY, r, r);
    pg.endDraw();
  }
  stroke(c, tintValue);
  r*=2;
  line(centerX, centerY, centerX - r*sin(t-HALF_PI), centerY - r*cos(t-HALF_PI));
}

void selectColor() {
  if (fileIdx < 8) {
    start = #8a2387;
    end = #e94057;
    return;
  }
  if (fileIdx < 12) {
    start = #52ba97;
    end = #175694;
    return;
  }
  start = #4362ad;
  end = #a566a7;
}
