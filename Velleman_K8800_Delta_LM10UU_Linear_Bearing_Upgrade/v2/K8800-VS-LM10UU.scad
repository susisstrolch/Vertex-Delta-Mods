//
//  Velleman K8800 Carriage Alterations to fit LM1000 linear bearings.
//
//  Copyright (c) 2018 Christopher Phillips.
//  Distibuted under the Creative Commons license.
//

$fn = 64;

// These bearings are not as tall as the original bushings, so it is possible
// to gain up to 5mm of bonus Z-Axis travel.  set (bonus = 0) to preserve the
// stock height of the original part.

nozzle_d = 0.35;    // K8800 default nozzle
rod_distance = 60;  // distance between rod center

// bearing types
LM10UU = 0;     // Metric Linear Bearing, steal
RJUM1  = 1;     // drylin self-lubricating polymer, alu shell
RJ4JP  = 2;     // drylin self-lubricating polymer

// settings
btype=RJ4JP;        // the bearing type used
bonus = 5;          // Bonus height?  0 to disable
endstop_l = 28;     // heigth above carriage

// === usually no changes required
endstop_tab_l = 8;
endstop_tab_w = 2.5;
endstop_tab_h = 28 + endstop_l;
endstop_tab_knob = 5;   // diameter knob

endstop_toe_w = 3.3;    // 
endstop_toe_h = 5;

// nuts and bolds
bolt_a = 5.5;
bolt_b = 5.3;
nut = 10;//9.64;

slop = 0;
slug_dh = 10;
slug_slop = 0.5;
tab_slop = 0.5;

// zip-tie 
tie_l = 20;      // Length of tie-wrap
tie_w = 1.5;     // tie-wrap slot width
tie_h = 3;       // tie-wrap slot height
tie_toe = 30;    // tie-wrap toe-in angle

horn_xy = 10;
horn_z = 7;
horn_d = 10;

// option: top and bottom brim to snap bearing into carriage
bearing_bb = 3 * nozzle_d;  // bottom brim heigth
bearing_tb = bearing_bb;    // top brim heigth

// bearing related dimensions
bearing_L  = 29.0;  // length of bearing
bearing_dr = 10.0;  // inner diameter (shaft)
bearing_D  = 19.0;  // outer diameter

// type related dimensions
bearing_B = (btype==RJUM1) ? 21.6 : (btype==RJ4JP) ? 22.0 : 22.0;  // spacing of the circlip grooves (top to bottom)
bearing_W = (btype==RJUM1) ?  1.3 : (btype==RJ4JP) ?  1.3 : 1.30;  // circlip groove width
bearing_D1= (btype==RJUM1) ? 17.5 : (btype==RJ4JP) ? 18.0 : 18.0;  // slot (groove) diameter

// computed dimensions 
bearing_h0 = (bearing_L - bearing_B) / 2;   // height of start of circlip groove
bearing_h1 = bearing_h0 + bearing_W;        // height of end of circlip grooves


// carriage_h = 30;    // carriage height
carriage_h = bearing_L + bearing_bb + bearing_tb;
echo("carriage heigth:", carriage_h);

module lm10UU()
{
    union()
    {
        color([.44,.44,.44,1])
        cylinder(h=bearing_L, d=bearing_D1+slop);
        color([.74,.74,.74,1])
        {
            // Wipe out grooves on one side:
            intersection()
            {
               translate([0,0,-slug_dh]) 
                cylinder(h=bearing_L+slug_dh, d=bearing_D+slug_slop);
               translate([-5,-50,-50]) 
                    cube([100,100,100]); 
            }

            translate([0,0,-slug_dh]) cylinder(h=bearing_h0+slug_dh, d=bearing_D+slug_slop);
            translate([0,0,bearing_L-bearing_h0]) cylinder(h=bearing_h0+slug_dh, d=bearing_D+slug_slop);
            translate([0,0,bearing_h1]) cylinder(h=bearing_L-(2*bearing_h1), d=bearing_D+slop);
        }

        // Tie-wraps
        // Lower
        color("black")
        {
        rotate([0,0,tie_toe]) translate([-tie_l,(-tie_w+bearing_D1)/2,bearing_h0-.5]) cube([tie_l,tie_w,tie_h]);
        rotate([0,0,-tie_toe]) translate([-tie_l,(-tie_w-bearing_D1)/2,bearing_h0-.5]) cube([tie_l,tie_w,tie_h]);
        // Upper
        rotate([0,0,tie_toe]) translate([-tie_l,(-tie_w+bearing_D1)/2,bearing_L-bearing_h1-.5]) cube([tie_l,tie_w,tie_h]);
        rotate([0,0,-tie_toe]) translate([-tie_l,(-tie_w-bearing_D1)/2,bearing_L-bearing_h1-.5]) cube([tie_l,tie_w,tie_h]);
        }        
    }
}


