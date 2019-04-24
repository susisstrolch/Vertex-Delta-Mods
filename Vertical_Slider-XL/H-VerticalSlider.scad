// iteration #6
include <Vertex-Delta-K8800-CAD.scad>;
include <nutsnbolts/cyl_head_bolt.scad>;
include <linear_bearing.scad>;
include <endstop-actuator.scad>

$fa=0.1;
$fs=0.1;

// _Dxxxx: diameter / distance, absolute, mm
// _Fxxxx: fraction of nozzle diameter
// _Mxxxx: multiplier for 1/4 nozzle diameter

// Nozzle diameter
_D_NOZZLE   = 0.35;
_D_NOZZLE_0 = _D_NOZZLE *0 / 4;
_D_NOZZLE_1 = _D_NOZZLE *1 / 4;
_D_NOZZLE_2 = _D_NOZZLE *2 / 4;
_D_NOZZLE_3 = _D_NOZZLE *3 / 4;

// #perimeters (base: nozzle dia.)
_M_WALL           = 3;

// ---------------------------------
// endstop actuator clearance multiplicator (base:_D_NOZZLE)
_CLD_ES_TOE  = 0.3   ; 
// height of endstop actuator flag - must be >3.5mm
_H_ES_FLAG = 5;
// optimistic clearing distance
_F_CLD            = 4;
// horizontal clearing distance
_F_HCLD           = 2;
// print layer height
_F_VCLD           = 4;

_D_WALL             = _D_NOZZLE * _M_WALL;
_D_CLD              = _D_NOZZLE / _F_CLD;
_D_HCLD             = _D_NOZZLE / _F_HCLD;
_D_VCLD             = _D_NOZZLE / _F_VCLD;

 // ES hole: non-threaded: no, threaded: modeled
_ES_HOLE_THREAD     = "no";
// clearing distance for non-threaded ES hole 
_ES_HOLE_CLTD       = _D_NOZZLE_1;  // 1/4 nozzle

// clearing distance for M5 nut catch
_ES_HOLE_CLNC       = _D_NOZZLE_3;  // 3/4 nozzle

// bearing type
_VS_LINEAR_BEARING  = "RJ4JP-01-10";

// marker for slider / endstop (none || any text)
_T_MARKER           = "none";
// print belt catch block
_PRINT_BCBLOCK      = "false";
// print single bearing block
_PRINT_BEARINGBLOCK = "false";
// print endstop actuator
_PRINT_ES_ACTUATOR  = "false";
// print endstop actuator test
_PRINT_ES_TEST      = "false";
// length of bearing leg
_hLeg=110;
_hDiff= _hLeg*2.01/2;

_center=_hLeg/2;

module fixed_values() {
}

// center of rod is at [(+/-)_VS_DIST_ROD_ROD/2,0]
_VS_DIST_ROD_ROD    = 60;   // distance between center of rods
_VS_DIST_ROD_ROD2   = _VS_DIST_ROD_ROD/2;   // distance between rod and center of pylon

_VS_DIST_VSBACK_ROD =  6;   // distance VS backside to center of rod

_VS_BELTCATCH_HEIGHT= 36.0; // Z-dimension
_VS_BELTCATCH_DEPTH = 16;   // Y-dimension
_VS_BELTCATCH_WIDTH = 20;   // X-dimension

// --- the Pylon...
// using 'projection' we can apply an offset to use as punch mask
module pylon(delta=0) {
    h=_hLeg*1.01;           // height of pylon segment
    color("blue")
    translate([0,0,-_hDiff])
        linear_extrude(height=h)
            offset(delta=delta)
                projection(cut=true)
                    translate([0,-5,0]) // empiric..
                       stl_K8800_RI();
}

/* ==============================
 * the vertical slider components
 * ============================== */

/* ------------------------------ 
 * iteration 6 - looks like we really need a zip-tie
 * or wire to fasten the bearing - otherwise we get
 * unwanted movement during acceleration on X-plane
 * ------------------------------ */
module ziptie_cutout() {
    // cut out on the backside of VSBlock
    // zip-tie diameter: 1.5x3 (wxh)
    tie_w = 3;    // tie-wrap slot width
    tie_h = 4;    // tie-wrap slot height
    tie_a = 60;     // angle in degrees
    
    // we set the tie slot approx. 1mm away from bearing outside
    tie_offset = 2.0;   // fine adjustment later...
    
    color("purple")
    // the zip-tie slot, 360°
    linear_extrude(height=tie_h)
    // the 2D ring for the zip-tie
        difference() {
            circle(d=_get_outer_dia(_VS_LINEAR_BEARING) + tie_offset + tie_w);
            circle(d=_get_outer_dia(_VS_LINEAR_BEARING) + tie_offset);
        }
    
    
};

