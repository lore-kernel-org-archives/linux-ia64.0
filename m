From: Jack Steiner <steiner@sgi.com>
Date: Fri, 14 Mar 2003 18:51:43 +0000
Subject: [Linux-ia64] Single bundle loops on Itanium-2 sometimes run slow
Message-Id: <marc-linux-ia64-105590709806106@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SUMMARY:
It appears that if a single bundle misaligned loop is interrupted (timer, etc),
when the loop is resumed, it sometimes runs at about 1/3 the normal rate until 
the loop completes. (I dont mean 1 or a few iterations of the loop!!)

	4000000000000eb0:       [MIB]       adds r8=1,r32
	4000000000000eb6:                   adds r32=-1,r32
	4000000000000ebc:                   br.cloop.sptk.few 4000000000000eb0 <compute+0x60>;;


If "noise" is present, pfmon shows significant lost cycles due to BE_LOST_BW_DUE_TO_FE_BR_ILOCK.
A 15 second sample shows:
	BE_LOST_BW_DUE_TO_FE_BR_ILOCK =       423 for good run
	BE_LOST_BW_DUE_TO_FE_BR_ILOCK = 105935651 for noisy run

Changing the test so that code is at different addresses effects the likelyhood
that noise will occur. Sometimes noise occurs on only a subset of the cpus. Sometimes
booting a different kernel changes the likelyhood of seeing noise.

Has anyone seen this behavior or have an explanation. 



-----------------------------------------------------------------------------------------

DETAILS:
We have a test that attempts to measure the amount of system "noise". "Noise" is
time spent away from the user application for servicing interrupts, timers, etc.
The test was run on an Itanium-2 (900 MHz). The system is idle & most daemons have been 
killed.


The relevant parts of the test are:
	- a compute loop 
	- a loop that uses a hardware clock to measure the 
	  actual amount of time it took to execute the compute loop


Here is the code:

	long 
	compute(long work )
	{
        	long i, dum=0;
	
        	for (i =  COMPUTE_K * work; i; i--)
                	dum = i + 1;
	
        	return dum;
	}

	...

	slave(int id) {
		...
	        while (go) {
                	compute(compute_us);
                	getclk(clk);			// uses chipset clock
                	delta = (clk - clkprev)/SCALE;
                	if (delta >= BUCKETS-1) 
                       		stats[id][BUCKETS-1]++;
                	else
                       		stats[id][delta]++;
                	clkprev = clk;
        	}
	}


Sometimes the test runs fine & does not show noise. The following shows the test output with 
a compute loop of 5 usec (other compute times behave as expected). The test should
spin for 5 usec in the compute loop, then read the clock & update 
a histogram that shows how much time was spent in the compute loop. Here is a typical
output of the program:

       0          0
       1          0
       2          0
       3          0
       4          0
       5    1952417
       6     534859
       7          3
       8      13618
       9       1725
      10          8
      11          0
      12          0
      13          1
      14          0
      15          0

There is a spike at 5-6 usec. This is the time that it takes to execute the
compute loop. There is a secondary spike at 8-9 usec. If the compute loop is
interrupted by a timer tick, the time spent in the kernel processing the timer interrupt
must be added to the time required to execute the compute loop. The test shown above ran 
for 15 sec wallclock time. The timer interrupt occurs one every 1/1024 sec or about 1 
interrupt every millisecond. You should expect ~15000 timer ticks during the test period. This
agrees with what was measured.



Sometimes the test shows significant noise:

       0          0
       1          0
       2          0
       3          0
       4          0
       5    1913480
       6     559966
       7          0
       8       1309
       9       1166
      10       1038
      11       1078
      12       1376
      13       1377
      14       1551
      15       1480
      16       1228
     ...
      29        400
      30          0

The spike at 7-8 usec has been smeared/leveled out. It extends to ~30 usec
The total number of samples in the 8-30 usec bins is still ~15000.

Another interesting data point is that the range of the smeared/leveled out data points
depends on the amount of time spent in the compute loop. Running the test with different 
times for the spinloop shows:
	-   5 usec compute loop -> timer tick is smeared by ~30 usec
	- 100 usec compute loop -> timer tick is smeared by ~330 usec
	- 500 usec compute loop -> timer tick is smeared by ~1600 usec


