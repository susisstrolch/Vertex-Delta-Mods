//color("green")import("K8800-TAP.stl");
difference(){
    union(){
        hull(){
        color("blue")rotate(120)translate([-45,123,-5])cube([70,30,3]);
            color("red")rotate(120)translate([-40.0,153,-5])cylinder($fn=100,d=24,h=3);
        }
        hull(){
        color("red")rotate(120)translate([-52,123,-5])cube([25,30,3]);
        color("red")rotate(120)translate([-40.0,138,-10])cylinder($fn=100,d=8,h=8);
    }
    
        
    rotate(120)translate([-40.0,138,-35.49])cylinder($fn=100,d=7.9,h=30);
    rotate(120)translate([-40.0,138,-36.49])cylinder($fn=100,d2=7.9, d1=7,h=1);
        //}
    }
    rotate(120)translate([18.0,145.7,-5.5])cylinder($fn=100,d=4.5,h=11);
    rotate(120)translate([-18.0,145.7,-5.5])cylinder($fn=100,d=4.5,h=11);
    rotate(120)translate([18.0,145.7,-5.5])cylinder($fn=100,d1=9,d2=4.5,h=2);
    rotate(120)translate([-18.0,145.7,-5.5])cylinder($fn=100,d1=9,d2=4.5,h=2);
}


