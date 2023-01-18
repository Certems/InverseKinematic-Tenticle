tenticle t1;

void setup(){
    fullScreen();
    t1 = new tenticle( new PVector(width/2.0, height/2.0), 16, 300.0, -PI/2.0 );
}
void draw(){
    clear();
    background(60,60,60);

    t1.display();
    t1.calcMovement();
    t1.calcTenticleSway(0, 1.0, 3.0);

    println("---");
    text(frameRate, 30,30);
}
void keyPressed(){
    if(key == '1'){
        t1.moveMarker = new PVector(mouseX, mouseY);
    }
}
void mousePressed(){
    t1.moveMarker = new PVector(mouseX, mouseY);
}


class tenticle{
    ArrayList<node> nodes = new ArrayList<node>();

    PVector moveMarker;
    PVector orig;

    int n;

    float l;
    float lSeg;

    int sTimer = 0;

    tenticle(PVector origin, int nodeNumber, float length, float startingAngle){
        orig = origin;
        n    = nodeNumber;
        l    = length;
        lSeg = length / (nodeNumber-1);
        createNodes(nodeNumber, origin, startingAngle);
    }

    void display(){
        //displayConnected();
        displayNodes();
        displayMoveMarker();
    }
    void displayConnected(){
        pushStyle();

        float strokeVal   = 60.0;
        float strokeMulti = 0.85;

        noFill();
        stroke(200,200,200);

        beginShape();
        curveVertex(nodes.get(0).pos.x, nodes.get(0).pos.y);
        for(int i=0; i<nodes.size(); i++){
            strokeWeight(strokeVal);
            curveVertex(nodes.get(i).pos.x, nodes.get(i).pos.y);
            strokeVal *= strokeMulti;
        }
        curveVertex(nodes.get(nodes.size()-1).pos.x, nodes.get(nodes.size()-1).pos.y);
        //strokeWeight(-10);
        endShape();

        popStyle();
    }
    void displayNodes(){
        for(int i=0; i<nodes.size(); i++){
            nodes.get(i).display();
        }
    }
    void displayMoveMarker(){
        pushStyle();

        fill(255,100,200);
        stroke(0);
        strokeWeight(1);
        ellipse(moveMarker.x, moveMarker.y, 10.0, 10.0);

        popStyle();
    }
    void calcMovement(){
        //IK from end to start
        for(int i=nodes.size()-1; i>=0; i--){
            if(i == nodes.size()-1){
                nodes.get(i).pos = moveAtoBlerp(nodes.get(i).pos, moveMarker);}
            else if(i != 0){
                nodes.get(i).pos = moveAtoB(nodes.get(i).pos, nodes.get(i+1).pos, lSeg);
            }
            else{
                nodes.get(i).pos.set(orig.x, orig.y);}
        }
        //IK from start to end
        for(int i=1; i<nodes.size(); i++){
            nodes.get(i).pos = moveAtoB(nodes.get(i).pos, nodes.get(i-1).pos, lSeg);
        }
    }
    void calcTenticleSway(float tSrtTheta, float swayAmp, float freqFac){
        /*
        Sinusoidually sways the tenticle
        */
        for(int i=1; i<nodes.size(); i++){
            float tOffset = 2.0*PI / nodes.size();
            float sineVal = sin( (2.0*PI)*(sTimer/(60.0*freqFac)) + tOffset*i + tSrtTheta );
            PVector uPerpVec = normaliseVec( new PVector( -dirVec(nodes.get(i).pos,nodes.get(i-1).pos).y, dirVec(nodes.get(i).pos,nodes.get(i-1).pos).x ) );
            nodes.get(i).pos.x += swayAmp*uPerpVec.x*sineVal;
            nodes.get(i).pos.y += swayAmp*uPerpVec.y*sineVal;
        }
        sTimer++;
    }
    void createNodes(int n, PVector orig, float ang){
        PVector vWalk = new PVector(0,0);
        PVector newPos;
        for(int i=0; i<n; i++){
            if(i == 0){
                newPos = new PVector(orig.x, orig.y);}
            else{
                newPos = new PVector( nodes.get(nodes.size()-1).pos.x, nodes.get(nodes.size()-1).pos.y );}
            node newNode = new node( new PVector(newPos.x +vWalk.x, newPos.y +vWalk.y) );
            nodes.add(newNode);

            float rTheta = random(0,PI/8.0);
            vWalk.set(cos(ang+rTheta)*lSeg, sin(ang+rTheta)*lSeg);
        }
        moveMarker = new PVector( nodes.get(nodes.size()-1).pos.x, nodes.get(nodes.size()-1).pos.y );
    }
}
class node{
    PVector pos;

    node(PVector position){
        pos = position;
    }

    void display(){
        println("NodePos -> ",pos);
        pushStyle();

        noFill();
        stroke(255);
        strokeWeight(1);
        ellipse(pos.x, pos.y, 10.0, 10.0);

        popStyle();
    }
}


PVector moveAtoB(PVector a, PVector b, float separation){
    float dist   = vecDist(a,b);
    PVector uDir = normaliseVec( dirVec(a,b) );
    PVector change = new PVector((dist-separation)*uDir.x, (dist-separation)*uDir.y);
    PVector newVec = new PVector(a.x +change.x, a.y +change.y);
    return newVec;
}
PVector moveAtoBlerp(PVector a, PVector b){
    float speed = 2.0;
    float threshold = speed*5.0;
    float dist   = vecDist(a,b);
    if(dist < threshold){
        speed = 0;}
    PVector uDir = normaliseVec( dirVec(a,b) );
    PVector change = new PVector(speed*uDir.x, speed*uDir.y);
    PVector newVec = new PVector(a.x +change.x, a.y +change.y);
    return newVec;
}


float vecMag(PVector v){
    float mag = sqrt( pow(v.x,2) + pow(v.y,2) );
    return mag;
}
float vecDist(PVector v1, PVector v2){
    float dist = sqrt( pow(v1.x-v2.x,2) + pow(v1.y-v2.y,2) );
    return dist;
}
PVector dirVec(PVector v1, PVector v2){
    /*
    FROM v1 TO v2
    */
    PVector newVec = new PVector(v2.x - v1.x, v2.y - v1.y);
    return newVec;
}
PVector normaliseVec(PVector v){
    float mag = vecMag(v);
    PVector newVec;
    if(mag == 0){
        newVec = new PVector(0,0);}
    else{
        newVec = new PVector(v.x /mag, v.y /mag);}
    return newVec;
}