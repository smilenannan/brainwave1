public class Boid{
  int NUM_BOIDS;
  int DIST_THRESHOLD1;
  int DIST_THRESHOLD2;
  int DIST_THRESHOLD3;
  float FACTOR_COHESION;
  float FACTOR_SEPARATION;
  float FACTOR_ALINGMENT;
  float VELOCITY_LIMIT;
  float TRAIL_SCALE;

  float r1; // Cohesion:   pull to center of flock
  float r2; // Separation: avoid bunching up
  float r3; // Alingment:  match average flock speed

  Boid(int NUM_BOIDS, 
       int DIST_THRESHOLD1, int DIST_THRESHOLD2, int DIST_THRESHOLD3, 
       float FACTOR_COHESION, float FACTOR_SEPARATION, float FACTOR_ALINGMENT, 
       float VELOCITY_LIMIT, 
       float TRAIL_SCALE, 
       float r1, float r2, float r3){
    this.NUM_BOIDS = NUM_BOIDS;
    this.DIST_THRESHOLD1 = DIST_THRESHOLD1; this.DIST_THRESHOLD2 = DIST_THRESHOLD2; this.DIST_THRESHOLD3 = DIST_THRESHOLD3;
    this.FACTOR_COHESION = FACTOR_COHESION; this.FACTOR_SEPARATION = FACTOR_SEPARATION; this.FACTOR_ALINGMENT = FACTOR_ALINGMENT;
    this.VELOCITY_LIMIT = VELOCITY_LIMIT;
    this.TRAIL_SCALE = TRAIL_SCALE;
    this.r1 = r1; this.r2 = r2; this.r3 = r3;
  }

  Vector v1 = new Vector();
  Vector v2 = new Vector();
  Vector v3 = new Vector();
  
  float xpos, ypos;
  float vx, vy;
  
  //draw fish
  void drawMe(){
    float velocity = sqrt(sq(vx) + sq(vy));
    stroke(255, 110, 0, 150);
    fill(255, 110, 0, 200);
    pushMatrix();
    translate(xpos,ypos);
    ellipse(0, 0,20,20);
    line(0,0,-20*vx/velocity,-20*vy/velocity);
    popMatrix();
  }
   
  //decide next position
  void update(){
    //initialization of vectors
    v1.x = v1.y = v2.x = v2.y = v3.x = v3.y = 0;
    
    //decide the three vectors
    rule1();
    rule2();
    rule3();
    
    // add vectors to velocities
    vx += r1*v1.x + r2*v2.x + r3*v3.x;
    vy += r1*v1.y + r2*v2.y + r3*v3.y;
    
    //decide the absolute of velocity
    limitVelocity();
    
    //update position
    xpos += vx;
    ypos += vy;
    
    //move fished from one side to the opposite side 
    if(xpos < 0){
      xpos = width;
    } else if(xpos > width){
      xpos = 0;
    }
    if(ypos < 0){
      ypos = height;
    } else if(ypos > height){
      ypos = 0;
    }
  }
  
  //decide the absolute of velocities
  void limitVelocity(){
    float velocity = sqrt(sq(vx) + sq(vy));
    if(velocity > VELOCITY_LIMIT){
      vx = (vx/velocity)*VELOCITY_LIMIT;
      vy = (vy/velocity)*VELOCITY_LIMIT;
    }
  }
  
  // Cohesion: pull to center of flock
  void rule1(){
    //initialization of len and count
    float len = 0;
    int count = 0;
    
 //If "the distance between one boid and the other boid" is bigger than 2, smaller than 3, the "v1.x,y" = "v1.x" + "the position of other boid".
    for(int i=0; i < NUM_BOIDS; ++i){
      if(this != flock[i]){
        len = dist(xpos, ypos, flock[i].xpos, flock[i].ypos);
        if(len > DIST_THRESHOLD2 && len < DIST_THRESHOLD3){
          v1.x += flock[i].xpos;
          v1.y += flock[i].ypos;
          count++;
        }
      }
    }
    
// "v1.x" becomes "the average other boid" / "factor-cohesion"

  if(count > 0){
      v1.x /= count;
      v1.y /= count;
      v1.x = (v1.x - xpos) / FACTOR_COHESION;
      v1.y = (v1.y - ypos) / FACTOR_COHESION;
    }
  }
  
  // Separation
  void rule2(){
    float len = 0;
    
    for(int i=0; i < NUM_BOIDS; ++i){
      if(this != flock[i]){
        len = dist(xpos, ypos, flock[i].xpos, flock[i].ypos);
        if(len < DIST_THRESHOLD1){
          v2.x -= (flock[i].xpos - xpos)/FACTOR_SEPARATION;
          v2.y -= (flock[i].ypos - ypos)/FACTOR_SEPARATION;
        }
      }
    }
  }
  
  // Alingment
  void rule3(){
    float len = 0;
    int count = 0;
    
    for(int i=0; i < NUM_BOIDS; ++i){
      if(this != flock[i]){
        len = dist(xpos, ypos, flock[i].xpos, flock[i].ypos);
        if(len > DIST_THRESHOLD1 && len < DIST_THRESHOLD2){
          v3.x += flock[i].vx;
          v3.y += flock[i].vy;
          count++;
        }
      }
    }
    
    if(count > 0){
      v3.x /= count;
      v3.y /= count;
      v3.x = (v3.x - vx)/FACTOR_ALINGMENT;
      v3.y = (v3.y - vy)/FACTOR_ALINGMENT;
    }
  }
}