$fa=1;

module umlenkrolle() {
import("/home/jorschiedt/Development/3D-Print/Thingiverse/filament_return_pulley_for_Vellemann_Vertex_3D_Delta_K8800/files/filamentumlenker-rolle.stl");
}

module fuss() {
    difference() {
    cylinder(d1=45,d2=33,2,h=5);
    translate([0,0,3.5]) cylinder(d1=33.2,d2=33.2,h=1.5);
//    translate([0,0,0]) cylinder(d1=22,d2=22,h=5);
    translate([0,0,0]) cylinder(d1=28,d2=22,h=3.5);
    
    }
}

fuss();
// translate([0,0,3.5]) umlenkrolle();

