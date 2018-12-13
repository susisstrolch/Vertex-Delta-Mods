//
//  Velleman K8800 Carriage Alterations to fit LM1000 linear bearings.
//
//  Copyright (c) 2018 Christopher Phillips.
//  Distibuted under the Creative Commons license.
//
// These bearings are not as tall as the original bushings, so it is possible
// to gain up to 5mm of bonus Z-Axis travel.  set (bonus = 0) to preserve the
// stock height of the original part.

// fence for inner punches (>= layer heigth)
guard = 0.2;        

// EMBEDED=0, LM10UU=1, RJ4JP=2, RJUM1=3
bearing_type = 3;

// endstop heigth above carriage
endstop = 10;

// enable/disable bearing brim
enable_brim = 1;

// Bonus height?  0 to disable
bonus = 5;

// the following parameters are not changeable via Customizer...
module dont_show_in_customizer() {
}

$fn = 64;

// supported bearing types
EMBEDED= 0;     // embedded bearing 
LM10UU = 1;     // Metric Linear Bearing, steal
RJ4JP  = 2;     // drylin self-lubricating polymer
RJUM1  = 3;     // drylin self-lubricating polymer, alu shell

rod_dist  = 60;     // distance between center of slides
rod_dist2 = rod_dist / 2; 

horn_xy = 10;
horn_z = 7;
horn_d = 10;

nozzle_d = 0.35;    // K8800 default nozzle

// extrusion control - read the source, Luke
slop = 0;
slug_dh = 10;
slug_slop = 0.5;

// endstop definitions
// the endstop consists of two parts:
// - endstop_base - the overall height of the part inserted into the carrier
//                  default: 10mm, bonus: 15.0mm
//                  the base is made of a cylinder (triangle) and the tab cube
// - endstop_tab  - the tab above the carrier
endstop_base_knob = 5;      // diameter of endstop knob
endstop_base_l    = 10;     // overall length of endstop base inside carriage

endstop_tab_l = endstop;    // height above carrier
endstop_tab_w = 2.5;        // width of the tab (must fit into the IR sensor)   
endstop_tab_h = endstop_base_l + endstop;   // overall height of endstop tab
endstop_tab_offset = 0.5;         // offset for punching the endstop slot


endstop_toe_w = 3.3;    // 
endstop_toe_h = 5;

// nuts and bolds
bolt_a = 5.5;
bolt_b = 5.3;
nut = 10;//9.64;

// zip-tie 
tie_l = 20;      // Length of tie-wrap
tie_w = 1.5;     // tie-wrap slot width
tie_h = 3;       // tie-wrap slot height
tie_toe = 30;    // tie-wrap toe-in angle

// option: top and bottom brim to keep bearing in carriage
bearing_bb = enable_brim ? 3 * nozzle_d : 0;  // bottom brim heigth
bearing_tb = bearing_bb;    // top brim heigth

// bearing related dimensions
bearing_L  = 29.0;  // length of bearing
bearing_dr = 10.0;  // inner diameter (shaft)
bearing_D  = 19.0;  // outer diameter

// type specific dimensions (RJ4JP and LM10UU are identical)
bearing_B = (bearing_type==RJUM1) ? 21.6 : 22.0;   // spacing of the circlip grooves (top to bottom)
bearing_W = (bearing_type==RJUM1) ?  1.3 : 1.3;    // circlip groove width
bearing_D1= (bearing_type==RJUM1) ? 17.5 : 18.0;   // slot (groove) diameter

// computed dimensions 
bearing_h0 = (bearing_L - bearing_B) / 2;   // height of start of circlip groove
bearing_h1 = bearing_h0 + bearing_W;        // height of end of circlip grooves

L_shaft = 3.0;  // (save) length of punch through shaft for bearing top/bottom

// carriage_h = 30;    // carriage height

carriage_h = (1 + bearing_L) + bearing_bb + bearing_tb;

echo("carriage heigth:", carriage_h);

// punch mask for bearing
// the model is used as punching mask for the carrier, so we have
// to do some failsafe calculation to fit the real one into the carriage

module bearing_2D(offset=0) {
    // 2D drawing of the bearing, according to datasheet
    // we use a polygon to create the positive X of the outline
    O=offset;    // x/y offset for later offset function...
    xR=bearing_D/2; xR1=bearing_D1/2;
    h0=bearing_h0; W=bearing_W; B=bearing_B; L=bearing_L;
    outline=[
        [O,O], [O+xR,O],
        [O+xR,O+h0], [O+xR1,O+h0],
        [O+xR1,O+h0+W], [O+xR,O+h0+W],
        [O+xR,O+h0+B-W], [O+xR1,O+h0+B-W],
        [O+xR1,O+h0+B], [O+xR,O+h0+B],
        [O+xR,O+L], [O,O+L],
        [O,O]
    ];
    polygon(points=outline);
}

