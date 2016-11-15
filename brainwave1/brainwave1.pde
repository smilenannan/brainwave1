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
Ripple ripple1;
Ripple ripple2;

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
  img1 = loadImage("teamlab.jpg");
  img2 = loadImage("stars.jpg");
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
  //player.play();
  }
  
  ripple1 = new Ripple(img1);
  ripple2 = new Ripple(img2);
  frameRate(30);
  noSmooth();
  
  font = createFont("Courier", 12);
  //msg = "Area("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") Velocity("+VELOCITY_LIMIT+")";
}

 
void draw(){
  
  if (time%400 <201){
  ripple2.draw();
    if(time%400 <50){
      fill(0,255*(50-time)/50);
      rect(0,0,1200,700);
    }else if(time%400 >150){
      fill(0,255*(time-150)/50);
      rect(0,0,1200,700);
    }
  }else if(time%400 >200){
    ripple1.draw();
    if(time%400 <250){
      fill(0,255*(250-time)/50);
      rect(0,0,1200,700);
    }else if(time%400 >350){
      fill(0,255*(time-350)/50);
      rect(0,0,1200,700);
    };
  }
  
  if(time==399){
  time = 0;
  }
  
  
  
  /*if (time%100 > 50){
  ripple1.draw();
  }else if(time%100 < 50){
  ripple2.draw();
  }
  if(time > 100){
  time = 0;
  }*/
  time++;
  
  msg = "alpha waves : ";
  //fetch alpha waves 
  if (time < 50){
    alpha_avg = 0;
  }else if(time < 100){
    alpha_avg = 0.2;
  }else{
    alpha_avg = 0.4;
  }
  /*
  for(int ch = 0; ch < N_CHANNELS; ch++){
    for(int t = 0; t < BUFFER_SIZE; t++){
      alpha_avg += buffer[ch][(t+pointer) % BUFFER_SIZE];
    }
  }
  alpha_avg /= N_CHANNELS * BUFFER_SIZE;*/
  //update r1, r2, r3
  if(alpha_avg == 0){
    //necessary to revise here
    
    for(int i=0; i<NUM_BOIDS; ++i){
      if (alpha_avg < 0.10){
      flock[i].r1 = 0.1;
      flock[i].r2 = 10.0;
      flock[i].r3 = 0.1;
      flock[i].VELOCITY_LIMIT = 100;
      if(low_sound == true){
        player.close();
      }
      low_sound = false;
      //minim.stop();
      
    }else if(alpha_avg < 0.3){
      //print("kanamoto");
      flock[i].r1 = 20.0;
      flock[i].r2 = 0.1;
      flock[i].r3 = 10.0;
      flock[i].VELOCITY_LIMIT = 2;
      if(low_sound == false){
      player = minim.loadFile("BGMrepeat.mp3");
      player.loop();
      }
      low_sound = true;
    }else{
      flock[i].r1 = 20.0;
      flock[i].r2 = 0.1;
      flock[i].r3 = 10.0;
      flock[i].VELOCITY_LIMIT = 0;
      if(low_sound == true){
        player.close();
      }
      low_sound = false;
    }
    }
    
    
   }else{ //when muse is not connected
    r1 = 1.0;
    r2 = 0.8;
    r3 = 0.1;
  }
  /*
  fill(0,0,0);
  noStroke();
  rect(0, 0, width, height);*/
 // ripple.draw();
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
    seek1[i].drawSeekAgent1(80,7);
    //ripple.disturb((int)seek1[i].xpos, (int)seek1[i].ypos);
    seek2[i].drawSeekAgent1(8,1);
    //ripple.disturb((int)seek2[i].xpos, (int)seek2[i].ypos);
    seek3[i].drawSeekAgent1(8,1);
    ripple1.disturb((int)seek3[i].xpos, (int)seek3[i].ypos);
    ripple2.disturb((int)seek3[i].xpos, (int)seek3[i].ypos);
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

/*action when the pointer moves
void mousePressed(){
  DIST_THRESHOLD1 = round(random(1,30));
  DIST_THRESHOLD2 = DIST_THRESHOLD1+round(random(1,20));
  DIST_THRESHOLD3 = DIST_THRESHOLD2+round(random(1,20));
  VELOCITY_LIMIT = random(1, 10);
  msg = "Area("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") Velocity("+VELOCITY_LIMIT+")";
  println("AREA("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") VELOCITY("+VELOCITY_LIMIT+")");
}*/