/* ------------------------------
 * carve outs for single leg
  ------------------------------ */
module carveOutLeg() {
    {
        linear_extrude(height=_hLeg, convexity = 10)
            bearingBlock2D();
        union() {
            color("red")
            translate([-_VS_DIST_ROD_ROD2,-22.5,_Y_MC_bold])
                rotate([90,0,0])
                    hole_through(name="M5",l=_L_MC_bold,h=_H_NH);

            color("blue")
            translate([-_VS_DIST_ROD_ROD2,-(_MC_NC_dist),_Y_MC_bold])
                rotate([90,0,0])
                    nutcatch_parallel(name="M5",l=_H_NH + _MC_NC_inset, clk=_ES_HOLE_CLNC);
            
            // punch out the bearing
            color("lightgrey")
            translate([-_VS_DIST_ROD_ROD2,0,h/2])
               linear_bearing(
                    type=_VS_LINEAR_BEARING,
                    cld  =  _D_NOZZLE_1, sl = 3.0, sb = 1.5
                );
        }
         // upper and lower zip-tie slot...
        translate([-_VS_DIST_ROD_ROD2,0,_get_flange_h0(_VS_LINEAR_BEARING)])
            ziptie_cutout();
        translate([-_VS_DIST_ROD_ROD2,0,_get_flange_h0(_VS_LINEAR_BEARING)+_get_flange_B(_VS_LINEAR_BEARING)-_get_ring_w(_VS_LINEAR_BEARING)])
            ziptie_cutout();
    }
    
    // put in MC and nut...
#           color("blue")
            translate([-_VS_DIST_ROD_ROD2,-(_MC_NC_dist),_Y_MC_bold])
                rotate([90,0,0])
                    nutcatch_parallel(name=_type,clk=_ES_HOLE_CLNC);
    
    // slider...
#    cylinder();
}
/* ------------------------------
 * a single block, carved out
  ------------------------------ */
module VSBlock(h=31) {
    _MC_type="M5";      // MC clip is M5...
    _L_MC_bold=8.5;     // length of MC clip shaft
    
    _Y_MC_bold=21;      // Y-offset for MC bold

//	_df   = _get_fam(name=_MC_type);
//	_H_NH = _df[_NB_F_NUT_HEIGHT];
    _H_NH = 4.7;
    
/* the nuthole catch min. Y distance for punch:
           _get_outer_dia(_VS_LINEAR_BEARING)/2 +
           _get_nut_height("M5") + inset
    */
    _MC_NC_inset= 1.5; // shift towards rod to punch the boarder
    _MC_NC_dist = _get_outer_dia(_VS_LINEAR_BEARING)/2 
                + _H_NH
                -_MC_NC_inset;

/* -----------------
   the magnetic clib
   bold length is 8.5mm, so the critical Y distance equals
     _get_outer_dia(_VS_LINEAR_BEARING)/2 + 8.5mm
   ----------------- */            
    _MC_dist = _get_outer_dia(_VS_LINEAR_BEARING)/2 + _L_MC_bold;
    
    echo(str("_H_NH=",_H_NH, "\n_MC_NC_dist=", _MC_NC_dist, "\n_MC_dist=", _MC_dist));
    
    color("orange")
    difference() {
        translate([0,0,h-_hLeg])
        linear_extrude(height=_hLeg, convexity = 10)
            bearingBlock2D();
        union() {
            color("red")
            translate([-_VS_DIST_ROD_ROD2,-22.5,_Y_MC_bold])
                rotate([90,0,0])
                    hole_through(name="M5",l=_L_MC_bold,h=_H_NH);

            color("blue")
            translate([-_VS_DIST_ROD_ROD2,-(_MC_NC_dist),_Y_MC_bold])
                rotate([90,0,0])
                    nutcatch_parallel(name="M5",l=_H_NH + _MC_NC_inset, clk=_ES_HOLE_CLNC);
            
            // punch out the bearing
            color("lightgrey")
            translate([-_VS_DIST_ROD_ROD2,0,h/2])
               linear_bearing(
                    type=_VS_LINEAR_BEARING,
                    cld  =  _D_NOZZLE_1, sl = 3.0, sb = 1.5
                );
        }
         // upper and lower zip-tie slot...
        translate([-_VS_DIST_ROD_ROD2,0,_get_flange_h0(_VS_LINEAR_BEARING)])
            ziptie_cutout();
        translate([-_VS_DIST_ROD_ROD2,0,_get_flange_h0(_VS_LINEAR_BEARING)+_get_flange_B(_VS_LINEAR_BEARING)-_get_ring_w(_VS_LINEAR_BEARING)])
            ziptie_cutout();
    }
    