// bearing model - for completeness/debugging  only - not explicitly used
module bearing_3D() {
    $fn=90;
    difference(){
        color("green")
        translate([0,0,0])
            rotate_extrude($fn = 90)
                bearing_2D(0);
        // cut out for rod
        color("red")
            cylinder(d=bearing_dr, h=bearing_L+guard*2);
    }
}

// bearing with 'guard' offset for use in punchmask
module bearing_punch() {
    // offset(delta=guard) is used because of possible over-extrusion
    $fn=90;
    color("green")
    translate([0,0,0])
        rotate_extrude($fn = 90)
            offset(delta=guard)    // extend shape by delta
                bearing_2D(guard); // offset from delta
    // object is at [0,0,0]. Because of offset(xxx) effective
    //   zMax = bearing_L + 2* guard, D=bearing_D + 2* guard
}

module bearing_punchmask() {
    // a) The punchmask diameter is 'D' as extended in module bearing_punch()
    //    'guard'. That's because of the filament expansion during 
    //    extrusion.
    // b) We add a shaft to punch through the carriage.
    //    For 'enable_brim'==1 the shaft diameter is 'bearing_D' - 2.0mm.
    //    Otherwise we use the punchmask diameter for the shaft.

    L_punch = bearing_L + 2*guard;    // bearing_punch heigth
    D_punch = bearing_D + 2*guard;    // bearing_punch diameter
    D_shaft = enable_brim ? D_punch - 2.0  : D_punch;    // space for rod...
    
    union() {
        // punch through shaft
        translate([0,0,0])
            cylinder(d=D_shaft, h=L_punch + 2* L_shaft);
     
        // the bearing (+guard) itself
        translate([0,0,L_shaft])
                bearing_punch();
    }
    // zMax = bearing_L + 2* guard + 2* L_shaft
}

module lm10UU()
{
    union()
    {
        bearing_punchmask();
        // Tie-wraps
        // Lower
        color("black")
        {
        rotate([0,0,tie_toe])
            translate([-tie_l,(-tie_w+bearing_D1)/2,L_shaft + bearing_h0 -.5])
              cube([tie_l,tie_w,tie_h]);
        rotate([0,0,-tie_toe])
            translate([-tie_l,(-tie_w-bearing_D1)/2,L_shaft + bearing_h0 -.5])
              cube([tie_l,tie_w,tie_h]);
        // Upper
        rotate([0,0,tie_toe])
            translate([-tie_l,(-tie_w+bearing_D1)/2,L_shaft + bearing_L-bearing_h1-.5])
              cube([tie_l,tie_w,tie_h]);
        rotate([0,0,-tie_toe])
            translate([-tie_l,(-tie_w-bearing_D1)/2,L_shaft + bearing_L-bearing_h1-.5])
              cube([tie_l,tie_w,tie_h]);
        }        
    }
}


// development - import Velleman CAD object
//
module belt_catch() {
// measured dimensions of the "belt catch"
//  bounding box:   X=16.5, Y=36
//  center of bb:   X=8.25, Y=18.0
//  mounting hole:  X=5, Y=18, D=5.5
//  off be1t fetch: X=13.1 (12.75/13.5)
//  nose:           X=5, Y=30.5
//                  D=3.5
//  corners (left): r=3.0
//      x0,y0:      3.0, 3.0
//      x0,yMax:    3.0, 33.0

    import("/bay/Development/3D-Print/Vertex-Delta-CAD/K8800-BC/K8800-BC.stl");
}


module connector_block_2d() {
}

module connector_block() {
        // will be replaced by 2D extrusion...
        cube([15,22,carriage_h+5+bonus]);
}

module belt_connector() {
    translate([-22,-22/2,-carriage_h/2])
        connector_block();
    // Belt retainer alignment tab:
    translate([-(1.8+11.75),-endstop_toe_w/2,-carriage_h/2]) 
        cube([endstop_tab_l,endstop_toe_w,endstop_toe_h]);
    translate([-(1.8+3.75+endstop_toe_h),0,endstop_toe_h-carriage_h/2]) 
        rotate([0,90,0]) 
            cylinder(d=endstop_toe_w, h=endstop_toe_h);
    translate([-5.5,0,endstop_toe_h-carriage_h/2]) 
        sphere(d=endstop_toe_w);
    translate([-(1.8+3.75),0,-carriage_h/2]) 
        rotate([0,0,0]) cylinder(d=endstop_toe_w, h=endstop_toe_h);
}

module carriage_block() {
    // carriage w/o any punches
}

