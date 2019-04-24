$fa=0.1;
$fs=0.1;

// mounting hole
d1=10.0;
// diameter top washer
d2=14.0;

// diameter holding screw
dh=5.2;     
cr=d1/2 - dh/2 - 0.1;

difference() {
  union() {
    cylinder(d=d1,h=5);
    cylinder(d=d2,h=2);
  }


  translate([0,0,-0.1])
  linear_extrude(height=10.0)
    hull() {
      translate([-cr,0,0])
        circle(d=dh);
      translate([cr,0,0])
        circle(d=dh);
  }
}