module belt_holder() {
//    import("/bay/Development/3D-Print/Vertex-Delta-CAD/K8800-BC/K8800-BC.stl");
}

module belt_connector()         
       {
           // we need a cut-out on the right hand side because belt may touch the body
           // cut approx. 3mm depth, 5,5mm from center,
        translate([-22,-22/2,-carriage_h/2]) 
           difference() {
           cube([15,22,carriage_h+5+bonus]);
               translate([12,16.5,0])
               minkowski() {
                   cube([4,10,carriage_h+5+bonus+1]);
                   cylinder(r=2);
               }
           }
           
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


module lm10uu_carriage()
{
  intersection()
  {
    translate([-15,0,0]) cube([50,83,100], center=true);  // Trim extremeties
    union()
    {
        // Area across inside:
        translate([-22,-30,-carriage_h/2]) cube([4,60,carriage_h]);
        // Belt connector column:
       translate([0,0,-(5+bonus)])
             belt_connector();

        // Fill behind bearing clip:
        translate([-21,30-5,-carriage_h/2]) cube([15,7,carriage_h]);
        mirror([0,1,0])
        translate([-21,30-5,-carriage_h/2]) cube([15,7,carriage_h]);

        translate([-25,30,-carriage_h/2]) rotate([0,0,-60]) translate([0,2,0]) cube([9,30-5,carriage_h]);
        mirror([0,1,0])
        translate([-25,30,-carriage_h/2]) rotate([0,0,-60]) translate([0,2,0]) cube([9+1,30-5,carriage_h]);
        
        translate([0,30,-carriage_h/2]) rotate([0,0,-60]) translate([-23/2,-23/2,0]) cube([14,23,carriage_h]);
        mirror([0,1,0])
        translate([0,30,-carriage_h/2]) rotate([0,0,-60]) translate([-23/2,-23/2,0]) cube([14,23,carriage_h]);
        
        translate([-14,30,0]) horn();
        translate([-14,-30,0]) horn();        
    }
  }
}

module new_carriage()
{
    difference()
    {
        lm10uu_carriage();
        translate([-15,0,8-tab_slop-bonus]) rotate([0,0,-90]) actuator_slab();
  
        union()
        {
            // Nut holders for magnetic balls
            translate([-13,30,0]) rotate([0,90,0]) cylinder(h=5,d=nut, $fn=6);
            translate([-13,-30,0]) rotate([0,90,0]) cylinder(h=5,d=nut, $fn=6);

            translate([-35,30,0]) rotate([0,90,0]) cylinder(h=45,d=bolt_b);
            translate([-35,-30,0]) rotate([0,90,0]) cylinder(h=45,d=bolt_b);
            
            // Horn slots:
            translate([-(30-1),30,0]) rotate([0,90,0]) cylinder(h=10.5,d=horn_d);
            translate([-(30-1),-30,0]) rotate([0,90,0]) cylinder(h=10.5,d=horn_d);

            // Cutouts to prevent rod interference:
            translate([-(35-1),30+3,-30]) rotate([0,0,0]) cylinder(h=32,d2=30, d1=40);
            translate([-(35-1),-(30+3),-30]) rotate([0,0,0]) cylinder(h=32,d2=30, d1=40);

            translate([-35,0,0-bonus]) rotate([0,90,0]) cylinder(h=45,d=bolt_a);
            translate([-30,0,0-bonus]) rotate([0,90,0]) cylinder(h=10,d=bolt_a+5);
        
            translate([0, 30,-29/2]) rotate([0,0,-60]) lm10UU();
            translate([0,-30,-29/2]) rotate([0,0,60]) lm10UU();
        }
    }
}

module horn()
{
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

// The actual actuator_tab to be printed:
module actuator_tab()
{
    color("green")
    rotate([-90,0,0])
    union()
    {
        translate([-endstop_tab_w/2,0,0]) cube([endstop_tab_w, endstop_tab_l, 20]);
        cylinder(d=endstop_tab_knob,h=endstop_tab_l);
    }
}

// A slightly oversized slug to use as a cutout for the actuator_tab:
module actuator_slab()
{
    union()
    {
        translate([-(endstop_tab_w+tab_slop)/2,0,0]) cube([endstop_tab_w+tab_slop, endstop_tab_l+tab_slop, 20]);
        // rotate([-90,0,0]) 
        cylinder(d=endstop_tab_knob+tab_slop,h=endstop_tab_l+tab_slop);
    }
}

module printable_set()
{
    translate([0,0,15]) rotate([180,0,0]) new_carriage();
    translate([0,0,0]) rotate([90,0,0]) actuator_tab();
}

printable_set();
// belt_connector();
// color("blue") translate([0,1.5-22/2,-carriage_h/2]) rotate([90,180,90])  belt_holder();