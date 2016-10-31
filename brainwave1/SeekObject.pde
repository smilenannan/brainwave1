class SeekObject{
  float xpos, ypos ,disx ,disy;
  float distance;
  PImage img;

  SeekObject(float _xpos,float _ypos,float _disx,float _disy){
    xpos = _xpos;
    ypos = _ypos;
    disx = _disx;
    disy = _disy;
  }

  PImage createLight(float rPower, float gPower, float bPower ,int side , float t) {
  //int side 1辺の大きさ
  // tは円の大きさを調節するための変数
  float center = side / 2.0; // 中心座標
  
  // 画像を生成
  PImage img = createImage(side, side, RGB);
  
  // 画像の一つ一つのピクセルの色を設定する
  for (int y = 0; y < side; y++) {
    for (int x = 0; x < side; x++) {
      //float distance = sqrt(sq(center - x) + sq(center - y));
      float distance = (sq(center - x) + sq(center - y)) / t;
      int r = int( (255 * rPower) / distance );
      int g = int( (255 * gPower) / distance );
      int b = int( (255 * bPower) / distance );
      img.pixels[x + y * side] = color(r, g, b);
      }
    }
    return img;
  }
  
  void drawSeekAgent1(int side, float t){
    img = createLight(random(0.5, 0.8), random(0.5, 0.8), random(0.5, 0.8),side,t);
    image(img,xpos-side/2,ypos-side/2);
  }

  void update(float targetX,float targetY,float span){
  disx = targetX - xpos;
  disy = targetY - ypos;
  distance = sqrt(sq(disx) + sq(disy));
  if(distance>span){
    xpos += (distance-span)*disx/distance;
    ypos += (distance-span)*disy/distance;
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