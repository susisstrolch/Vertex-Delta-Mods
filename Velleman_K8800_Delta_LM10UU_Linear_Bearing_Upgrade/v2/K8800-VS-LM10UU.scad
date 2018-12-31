//
//  Velleman K8800 Carriage Alterations to fit LM1000 linear bearings.
//
//  Copyright (c) 2018 Christopher Phillips.
//  Distibuted under the Creative Commons license.
//
// These bearings are not as tall as the original bushings, so it is possible
// to gain up to 5mm of bonus Z-Axis travel.  set (bonus = 0) to preserve the
// stock height of the original part.

// extrusion guard (~nozzle/2)
guard = 0.175;        

// EMBEDED=0, LM10UU=1, RJ4JP=2, RJUM1=3
bearing_type = 3;

// endstop heigth above carriage
endstop = 10;

// enable/disable bearing brim
enable_brim = 1;

// set to 1 to print the carriage
print_sled = 0;

// set to 1 to print the actuator
print_actuator = 0;

// disable/enable debug
debug = 0;

// this dummy hides the following vars in Customizer
module dont_show_in_customizer() {
}

$fn = 64;

// supported bearing types
EMBEDED= 0;     // embedded bearing 
LM10UU = 1;     // Metric Linear Bearing, steal
RJ4JP  = 2;     // drylin self-lubricating polymer
RJUM1  = 3;     // drylin self-lubricating polymer, alu shell

// ------------------------------------------
// fixed parameters (given by printer design)

// the rods
d_RD10  = 60;       // distance between center of rods
d_RD10_2 = d_RD10/2; 
RD10_d  = 10;       // rod diameter

// the belt catch
BC_z = 36.0;    // height of belt catch
BC_x = 16.0;    // thicknes of belt catch
BC_y = 2* 11.5; // non-centric hole!

nozzle_d = 0.35;    // K8800 default nozzle

// ------------------------------------------
horn_xy = 10;
horn_z = 7;
horn_d = 10;

// endstop definitions
// the endstop consists of two parts:
// - endstop_base - the overall height of the part inserted into the carrier
//                  default: 10mm
//                  the base (toe) is made of a triangle and the tab cube
// - endstop_tab  - the tab above the carrier
endstop_toe_w = 5;  // width of endstop knob
endstop_toe_h = 7.5; // overall length of endstop base inside carriage

endstop_tab_l = endstop;    // height above carrier
endstop_tab_w = 2.5;        // width of the tab (must fit into the IR sensor)   
endstop_tab_h = endstop_toe_h + endstop;   // overall height of endstop tab
endstop_tab_guard = guard;                 // offset for punching the endstop slot

// nuts and bolds
bolt_a = 5.5;       // belt fetch holder
bolt_b = 5.3;       // magnetic cub
nut = 10;//9.64;

// zip-tie 
tie_l = 20;      // Length of tie-wrap
tie_w = 1.5;     // tie-wrap slot width
tie_h = 3;       // tie-wrap slot height
tie_toe = 30;    // tie-wrap toe-in angle

// the bearing...
bearing_L  = 29.0;  // length of bearing
bearing_dr = 10.0;  // inner diameter (shaft)
bearing_D  = 19.0;  // outer diameter

// type specific dimensions (RJ4JP and LM10UU are identical)
bearing_B = (bearing_type==RJUM1) ? 21.6 : 22.0;   // spacing of the circlip grooves (top to bottom)
bearing_W = (bearing_type==RJUM1) ?  1.3 : 1.3;    // circlip groove width
bearing_D1= (bearing_type==RJUM1) ? 17.5 : 18.0;   // slot (groove) diameter

// circlip grooves - computed dimensions 
bearing_h0 = (bearing_L - bearing_B) / 2;
bearing_h1 = bearing_h0 + bearing_W;

// option: top and bottom brim to keep bearing in carriage
bearing_bb = enable_brim ? 3 * nozzle_d : 0;  // bottom brim heigth
bearing_tb = bearing_bb;    // top brim heigth

L_shaft = 3.0;  // length of punch through shaft for bearing top/bottom

d_punch = 3.0;  // shortening offset for shaft in brim

// VS (vertical slight
carriage_h = (bearing_L) + bearing_bb + bearing_tb;
echo("carriage heigth:", carriage_h);

