import oscP5.*;
import netP5.*;

int NUM_BOIDS = 30;
int DIST_THRESHOLD1 = 10;
int DIST_THRESHOLD2 = 20;
int DIST_THRESHOLD3 = 30;
float FACTOR_COHESION = 100;
float FACTOR_SEPARATION = 10;
float FACTOR_ALINGMENT = 10;
float VELOCITY_LIMIT = 2;
float TRAIL_SCALE = 1;

float r1 = 1.0; // default, Cohesion:   pull to center of flock
float r2 = 0.8; // default, Separation: avoid bunching up
float r3 = 0.1; // default, Alingment:  match average flock speed

PImage img;
Ripple ripple;

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

PFont font;
String msg;
   
void setup(){
  //println("hello, World!");
  img = loadImage("water.jpg");
  //tint(255, 255);
  //image(img, 0, 0);  

  size(500, 400);
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
    
    seek1[i] = new SeekObject(flock[i].xpos+10,flock[i].ypos+10,12.0,16.0);
    seek2[i] = new SeekObject(seek1[i].xpos+10,seek1[i].ypos+10,12.0,16.0);
    seek3[i] = new SeekObject(seek2[i].xpos+10,seek2[i].ypos+10,12.0,16.0);
  }
  
  frameRate(30);
  
  ripple = new Ripple(img);
  smooth();
  //noSmooth();
  
  font = createFont("Courier", 12);
  //msg = "Area("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") Velocity("+VELOCITY_LIMIT+")";
}

 
void draw(){
  msg = "alpha waves : ";
  //fetch alpha waves
  alpha_avg = 0;
  for(int ch = 0; ch < N_CHANNELS; ch++){
    for(int t = 0; t < BUFFER_SIZE; t++){
      alpha_avg += buffer[ch][(t+pointer) % BUFFER_SIZE];
    }
  }
  alpha_avg /= N_CHANNELS * BUFFER_SIZE;
  
  //update r1, r2, r3
  if(alpha_avg != 0){
    //necessary to revise here
    r1 = alpha_avg * 10;
    r2 = 1 / (alpha_avg+0.1);
    r3 = alpha_avg * 5;
    for(int i=0; i<NUM_BOIDS; ++i){
    flock[i].r1 = r1;
    flock[i].r2 = r2;
    flock[i].r3 = r3;
  }
  }else{ //when muse is not connected
    r1 = 1.0;
    r2 = 0.8;
    r3 = 0.1;
  }

  

  /*
  fill(255, 255, 255, 75);
  noStroke();
  rect(0, 0, width, height);
  noFill();
  stroke(0);
  */
  /*
  for(int t = 0; t < BUFFER_SIZE; t++){
    println(buffer[0][t]);
  }*/
  ripple.draw();
  strokeWeight(3);
  for(int i=0; i<NUM_BOIDS; ++i){
    flock[i].update();
    seek1[i].update(flock[i].xpos,flock[i].ypos);
    seek2[i].update(seek1[i].xpos,seek1[i].ypos);
    seek3[i].update(seek2[i].xpos,seek2[i].ypos);
    flock[i].drawMe();
    ripple.disturb((int)flock[i].xpos, (int)flock[i].ypos);
    seek1[i].drawSeekAgent1();
    seek2[i].drawSeekAgent1();
    seek3[i].drawSeekAgent1();
  }

  //make the area of message
  msg += alpha_avg;
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

/*action when the pointer moves
void mousePressed(){
  DIST_THRESHOLD1 = round(random(1,30));
  DIST_THRESHOLD2 = DIST_THRESHOLD1+round(random(1,20));
  DIST_THRESHOLD3 = DIST_THRESHOLD2+round(random(1,20));
  VELOCITY_LIMIT = random(1, 10);
  msg = "Area("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") Velocity("+VELOCITY_LIMIT+")";
  println("AREA("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") VELOCITY("+VELOCITY_LIMIT+")");
}*/