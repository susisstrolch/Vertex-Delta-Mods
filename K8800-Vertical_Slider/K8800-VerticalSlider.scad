include <Vertex-Delta-K8800-CAD.scad>;
include <nutsnbolts/cyl_head_bolt.scad>;
include <linear_bearing.scad>;
include <K8800-endstop-actuator.scad>

$fn=64;
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
// endstop actuator clearance multiplicator (base:_D_NOZZLE_4)
_D_ENDSTOP_TOE    = 2; 
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
_ES_HOLE_CLTD       = _D_NOZZLE_1;  // 1/4
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
    h=50;           // height of pylon segment
    color("blue")
    translate([0,0,-h/2])
        linear_extrude(height=h)
            offset(delta=delta)
                projection(cut=true)
                    translate([0,-5,0]) // empiric..
                       stl_K8800_RI();
}

/* ==============================
 * the vertical slider components
 * ============================== */

/* 2D outline for bearing holder */
module bearingBlock2D(){
    /* inner carving for vertical slider - empiric data */
    vsCarveOut=[[0,-12],[-19,-12],[-_VS_DIST_ROD_ROD2,12],[0,12],[0,-12]];
    difference() {
        hull(){
            translate([-_VS_DIST_ROD_ROD2,-1,0])
                circle(d=23);
            translate([-(_VS_DIST_ROD_ROD2-1),-11,0])
                circle(d=15);
            translate([-9.5,-18,0])
                circle(d=10);
        }   
        polygon(points=vsCarveOut);
    }
}

/* ------------------------------
 * a single block, carved out
  ------------------------------ */
module VSBlock(h=31) {
    MC_y=21;
    nutD=5.0;
    
    color("orange")
    difference() {
        linear_extrude(height=h, convexity = 10)
            bearingBlock2D();
        union() {
            // the magnetic clib
            color("red")
            translate([-30,-20.5,MC_y])
                rotate([90,0,0])
                    hole_through(name="M5",l=8.5,h=4.5);

            // the corresponding nuthole
            color("blue")
            translate([-30,-(9.5+4),MC_y])
                rotate([90,0,0])
                    nutcatch_parallel(name="M5",clk=_ES_HOLE_CLTD);
            
            // punch out the bearing
            color("lightgrey")
            translate([-30,0,h/2])
               linear_bearing(
                    type=_VS_LINEAR_BEARING,
                    cld  =  0.175, sl = 3.0, sb = 1.5
                );
        }
    }
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
        translate([-0,-23,0])
            rotate([90,-0,0])
                hole_through(name="M5",l=20,h=4.5, cld=_ES_HOLE_CLTD);
        
        // belt protection carve-out
        translate([-bcw/2,-7,-0])
            cylinder(h=h,r=5,center=true);
        
        // punch out for endstop 
        translate([0,-get_ES_depth(),h/2])
            K8800_ES_Mask(_F_HCLD);
        
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
module vsBlock(bch=36,vsh=31){
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
                vsBlock(bch=36,vsh=31);
                pylon(delta=0.35*7);
            }
}

/* ==============================
 * the endstop actuator
 * ============================== */
module K8800_VS_Endstop(
    cld=_D_CLD,
    thread=_ES_HOLE_THREAD,
    text="none") {
        K8800_ES_Endstop(_ES_hcld=cld,_ES_thread=thread,_ES_marker=text);
}

module K8800_VS_Endstop_actuator(
    cld=_D_CLD,
    thread=_ES_HOLE_THREAD,
    text="none") {
    translate([0,-5+get_ES__ES_TOE_Y(),get_ES__ES_TOE_Z()])
        rotate([0,0,180])
        K8800_VS_Endstop(cld=cld,thread=_ES_HOLE_THREAD,text=text);
}
    
/* ==============================
 *  here we go....
 * ============================== */

/* ------------------------------
 * create single bearing block to check snap-in
 * ------------------------------ */
if (_PRINT_BEARINGBLOCK == "true") {
    // the bearing holder
    intersection() {
        K8800_VS();
        translate([-45,-15,0])
            cube([25,35,40]);
    }
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


if (_PRINT_BCBLOCK=="false" &&
    _PRINT_BEARINGBLOCK=="false" &&
    _PRINT_ES_ACTUATOR=="false" &&
    _PRINT_ES_TEST=="false") {
    /* ==============================
     * create printable objects
     * ============================== */
        K8800_VS();
}
 
