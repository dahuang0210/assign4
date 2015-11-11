/** 
 Assignment 4
 Author:          Bao Yuchen
 Student Number:  103254021
 Update:          2015/11/11
 */

public class ObjType {
  final static int FIGHTER = 1, ENEMY = 2, TREASURE = 3, BULLET = 4;
  final static int BACKGROUND = 10, TITLE = 11;
  final static int NOTHING = -1, UNKNOWN = 0;
}

final int MOUSE_LEFT = 37, MOUSE_RIGHT = 39, MOUSE_MID = 3;

ResourcesManager resourcesManager = null;

private GamePlayScene gameMain = null;

/**
 * to initialize system
 */
void setup () {
  size(640, 480) ;
  resourcesManager = new ResourcesManager();
  gameMain = new GamePlayScene();
}


void draw() {
  gameMain.drawFrame();
}

//-------------------------- override listener method --------------------------

void mouseMoved() {
  gameMain.mouseMovedFun(mouseX, mouseY);
}

void mousePressed() {
  gameMain.mousePressedFun(mouseButton);
}

void mouseReleased() {
  gameMain.mouseReleasedFun(mouseButton);
}

/**
 * when key pressed
 */
void keyPressed() {
  gameMain.keyPressedFun(keyCode);
}

/**
 * when key released
 */
void keyReleased() {
  gameMain.keyReleasedFun(keyCode);
}

//****************************************************************************************************************
//****************************************************************************************************************

//================================================================================================================
//================================================================================================================

interface MouseListener {
  public void mouseReleasedFun(int keyCode1) ;
  public void mousePressedFun(int keyCode1) ;
  public void mouseMovedFun(int x, int y);
}

//================================================================================================================
//================================================================================================================

interface KeyPressListener {
  public void keyReleasedFun(int keyCode1) ;
  public void keyPressedFun(int keyCode1) ;
}

//================================================================================================================
//================================================================================================================

interface ScreenChangeListener {
  public void startGame() ;
  public void endGame(int level) ;
  public void restartGame() ;
}

//================================================================================================================
//================================================================================================================

interface GameDataChanged {
  public void addHP(int val);
  public void subHP(int val, DrawingOBJ obj);
  public void enemyMoveOut(Enemy target, boolean isShowExplode);
  public void explodeFinished(Explode target);
}

//****************************************************************************************************************
//****************************************************************************************************************

//================================================================================================================
//================================================================================================================

class ResourcesManager extends HashMap<Integer, PImage> {

  public final static int hp = 1;
  public final static int end1 = 10, end2 = 11;
  public final static int bg1 = 20, bg2 = 21;
  public final static int st1 = 30, st2 = 31;
  public final static int enemy = 40, enemy1=41;
  public final static int fighter = 50, treasure = 51, bullet = 52;
  public final static int explode = 70;

  public ResourcesManager() {
    super();
    loadResources();
  }


  private void addImage(int Key, String resName) {
    if (!this.containsKey(Key)) {
      PImage newRes = loadImage(resName);
      this.put(Key, newRes);
    }
  }
  /**
   * to load pictures
   */
  private void loadResources() {
    addImage(ResourcesManager.hp, "img/hp.png");
    addImage(ResourcesManager.end1, "img/end1.png");
    addImage(ResourcesManager.end2, "img/end2.png");
    addImage(ResourcesManager.bg1, "img/bg1.png");
    addImage(ResourcesManager.bg2, "img/bg2.png");
    addImage(ResourcesManager.st1, "img/start1.png");
    addImage(ResourcesManager.st2, "img/start2.png");
    addImage(ResourcesManager.enemy, "img/enemy.png");
    //addImage(ResourcesManager.enemy1, "img/Moocs-element-enemy1.png");
    addImage(ResourcesManager.fighter, "img/fighter.png");
    addImage(ResourcesManager.treasure, "img/treasure.png");
    addImage(ResourcesManager.bullet, "img/shoot.png");
    for (int i=0; i<5; i++) {
      addImage(ResourcesManager.explode+i, "img/flame"+(i+1)+".png");
    }
  }
}

