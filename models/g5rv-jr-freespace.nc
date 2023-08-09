// Global variables
real height;
real elem_length, elem_droop, elem_wire;
real feed_length, feed_spacing, feed_wire;
element driven;
int nsegs;
int ndsegs;
real ant_angle;

model ( "g5rv-freespace" ) {

  transform ta;

  nsegs=21; // # segments in non-driven wires
  ndsegs=9; // # segments in driven wire

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
// Antenna detail:

  height = 35;
  elem_length = 7.775; // half-length
  elem_droop = 0.0; // vertical droop at ends
  feed_length = 4.42; // meters
  ant_angle = 15; // rotation angle
  ta=rotateZ(ant_angle);

//****************
// Simulation:

  freespace();
  draw_antenna(ta);

//****************
// Frequencies:


//   addFrequency(  1.900 ); // 160m
//   addFrequency(  3.500 ); // 80m
//   addFrequency(  5.348 ); // 60m
     addFrequency(  7.100 ); // 40m
//   addFrequency( 10.140 ); // 30m
     addFrequency( 14.100 ); // 20m
//   addFrequency( 18.100 ); // 17m
     addFrequency( 21.100 ); // 15m
//   addFrequency( 24.925 ); // 12m
     addFrequency( 28.100 ); // 10m

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

