module default() 
{
    import("/home/jorschiedt/Development/3D-Print/Thingiverse/Velleman_K8800_Delta_LM10UU_Linear_Bearing_Upgrade/files/K8800-VS-LM10UU-v1.1.stl");
}

module bonus() {
    import("/home/jorschiedt/Development/3D-Print/Thingiverse/Velleman_K8800_Delta_LM10UU_Linear_Bearing_Upgrade/files/K8800-VS-LM10UU-v1.1-bonus.stl");

}

module actuator() {
    import("/home/jorschiedt/Development/3D-Print/Thingiverse/Velleman_K8800_Delta_LM10UU_Linear_Bearing_Upgrade/files/K8800-VS-LM10UU-v1.1-actuator.stl");
    
}

color("blue") union() {
translate([-10,0,0]) 
    rotate([0,180,180])
        default();
translate([-17,0,-7]) 
    rotate([-90,0,90])
        actuator();
}

color("red") union() {
translate([+10,0,0]) 
    rotate([0,180,0])
        bonus();
translate([25,0,-7]) 
    rotate([-90,0,90])
        actuator();

}

