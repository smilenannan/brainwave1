int NUM_BOIDS = 70;
int DIST_THRESHOLD1 = 10;
int DIST_THRESHOLD2 = 20;
int DIST_THRESHOLD3 = 30;
float FACTOR_COHESION = 100;
float FACTOR_SEPARATION = 10;
float FACTOR_ALINGMENT = 10;
float VELOCITY_LIMIT = 2;
float TRAIL_SCALE = 2;

float r1 = 1.0; // Cohesion:   pull to center of flock
float r2 = 0.8; // Separation: avoid bunching up
float r3 = 0.1; // Alingment:  match average flock speed

Boid[] flock = new Boid[NUM_BOIDS];
SeekObject[] seek1 = new SeekObject[NUM_BOIDS];
SeekObject[] seek2 = new SeekObject[NUM_BOIDS];
SeekObject[] seek3 = new SeekObject[NUM_BOIDS];

//PFont font;
//String msg = "";
   
void setup(){
  size(displayWidth, displayHeight);
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
  }
  
  frameRate(30);
  noSmooth();
  
  //font = createFont("Courier", 12);
  //msg = "Area("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") Velocity("+VELOCITY_LIMIT+")";
}

 
void draw(){
  fill(0,0,0);
  noStroke();
  rect(0, 0, width, height);
  for(int i=0; i<NUM_BOIDS; ++i){
    blendMode(BLEND);
    flock[i].update();
    seek1[i].update(flock[i].xpos,flock[i].ypos,15);
    seek2[i].update(seek1[i].xpos,seek1[i].ypos,10);
    seek3[i].update(seek2[i].xpos,seek2[i].ypos,10);
    blendMode(ADD);
    flock[i].drawMe();
    seek1[i].drawSeekAgent1(80,7);
    seek2[i].drawSeekAgent1(8,1);
    seek3[i].drawSeekAgent1(8,1);
    blendMode(BLEND);
  }
  /*make the area of message
  noStroke();
  fill(30);
  rect(0, height-20, width, height);
  fill(200);
  textFont(font);
  text(msg, 7, height-7);*/
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