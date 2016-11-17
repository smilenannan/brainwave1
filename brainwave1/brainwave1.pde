import oscP5.*;
import netP5.*;
import ddf.minim.*;
import java.util.Random;

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

PImage img0;
PImage img1;
PImage img2;
PImage img3;
PImage img4;
Ripple[] ripple = new Ripple[5];

Ripple buff;
int ran[] = new int[5];

/*
Ripple ripple1;
Ripple ripple2;
Ripple ripple3;*/

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

// start window
boolean start;
Boid startBoid1;
SeekObject startSeek1;
SeekObject startSeek2;
SeekObject startSeek3;
Boid startBoid2;
SeekObject startSeek4;
SeekObject startSeek5;
SeekObject startSeek6;
   
void setup(){
  img0 = loadImage("stars.jpg");
  img1 = loadImage("teamlab.jpg");
  img2 = loadImage("firefly.jpg");
  img3 = loadImage("jellyfish.jpeg");
  img4 = loadImage("blue.jpg");
  fullScreen();
  //size(1200, 700);
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

  ripple[0] = new Ripple(img0);
  ripple[1] = new Ripple(img1);
  ripple[2] = new Ripple(img2);
  ripple[3] = new Ripple(img3);
  ripple[4] = new Ripple(img4);
 
  frameRate(30);
  noSmooth();
  
  font = createFont("Courier", 12);

  // start window
  start = false;
  startBoid1 = new Boid(NUM_BOIDS, 
                        DIST_THRESHOLD1, DIST_THRESHOLD2, DIST_THRESHOLD3, 
                        FACTOR_COHESION, FACTOR_SEPARATION, FACTOR_ALINGMENT, 
                        VELOCITY_LIMIT, 
                        TRAIL_SCALE, 
                        r1, r2, r3);
  startBoid2 = new Boid(NUM_BOIDS, 
                        DIST_THRESHOLD1, DIST_THRESHOLD2, DIST_THRESHOLD3, 
                        FACTOR_COHESION, FACTOR_SEPARATION, FACTOR_ALINGMENT, 
                        VELOCITY_LIMIT, 
                        TRAIL_SCALE, 
                        r1, r2, r3);
                       
  startBoid1.ypos = 650;

  startBoid2.ypos = 650;
  startSeek1 = new SeekObject(startBoid1.xpos+5,startBoid1.ypos+5,12.0,16.0);
  startSeek2 = new SeekObject(startSeek1.xpos+5,startSeek1.ypos+5,6.0,8.0);
  startSeek3 = new SeekObject(startSeek2.xpos+5,startSeek2.ypos+5,6.0,8.0);
  startSeek4 = new SeekObject(startBoid2.xpos+5,startBoid2.ypos+5,12.0,16.0);
  startSeek5 = new SeekObject(startSeek4.xpos+5,startSeek4.ypos+5,6.0,8.0);
  startSeek6 = new SeekObject(startSeek5.xpos+5,startSeek5.ypos+5,6.0,8.0);
  for(int i=0; i<5; i++){
    ran[i] = i;
  }
}

 
void draw(){
  msg = "alpha waves : ";
  
  time++; 
  //alpha_avg = 0.35*time/199;
  
  
  for(int ch = 0; ch < N_CHANNELS; ch++){
    for(int t = 0; t < BUFFER_SIZE; t++){
      alpha_avg += buffer[ch][(t+pointer) % BUFFER_SIZE];
    }
  }
  alpha_avg /= N_CHANNELS * BUFFER_SIZE;
  //update r1, r2, r3
    
    
  if(start==false){
    fill(0);
    rect(0,0,1500,1000);
    startBoid1.xpos = time*1.0/199*displayWidth/2;
    startBoid2.xpos = displayWidth-time*1.0/199*displayWidth/2;
    // need to revise
    blendMode(BLEND);
    startSeek1.update(startBoid1.xpos,startBoid1.ypos,15);
    startSeek2.update(startSeek1.xpos,startSeek1.ypos,10);
    startSeek3.update(startSeek2.xpos,startSeek2.ypos,10);
    startSeek4.update(startBoid2.xpos,startBoid2.ypos,15);
    startSeek5.update(startSeek4.xpos,startSeek4.ypos,10);
    startSeek6.update(startSeek5.xpos,startSeek5.ypos,10);
    blendMode(ADD);
    startSeek1.drawSeekAgent1(80,7);
    startSeek2.drawSeekAgent1(8,1);
    startSeek3.drawSeekAgent1(8,1);
    startBoid1.drawMe();
    startSeek4.drawSeekAgent1(80,7);
    startSeek5.drawSeekAgent1(8,1);
    startSeek6.drawSeekAgent1(8,1);
    startBoid2.drawMe(); 
    blendMode(BLEND);
    if (startBoid1.xpos == displayWidth/2){
      start = true;
    }
  }else{
    
      ripple[ran[0]].draw();
  
  if(time >199){
  Random rnd = new Random();
    for(int i = 0; i < 5; i++){
          ran[i] = rnd.nextInt(5);
          int x = ran[i];
          for( i = 0; i < 5 ; i++)
              if(ran[i] ==x)
              break;
      }
     
    time = 0;
  }
  
  
  if (time < 30){
      fill(0,255*(30-time)/30);
      rect(0,0,displayWidth,displayHeight);
  }else if(time >= 170){
      fill(0,255*(time-170)/30);
      rect(0,0,displayWidth,displayHeight);
  }
  
   
   if(alpha_avg < 0.3){
    
    if(low_sound == false){
      player = minim.loadFile("BGMrepeat.mp3");
      player.loop();
    }
    low_sound = true;

  }else{
    if(low_sound == true){
      player.close();
    }
    }
    
  for(int i=0; i<NUM_BOIDS; ++i){
    if (alpha_avg < 0.20){
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
    ripple[0].disturb((int)flock[i].xpos, (int)flock[i].ypos);
    seek1[i].drawSeekAgent1(80,7);
    seek2[i].drawSeekAgent1(8,1);
    seek3[i].drawSeekAgent1(8,1);
    ripple[0].disturb((int)seek3[i].xpos, (int)seek3[i].ypos);
    blendMode(BLEND);
    }
  }
 

  //make the area of message
  msg += alpha_avg;
  msg += "and_" + time;
  //msg += "_and_" + ran1 + " "+ ran2;
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