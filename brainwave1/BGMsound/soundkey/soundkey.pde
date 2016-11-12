import ddf.minim.*;

Minim minim;
AudioPlayer song;
 
void setup()
{
  minim = new Minim(this);
  song = minim.loadFile("BGM1.mp3.mp3");
}

void draw()
{
  background(0);
}

void keyPressed()
{
  if ( key == 'p' )
  {
    song.play();
  }
}
 
void stop()
{
  song.close();
  minim.stop();
  super.stop();
}