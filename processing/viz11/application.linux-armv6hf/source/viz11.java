import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.voidplus.redis.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class viz11 extends PApplet {




Redis redis;
int screenwidth = 1620;
int screenheight = 780;
int texty = 560;
int scorey = 500;
int lmargin = 50;
int textmargin = 7;
String setname = "bloomset";

public void setup(){
    
    background(100, 100, 200);
    redis = new Redis(this, "127.0.0.1", 6379);
    textSize(20);
    noStroke();
    int c1 = color(255, 255, 255);
    fill(c1);
}

public void draw() {
  textSize(20);
  drawbg();
  int c1 = color(255, 255, 255);
  fill(c1);
  Set stuff = redis.zrevrangeWithScores(setname, 0, 29);
  int boxwidth = (screenwidth) / (stuff.size() + 1);
  Iterator<redis.clients.jedis.Tuple> it = stuff.iterator();
  int counter = 0;
  while(it.hasNext()) {
    redis.clients.jedis.Tuple i = it.next();
    String fun = i.getElement();
    double score = i.getScore();
    println(fun);
    println(score);
    text(String.format("%d",(long)score), lmargin+counter*boxwidth, scorey);
    rect((float)lmargin+counter*boxwidth, 400 - (float)score*2, (float)0.7f*boxwidth, (float)score*2);
    translate(textmargin+lmargin+counter*boxwidth, texty);
    rotate(PI/4);
    text(String.format("#%s",fun), 0, 0);
    rotate(-PI/4);
    translate(-1*(textmargin+lmargin+counter*boxwidth), -1*texty);
    counter++;
  }
  textSize(50);
  text(String.format("SET: \"%s\"",setname), screenwidth/(1.7f), 200);
}

public void drawbg() {
  double a1 = 0.2f;
  double a2 = 0.2f;
  double a3 = 0.1f;
  for (int i = 0; i < screenheight; i++) {
    int c1 = color((int)(150-i*a1), (int)(150-i*a2), (int)(255-i*a3));
    fill(c1);
    rect(0, i, screenwidth, 1);
  }
}
  public void settings() {  size(1620, 780); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "viz11" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
