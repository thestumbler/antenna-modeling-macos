model ( "dipole" )
{
	real height, length ;
	element driven ;

	height = 40' ;
	length = 5.0 ;
	driven = wire( 0, -length, height, 0, length, height, #14, 21 ) ;
	voltageFeed( driven, 1.0, 0.0 ) ;
  averageGround();
  radials( 0, 0, 28', 2.5, #20, 36 );

// addFrequency(  1.900 ); // 160m
// addFrequency(  3.500 ); // 80m
   addFrequency(  5.348 ); // 60m
   addFrequency(  7.100 ); // 40m
   addFrequency( 10.140 ); // 30m
   addFrequency( 14.100 ); // 20m
// addFrequency( 18.100 ); // 17m
// addFrequency( 21.100 ); // 15m
// addFrequency( 24.925 ); // 12m
// addFrequency( 28.100 ); // 10m

}


control () {

  runModel();

}
