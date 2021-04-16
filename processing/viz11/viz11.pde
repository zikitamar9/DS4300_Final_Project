import de.voidplus.redis.*;
import java.util.*;

Redis redis;
int screenwidth = 1620;
int screenheight = 780;
int texty = 560;
int scorey = 500;
int lmargin = 50;
int textmargin = 7;

void setup(){
    // ...
    size(1620, 780);
    redis = new Redis(this, "127.0.0.1", 6379);
    
    redis.set("key", "value");
    println(redis.get("key"));
    textSize(20);
    noStroke();
    color c1 = color(255, 255, 255);
    fill(c1);
}

void draw() {
  background(100, 100, 200);
  Set stuff = redis.zrevrangeWithScores("bloomset", 0, 29);
  int boxwidth = (screenwidth - 300) / (stuff.size() + 1);
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
    translate(textmargin-lmargin-counter*boxwidth, -1*texty);
    counter++;
  }
  //String s1 = String.join(",", stuff[1]);
  //text(s1, 200, 400);
  //ellipse(mouseX, mouseY, 80, 80);
}