// ----------------------------------------
// development - import Velleman CAD object
//
module belt_catch() {
// measured dimensions of the "belt catch"
//  bounding box:   X=16, Y=36
//  center of bb:   X=8, Y=18.0
//  mounting hole:  X=5, Y=18, D=5.5
//  off be1t fetch: X=13 (12.75/13.5)
//  nose:           X=5, Y=30
//                  D=3.5
//  corners (left): r=3.0
//      x0,y0:      3.0, 3.0
//      x0,yMax:    3.0, 33.0

    // [0,0,0] center of bolt
    translate([-20,-carriage_h,-00])
        rotate([0,0,180])
            import("/bay/Development/3D-Print/Vertex-Delta-CAD/K8800-BC/K8800-BC.stl");
}

// ----------------------------------------
// actuator_tab
// we use a triangle shape for the base so we can print w/o support
// add slop parameter in case the actuator slot is to wide
module actuator_tab(len=endstop, slop=0) {
    xr=slop + endstop_toe_w/2; xl=-xr;
    xbr=slop + endstop_tab_w/2; xbl=-xbr;
    yb=slop + endstop_tab_l/2;
    z=endstop_toe_h;
    
    l = endstop_toe_h + len;  
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
    translate([xbl,0,0]) 
        cube([xbr*2, endstop_tab_l, l]);
}

// the shape to be punched out of the carrier
module actuator_punch(es_guard=endstop_tab_guard) {
    linear_extrude(height=endstop_toe_h)
        offset(delta=es_guard)
            rotate([0,0,-90])
                projection()
                    actuator_tab();
}

// magnetic cub - punch shape
module magcub() {
    MCd1=5; MCh1=8.25;  // shaft
    MCd2=10; MCh2=4.3;  // head -d2 real: 8.5
    MCd3=10; MCh3=4.0;  // nut
    
    rotate([0,-90,0])
        union() {
            color("red")
            translate([0,0,-MCh1/2])
                cylinder(center=true, d=MCd1, h=MCh1, $fn=64);
            color("red")
            translate([0,0,MCh2/2])
                cylinder(center=true, d=MCd2, h=MCh2, $fn=64);
            color("orange")
            translate([0,0,MCh2+MCh2/2]) // punch through for head
                cylinder(center=true, d=MCd2, h=MCh2, $fn=64);
            
            color("red")
            translate([0,0,-MCh1+MCh3/2])
                difference() {
                    cylinder(center=true, d=MCd3, h=MCh3, $fn=6);
 *                   cylinder(center=true, d=MCd1, h=MCh3, $fn=64);
                }
            color("orange")
            translate([0,0,-MCh1-MCh3/2])  // punch through for nut
                difference() {
                    cylinder(center=true, d=MCd3, h=MCh3, $fn=6);
*                    cylinder(center=true, d=MCd1, h=MCh3, $fn=64);
            }
        }
    }

// ----------------------------------------
// connector block - holding the belt catch
//
module connector_block() {
    // bounding box: x=22, y=36
    bby=22; bby2=bby/2; // bounding box x/2
    bbx=15; bbx2=bbx/2; // bounding box y/2
    edge=5.5;           // edge to avoid belt contact
    
    2D_shape=[
        [0,bby2-edge], 
        [-edge,bby2],
        [-bbx,bby2],
        [-bbx,-bby2],
        [0,-bby2],
        [0,0]
    ];
    
    linear_extrude(height=BC_z)
        polygon(2D_shape);
}

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
module bearing_3D(offset=0) {
    $fn=90;
    difference(){
        color("green")
        translate([0,0,0])
            rotate_extrude($fn = 90)
                bearing_2D(offset);
        // cut out for rod
        color("red")
        cylinder(d=bearing_dr, h=bearing_L+guard*2);
    }
}

module bearing_punch() {
// bearing with 'guard' offset for use in punchmask
    // object is at [0,0,0]. 
    // The variables zMax and D are only used to show the effective 
    // size after applying the offset(xxx) function
    D=bearing_D + 2* guard;
    zMax = bearing_L + 2* guard;
    
