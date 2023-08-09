// Global variables
real height, hgt_bldg, hgt_hut, hgt_mast;
real elem_length, elem_droop, elem_wire;
real feed_length, feed_spacing, feed_wire;
real wid_bldg, len_bldg;
real ant_angle, bldg_angle;
real zmin;
real ahd_wid, arr_len, ahd_len;
int nsegs;
int ndsegs;
element driven ;

// Coordinate System
// +x axis is East
// +y axis is North


// Geography of the antenna installation
//
// * alignment street (taken from map)
//   street angle: 700m east, 500m north, about 35 degrees north of east,
// * House looks to be angled additional 10 degs north of street
//

// Antenna Details
// * Standard G5RV, except using 450-ohm ladder line vs 300
//
// https://owenduffy.net/transmissionline/300/davis.htm
// http://www.astrosurf.com/luxorion/qsl-g5rv-2.htm


model ( "g5rv-dipole" ) {
  transform ta, tb;

  nsegs=21; // # segments in non-driven wires
  ndsegs=9; // # segments in driven wire


// Arrowhead pointing North
  arr_len=5.0;
  ahd_len=2.0;
  ahd_wid=0.75;

//****************
// Wire Types:

  // radiating wire details:
  elem_wire = #14; // #14 AWG (radius)

  // twin-line details:
  // ladde line calculator site:
  // https://hamwaves.com/zc.circular/en/index.html
  feed_wire = #16; // #16 AWG (radius)
  // feed_spacing = 0.5 * 0.007936; // 300 ohm #16AWG
  feed_spacing = 0.5 * 0.027562; // 450 ohm #16AWG

//****************
// Environment

  wid_bldg = 15;
  len_bldg = 25;
	hgt_bldg = 30; // 10-story building, estimated 3m/story
	hgt_hut = 3; // hut on roof, est 3m tall
  hgt_mast = 2; // mast height
  bldg_angle = 45; // angle of building with X-axis (East)
  // other 
  zmin=0.5; // min distance ground wire above ground

//****************
// Antenna details:

  // antenna will be placed along the
  // building diagonally, about 30 degs
  ant_angle=-30.0;

  // height at apex
	height = hgt_bldg + hgt_hut + hgt_mast;

	elem_length = 15.55; // half-length
  elem_droop = 0.0; // vertical droop at ends
  feed_length = 8.84; // meters

  tb = rotateZ(bldg_angle);
  ta = rotateZ(bldg_angle + ant_angle);


//****************
// Simulation:

// averageGround();
// City ground - see this link:
//  https://hamwaves.com/antennas/doc/4nec2.rtf.pdf
  ground( 5.0, 0.001 );

  // attempt to simulate a metal roof on the hut
  radials( 0, 0, hgt_bldg+hgt_hut, 2.5, #20, 36 );
  draw_north_arrow();
  draw_building(tb);
  draw_antenna(ta);

//****************
// Frequencies:

//   addFrequency(  1.900 ); // 160m
     addFrequency(  3.500 ); // 80m
//   addFrequency(  5.348 ); // 60m
     addFrequency(  7.100 ); // 40m
//   addFrequency( 10.140 ); // 30m
     addFrequency( 14.100 ); // 20m
//   addFrequency( 18.100 ); // 17m
     addFrequency( 21.100 ); // 15m
//   addFrequency( 24.925 ); // 12m
//   addFrequency( 28.100 ); // 10m


}

// draws the antenna along the x-azis direction,
// y-axis is broadside.
void draw_antenna( transform t ) {
	wirev( t, vect( -elem_length,  0,   height-elem_droop ),
            vect( -feed_spacing, 0,   height ),
        elem_wire, nsegs ) ;

	wirev( t, vect( elem_length,   0,  height-elem_droop ),
            vect( feed_spacing,  0,  height ),
        elem_wire, nsegs ) ;

	wirev( t, vect( feed_spacing,  0,  height ), 
            vect( feed_spacing,  0,  height-feed_length ), 
        feed_wire, nsegs ) ;

	wirev( t, vect( -feed_spacing, 0,   height), 
            vect( -feed_spacing, 0,   height-feed_length), 
        feed_wire, nsegs ) ;

	driven = wirev( t, vect( -feed_spacing, 0, height-feed_length ), 
                     vect(  feed_spacing, 0, height-feed_length ), 
                 feed_wire, ndsegs ) ;

	voltageFeed( driven, 1.0, 0.0 ) ;
}


// The building is drawn centered in the XY plane
// Aligned length-wise along the X-axis
void draw_building( transform t ) {

	wirev( t, vect( -0.5*len_bldg,  -0.5*wid_bldg, zmin ),
	          vect( -0.5*len_bldg,   0.5*wid_bldg, zmin ), 
            #20, nsegs ) ;
	wirev( t, vect( -0.5*len_bldg,   0.5*wid_bldg, zmin ), 
	          vect(  0.5*len_bldg,   0.5*wid_bldg, zmin ), 
            #20, nsegs ) ;
	wirev( t, vect(  0.5*len_bldg,   0.5*wid_bldg, zmin ), 
	          vect(  0.5*len_bldg,  -0.5*wid_bldg, zmin ), 
            #20, nsegs ) ;
	wirev( t, vect(  0.5*len_bldg,  -0.5*wid_bldg, zmin ), 
	          vect( -0.5*len_bldg,  -0.5*wid_bldg, zmin ), 
            #20, nsegs ) ;

	wirev( t, vect( -0.5*len_bldg,  -0.5*wid_bldg, hgt_bldg ), 
	          vect( -0.5*len_bldg,   0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;
	wirev( t, vect( -0.5*len_bldg,   0.5*wid_bldg, hgt_bldg ), 
	          vect(  0.5*len_bldg,   0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;
	wirev( t, vect(  0.5*len_bldg,   0.5*wid_bldg, hgt_bldg ), 
	          vect(  0.5*len_bldg,  -0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;
	wirev( t, vect(  0.5*len_bldg,  -0.5*wid_bldg, hgt_bldg ), 
	          vect( -0.5*len_bldg,  -0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;

	wirev( t, vect(  0.5*len_bldg,   0.5*wid_bldg, zmin ), 
	          vect(  0.5*len_bldg,   0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;
	wirev( t, vect( -0.5*len_bldg,   0.5*wid_bldg, zmin ), 
	          vect( -0.5*len_bldg,   0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;
	wirev( t, vect(  0.5*len_bldg,  -0.5*wid_bldg, zmin ), 
	          vect(  0.5*len_bldg,  -0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;
	wirev( t, vect( -0.5*len_bldg,  -0.5*wid_bldg, zmin ), 
	          vect( -0.5*len_bldg,  -0.5*wid_bldg, hgt_bldg ), 
            #20, nsegs ) ;
  return;
}

// Just for sanity / point of reference,
// draw an arrow along the positive Y-axis
// which appears as North in the polar azimuth plots
void draw_north_arrow( ) {
	wire(  0,  0, zmin, 
	       0, arr_len, zmin, 
         #20, 1 ) ;
	wire( -ahd_wid, arr_len-ahd_len, zmin, 
	       0, arr_len, zmin, 
         #20, 1 ) ;
	wire(  ahd_wid, arr_len-ahd_len, zmin, 
	       0, arr_len, zmin, 
         #20, 1 ) ;
}
