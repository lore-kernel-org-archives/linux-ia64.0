From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Tue, 14 Jan 2003 22:18:09 +0000
Subject: RE: [Linux-ia64] cpu_halt() question
Message-Id: <marc-linux-ia64-105590709805673@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805669@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805669@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Alex,
It is true that one won't see any great power saving (even assuming the
system was completely idle while you were taking your reading) with
current releases.  It is expected that in future PAL_HALT_LIGHT will be
more power friendly. This may come at a little extra cost though(in
terms of entry and exit latencies).  We will be doing some experiments
internally to understand its impact on few key benchmarks.

rohit

> -----Original Message-----
> From: Alex Williamson [mailto:alex_williamson@hp.com] 
> Sent: Tuesday, January 14, 2003 7:36 AM
> To: Christian Hildner
> Cc: linux ia64 kernel list
> Subject: Re: [Linux-ia64] cpu_halt() question
> 
> 
> Christian,
> 
>    I think what you're after is cpu_idle(), not cpu_halt().  
> cpu_halt is what takes a processor offline, so it's not a 
> performance issue to make an extra PAL call before doing it.
> 
>    I've played around with calling ia64_pal_halt_light() in 
> cpu_idle to see if I could impact the power consumption.  
> Using very crude measurements, the temperature at the back of 
> an i2000 dropped ~10 degrees F adding something simple like:
> 
> if (pm_idle)
>     (*pm_idle)();
> else
>     ia64_pal_halt_light();
> 
> Unfortunately, on McKinley, the PAL_HALT_LIGHT state claims 
> the same power consumption as the full run state.  I've 
> verified that I get almost no change in processor temperature 
> by adding this call.  BTW, this is PAL_A 0.7.31, PAL_B 0.7.36.
> 
> 	Alex
> 
> Christian Hildner wrote:
> > 
> > Hi,
> > 
> > cpu_halt (in process.c) calls ia64_pal_halt_info() every 
> time when it 
> > is called. I assume that cpu_halt is called often and pal_halt_info 
> > will never change for a specific PAL/processor. Why not call
> > ia64_pal_halt_info() once at setup time and save the 
> min_power_state 
> > in a global variable? This would save power (important when Itanium 
> > notebooks are coming) and (if you are lucky) increases 
> performance if 
> > time needed by the two PAL calls is bigger then the time 
> needed by the 
> > external resource to finish.
> > 
> > Additionally a loop including nops instead of the 
> ia64_pal_halt call 
> > could bring a acceleration of the response of an external 
> interruption 
> > (depending on interrupt handling in PAL).
> > 
> > Opinions?
> > 
> > Christian
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org 
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> --
> Alex Williamson                                  Linux Development Lab
> alex_williamson@hp.com                                 Hewlett Packard
> 970-898-9173                                          Fort Collins, CO
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org 
> http://lists.linuxia64.org/lists/listinfo/linu> x-ia64
> 

