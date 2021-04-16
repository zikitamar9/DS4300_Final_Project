import de.voidplus.redis.*;
import java.util.*;

Redis redis;
int screenwidth = 1620;
int screenheight = 780;
int texty = 560;
int scorey = 500;
int lmargin = 50;
int textmargin = 7;
String setname = "bloomset";

void setup(){
    size(1620, 780);
    background(100, 100, 200);
    redis = new Redis(this, "127.0.0.1", 6379);
    textSize(20);
    noStroke();
    color c1 = color(255, 255, 255);
    fill(c1);
}

void draw() {
  textSize(20);
  drawbg();
  color c1 = color(255, 255, 255);
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
    rect((float)lmargin+counter*boxwidth, 400 - (float)score*2, (float)0.7*boxwidth, (float)score*2);
    translate(textmargin+lmargin+counter*boxwidth, texty);
    rotate(PI/4);
    text(String.format("#%s",fun), 0, 0);
    rotate(-PI/4);
    translate(-1*(textmargin+lmargin+counter*boxwidth), -1*texty);
    counter++;
  }
  textSize(50);
  text(String.format("SET: \"%s\"",setname), screenwidth/(1.7), 200);
}

void drawbg() {
  double a1 = 0.2;
  double a2 = 0.2;
  double a3 = 0.1;
  for (int i = 0; i < screenheight; i++) {
    color c1 = color((int)(150-i*a1), (int)(150-i*a2), (int)(255-i*a3));
    fill(c1);
    rect(0, i, screenwidth, 1);
  }
}
