include <arc.scad>;

r0 = 170/2;     // inner diameter for piezos
r1 = 220/2;     // outer diameter for heatbed

wh=15;          // width heatbed support
wp=(r1 - r0);   // width piezo support
dia=10;         // dia heatbreak hole

height=4;       // height of pertinax plate

angle=30;
$fn=64;

module BP() {
import( "/home/jorschiedt/Development/3D-Print/Velleman/Vertex-Delta-CAD/K8800-BP/K8800-BP.stl");
}

module segment(x=0,y=0,w=wh,r=r0) {
        difference() {
            color("blue")
            arc(r+x,w,angle,$fn=128);
            color("red")
            translate([r+x+w-4,0,0])
                circle(d=3,$fn=64);
    }
}

module hole(x=0, y=0,d=dia) {
    translate([x, y, 0])
        circle(d=d);
}

module holes() {
    w = wh/2;   // center heatbed support
    o = r0 + w;

    linear_extrude(height=height){
        hole(x=0, y=o+2,d=8);
        hole(x=-10,y=o+6); 
        hole(x=10,y=o+6);
        hole(x=-19,y=o+1); 
        hole(x=19,y=o+1);
    }
}

module support(
    h=height,
    w=wp,
    x=r1, xs=0,
    color="blue") {
    color(color)
    rotate([0,0,90])
        translate([x,0,0])
          linear_extrude(height=h){
            translate([-x,0,0])
              segment(x=xs,y=0,w=w);
          }
}

module support_HB() {
    difference() {
        support(color="red", 
            h=height, w=wh, x=0, xs=5);
        holes();
    }
}

module support_BP() {
    support(color="firebrick", 
        h=height, w=wp+5, x=r1, xs=-10);
}

// the piezo support
* support_BP();

// simple template, side by side
*translate([0,-40,0])
    support_HB();

// the headbed support
translate([0,0,4])
    support_HB();