module lm10uu_carriage() {
  intersection()
  {
    color("orange")
    translate([-15,0,-15])
      cube([50,83,100], center=true);  // Trim extremeties
    color("Cyan")
    union()
    {
        // Area across inside:
        translate([-22,-30,-carriage_h/2])
            cube([4,60,carriage_h]);

        // Belt connector column:
       translate([0,0,-(5+bonus)])
             belt_connector();

        // Fill behind bearing clip:
        translate([-21,30-5,-carriage_h/2])
            cube([15,7,carriage_h]);
        mirror([0,1,0])
        translate([-21,30-5,-carriage_h/2])
            cube([15,7,carriage_h]);

        translate([-25,30,-carriage_h/2])
            rotate([0,0,-60])
                translate([0,2,0])
                    cube([9,30-5,carriage_h]);
        mirror([0,1,0])
        translate([-25,30,-carriage_h/2])
            rotate([0,0,-60])
                translate([0,2,0])
                    cube([9+1,30-5,carriage_h]);
        
        translate([0,30,-carriage_h/2])
            rotate([0,0,-60])
                translate([-23/2,-23/2,0])
                    cube([14,23,carriage_h]);
        mirror([0,1,0])
        translate([0,30,-carriage_h/2])
            rotate([0,0,-60])
                translate([-23/2,-23/2,0])
                    cube([14,23,carriage_h]);
        
        translate([-14,30,0])
            horn();
        translate([-14,-30,0])
            horn();        
    }
  }
}

module new_carriage() {
    difference()
    {
        lm10uu_carriage();
        
        color("red")
        translate([0,0,carriage_h])
            cube([5,5,5]);
        // punch out the actuator slot
        translate([-17.5,0,endstop_base_l])
            actuator_punch();
  
        union()
        {
            // Nut holders for magnetic balls
            translate([-13,30,0])
                rotate([0,90,0])
                    cylinder(h=5,d=nut, $fn=6);
            translate([-13,-30,0])
                rotate([0,90,0])
                    cylinder(h=5,d=nut, $fn=6);

            translate([-35,30,0])
                rotate([0,90,0])
                    cylinder(h=45,d=bolt_b);
            translate([-35,-30,0])
                rotate([0,90,0])
                    cylinder(h=45,d=bolt_b);
            
            // Horn slots:
            translate([-(30-1),30,0])
                rotate([0,90,0])
                    cylinder(h=10.5,d=horn_d);
            translate([-(30-1),-30,0])
                rotate([0,90,0])
                    cylinder(h=10.5,d=horn_d);

            // Cutouts to prevent rod interference:
            translate([-(35-1),30+3,-30])
                rotate([0,0,0])
                    cylinder(h=32,d2=30, d1=40);
            translate([-(35-1),-(30+3),-30])
                rotate([0,0,0])
                    cylinder(h=32,d2=30, d1=40);

            translate([-35,0,0-bonus])
                rotate([0,90,0])
                    cylinder(h=45,d=bolt_a);
            translate([-30,0,0-bonus])
                rotate([0,90,0])
                    cylinder(h=10,d=bolt_a+5);

            // punch out the bearing shape
            L_punch = bearing_L + 2* guard + 2* L_shaft;
            translate([0, 30,-L_punch/2]) rotate([0,0,-60]) lm10UU();
            translate([0,-30,-L_punch/2]) rotate([0,0,60]) lm10UU();
        }
    }
}

module horn()
{
    color("red") {
    horn_d = 10;
    rotate([0,0,90])
    intersection()
    {
      translate([-100,0,0]) cube([200,200,15]);
        difference()
        {
            translate([0,3,0]) rotate([40,0,0]) union()
            {
                translate([0,horn_d,-10]) cylinder(d=horn_d,h=35);
                translate([-(horn_d/2),0,-10]) cube([horn_d,horn_d,35]);
            }
            rotate([90,0,0]) cylinder(d=horn_d+1,h=100, center=true);
        }
    }
  }
}

// we use a triangle shape for the base so we can print w/o support
module actuator_tab() {
    color("green") {
    xr=endstop_base_knob/2; xl=-xr;
    xbr=endstop_tab_w/2; xbl=-xbr;
    yb=endstop_tab_l/2;
    z=endstop_base_l;
    
    polyhedron( points=[
            [xl,0,0],[xr,0,0],
            [xbr,yb,0],[xbl,yb,0],
            [xl,0,z],[xr,0,z],
            [xbr,yb,z],[xbl,yb,z]], 
        faces=[
            [0,1,2,3],  // bottom
            [4,5,1,0],  // front
            [7,6,5,4],  // top
            [5,6,2,1],  // right
            [6,7,3,2],  // back
            [7,4,0,3]]  // left
        );
    translate([-endstop_tab_w/2,0,0]) 
        cube([endstop_tab_w, endstop_tab_l,endstop_tab_h]);
    }
}

// the shape to be punched out of the carrier
module actuator_punch() {
    linear_extrude(height=endstop_base_l)
        offset(delta=endstop_tab_offset)
            rotate([0,0,-90])
                projection()
                    actuator_tab();
}

module printable_set()
{
    translate([0,0,carriage_h/2])
        rotate([180,0,0])
            new_carriage();
    translate([0,-endstop_base_l,0])
        rotate([90,0,180])
            actuator_tab();

    // === debug ===
*    color("green")
    translate([0,10,10+carriage_h])
        rotate([90,0,90])
            belt_catch();
*    translate([0,0,carriage_h/2])
        rotate([0,0,0])
            new_carriage();
*    translate([-17,5,30])
        rotate([0,0,-90])
            actuator_tab();
 
}

printable_set();
