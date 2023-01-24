/*
Generic parametric 3D-printable rectangular project box
Jenny List 2023
CC-BY-SA 4.0

projectBox() is the box itself
projectBox(x,y,z,cornerRadius=3,wallThickness=1,threadRadius=1.25)
x,y,and z are the three outer dimensions of the box

projectBoxLid() generates the corresponding box lid, upside down for printing
projectBoxLid(x,y,z,cornerRadius=3,wallThickness=1,threadRadius=1.25,toleranceGap=0.1)

Support over the bed will give nicer screw holes on the lid.

*/


//Module for generic solid box with rounded corners
module zRoundedBox(boxX,boxY,boxZ,CornerRadius){
    linear_extrude(boxZ){
        hull() {
            //translate([CornerRadius,CornerRadius,0]) square([boxX-CornerRadius,boxY-CornerRadius]);
            translate([CornerRadius,CornerRadius,0]) circle(CornerRadius,$fn=90);
            translate([CornerRadius,boxY-CornerRadius,0]) circle(CornerRadius,$fn=90);
            translate([boxX-CornerRadius,CornerRadius,0]) circle(CornerRadius,$fn=90);
            translate([boxX-CornerRadius,boxY-CornerRadius,0]) circle(CornerRadius,$fn=90);
        }
    }
}

//Open lidless project box
module projectBox(x,y,z,cornerRadius=3,wallThickness=1,threadRadius=1.25){
    difference(){
        zRoundedBox(x,y,z,cornerRadius); //outer box     
        innerBoxCornerRadius = cornerRadius - wallThickness;
        translate([wallThickness,wallThickness,wallThickness]) { // carve outspace inside box
            if(innerBoxCornerRadius < 1){ //radius of inner box corners can't be zero, we limit it to 1.
                zRoundedBox(x-(2*wallThickness),y-(2*wallThickness),z-wallThickness,1);
            }
            else{
                zRoundedBox(x-(2*wallThickness),y-(2*wallThickness),z-wallThickness,innerBoxCornerRadius);
            }
        }
    }
    translate([cornerRadius,cornerRadius,wallThickness]) cornerScrewPillar(z-(2*wallThickness),cornerRadius,threadRadius);
    translate([x-cornerRadius,cornerRadius,wallThickness]) cornerScrewPillar(z-(2*wallThickness),cornerRadius,threadRadius);
    translate([cornerRadius,y-cornerRadius,wallThickness]) cornerScrewPillar(z-(2*wallThickness),cornerRadius,threadRadius);
    translate([x-cornerRadius,y-cornerRadius,wallThickness]) cornerScrewPillar(z-(2*wallThickness),cornerRadius,threadRadius);  
    
    //Generic PCB standoff
    module cornerScrewPillar(height=20,radius=2.5,threadRadius=1.25){
        difference(){
            cylinder(height,radius,radius); //The stand off itself
            cylinder(height,threadRadius,threadRadius); //width of screw thread
        }
    }

}

//Project box lid
module projectBoxLid(x,y,z,cornerRadius=3,wallThickness=1,threadRadius=1.25,toleranceGap=0.1){

   difference(){
        union(){
            zRoundedBox(x,y,wallThickness,cornerRadius);   //Top plate of lid
            translate([wallThickness+toleranceGap,wallThickness+toleranceGap,wallThickness]) { // Inner lip
                innerBoxCornerRadius = cornerRadius - wallThickness;
                if(innerBoxCornerRadius < 1){ //radius of inner box corners can't be zero, we limit it to 1.
                    zRoundedBox(x-(2*(wallThickness+toleranceGap)),y-(2*(wallThickness+toleranceGap)),wallThickness,1);
                }
                else{
                    zRoundedBox(x-(2*(wallThickness+toleranceGap)),y-(2*(wallThickness+toleranceGap)),wallThickness,innerBoxCornerRadius);
                }
            }
        }
        // carve out screw holes
        translate([cornerRadius,cornerRadius,0]) screwHole();
        translate([x-cornerRadius,cornerRadius,0])  screwHole();
        translate([cornerRadius,y-cornerRadius,0])  screwHole();
        translate([x-cornerRadius,y-cornerRadius,0])  screwHole();
        // carve out space for screw head
        translate([cornerRadius,cornerRadius,0]) screwHeadSpace();
        translate([x-cornerRadius,cornerRadius,0]) screwHeadSpace();
        translate([cornerRadius,y-cornerRadius,0]) screwHeadSpace();
        translate([x-cornerRadius,y-cornerRadius,0]) screwHeadSpace();
        //Carve out main inside face
        innerBoxCornerRadius = cornerRadius - 2*wallThickness;
        translate([2*wallThickness,2*wallThickness,wallThickness]) {
            difference(){
                if(innerBoxCornerRadius < 1){ //radius of inner box corners can't be zero, we limit it to 1.
                    zRoundedBox(x-(4*wallThickness),y-(4*wallThickness),wallThickness,1);
                }
                else{
                    zRoundedBox(x-(4*wallThickness),y-(4*wallThickness),wallThickness,innerBoxCornerRadius);
                }
                //leave some material round the screw holes
                cylinder(wallThickness,cornerRadius*1.5,cornerRadius*1.5, $fn=90);
                translate([x-(4*wallThickness),0,0]) cylinder(wallThickness,cornerRadius*1.5,cornerRadius*1.5, $fn=90);
                translate([0,y-(4*wallThickness),0]) cylinder(wallThickness,cornerRadius*1.5,cornerRadius*1.5, $fn=90);
                translate([x-(4*wallThickness),y-(4*wallThickness),0]) cylinder(wallThickness,cornerRadius*1.5,cornerRadius*1.5, $fn=90);  
            }
        }
    }
    //modules for screw hole components
    module screwHole(){
        cylinder(wallThickness*2,threadRadius*1.2,threadRadius*1.2, $fn=90);
    }
    module screwHeadSpace(){
        cylinder(wallThickness/2,cornerRadius,cornerRadius, $fn=90);
    }
}


 projectBox(100,70,30,3,1,1.25);
 translate([0,80,0]) projectBoxLid(100,70,30,3,1,1.25);


