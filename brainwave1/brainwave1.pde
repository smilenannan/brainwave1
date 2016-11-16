import oscP5.*;
import netP5.*;
import ddf.minim.*;

int NUM_BOIDS = 100;
int DIST_THRESHOLD1 = 10;
int DIST_THRESHOLD2 = 20;
int DIST_THRESHOLD3 = 30;
float FACTOR_COHESION = 100;
float FACTOR_SEPARATION = 10;
float FACTOR_ALINGMENT = 10;
float VELOCITY_LIMIT = 0;
float TRAIL_SCALE = 2;

float r1 = 1.0; // Cohesion:   pull to center of flock
float r2 = 0.8; // Separation: avoid bunching up
float r3 = 0.1; // Alingment:  match average flock speed

PImage img1;
PImage img2;
PImage img3;
Ripple ripple1;
Ripple ripple2;
Ripple ripple3;

int time=0;
boolean low_sound = false;

Boid[] flock = new Boid[NUM_BOIDS];
SeekObject[] seek1 = new SeekObject[NUM_BOIDS];
SeekObject[] seek2 = new SeekObject[NUM_BOIDS];
SeekObject[] seek3 = new SeekObject[NUM_BOIDS];

//parameters for getting alpha waves
final int N_CHANNELS = 4;
final int BUFFER_SIZE = 10;
float alpha_avg; //average of alpha waves
float[][] buffer = new float[N_CHANNELS][BUFFER_SIZE];
int pointer = 0;
final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

//sound
Minim minim;
AudioPlayer player;

//showing alpha_wave
PFont font;
String msg = "";
   
void setup(){
  img1 = loadImage("stars.jpg");
  img2 = loadImage("teamlab.jpg");
  img3 = loadImage("firefly.jpg");
  size(1200, 700);
  //size(displayWidth, displayHeight);
  background(0);
  
  randomSeed(int(random(1,1000)));
  
  for(int i=0; i<NUM_BOIDS; ++i){
    flock[i] = new Boid(NUM_BOIDS, 
                        DIST_THRESHOLD1, DIST_THRESHOLD2, DIST_THRESHOLD3, 
                        FACTOR_COHESION, FACTOR_SEPARATION, FACTOR_ALINGMENT, 
                        VELOCITY_LIMIT, 
                        TRAIL_SCALE, 
                        r1, r2, r3);
    flock[i].xpos = random(0, width);
    flock[i].ypos = random(0, height);
     
    flock[i].vx = random(-5, 5);
    flock[i].vy = random(-5, 5);
    
    seek1[i] = new SeekObject(flock[i].xpos+5,flock[i].ypos+5,12.0,16.0);
    seek2[i] = new SeekObject(seek1[i].xpos+5,seek1[i].ypos+5,6.0,8.0);
    seek3[i] = new SeekObject(seek2[i].xpos+5,seek2[i].ypos+5,6.0,8.0);

  minim = new Minim(this);
  }
  
  ripple1 = new Ripple(img1);
  ripple2 = new Ripple(img2);
  ripple3 = new Ripple(img3);
  frameRate(30);
  noSmooth();
  
  font = createFont("Courier", 12);
}

 
void draw(){
  msg = "alpha waves : ";

  if(time==399){
  time = 0;
  }
  time++; 
  
  alpha_avg = 0.35*time/399;
  
  /*
  for(int ch = 0; ch < N_CHANNELS; ch++){
    for(int t = 0; t < BUFFER_SIZE; t++){
      alpha_avg += buffer[ch][(t+pointer) % BUFFER_SIZE];
    }
  }
  alpha_avg /= N_CHANNELS * BUFFER_SIZE;*/
  //update r1, r2, r3
    
  if (alpha_avg < 0.10){
    ripple1.draw();
  
    if(low_sound == true){
      player.close();
    }
    low_sound = false;
  
    if (alpha_avg >0.08){
      fill(0,255*(alpha_avg-0.08)/0.02);
      rect(0,0,1200,700);
    }
  }else if(alpha_avg < 0.3){
    ripple2.draw();
    
    if(low_sound == false){
      player = minim.loadFile("BGMrepeat.mp3");
      player.loop();
    }
    low_sound = true;
    
    if(alpha_avg < 0.12){
      fill(0,255*(0.12-alpha_avg)/0.02);
      rect(0,0,1200,700);
    }
      if(alpha_avg >0.28){
      fill(0,255*(alpha_avg-0.28)/0.02);
      rect(0,0,1200,700);
    }
  }else{
    ripple3.draw();
    
    if(low_sound == true){
      player.close();
    }
    low_sound = false;

    if(alpha_avg < 0.32){
      fill(0,255*(0.32-alpha_avg)/0.02);
      rect(0,0,1200,700);
    } 
    
  }
    
  for(int i=0; i<NUM_BOIDS; ++i){
    if (alpha_avg < 0.10){
    flock[i].r1 = 0.1;
    flock[i].r2 = 10.0;
    flock[i].r3 = 0.1;
    flock[i].VELOCITY_LIMIT = 100;    
  }else if(alpha_avg < 0.3){
    flock[i].r1 = 20.0;
    flock[i].r2 = 0.1;
    flock[i].r3 = 10.0;
    flock[i].VELOCITY_LIMIT = 2;     
  }else{
    flock[i].r1 = 20.0;
    flock[i].r2 = 0.1;
    flock[i].r3 = 10.0;
    flock[i].VELOCITY_LIMIT = 0;
    }
  }
    
  for(int i=0; i<NUM_BOIDS; ++i){
    blendMode(BLEND);
    flock[i].update();
    seek1[i].update(flock[i].xpos,flock[i].ypos,15);
    seek2[i].update(seek1[i].xpos,seek1[i].ypos,10);
    seek3[i].update(seek2[i].xpos,seek2[i].ypos,10);
    blendMode(ADD);
    flock[i].drawMe();
    ripple1.disturb((int)flock[i].xpos, (int)flock[i].ypos);
    ripple2.disturb((int)flock[i].xpos, (int)flock[i].ypos);
    ripple3.disturb((int)flock[i].xpos, (int)flock[i].ypos);
    seek1[i].drawSeekAgent1(80,7);
    seek2[i].drawSeekAgent1(8,1);
    seek3[i].drawSeekAgent1(8,1);
    ripple1.disturb((int)seek3[i].xpos, (int)seek3[i].ypos);
    ripple2.disturb((int)seek3[i].xpos, (int)seek3[i].ypos);
    ripple3.disturb((int)flock[i].xpos, (int)flock[i].ypos);
    blendMode(BLEND);
  }

  //make the area of message
  msg += alpha_avg;
  msg += "and_" + time;
  noStroke();
  fill(30);
  rect(0, height-20, width, height);
  fill(200);
  textFont(font);
  text(msg, 7, height-7);
}

//import the value of alpha waves
void oscEvent(OscMessage msg){
  float data;
  if(msg.checkAddrPattern("/muse/elements/alpha_relative")){
    for(int ch = 0; ch < N_CHANNELS; ch++){
      data = msg.get(ch).floatValue();
      buffer[ch][pointer] = data;
    }
    pointer = (pointer + 1) % BUFFER_SIZE;
  }
} 