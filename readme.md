# Ham Radio Antenna Simulation Notes

Back in the summer of 2020, I helped a friend do some NEC modeling for a
proposed G5RV antenna atop his home in Daegu, South Korea (he has since
moved away). These are the results of those investigations, posted online
in 2023 and without review. YMMV.

Here is a
[blog post](https://thestumbler.io/projs/hamradio/01-antenna-modeling.html)
about the project that I wrote up at the time.

## Computer

I ran these simulations on Mac Mini computer in whatever MacOS was in
use at the time (my friend was also used a Mac, so it seemed like a good
choice). I don't recall any OS limitaions with the NEC code, although
the analyses herein use a MacOS incarnation called cocoaNEC. If you're
using Linux or Windows, I think there is still a lot of applicable
information here to help get someone started.

## Helpful References:

* [CocoaNEX Manual:](http://www.w7ay.net/site/Manuals/cocoaNEC/index.html)

* [NEC2 Documentation](https://www.nec2.org/other/nec2prt3.pdf)

* [Interesting article (makes Card Stack input easier)](https://owenduffy.net/blog/?p=3047)

* [Notes on using NEC2 to simulate antennas](http://www.ipellejero.es/tecnico/nec-2/english.php#5)

* [Report compiled by Larry James LeBlanc](https://www.w5ddl.org/files/Zs6bkw_vs_G5rv_20100221b.pdf)
  - see page 38 of 96 for input data for his G5RV antenna.


## Details:

* rooftop 10 stories tall, about 35m
* diagonal distance of rectangular roof is about 30m
* see images in the `pic` folder