//================================================================================================================
//================================================================================================================

class GamePlayScene implements ScreenChangeListener {

  Screen screenOBJ = null;
  KeyPressListener keyListener = null;
  MouseListener mouseListener = null;

  public GamePlayScene() {

    restartGame();
  }

  public void drawFrame() {
    if (screenOBJ != null) {
      screenOBJ.drawFrame();
    }
  }

  public void mouseMovedFun(int x, int y) {
    if (mouseListener != null) {
      mouseListener.mouseMovedFun(x, y);
    }
  }

  public void mousePressedFun(int code) {
    if (mouseListener != null) {
      mouseListener.mousePressedFun(code);
    }
  }

  public void mouseReleasedFun(int code) {
    if (mouseListener != null) {
      mouseListener.mouseReleasedFun(code);
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int code) {
    if  (keyListener != null ) {
      keyListener.keyPressedFun(code);
    }
  }

  /**
   * when key released
   */
  public void keyReleasedFun(int code) {
    if  (keyListener != null ) {
      keyListener.keyReleasedFun(code);
    }
  }

  //--------------------------- handled by listener ---------------------------

  public void endGame(int level) {
    onScreenChange();
    GameEnd newScreen = new GameEnd(this);
    newScreen.level = level;
    screenOBJ = newScreen;
    mouseListener = newScreen;
  }

  public void startGame() {
    onScreenChange();
    OnGaming newScreen = new OnGaming(this);
    screenOBJ = newScreen;
    keyListener = newScreen;
  }

  public void restartGame() {
    onScreenChange();
    GameStart newScreen = new GameStart(this);
    screenOBJ = newScreen;
    mouseListener = newScreen;
  }

  //--------------------------- private method ---------------------------

  private void onScreenChange() {
    screenOBJ = null;
    keyListener = null;
    mouseListener = null;
  }
}

//================================================================================================================
//================================================================================================================

abstract class DrawingOBJ {
  public int classID = ObjType.NOTHING;
  public int objWidth, objHeight;
  public int x, y;
  public int zOrder;
  protected PImage img = null;
  protected boolean isDrawSelf = true;

  public DrawingOBJ(int objWidth, int objHeight, PImage image, int classID) {
    this.objWidth = objWidth;
    this.objHeight = objHeight;
    this.classID = classID;
    img = image;
    x = 0;
    y = 0;
    zOrder = 0;
  }

  public void setIsDrawSelf(boolean isDrawSelf) {
    this.isDrawSelf = isDrawSelf;
  }

  public void drawFrame() {
    doGameLogic();
    SpecialDraw();
    if (isDrawSelf) {
      int half_height = objHeight>>1;
      int half_width = objWidth>>1;
      image(img, x - half_width, y - half_height);
    }
  }

  boolean isPointHitArea(int px, int py, int x, int y, int r, int b) {
    return ((px > x) && (px < r) && (py > y) && (py < b));
  }

  public boolean isHitOBJ(DrawingOBJ obj) {
    int xOffset = objWidth >> 1, yOffset = objHeight >> 1 ;
    int xOffset1 = obj.objWidth >> 1, yOffset1 = obj.objHeight >>1;
    int left = x - xOffset, right = x + xOffset;
    int top = y + yOffset, bottom = y - yOffset;
    int tl = obj.x - xOffset1, tr = obj.x + xOffset1;
    int tt = obj.y + yOffset1, tb = obj.y - yOffset1;
    if ((left< tr) && (right > tl)) {
      if ((bottom < tt)&&(top > tb)) {
        return true;
      }
    }
    return false;
  }

