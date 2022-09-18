$fn = 30;

pin_length = 50;
pin_spacing = 10;
pin_width = 10;
pin_thickness = 5;

tooth_count = 3;
tooth_thickness = 3;

module tooth(width, height, thickness, slope) {
    linear_extrude(height = thickness, center = true, convexity = 10, twist = 0)
    polygon(points=[[0,0],[width*slope,0],[width,height]]);
}

module teeth(teeth_count, tooth_width, tooth_height) {
    for(tooth_offset = [0 : tooth_width : tooth_width*(teeth_count-1)]) {
        translate([tooth_offset, 0, 0]) tooth(tooth_width, tooth_height, tooth_thickness, 0.7);
    }
}

// centered polygon to define cross-section of the pin 
module cross_cut() {
    //square([pin_thickness, pin_width], center = true);
    scale([pin_thickness / pin_width, 1]) circle(d = pin_width);
}

module leg() {
    // distance from center to a leg
    leg_offset = pin_spacing / 2 + pin_thickness / 2;
    
    // arc
    rotate(a=[90,0,0])
    rotate_extrude(convexity = 10, angle = 90)
    translate([leg_offset, 0, 0])
    cross_cut();
    
    // leg
    translate([0,0,-pin_length])
    linear_extrude(height = pin_length, center = false, convexity = 10, twist = 0)
    translate([leg_offset, 0, 0])
    cross_cut();
    
    // rounded end of the leg
    translate([leg_offset, 0,-pin_length]) rounded_end();
}

module rounded_end() {
    cut_size = max(pin_width, pin_thickness);

    rotate(a=[90, 0, 0])
    rotate_extrude(convexity = 10, angle = 180)
    difference() {
        cross_cut();
        translate([0, -cut_size / 2, 0]) square(cut_size);
    }
}

module pin() {
    leg();
    rotate([0, 0, 180]) leg();
    
    // teeth
    tooth_width = pin_length / tooth_count*0.7;
    tooth_height = pin_spacing * 0.55;
    translate([pin_spacing/2, 0, -pin_length]) rotate([90, -90, 0]) union() {
        teeth(tooth_count, tooth_width, tooth_height);
        translate([tooth_width/3,pin_spacing,0]) mirror([0,1,0]) teeth(tooth_count, tooth_width, tooth_height);
}}

pin();