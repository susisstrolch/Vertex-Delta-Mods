%//color("blue")
rotate(180,[0,1,0])
translate([99.5,103.5,5.0])
import("C:/Users/chuebsch/Documents/3d/filamentumlenker-v2.stl");


module cyl(di,do,h,slope=20){
    y=abs(di-do);
    d0=max(di,do);
    union(){
    for (i=[0:h-1]){
        translate([0,0,i])cylinder(
        d1=d0-y*sin(i/h*180)+slope-i/h*slope,
        d2=d0-y*sin((i+1)/h*180)+slope-(1+i)/h*slope,h=1);
        }
    }
    }
$fn=120;
difference(){
    cyl(di=33,do=23,h=55);
    //cylinder($fn=100,d=23,h=19);
    translate([0,0,-0.1])
    cylinder(d=22.05,h=11.4);
    translate([0,0,22.1])
    cylinder(d=22.05,h=48.1);
    cylinder(d=8.5,h=28.1);
    scale([50,50,15])sphere(d=1);
}