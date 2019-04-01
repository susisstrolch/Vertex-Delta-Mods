$fn=64;

difference() {
union() {
cylinder(d=8,h=4);
translate([0,0,4])
    cylinder(d=14,h=3);
}


translate([0,0,-0.1])
linear_extrude(height=10.0)
hull() {
translate([-1.5,0,0])
circle(d=5.2);
translate([1.5,0,0])
circle(d=5.2);
}
}