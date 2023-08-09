// Global, simulation-wide variables
// must be initialized with call to:
//   sim_initialize()
real zmin;
int nsegs;
int ndsegs;

//************************************************************************
// Notes on the NEC / cocoaNEC Coordinate System
//************************************************************************
// +x axis is map East
// +y axis is map North
// the cocoaNEC manual is confusing on this point, see:
// http://www.w7ay.net/site/Manuals/cocoaNEC/Manual/RefManual/Output.html
// This section is talking about the values in the Azimuth input box
// on the bottom of the Geometry view.
//   1. An azimuth angle of 0 corresponds to placing the eye on 
//      the +x axis and looking back at the antenna. <== TRUE
//   2. An azimuth angle of 90 degrees corresponds to placing 
//      the eye on the +y axis.  <== FALSE
//      Az angle of 90 degs it is actually looking into the -y axis.

model ( "daegu-site" ) {

  transform ta, tb;
  element driven ;
  real height;
  real ant_angle, bldg_angle;
  real radial_hgt;

  sim_initialize(); // initialize simulation-wide variables
  bldg_initialize(); // initializes variables describing the building

//************************************************************************
// Describe some candidate antennas
//************************************************************************

  //================
  // Setup G5RV antenna details:
  //================
  // g5rv_wire_set() function arguments:
  // 1. wire radius of main radiators, legs 1 and 2
  // 2. wire radius of ladder line
  // 3. spacing of ladder line (center-to-center)
  g5rv_wire_set( #14, #16, 0.027562 );
  // g5rv_elem_set() function arguments:
  // 1. length of each leg
  // 2. droop at each end
  // 3. length of feed line matching section
  // ### the antenna you want needs to be the last one in this list
  g5rv_elem_set( 15.55, 0.0, 8.84 ); // g5rv, full size
  g5rv_elem_set( 7.775, 0.0, 4.42 ); // g5rv, half-size

  //================
  // Setup Dipole antenna details:
  //================
  // dipole_wire_set() function arguments:
  // 1. wire radius of main radiators, legs 1 and 2
  dipole_wire_set( #14 );
  // dipole_elem_set() function arguments:
  // 1. length of each leg
  // 2. droop at each end
  // ### the antenna you want needs to be the last one in this list
  dipole_elem_set(  5.0, 0.0 ); // 20m dipole
  dipole_elem_set( 10.153, 2.0 ); // 40m dipole

  //================
  // Setup Rhombic antenna details:
  //================
  // rhom_wire_set() function arguments:
  // 1. wire radius of main radiators, legs 1 and 2
  rhom_wire_set( #14 );
  // rhom_elem_set() function arguments:
  // (only feed gap - for now, assumes corners are the building)
  // 1. feedline /termination gap
  // ### the antenna you want needs to be the last one in this list
  rhom_elem_set( 0.027562 );

  //================
  // Setup Horizontal Loop antenna details:
  //================
  // loop_wire_set() function arguments:
  // 1. wire radius of main radiators, legs 1 and 2
  loop_wire_set( #14 );
  // loop_elem_set() function arguments:
  // (only feed gap - for now, assumes corners are the building)
  // 1. feedline /termination gap
  // ### the antenna you want needs to be the last one in this list
  loop_elem_set( 0.027562 );

//************************************************************************
// Setup the Daegu site details
//************************************************************************
  // * main street alignment, taken from map, 700m E, 500m N, est 35 degs
  // * the bldg is angled add'l 10 degs N of street, or 45 degs (NW)
  // * antenna(s) placed along the diagonals of the roof, est. 30 degs
  // * apex placed at top of pole mounted on hut
  //****************
  bldg_angle = 45.0;
  ant_angle=-30.0;
  height = bldg_apex_height_get();
  // prepare the transformation matrices
  tb = rotateZ(bldg_angle);
  ta = translateTransform( vect( 0, 0, height) ) * rotateZ(bldg_angle + ant_angle);

//************************************************************************
// Now make the things to simulate, ...
//************************************************************************

  //=== (1) Ground
  // averageGround();
  // City ground - see this link:
  // https://hamwaves.com/antennas/doc/4nec2.rtf.pdf
  ground( 5.0, 0.001 );

  //=== (2) Nearby things
  //------  metal roof on the hut (feeble attempt)
  radial_hgt = bldg_hut_roof_height_get();
  radials( 0, 0, radial_hgt, 2.5, #20, 36 );
  //------  building (for visual confirmation only)
  bldg_draw(tb);
  //=== North reference arrow (for Azimuth sanity check only)
  draw_north_arrow();

  //=== (3) Antenna, FINALLY
  // ### uncomment the kind of antenna you want to simulate
  //     (only one can be uncommented)
  // driven=make_g5rv(ta);
  driven=make_dipole(ta);
  // driven=make_rhombic(ta);
  // driven=make_loop(ta);

  voltageFeed( driven, 1.0, 0.0 ) ;

//****************
// Simulation controls
//****************

// ### uncomment the frequency(ies) you want to plot
//     (only four frequencies can be plotted)
//   addFrequency(  1.900 ); // 160m
//   addFrequency(  3.500 ); // 80m
//   addFrequency(  5.348 ); // 60m
//   addFrequency(  7.100 ); // 40m
//   addFrequency( 10.140 ); // 30m
//   addFrequency( 14.100 ); // 20m
//   addFrequency( 18.100 ); // 17m
//   addFrequency( 21.100 ); // 15m
//   addFrequency( 24.925 ); // 12m
//   addFrequency( 28.100 ); // 10m

// ### or do a freqeuncy sweep
     frequencySweep( 7.000, 7.300, 15 );

}


//************************************************************************
// ANTENNA, G5RV 
// These functions generate a G5RV-style antenna
//************************************************************************
// references:
// https://owenduffy.net/transmissionline/300/davis.htm
// http://www.astrosurf.com/luxorion/qsl-g5rv-2.htm
// ladder line calculator site:
// https://hamwaves.com/zc.circular/en/index.html
// feed_spacing = 0.5 * 0.007936; // 300 ohm #16AWG
// feed_spacing = 0.5 * 0.027562; // 450 ohm #16AWG
//************************************************************************
// Global variables (only used by g5rv antenna functions) 
real g5_elem_length, g5_elem_droop, g5_elem_wire;
real g5_feed_length, g5_feed_spacing, g5_feed_wire;

void g5rv_wire_set( real erad, real frad, real fgap ) {
  g5_elem_wire = erad;
  g5_feed_wire = frad;
  g5_feed_spacing = 0.5*fgap; 
}

void g5rv_elem_set( real elem, real esag, real flen ) {
  g5_elem_length = elem;
  g5_elem_droop = esag;
  g5_feed_length = flen;
}

// the antenna is made along the x-azis direction, y-axis is broadside.
// subsequently it is rotated and translated into the proper position 
// using argument #1, the transform variable "t"
element make_g5rv( transform t ) {
  element main_leg1, main_leg2;
  element ladd_leg1, ladd_leg2;
  element g5driven;
  main_leg1 = wirev( t, vect( -g5_elem_length,  0,  -g5_elem_droop ),
                        vect( -g5_feed_spacing, 0,   0 ),
                        g5_elem_wire, nsegs ) ;

  main_leg2 = wirev( t, vect( g5_elem_length,   0,  -g5_elem_droop ),
                        vect( g5_feed_spacing,  0,   0 ),
                        g5_elem_wire, nsegs ) ;

  ladd_leg1 = wirev( t, vect( g5_feed_spacing,  0,   0 ), 
                        vect( g5_feed_spacing,  0,  -g5_feed_length ), 
                        g5_feed_wire, nsegs ) ;

  ladd_leg2 = wirev( t, vect( -g5_feed_spacing, 0,   0 ), 
                        vect( -g5_feed_spacing, 0,  -g5_feed_length), 
                        g5_feed_wire, nsegs ) ;

  g5driven = wirev( t, vect( -g5_feed_spacing, 0, -g5_feed_length ), 
                       vect(  g5_feed_spacing, 0, -g5_feed_length ), 
                       g5_feed_wire, ndsegs ) ;
  return g5driven;

}

//************************************************************************
// ANTENNA, DIPOLE 
// These functions generate a G5RV-style antenna
//************************************************************************
// Global variables (only used by dipole antenna functions) 
real dipole_elem_length, dipole_elem_droop, dipole_elem_wire;

void dipole_wire_set( real erad ) {
  dipole_elem_wire = erad;
}

void dipole_elem_set( real elem, real esag ) {
  dipole_elem_length = elem;
  dipole_elem_droop = esag;
}

element make_dipole ( transform t ) {
  element dipole;
  dipole = wirev( t, vect( -dipole_elem_length, 0, 0 ),
                     vect(  dipole_elem_length, 0, 0 ), 
                     dipole_elem_wire, ndsegs );
  return dipole;
}

//************************************************************************
// ANTENNA, RHOMBIC  
// These functions generate a pseudo-rhombic
// using the dimensions of the building and
// feeding it at a corner
//
//                        2
//                   *         *
//              *                   *
// (feed) 1*            ----> +x         *3 (termination)
//              *                   *
//                   *         *
//                        4
//
//
// simplifications for now:
// * it will be a square, so calculating feed/term gap is easier
// * no termination, just open circuit
//************************************************************************
// Global variables (only used by rhombic antenna functions) 
real rhom_fgap, rhom_elem_wire;
vector rhom_corner[4];

void rhom_wire_set( real erad ) {
  rhom_elem_wire = erad;
}

void rhom_elem_set( real fgap ) {
  bldg_corners_get( rhom_corner );
  rhom_fgap = 0.5 * fgap;
}

// feed point is between corner 1 and 4
// termniation is betwene corner 2 and 3
element make_rhombic ( transform t ) {
  element rhom_leg_l1, rhom_leg_l2, rhom_leg_r1, rhom_leg_r2;
  element rhom;

  rhom_leg_l1 = wirev( t, rhom_corner[0] + vect( 0.0, rhom_fgap*cos(45.0), 0.0), 
                          rhom_corner[1],
                          rhom_elem_wire, nsegs ) ;
  rhom_leg_l2 = wirev( t, rhom_corner[1],
                          rhom_corner[2] - vect( rhom_fgap*cos(45.0), 0.0, 0.0), 
                          rhom_elem_wire, nsegs ) ;
  rhom_leg_r2 = wirev( t, rhom_corner[2] - vect( 0.0, rhom_fgap*cos(45.0), 0.0), 
                          rhom_corner[3],
                          rhom_elem_wire, nsegs ) ;
  rhom_leg_r1 = wirev( t, rhom_corner[3],
                          rhom_corner[0] + vect( rhom_fgap*cos(45.0), 0.0, 0.0), 
                          rhom_elem_wire, nsegs ) ;

  rhom        = wirev( t, rhom_corner[0] + vect( 0.0, rhom_fgap*cos(45.0), 0.0), 
                          rhom_corner[0] + vect( rhom_fgap*cos(45.0), 0.0, 0.0), 
                          rhom_elem_wire, 5 );
  return rhom;
}

//************************************************************************
// ANTENNA, HORIZONAL LOOP  
// These functions generate horizontal loop
// the dimensions of the building and
// feeding it at a side between corners 3 and 4
//
//
//
//    (1) +----------------------------+ (2)
//        |                            |
//        |              +y            |
//        |              ^             |
//        |              |             |
//        |              |             |
//        |              +-----> +x    |
//        |                            |
//        |                            |
//        |                            |
//        |                            |
//    (4) +-----------<feed>-----------+ (3)
//    
//************************************************************************
// Global variables (only used by horizontal loop antenna functions) 
real loop_fgap, loop_elem_wire;
vector loop_corner[4];

void loop_wire_set( real erad ) {
  loop_elem_wire = erad;
}

void loop_elem_set( real fgap ) {
  bldg_corners_get( loop_corner );
  loop_fgap = 0.5 * fgap;
}

// feed point is middle of side 1
element make_loop ( transform t ) {
  element loop_leg1, loop_leg2, loop_leg3, loop_leg4;

  loop_leg1 = wirev( t, loop_corner[0], loop_corner[1],
                          loop_elem_wire, ndsegs ) ;
  loop_leg2 = wirev( t, loop_corner[1], loop_corner[2],
                          loop_elem_wire, nsegs ) ;
  loop_leg3 = wirev( t, loop_corner[2], loop_corner[3],
                          loop_elem_wire, nsegs ) ;
  loop_leg4 = wirev( t, loop_corner[3], loop_corner[0],
                          loop_elem_wire, nsegs ) ;

  return loop_leg3;
}


//************************************************************************
// BUILDING
//************************************************************************
// The building is drawn centered in the XY plane
// Aligned length-wise along the X-axis
// It will be rotated using the transform "t" when drawn
// the dimensions of the building are hard-coded in this function

// Global variables (only used by bldg functions) 
real bldg_hgt, bldg_wid, bldg_len;
real bldg_hgt_hut, bldg_hgt_mast;

void bldg_initialize() {
  bldg_hgt = 30; // 10-story building, estimated 3m/story
  bldg_wid = 15;
  bldg_len = 25;
  bldg_hgt_hut = 3; // hut on roof, est 3m tall
  bldg_hgt_mast = 2; // mast height

}

real bldg_apex_height_get() {
  return bldg_hgt + bldg_hgt_hut + bldg_hgt_mast;
}

real bldg_hut_roof_height_get() {
  return bldg_hgt + bldg_hgt_hut;
}

void bldg_corners_get( vector *corn ) {
  corn[0]=vect( -0.5*bldg_len,  -0.5*bldg_wid, 0 );
  corn[1]=vect( -0.5*bldg_len,   0.5*bldg_wid, 0 ); 
  corn[2]=vect(  0.5*bldg_len,   0.5*bldg_wid, 0 ); 
  corn[3]=vect(  0.5*bldg_len,  -0.5*bldg_wid, 0 ); 
}

void bldg_draw( transform t ) {

  wirev( t, vect( -0.5*bldg_len,  -0.5*bldg_wid, zmin ),
            vect( -0.5*bldg_len,   0.5*bldg_wid, zmin ), 
            #20, nsegs ) ;
  wirev( t, vect( -0.5*bldg_len,   0.5*bldg_wid, zmin ), 
            vect(  0.5*bldg_len,   0.5*bldg_wid, zmin ), 
            #20, nsegs ) ;
  wirev( t, vect(  0.5*bldg_len,   0.5*bldg_wid, zmin ), 
            vect(  0.5*bldg_len,  -0.5*bldg_wid, zmin ), 
            #20, nsegs ) ;
  wirev( t, vect(  0.5*bldg_len,  -0.5*bldg_wid, zmin ), 
            vect( -0.5*bldg_len,  -0.5*bldg_wid, zmin ), 
            #20, nsegs ) ;

  wirev( t, vect( -0.5*bldg_len,  -0.5*bldg_wid, bldg_hgt ), 
            vect( -0.5*bldg_len,   0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;
  wirev( t, vect( -0.5*bldg_len,   0.5*bldg_wid, bldg_hgt ), 
            vect(  0.5*bldg_len,   0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;
  wirev( t, vect(  0.5*bldg_len,   0.5*bldg_wid, bldg_hgt ), 
            vect(  0.5*bldg_len,  -0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;
  wirev( t, vect(  0.5*bldg_len,  -0.5*bldg_wid, bldg_hgt ), 
            vect( -0.5*bldg_len,  -0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;

  wirev( t, vect(  0.5*bldg_len,   0.5*bldg_wid, zmin ), 
            vect(  0.5*bldg_len,   0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;
  wirev( t, vect( -0.5*bldg_len,   0.5*bldg_wid, zmin ), 
            vect( -0.5*bldg_len,   0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;
  wirev( t, vect(  0.5*bldg_len,  -0.5*bldg_wid, zmin ), 
            vect(  0.5*bldg_len,  -0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;
  wirev( t, vect( -0.5*bldg_len,  -0.5*bldg_wid, zmin ), 
            vect( -0.5*bldg_len,  -0.5*bldg_wid, bldg_hgt ), 
            #20, nsegs ) ;
  return;
}


//=== Initialize simulation-wide variables
void sim_initialize() {
  zmin=0.5; // min distance ground wire above ground
  nsegs=21; // # segments in non-driven wires
  ndsegs=5; // # segments in driven wire
}

//=== Arrowhead pointing North
// Just for sanity / point of reference,
// draw an arrow along the positive Y-axis
// which appears as North in the polar azimuth plots
void draw_north_arrow( ) {
  real ahd_wid, arr_len, ahd_len;
  arr_len=5.0;
  ahd_len=2.0;
  ahd_wid=0.75;
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