KEY OBSERVATION: 
Note that the smear extends to roughly 3X the size of the compute loop.


Now lets look at the code for the compute loop.  The inner loop that is generated for the 
compute loop is:

	4000000000000eb0:       [MIB]       adds r8=1,r32
	4000000000000eb6:                   adds r32=-1,r32
	4000000000000ebc:                   br.cloop.sptk.few 4000000000000eb0 <compute+0x60>;;

This is a 1-bundle loop that is misaligned. Itanium-2 optimization guides call for 
a minimum of 2 bundles. Furthermore, branch target addresses are suppose to be aligned on 32-byte 
boundaries for best performance. The code shown above branches to an address that does not have
this alignment. 


KEY OBSERVATION:
If I add code to the program to cause the compute loop to be 32byte
aligned OR if I change the compute loop to be a 2-bundle loop, the noise disappears!!!
I have not been successful in seeing ANY noise with a properly aligned compute() loop.


THEORY (yet to be proven):
My working theory at this point is that if the compute loop is interrupted by a 
timer tick, when the loop resumes execution, it runs at 1/3 of it's normal rate 
until the loop completes. This has the effect of lengthening the compute loop 
by 3X of the time remaining in the compute loop. The net effect of this 
lengthing is that the time actually spent in an N usec compute loop should be evenly 
distributed between N and 3N usec.



NOT UNDERSTOOD YET: 
	- whatever is causing the loop to run at 1/3 the normal rate is
	  both kernel dependent & cpu dependent. Some kernels NEVER show noise. Making slight
	  changes in the kernel can cause the noise to appear or disappear. 

	- the noise does not always occur on every cpu. Rebooting the system _may_ cause the
	  noise to move to a different set of cpus.

	- sometimes, nosie appears or disappears without a kernel reboot. This does
	  not occur very often, however.

Different kernels/cpus will reference different data addresses to process a timer
interrupt. Dynamic branch prediction may also change timing. This _might_ be an
explanation, but this has not been proven yet.




ADDITIONAL IMPORTANT DATA:
Here is data from pfmon that shows performance monitor statistics. The
data is collcted separately for user mode & kernel mode. The most
significant statistic is user mode BE_LOST_BW_DUE_TO_FE_BR_ILOCK. This
counter indirectly measures cpu stalls in instruction issue.

Only counters that are significantly different between good & bad runs 
are listed here. (I have the full set if anyone is interested).

User Mode counts
----------------------------------------------------------------------------
    GOOD RUNS    NOISY RUNS        RATIO    STATISTIC COUNTER
----------------------------------------------------------------------------
          426     105935651    248675.24    BE_LOST_BW_DUE_TO_FE_BR_ILOCK
          537          1248         2.32    FE_BUBBLE_FILL_RECIRC
        58714         30960          .53    FE_LOST_BW_BI
      8682390     116343848        13.40    FE_LOST_BW_BR_ILOCK
         1086          2426         2.23    FE_LOST_BW_FILL_RECIRC
          454     107145640    236003.61    IDEAL_BE_LOST_BW_DUE_TO_FE_BR_ILOCK
           15          1265        84.33    IDEAL_BE_LOST_BW_DUE_TO_FE_FILL_RECIRC
        13765           964          .07    L2_IFET_CANCELS_ANY
        13145           448          .03    L2_IFET_CANCELS_BYPASS
          505           129          .26    L2_IFET_CANCELS_DATA_RD



Kernel counts
----------------------------------------------------------------------------
    GOOD RUNS    NOISY RUNS        RATIO    STATISTIC COUNTER
----------------------------------------------------------------------------
          240         22630        94.29    BE_LOST_BW_DUE_TO_FE_FILL_RECIRC
        23652         13271          .56    BUS_OOQ_LIVE_REQ_HI
       218034        326080         1.50    FE_BUBBLE_BRANCH
        11493         13844         1.20    FE_BUBBLE_FILL_RECIRC
       227455        351785         1.55    FE_BUBBLE_GROUP3
        50038        309428         6.18    FE_LOST_BW_BI
         9370          3393          .36    L2_FILLB_FULL_THIS
        14314         24403         1.70    L2_OZQ_CANCELS2_DIDNT_RECIRC
        10194         12999         1.28    L2_OZQ_CANCELS2_RECIRC_OVER_SUB


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