  public void drawStrokeText(String str, color textColor, color strokeColor, int textx, int texty, int strokeWidth) {
    fill(strokeColor);
    text(str, textx-strokeWidth, texty);
    text(str, textx+strokeWidth, texty);
    text(str, textx, texty-strokeWidth);
    text(str, textx, texty+strokeWidth);
    text(str, textx-strokeWidth, texty-strokeWidth);
    text(str, textx-strokeWidth, texty+strokeWidth);
    text(str, textx+strokeWidth, texty-strokeWidth);
    text(str, textx+strokeWidth, texty+strokeWidth);
    fill(textColor);
    text(str, textx, texty);
  }

  abstract public void SpecialDraw();
  abstract public void doGameLogic();
}

//================================================================================================================
//================================================================================================================

abstract class Screen extends DrawingOBJ {
  protected ScreenChangeListener listener;
  public Screen(PImage background, int objType, ScreenChangeListener listener) {
    super(0, 0, background, ObjType.BACKGROUND);
    this.listener = listener;
  }
}

//================================================================================================================
//================================================================================================================

class Fighter extends DrawingOBJ implements KeyPressListener {

  public int hp;
  public boolean healing;

  private ArrayList<Integer> xKeyStack, yKeyStack;                    // sequence of key pressed
  private int xKeyPressedTime=1, yKeyPressedTime=1;                   // how long did user pressed a key

  private color hpColor = #ffffff;
  private int healRange;
  public Fighter() {
    super(50, 50, resourcesManager.get(ResourcesManager.fighter), ObjType.FIGHTER);
    xKeyStack = new ArrayList();
    yKeyStack = new ArrayList();
    x = 600;
    y = 240;
    healing = false;
    healRange = 0;
  }

  public void setHP(int hp) {
    if (this.hp < hp) {
      healing = true;
    }
    this.hp = hp;
  }

  public void SpecialDraw() {
    float hpVal = hp;
    stroke(hpColor);
    fill(hpColor);
    ellipse(x, y, 45 + floor(hpVal/4f), 50);
    if (healing) {
      healRange +=10;
      ellipse(x, y, healRange, healRange);
      if (healRange >= 90) {
        healing = false;
      }
    } else if (healRange > 30) {
      healRange -= 5;
      ellipse(x, y, healRange, healRange);
    }
  }

  public void doGameLogic() {
    refreshKeyState();
    float hpVal = hp;
    if (hp>66) {
      int val = floor((hpVal - 66f) / 33f * 255f);
      hpColor = color(val, 255, val);
    } else if (hp>33) {
      int val = 255 - floor((hpVal - 33f) / 33f * 255f);
      hpColor = color(val, 255, 0);
    } else {
      int val = floor(hpVal / 33f * 255f);
      hpColor = color(255, val, 0);
    }
  }

  private void refreshKeyState() {
    if (xKeyStack.size()>0) {
      xKeyPressedTime ++;
      if (xKeyPressedTime>20) {
        xKeyPressedTime = 20;
      }
      switch(xKeyStack.get(xKeyStack.size()-1)) {
      case LEFT:
        x-=xKeyPressedTime>>1;
        break;
      case RIGHT:
        x+=xKeyPressedTime>>1;
      }
      int offset = objWidth >> 1;
      if (x < offset) {
        x = offset;
      } else if (x > (640 - offset)) {
        x = 640 - offset;
      }
    }
    if (yKeyStack.size()>0) {
      yKeyPressedTime ++; 
      if (yKeyPressedTime > 20) {
        yKeyPressedTime = 20;
      }
      switch(yKeyStack.get(yKeyStack.size()-1)) {
      case UP:
        y -= yKeyPressedTime >> 1;
        break;          
      case DOWN:
        y += yKeyPressedTime >> 1;
      }
      int offset = objHeight >> 1;
      if (y < offset) {
        y = offset;
      } else if (y > (480 - offset)) {
        y = 480 - offset;
      }
    }
  }

