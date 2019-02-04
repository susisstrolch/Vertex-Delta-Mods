/* 
    Linear Bearings - an OpenSCAD library
    Copyright (C) 2019 SusisStrolch

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

/* Linear Bearings - Data Section 
   Specification according to http://www.ekt2.com/ || https://www.igus.com/info/page-17748 || https://www.igus.de/product/1185
    d:  nominal shaft diameter (IGUS: d1)
    D:  outer diameter  (IGUS: d2)
    L:  bearing length  (IGUS: B)
    B:  Distance between outer ring flanges (IGUS: B1)
    W:  Ring width  (IGUS: s)
    D1: Ring diameter   (IGUS: dn)
    h0: offset lower ring, lower flange - (L - B) / 2;
    h1: offset lower ring, upper flange - h0 + W
*/

data_bearings = [
    //  name    ,   d , D,  L,  B,   W,  D1,  h0,   h1  
    ["Generic",     10, 10, 29, 0,   0,  19.0, 0,   0],
    ["LM10UU",      10, 19, 29, 22.0,1.3,18.0, 3.5, 4.8],
    ["RJ4JP-01-10", 10, 19, 29, 22.0,1.3,18.0, 3.5, 4.8],
    ["RJUM1-01-10", 10, 19, 29, 21.6,1.3,17.5, 3.7, 5.0]
];

// access key
_LB_DESC=0;     // Name
_LB_d=1;        // nominal shaft diameter (IGUS: d1)
_LB_D=2;        // outer diameter  (IGUS: d2)
_LB_L=3;        // bearing length  (IGUS: B)
_LB_B=4;        // Distance between outer ring flanges (IGUS: B1)
_LB_W=5;        // Ring width  (IGUS: s)
_LB_D1=6;       // Ring diameter   (IGUS: dn)
_LB_h0=7;       // offset lower ring, lower flange - (L - B) / 2;
_LB_h1=8;       // offset lower ring, upper flange - h0 + W

// access functions
function _get_bearing(n) = data_bearings[search([n], data_bearings)[0]];

function _get_desc(n)       = _get_bearing(n)[_LB_DESC];
function _get_outer_dia(n)  = _get_bearing(n)[_LB_D];
function _get_inner_dia(n)  = _get_bearing(n)[_LB_d];
function _get_length(n)     = _get_bearing(n)[_LB_L];
function _get_flange_B(n)   = _get_bearing(n)[_LB_B];
function _get_ring_w(n)     = _get_bearing(n)[_LB_W];
function _get_ring_d1(n)    = _get_bearing(n)[_LB_D1];
function _get_flange_h0(n)  = _get_bearing(n)[_LB_h0];
function _get_flange_h1(n)  = _get_bearing(n)[_LB_h1];

// build that thing...
module 2D_linear_bearing(
    type="RJ4JP-01-10",
)
{  
    // 2D drawing of the bearing, according to datasheet
    db=_get_bearing(type);

    xR=db[_LB_D]/2; xR1=db[_LB_D1]/2;
    W=db[_LB_W]; B=db[_LB_B]; L=db[_LB_L];
    h0=(L-B)/2; h1=h0+W;

    outline=[
        [0,0], [xR,0],
        [xR,h0], [xR1,h0],
        [xR1,h0+W], [xR,h0+W],
        [xR,h0+B-W], [xR1,h0+B-W],
        [xR1,h0+B], [xR,h0+B],
        [xR,L], [0,L],
        [0,0]
    ];

    polygon(points=outline);
}

module linear_bearing(
    type="RJ4JP-01-10",
	cld  =  0.0,    // dia clearance for overextrusion
    sl = 0.0,       // opt. shaft length above/below bearing
    sb = 0.0        // opt. shaft brim width
)
{
    translate([0,0,-_get_length(type)/2])
    union() {
        rotate_extrude(angle=360,convexity=10,$fn = 90)
            translate([cld+0.01,0,0])
                offset(delta=cld)
                    2D_linear_bearing(type);
        if (sl > 0.0) {
            translate([0,0,-sl])
                cylinder(d=_get_outer_dia(type)-sb, h=_get_length(type)+2*sl);
        }
    }
 }



