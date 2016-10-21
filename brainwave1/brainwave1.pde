int NUM_BOIDS = 500;
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

//PFont font;
//String msg = "";
   
void setup(){
  size(2000, 1000);
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
  }
  
  frameRate(30);
  noSmooth();
  
  //font = createFont("Courier", 12);
  //msg = "Area("+DIST_THRESHOLD1+","+DIST_THRESHOLD2+","+DIST_THRESHOLD3+") Velocity("+VELOCITY_LIMIT+")";
}

 
void draw(){
  fill(255, 255, 255, 75);
  noStroke();
  rect(0, 0, width, height);
  //noFill();
  //stroke(0);
  strokeWeight(3);
  for(int i=0; i<NUM_BOIDS; ++i){
    flock[i].update();
    flock[i].drawMe();
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