    // put in MC and nut...
#           color("blue")
            translate([-_VS_DIST_ROD_ROD2,-(_MC_NC_dist),_Y_MC_bold])
                rotate([90,0,0])
                    nutcatch_parallel(name=_type,clk=_ES_HOLE_CLNC);
    
}

/* ------------------------------ 
 * the Belt Catch Block (incl. endstop punch and BC-fix)
 * ------------------------------ */
module BCBlock(h=_VS_BELTCATCH_HEIGHT,
               cld=_ES_HOLE_CLTD) {
    bcw=_VS_BELTCATCH_WIDTH; bcd=_VS_BELTCATCH_DEPTH;
    
    color("FireBrick") 
    difference(){
        translate([0,-15,0])
            cube([bcw,bcd,h],center=true);

        // punch out the M5x20 allen screw
        translate([-0,-23])
            rotate([90,-0,0])
                hole_through(name="M5",l=20,h=4.5, cld=_ES_HOLE_CLTD);
        
        // belt protection carve-out
        translate([-bcw/2,-7,-0])
            cylinder(h=h,r=5,center=true);
        
        // punch out for endstop 
        translate([0,-get_ES_depth(),h/2])
            K8800_ES_Mask(_ES_hcld = _CLD_ES_TOE*_D_NOZZLE);
        
        // optional _T_MARKER
        if (_T_MARKER != "none") {
        translate([-4,-(bcd+7-_D_NOZZLE*2.0),7])
            rotate([90,0,0])
            linear_extrude(height=_D_NOZZLE*2)
                text(_T_MARKER,font="Courier New:style=Regular");
        }
    }
    
    // Belt catch alignment tab
    toe_x = 3.2; toe_y = 2.7; toe_z = 6.75;
    toe_r = toe_y/2;

    color("green")
    translate([-toe_r,-0.1-15+bcd/2,toe_z-toe_r-h/2])
    rotate([-90,0,0])
    linear_extrude(height=toe_x)
        union() {
            square(size=[toe_y,toe_z-toe_r]);
            translate([toe_r,0,0])
                circle(d=toe_y);
        };
}

/* ==============================
 * the vertical slider block
 * ============================== */
module vsBlock(bch=_VS_BELTCATCH_HEIGHT,vsh=31){
    BCBlock(bch);

    translate([0,0,-13]) {
    VSBlock(h=vsh);
    mirror([1,0,0])
        VSBlock(h=vsh);
    }
}

/* ==============================
 * the new vertical slider
 * ============================== */
module K8800_VS() {
    translate([0,0,_VS_BELTCATCH_HEIGHT/2])
        rotate([180,0,0])
            difference() {
                vsBlock(bch=_VS_BELTCATCH_HEIGHT,vsh=31);
                pylon(delta=0.35*5);
            }
}

/* ==============================
 * the endstop actuator
 * ============================== */
module K8800_VS_Endstop_actuator(
    cld=_D_CLD,
    thread=_ES_HOLE_THREAD,
    text="none") {
    translate([0,-5+get_ES__ES_TOE_Y(),get_ES__ES_TOE_Z()])
        rotate([0,0,180])
        K8800_ES_Endstop(_ES_hcld=cld,_ES_thread=_ES_HOLE_THREAD,_ES_marker=text,_ES_flag_z=_H_ES_FLAG);
}
 
module bearingHolder() {
    intersection() {
        K8800_VS();
        translate([-45,-15,0])
            cube([25,35,40]);
    }
}

/* ==============================
 *  here we go....
 * ============================== */

/* ------------------------------
 * create single bearing block to check snap-in
 * ------------------------------ */
if (_PRINT_BEARINGBLOCK == "true") {
    // the bearing holder
    bearingHolder();
} 

/* ------------------------------
 * create belt catch block
 * ------------------------------ */
if (_PRINT_BCBLOCK=="true") {
    intersection() {
        K8800_VS();
        translate([-10,-15,0])
            if (_PRINT_ES_TEST=="true")
                cube([20,40,_VS_BELTCATCH_HEIGHT/2]);
            else
                 cube([20,40,40]);
               
    }
}

/* ------------------------------
 * build single actuator w given cld
 * ------------------------------ */
if (_PRINT_ES_ACTUATOR=="true") {
        K8800_VS_Endstop_actuator(cld=0,text=str(0));
}

/* ------------------------------
 * build ES actuator fit and actuators with increasing cld
 * ------------------------------ */
if (_PRINT_ES_TEST=="true") {
    for (i=[0:4]) {
        translate([(i-2)*10,0,0])
            K8800_VS_Endstop_actuator(cld=-i*_D_NOZZLE_4,text=str(i));
    }
}