  /**
   * when key released
   */
  public void keyReleasedFun(int keyCode1) {
    if (keyCode1 == LEFT || keyCode1 == RIGHT) {
      xKeyPressedTime = 1;
      for (int i=0; i<xKeyStack.size(); i++) {
        if (xKeyStack.get(i)==keyCode1) {
          xKeyStack.remove(i);
          break;
        }
      }
    }
    if (keyCode1 == UP||keyCode1 == DOWN) {
      yKeyPressedTime = 1;
      for (int i=0; i<yKeyStack.size(); i++) {
        if (yKeyStack.get(i)==keyCode1) {
          yKeyStack.remove(i);
          break;
        }
      }
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int keyCode1) {
    if (keyCode1 == LEFT || keyCode1 == RIGHT) {
      if (xKeyStack.size()==0 || xKeyStack.get(xKeyStack.size()-1)-keyCode1 != 0) {
        xKeyStack.add(keyCode1);
      }
    }
    if (keyCode1 == UP||keyCode1 == DOWN) {
      if (yKeyStack.size()==0 || yKeyStack.get(yKeyStack.size()-1)-keyCode1 != 0) {
        yKeyStack.add(keyCode1);
      }
    }
  }
}

//================================================================================================================
//================================================================================================================

class Treasure extends DrawingOBJ {

  private Fighter target = null;
  private GameDataChanged listener;

  public Treasure(Fighter target, GameDataChanged listener) {
    super(40, 40, resourcesManager.get(ResourcesManager.treasure), ObjType.TREASURE);
    this.listener = listener;
    this.target = target;
    randomTreasure();
  }

  public void SpecialDraw() {
  }

  public void doGameLogic() {
    if (target != null) {
      if (isHitOBJ(target)) {
        if (listener != null) {
          listener.addHP(10);
        }
        randomTreasure();
      }
    }
  }

  /**
   * to random an treasure
   */
  public void randomTreasure() {
    // x is from 20 to 620
    // y is from 20 to 460
    do {
      x = floor(random(600)+20);
      y = floor(random(440)+20);
    } while (isHitOBJ(target));
  }
}

//================================================================================================================
//================================================================================================================

class Enemy extends DrawingOBJ {

  public int eSpeed;
  protected boolean isInTeam;
  private Fighter target = null;
  private Bullet[] bulletArray;
  private GameDataChanged listener;
  private float angle = 0;

  public Enemy(Bullet[] bulletArray, Fighter target, GameDataChanged listener, int level) {
    //super(60, 60, resourcesManager.get(ResourcesManager.enemy1), ObjType.ENEMY);
    super(60, 60, resourcesManager.get(ResourcesManager.enemy), ObjType.ENEMY);
    setIsDrawSelf(false);
    this.listener = listener;
    this.target = target;
    this.bulletArray = bulletArray;
    isInTeam = false;
    randomEnemy(true);
    eSpeed = floor(eSpeed * (level/50f+1));
  }

  public void SpecialDraw() {
    pushMatrix();
    int half_height = objHeight>>1;
    int half_width = objWidth>>1;
    translate(x, y );
    rotate(angle);
    image(super.img, -half_width, -half_height);
    popMatrix();
  }

  public void setIsInTeam(boolean isInTeam) {
    this.isInTeam = isInTeam;
    img =  resourcesManager.get(ResourcesManager.enemy);
  }

