include <nutsnbolts/cyl_head_bolt.scad>

$fn=64;

module pulley_2d_block() {
    circle(r=10);
    translate([0,-10,0])
    square([23,20]);   
}

module pulley_2d_punch() {
    translate([10,00,10])
    hull() {
    translate([-1.35,0,0])
        circle(r=5);
    translate([ 1.35,0,0])
        circle(r=5);
    translate([-6.35,0,0])
       square([12.7,18.5]);
    }
}

difference() {
translate([0,0,23])
rotate([0,90,0])
color("red")
linear_extrude(height=25.25)
    pulley_2d_block();

translate([0,10,15])
  rotate([90,00,0])
    color("blue")
    linear_extrude(height=20)
        pulley_2d_punch();

// pulley wheel
    translate([0,0,23])
        rotate([0,-90,0])    
            screw(
                name="M5x25",
                thread="no");
     translate([21,0,23])
        rotate([0,-90,0])    
            nutcatch_parallel(
                name="M5",
                l=5.0,
                clk=0.2);
                
// pulley pull up
    translate([10,0,50])
        rotate([0,0,0])    
            screw(
                name="M5x50",
                thread="no");
     translate([10,0,13])
        rotate([0,0,90])    
            nutcatch_parallel(
                name="M5",
                l=8,
                clk=0.2);
                
}