*if (_PRINT_BCBLOCK=="false" &&
    _PRINT_BEARINGBLOCK=="false" &&
    _PRINT_ES_ACTUATOR=="false" &&
    _PRINT_ES_TEST=="false") {
    /* ==============================
     * create printable objects
     * ============================== */
        K8800_VS();
}

/* 2D outline for bearing holder */
module bearingBlock2D(){
    /* inner carving for vertical slider - empiric data */
    x=10.0;
    y=10.0;
    vsCarveOut=[[y,-x],[-y,-x],[-_VS_DIST_ROD_ROD2,x],[y,x],[y,-x]];
    difference() {
      hull(){
           translate([-_VS_DIST_ROD_ROD2,-1,0])
                circle(d=27);
            translate([-(_VS_DIST_ROD_ROD2+2),-12.5,0])
                circle(d=10);
            translate([-(_VS_DIST_ROD_ROD2-10),-20])
                circle(d=6);
            translate([-0,-19,0])
                circle(d=8);
            translate([-0,-15,0])
                circle(d=8);
            
      }
      translate([-17.5,-7]) 
        square([35,20]);
    }
}

/* ------------------------------ 
 *  ------------------------------ */
module H_BearingBlock() {
  translate([0,0,-_center])
    union() {
        linear_extrude(height=_hLeg, convexity = 10)
            bearingBlock2D();
        mirror([-1,0,0])
            linear_extrude(height=_hLeg, convexity = 10)
                bearingBlock2D();
    }
}

/**
 * H-Block - new H-shaped design w longer legs
**/

// clean up mask for outer contour
module H_BlockCarve(y=0){
    difference() {
        h=_hLeg/2;
        translate([-45,-23,y])
            cube([90,30,h]);
        translate([-_VS_DIST_ROD_ROD2-0.5,-0.7,y])
            cylinder(r=13.5,h=h);
        translate([_VS_DIST_ROD_ROD2+0.5,-0.7,y])
            cylinder(r=13.5,h=h);
    }
}

module H_Block() {
    difference() {
        H_BearingBlock();
        translate([0,0,8])
            H_BlockCarve();
       translate([0,0,-79])
            H_BlockCarve();
       translate([-16.5,-9,-_center])
            cylinder(d=6.5,h=_hDiff);
       translate([-17.5,-12,-_center])
            cylinder(d=6.5,h=_hDiff);
       translate([+16.5,-9,-_center])
            cylinder(d=6.5,h=_hDiff);
       translate([+17.5,-12,-_center])
            cylinder(d=6.5,h=_hDiff);
        
    }
}

module H_BlockShape() {
    projection(cut = false) H_Block();
}

module H_Block_Slider() {
  /*  
       translate([-16.5,-9,-_center])
            cylinder(d=6.5,h=_hDiff);
       translate([-17.5,-12,-_center])
            cylinder(d=6.5,h=_hDiff);
       translate([+16.5,-9,-_center])
            cylinder(d=6.5,h=_hDiff);
       translate([+17.5,-12,-_center])
            cylinder(d=6.5,h=_hDiff);
*/
    translate([0,0,-_center])
        union() {
            translate([-_VS_DIST_ROD_ROD2,0,-0.1])
                cylinder(d=11,h=_hDiff);
            translate([_VS_DIST_ROD_ROD2,0,-0.1])
                cylinder(d=11,h=_hDiff);
        }

}

/* solid VS slider */
module H_VS_Block(){
    difference(){
      H_BearingBlock();
      translate([0,0, 9.999]) H_BlockCarve();
      translate([0,0,-81]) H_BlockCarve();
      translate([0,0,_center]) pylon();
      // cut remaining stands from pylon
*      translate([-16.5,-9,-_center]) cylinder(d=6.5,h=_hDiff);
*      translate([+16.5,-9,-_center]) cylinder(d=6.5,h=_hDiff);
      translate([-15.5,-15,-_center]) 
       #rotate([0,0,55])
        cube([10,7.5,_hDiff]);
      mirror([-1,0,0])
       translate([-15.5,-15,-_center]) 
       #rotate([0,0,55])
        cube([10,7.5,_hDiff]);
       
        
      translate([-17.5,-12,-_center]) cylinder(d=6.5,h=_hDiff);
      translate([+17.5,-12,-_center]) cylinder(d=6.5,h=_hDiff);
    }
}

*color("cyan") translate([0,0,75])
  H_BlockShape();
#color("blue") translate([0,0,-8])
  BCBlock(_VS_BELTCATCH_HEIGHT);
color("orange") 
  H_VS_Block();
