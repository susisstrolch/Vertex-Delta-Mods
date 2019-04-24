// Velleman Vertex Delta K8800 CAD (.stl) files
//
// simple modules for importing the Velleman Vertex Delta .STP files

// root directory (from github)
CADpath = "/bay/Development/3D-Print/Velleman/Vertex-Delta-CAD/";

function stlFile(name) = str(CADpath,name,"/",name,".stl");

module importSTL(name) {
    echo(str("trying to import ",name));
    import(stlFile(name));
}

// ----------------
// raw CAD imports
module stl_K8800_BAP() {
    importSTL("K8800-BAP");
}
module stl_K8800_BC() {
    importSTL("K8800-BC");
}
module stl_K8800_BP() {
 importSTL("K8800-BP");
}
module stl_K8800_BPC() {
 importSTL("K8800-BPC");
}
module stl_K8800_CO10() {
 importSTL("K8800-CO10");
}
module stl_K8800_DR() {
 importSTL("K8800-DR");
}
module stl_K8800_EH() {
 importSTL("K8800-EH");
}
module stl_K8800_EM() {
 importSTL("K8800-EM");
}
module stl_K8800_EP() {
 importSTL("K8800-EP");
}
module stl_K8800_EXP() {
 importSTL("K8800-EXB");
}
module stl_K8800_EXSENS() {
 importSTL("K8800-EXSENS");
}
module stl_K8800_FANIN() {
 importSTL("K8800-FANIN");
}
module stl_K8800_GP() {
 importSTL("K8800-GP");
}
module stl_K8800_KN() {
 importSTL("K8800-KN");
}
module stl_K8800_LB10() {
 importSTL("K8800-LB10");
}
module stl_K8800_LCDIN() {
 importSTL("K8800-LCDIN");
}
module stl_K8800_MAGNET() {
 importSTL("K8800-MAGNET");
}
module stl_K8800_MBC() {
 importSTL("K8800-MBC");
}
module stl_K8800_MC() {
 importSTL("K8800-MC");
}
module stl_K8800_NMA() {
 importSTL("K8800-NMA");
}
module stl_K8800_NMB() {
 importSTL("K8800-NMB");
}
module stl_K8800_POWIN() {
 importSTL("K8800-POWIN");
}
module stl_K8800_RD10() {
 importSTL("K8800-RD10");
}
module stl_K8800_RI() {
 importSTL("K8800-RI");
}
module stl_K8800_SM() {
 importSTL("K8800-SM");
}
module stl_K8800_TAP() {
 importSTL("K8800-TAP");
}
module stl_K8800_VS() {
 importSTL("K8800-VS");
}
module stl_K8800_WC() {
 importSTL("K8800-WC");
}

// stl_K8800_RI();
