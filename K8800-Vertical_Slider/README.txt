K800 - Vertical Slider with linear bearings
Based on Dr. Vegetables work on vertical slider with linear bearings
Features:
- weight: 33g (RJ4JP bearing, 40%) vs. 42g (Velleman/brass bearing)
- selectable bearing:
    - LM10UU (steel)
    - RJ4JP-01-10 ()
    - RJUM1-01-10 ()
    - WIP: Generic
  the Generic must be fixed with zip-tie or wire, whereas the other ones
  are simply snap-in mounted
- adjustable endstop actuator 
    - range: 0-3mm, using a M3x12mm screw
- height win: +10mm (valuable if you use a heated bed)
- belt protection carving
- optional X/Y/Z marker on side of endstop actuator and front of vertical slider
-
The OpenSCAD files allows configuration of
- bearing type
- bearing brim height (upper/lower)
- length of endstop actuator flag (default: 10mm)
- clearance for overextrusion (0 / 1/4 / 1/2 / 3/4 nozzle dia)
- marker for vertical slider / endstop actuator (none, X, Y, Z)
- .slt for test block to check the required clearance (test block + 5 endstops with different clearing)
- .slt for single bearing block (to test the snap in)
- .slt for create endstop actuator with given clearance
- .slt for complete vertical slider incl. one endstop


Always use a zip-tie, otherwise the print head will get very spongy!

I used the following print parameters:
    layer height:       0,175 (= 1/2 nozzle dia)
    initial layer:      0,245
    wall thickness:     1,05 (= 3* nozzle dia)
    top/bottom thickness:    0,7
    build plate:        brim
        brim width:     6mm
        brim only on outside
    infill:             50%
        pattern:        gyroid
    no support
    no alternate skin rotation
    no adaptive layers

You'll need 3 bolds M3x12 (M3x15) for endstop adjustment.
No need to cut the threads
The endstop actuator should sit pretty tight in the belt catch block.