  public void doGameLogic() {
    angle = 0;
    if (x < -objWidth) {
      // wait 100 times, show warning and speed 
      float temp = (- objWidth - x);
      if (temp < 100) {
        int tSize = floor(20 * (1 - (- objWidth - x) / 100f) + 5);
        textAlign(LEFT);
        textSize(16);
        // draw different color with different speed
        if (eSpeed > 10) {
          // 10 - 20 yellow to red
          drawStrokeText("" + eSpeed, color(255, 255 - floor((eSpeed-10)/10f * 255), 0), #ffffff, 25, y+ 8, 1);
        } else {
          // 1 - 10 green to yellow
          drawStrokeText("" + eSpeed, color(floor((eSpeed)/10f * 255), 255, 0), #ffffff, 25, y+ 8, 1);
        }
        textSize(tSize);
        drawStrokeText("!", #ff0000, #ffffff, 10, y + (tSize >> 1), 1);
      }
      x += 1;
    } else {
      // normal moves
      x += eSpeed;
      if ((!isInTeam)&&(x<target.x)) {
        int yMove = (target.y-y)>>6;// (fightY-eY)/2^6 fast calculate
        if (yMove>10) {
          yMove =10;
        }
        y += yMove;
        angle = atan(float(yMove)/eSpeed);
      }
    }
    if (listener != null) {
      if (x>= 640) {
        listener.enemyMoveOut(this, false);
      }
    }
    if (this.isHitOBJ(target)) {
      if (listener != null) {
        listener.subHP(20, this);
        listener.enemyMoveOut(this, false);
      }
    }
    if (bulletArray!=null) {
      for (int i=0; i<5; i++) {
        Bullet target = bulletArray[i];
        if (target.isHitOBJ(this)) {
          listener.enemyMoveOut(this, true);
          target.setDisabled();
          break;
        }
      }
    }
  }

  private void randomEnemy(boolean isAvoidFighter) {
    x = -100 - objWidth;
    eSpeed = floor(random(1, 5));
    do {
      y = floor(random(0, 450));
      // if need avoid fighter and enemy is in fighter line then random again
    } while (isAvoidFighter && isInTargetLine(target));
  }

  private boolean isInTargetLine(Fighter obj) {
    int yOffset = objHeight >> 1 ;
    int yOffset1 = obj.objHeight >>1;
    int top = y + yOffset, bottom = y - yOffset;
    int tt = obj.y + yOffset1, tb = obj.y - yOffset1;
    if ((bottom < tt)&&(top > tb)) {
      return true;
    }
    return false;
  }
}

//================================================================================================================
//================================================================================================================

class GameTitle extends DrawingOBJ {

  public int hp = 0, level = 0;

  public GameTitle() {
    super(0, 0, resourcesManager.get(ResourcesManager.hp), ObjType.TITLE);
    x = 10;
    y = 10;
  }

  public void SpecialDraw() {
    textSize(15);
    textAlign(CENTER);
    drawStrokeText(hp + "", #ffffff, #000000, x + 112, y + 17, 1);
    drawLV();
  }

  public void doGameLogic() {
    if (hp< 0 ) {
      hp = 0;
    } else if (hp>100) {
      hp = 100;
    }
    color hpColor ;
    float hpVal = hp;
    int curhp = floor(194f * hp / 100f);
    if (hp > 50) {
      int val = 255 - floor((hpVal - 50f) / 50f * 255f);
      hpColor = color(val, 255, 0);
    } else {
      int val = floor(hpVal / 50f * 255f);
      hpColor = color(255, val, 0);
    }
    drawHPBar(hpColor, curhp);
  }

  private void drawHPBar(color barColor, int barWidth) {
    stroke(barColor);
    fill(barColor);
    rect( x + 12, y + 4, barWidth, 16);
  }

  /**
   * to draw the value of level
   */
  private void drawLV() {
    textSize(15);
    textAlign(RIGHT);
    drawStrokeText("Level:"+level, #ffffff, #000000, 620, 20, 1);
  }
}


//================================================================================================================
//================================================================================================================

class Explode extends DrawingOBJ {

  private PImage[] expArray;
  private int timer, shownID;
  private GameDataChanged listener;
  private DrawingOBJ targetOBJ;

  public Explode(GameDataChanged listener, int startID) {
    super(81, 81, null, ObjType.TITLE);
    this.listener = listener;
    setIsDrawSelf(false);
    expArray = new PImage[5];
    for (int i = 0; i<5; i++) {
      expArray[i] = resourcesManager.get(startID + i);
    }
    timer = 0;
    shownID = -1;
  }

  public void bindingOBJ(DrawingOBJ target) {
    targetOBJ = target;
    x = target.x;
    y = target.y;
  }

  public void SpecialDraw() {
    if (shownID<5) {
      image(expArray[shownID], x-(objWidth>>1), y-(objHeight>>1));
    } else if (listener != null) {
      listener.explodeFinished(this);
    }
  }

  public void doGameLogic() {
    if (timer == 0 ) {
      timer = millis();
    }
    shownID = floor((millis() - timer)/100);
    if (targetOBJ != null) {
      if (targetOBJ.classID == ObjType.FIGHTER) {
        x = targetOBJ.x;
        y= targetOBJ.y;
      } else if (targetOBJ.classID == ObjType.ENEMY) {
        Enemy temp =(Enemy)targetOBJ; 
        x+= temp.eSpeed;
      }
    }
  }
}

//================================================================================================================
//================================================================================================================

class Bullet extends DrawingOBJ {

  private boolean isEnabled;
  private int speed = 12;
  private DrawingOBJ target;

  public Bullet(DrawingOBJ target) {
    super(31, 27, resourcesManager.get(ResourcesManager.bullet), ObjType.BULLET);
    this.target = target;
    isEnabled = false;
  }

  public boolean shoot() {
    if (isEnabled) {
      return false;
    } else {
      isEnabled = true;
      x = target.x;
      y = target.y;
    }
    return true;
  }

  public void SpecialDraw() {
  }

  public void doGameLogic() {
    if (isEnabled) {
      x -= speed;
    }
    isEnabled = (x>-objWidth);
    setIsDrawSelf(isEnabled);
  }

  public void setDisabled() {
    isEnabled = false;
    x = -1-objWidth;
  }

  public boolean isHitOBJ(DrawingOBJ obj) {
    return (isEnabled && (super.isHitOBJ(obj)));
  }
}

//================================================================================================================
//================================================================================================================

class OnGaming extends Screen implements KeyPressListener, GameDataChanged {

  private final int SHOOT_DELAY = 70;

  public int level, hp;
  private long lastShootTime;
  private int bg2x = 640, speed = 5, teamCnt, teamId, listChangeCnt;
  private boolean fighting, added;
  private ArrayList<DrawingOBJ>  drawingArray;
  private Fighter fighter = null;
  private GameTitle title = null;
  private Bullet[] bulletArray;

  public OnGaming(ScreenChangeListener listener) {
    super(resourcesManager.get(ResourcesManager.bg1), ObjType.BACKGROUND, listener);
    fighting = false;
    drawingArray = new ArrayList();

    hp = 20;
    level = 0;
    teamId = 0;
    listChangeCnt = 0;
    lastShootTime = 0;

    fighter = new Fighter();
    fighter.setHP(hp) ;
    fighter.zOrder = 2;

    drawingArray.add(fighter);

    title = new GameTitle();
    title.hp = hp;
    title.zOrder = 4;
    drawingArray.add(title);

    Treasure t = new Treasure(fighter, this);
    t.zOrder = 3;
    drawingArray.add(t);

    bulletArray = new Bullet[5];
    for (int i = 0; i < 5; i++) {
      Bullet temp = new Bullet(fighter);
      temp.zOrder = 1;
      bulletArray[i]= temp;
      drawingArray.add(temp);
    }

    randomTeam();
  }

  public void SpecialDraw() {
    for (int i = 0; i < drawingArray.size(); i++) {
      for (int j = i+1; j < drawingArray.size(); j++) {
        if (drawingArray.get(i).zOrder > drawingArray.get(j).zOrder) {
          DrawingOBJ temp = drawingArray.get(i);
          drawingArray.set(i, drawingArray.get(j));
          drawingArray.set(j, temp);
        }
      }
    }
    for (int i = 0; (i < drawingArray.size()) && (i>-1); i++) {
      drawingArray.get(i).drawFrame();
      if (listChangeCnt>0) {
        i -= listChangeCnt;
        listChangeCnt = 0;
      }
    }
  }

  public void doGameLogic() {
    doBackgroundLogic();
    boolean isSpealLevel = (level%20 == 0);
    if ((level>0)&&(isSpealLevel)&&(!added)) {
      added = true;
      drawingArray.add(new Enemy(bulletArray, fighter, this, level));
    } else if (added&&(!isSpealLevel)) {
      added = false;
    }
    if (hp <= 0) {
      listener.endGame(level);
    }
    if (fighting) {
      boolean isShoot =false;
      long timeErr = millis() - lastShootTime;
      for (int i=0; ((i<5) &&(timeErr>SHOOT_DELAY)); i++) {
        isShoot = bulletArray[i].shoot();
        if (isShoot) {
          lastShootTime = millis();
          break;
        }
      }
    }
  }

  private void addEnemyInTeam(int x_offset, int y, int speed) {
    Enemy newEnemy = new Enemy(bulletArray, fighter, this, level);
    newEnemy.x = newEnemy.x - x_offset;
    newEnemy.y = y;
    newEnemy.eSpeed = speed;
    newEnemy.setIsInTeam(true);
    drawingArray.add(newEnemy);
  }

  private void randomTeam() {
    int yy;
    int s = floor(random(1, 5) * (level/50f+1));
    if (teamId==0) {
      yy= floor(random(420)+30);
      teamCnt = 5;
      for (int i =0; i<teamCnt; i++) {
        addEnemyInTeam(60*i/s, yy, s);
      }
    } else if (teamId==1) {
      yy= floor(random(220)+30);
      teamCnt = 5;
      for (int i =0; i<teamCnt; i++) {
        addEnemyInTeam(60*i/s, yy+50*i, s);
      }
    } else {
      yy= floor(random(220)+130);
      teamCnt = 8;
      addEnemyInTeam(0, yy, s);
      addEnemyInTeam(60/s, yy-50, s);
      addEnemyInTeam(60/s, yy+50, s);
      addEnemyInTeam(120/s, yy-100, s);
      addEnemyInTeam(120/s, yy+100, s);
      addEnemyInTeam(180/s, yy-50, s);
      addEnemyInTeam(180/s, yy+50, s);
      addEnemyInTeam(240/s, yy, s);
    }
    teamId++;
    if (teamId>2) {
      teamId = 0;
    }
  }

  private void doBackgroundLogic() {
    x = moveBG(x);
    bg2x = moveBG(bg2x);
    image(resourcesManager.get(ResourcesManager.bg2), bg2x, y);
  }

  private int moveBG(int curX) {
    // the more level the more quick background moves
    int speedOffset = level/10;
    int maxOffset = speed<<1;
    if (speedOffset> maxOffset) {
      speedOffset = maxOffset;
    }
    curX +=640 + speed + speedOffset;
    curX %= 1280;
    curX -= 640;
    return curX;
  }


  /**
   * when key released
   */
  public void keyReleasedFun(int keyCode1) {
    fighter.keyReleasedFun(keyCode1);
    if (keyCode1 == 32) {
      fighting = false;
    }
  }

  /**
   * when key pressed
   */
  public void keyPressedFun(int keyCode1) {
    fighter.keyPressedFun(keyCode1);
    if (keyCode1 == 32) {
      fighting = true;
    }
  }


  public void addHP(int val) {
    hp += val;
    level++;
    if (hp > 100) {
      hp = 100;
    }
    syncInfo();
  }

  public void subHP(int val, DrawingOBJ target) {
    hp -= val;
    if (hp < 0) {
      hp = 0;
    }

    Explode explode = new Explode(this, ResourcesManager.explode);
    explode.bindingOBJ(fighter);
    explode.zOrder = 3;
    drawingArray.add(explode);

    syncInfo();
  }

  public void explodeFinished(Explode target) {
    drawingArray.remove(target);
    listChangeCnt ++;
    target = null;
  }

  public void enemyMoveOut(Enemy target, boolean showExplode) {
    drawingArray.remove(target);
    if (target.isInTeam) {
      if (--teamCnt==0) {
        randomTeam();
      }
    }
    if (showExplode) {
      Explode explode = new Explode(this, ResourcesManager.explode);
      explode.bindingOBJ(target);
      explode.zOrder = 3;
      drawingArray.add(explode);
    }

    listChangeCnt ++;
    if (!target.isInTeam) {    
      drawingArray.add(new Enemy(bulletArray, fighter, this, level));
    }
    target = null;
  }

  public void drawFrame() {
    doGameLogic();
    int half_height = objHeight>>1;
    int half_width = objWidth>>1;
    image(super.img, x - half_width, y - half_height);    
    SpecialDraw();
  }

  private void syncInfo() {
    title.hp = hp;
    title.level= level;
    fighter.setHP(hp);
  }
}

//================================================================================================================
//================================================================================================================

class GameStart extends Screen implements MouseListener {

  private boolean isOnButton, isPressButton;
  private int alpha, alpha_offset ;

  public GameStart(ScreenChangeListener listener) {
    super(resourcesManager.get(ResourcesManager.st2), ObjType.TITLE, listener);
    alpha_offset = 10;
    alpha = 0;
  }

  public void SpecialDraw() {
    if (isOnButton && (! isPressButton)) {
      image(img, x, y);
      tint(255, alpha);
      image(resourcesManager.get(ResourcesManager.st1), 0, 0);
      tint(255, 255);
      alpha += alpha_offset;
      if (alpha>255) {
        alpha = 255;
        alpha_offset = -alpha_offset;
      } else if (alpha<100) {
        alpha = 100;
        alpha_offset = -alpha_offset;
      }
    }
  }

  public void doGameLogic() {
    setIsDrawSelf((!isOnButton) ||isPressButton);
  }


  public void mouseReleasedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = false;
      if (isOnButton && listener != null) {
        listener.startGame();
      }
    }
  }
  public void mousePressedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = true;
    }
  }
  public void mouseMovedFun(int x, int y) {
    boolean newBool = isPointHitArea(x, y, 210, 380, 450, 410);
    if (newBool!=isOnButton) {
      alpha_offset = 10;
      alpha = 0;
    }
    isOnButton =  newBool;
  }
}

//================================================================================================================
//================================================================================================================

class GameEnd extends Screen implements MouseListener {

