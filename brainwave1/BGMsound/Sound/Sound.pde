import ddf.minim.*;

Minim minim;  //Minim型変数であるminimの宣言
AudioPlayer player;  //サウンドデータ格納用の変数
 
void setup()
{
  size(100, 100);
  minim = new Minim(this);  //初期化
  player = minim.loadFile("BGM1.mp3.mp3"); //mp3ファイルを指定する 
  player.play();  //再生
}
 
void draw()
{
  background(0);
}

void stop()
{
  player.close();  //サウンドデータを終了
  minim.stop();
  super.stop();
}