    translate([0,0,0])
        rotate_extrude($fn = 90)
            offset(delta=guard)
                bearing_2D(guard);
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
    D_shaft = enable_brim ? D_punch - d_punch  : D_punch;    // space for rod...
    
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

module horn()
{
    horn_d = 10;
//    color("red")
    rotate([0,0,90])
    intersection()
    {
        translate([-10,0,0]) 
            cube([15,20,carriage_h/2]);
        translate([0,0,bearing_tb])
        difference()
        {
            translate([0,3,0]) rotate([40,0,0]) union()
            {
                translate([0,horn_d,-10]) cylinder(d=horn_d,h=BC_z);
                translate([-(horn_d/2),0,-10]) cube([horn_d,horn_d,BC_z]);
            }
            rotate([90,0,0]) cylinder(d=horn_d+1,h=100, center=true);
        }
    }
}

// punch mask for bearing and zip-ties
module lm10UU_punchmask()
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

module lm10uu_carriage() {
  intersection()
  {
    translate([-15,0,carriage_h/2])
      cube([50,83,100], center=true);  // Trim extremeties
    union()
    {
        // Area across inside:
        color("blue")
        translate([-22,-30,-carriage_h/2])
            cube([4,60,carriage_h]);

        // Belt connector column:
        translate([-22+15,0,-BC_z+carriage_h/2])
            connector_block();

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
        
      
        translate([0,29,-carriage_h/2])
            rotate([0,0,-60])
                translate([-23/2,-23/2,0])
                    cube([14,23,carriage_h]);
        mirror([0,1,0])
        translate([0,29,-carriage_h/2])
            rotate([0,0,-60])
                translate([-23/2,-23/2,0])
                    cube([14,23,carriage_h]);
        
        translate([-14,d_RD10_2,0])
            horn();
        translate([-14,-d_RD10_2,0])
            horn();        
    }
  }
}

module new_carriage() {
    difference()
    {
        lm10uu_carriage();
        
        // punch out the actuator slot
//        color("FireBrick")
        translate([-17.0,0,carriage_h/2-(endstop_toe_h)])
            actuator_punch();

        union()
        {
            // Nut holders for magnetic cub
            translate([-16.5,d_RD10_2,bearing_tb])
            magcub();
            
            translate([-16.5,-d_RD10_2,bearing_tb])
            magcub();
            
            // Horn slots - the 11mm is an approximation 
*            translate([-(30-1),d_RD10_2,bearing_tb])
                rotate([0,90,0])
                    cylinder(h=11,d=horn_d);
*            translate([-(30-1),-d_RD10_2,bearing_tb])
                rotate([0,90,0])
                    cylinder(h=11,d=horn_d);

            // Cutouts to prevent rod interference:
            translate([-(35-1),d_RD10_2+3,-30+bearing_tb])
                rotate([0,0,0])
                    cylinder(h=32,d2=30, d1=40);
            translate([-(35-1),-(d_RD10_2+3),-30+bearing_tb])
                rotate([0,0,0])
                    cylinder(h=32,d2=30, d1=40);

            // hole for belt catch screw
            bcb_off = (BC_z - carriage_h) / 2;
            translate([-35,0,-bcb_off])
                rotate([0,90,0])
                    cylinder(h=45,d=bolt_a);
            translate([-30,0,-bcb_off])
                rotate([0,90,0])
                    cylinder(h=10,d=bolt_a+5);

            // punch out the bearing shape
            L_punch = bearing_L + 2* guard + 2* L_shaft;
            translate([0, d_RD10_2,-L_punch/2]) 
                rotate([0,0,-60]) 
                    lm10UU_punchmask();
            translate([0,-d_RD10_2,-L_punch/2]) 
                rotate([0,0,60]) 
                    lm10UU_punchmask();
        }
    }
    
    
}

module printable_set()
{
    es_slop = 0.0;      // optimize: slop for endstop
    if (debug==0) {
        if (print_sled) 
            translate([0,0,carriage_h/2])
                rotate([180,0,0])
                    new_carriage();
        if (print_actuator) {
            translate([10,-endstop_toe_h,0])
                rotate([90,0,180])
                    actuator_tab();
        }
        
    } else {
    // ===== debug =====
*        magcub();
        
        intersection() {
            new_carriage();
            translate([-35,-45,0])
                cube([50,90,10]);
        }
        // top part of carriage
*        intersection() {
            translate([0,0,carriage_h/2])
                rotate([180,0,0])
                    new_carriage();
            translate([-35,-45,0])
                cube([50,90,10]);
        }
        
        // an actuator tab
*        translate([15,-7.5,0])
            rotate([90,0,180])
                actuator_tab();
        
*        translate([30,-15,0])
            bearing_2D(offset=guard);
        
*        translate([30,-30,0])
            bearing_3D(offset=guard);
    }
}
printable_set();
 