  public int level = 0;
  private boolean isOnButton, isPressButton;
  private int alpha, alpha_offset ;

  public GameEnd(ScreenChangeListener listener) {
    super(resourcesManager.get(ResourcesManager.end2), ObjType.TITLE, listener);
    isOnButton = false;
    isPressButton = false;
  }

  public void SpecialDraw() {
    if (isOnButton && (! isPressButton)) {
      image(img, x, y);
      tint(255, alpha);
      image(resourcesManager.get(ResourcesManager.end1), 0, 0);
      tint(255, 255);
      alpha += alpha_offset;
      if (alpha>255) {
        alpha = 255;
        alpha_offset = -alpha_offset;
      } else if (alpha<100) {
        alpha = 100;
        alpha_offset = -alpha_offset;
      }
    }
    textAlign(CENTER);
    textSize(30);
    drawStrokeText("Final Level:"+level, #ffffff, #ff0000, 320, 220, 2);
  }

  public void doGameLogic() {
    setIsDrawSelf((!isOnButton) ||isPressButton);
  }

  public void drawFrame() {
    doGameLogic();
    image(resourcesManager.get(ResourcesManager.end2), 0, 0);
    SpecialDraw();
  }

  public void mouseReleasedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = false;
      if (isOnButton && listener != null) {
        listener.restartGame();
      }
    }
  }
  public void mousePressedFun(int keyCode1) {
    if (keyCode1 == MOUSE_LEFT) {
      isPressButton = true;
    }
  }
  public void mouseMovedFun(int x, int y) {
    boolean newBool = isPointHitArea(x, y, 210, 310, 435, 345);
    if (newBool!=isOnButton) {
      alpha_offset = 10;
      alpha = 0;
    }
    isOnButton =  newBool;
  }
}
