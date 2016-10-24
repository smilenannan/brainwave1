class SeekObject{
  float xpos, ypos ,disx ,disy;
  float distance;

  SeekObject(float _xpos,float _ypos,float _disx,float _disy){
    xpos = _xpos;
    ypos = _ypos;
    disx = _disx;
    disy = _disy;
  }

  void drawSeekAgent1(){
    stroke(255, 110, 0);
    fill(255, 110, 0);
    ellipse(this.xpos,this.ypos,5,5);

  }

  void update(float targetX,float targetY){
  disx = targetX - xpos;
  disy = targetY - ypos;
  distance = sqrt(sq(disx) + sq(disy));
  if(distance>20){
    xpos += (distance-20)*disx/distance;
    ypos += (distance-20)*disy/distance;
  }

  disx = targetX - xpos;
  disy = targetY - ypos;

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

}