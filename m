From: Russ Anderson <rja@sgi.com>
Date: Wed, 18 Oct 2006 22:38:43 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <200610182238.k9IMchjN19614811@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:
> On Wed, Oct 18, 2006 at 04:55:30PM -0500, Jack Steiner wrote:
> > On Wed, Oct 18, 2006 at 02:44:13PM -0700, Stephane Eranian wrote:
> > > Jack,
> > > 
> > > The perfmon subsystem will not work correctly if you mix
> > > Madison and Montecito in the same box. And there is not an
> > > easy way to make it work with such configuration. Performance
> > > counters are different between the two models.
> >  
> > The failing case that I ran into was a mixture of rev 5 & rev 7
> > montecitos:
> >         Intel(r) Itanium(r) 2 Processor 1.6GHz with 24M L3 Cache for 533MHz Platforms
> >         Intel(r) Itanium(r) 2 Processor 1.6GHz with 18M L3 Cache for 533MHz Platforms
> > 
> > I assume that will work ok. Right?
> > 
> Yes, I think for this you are ok.
> 
> > However, there is also a patch that Russ Anderson pushed last week (at least
> > I think he pushed it). We are planning to support systems with mixtures of both
> > madison & montecito. Sounds like we have a problem :-(
> > 
> Yes, I recall seeing something along those lines not too long ago...

http://marc.theaimsgroup.com/?l=linux-ia64&m6070997529216&w=2

> With the existing perfmon v2.0, All the PMU description tables are compiled in.
> 
> I think what we could do is to detect we have a mixed (family) configuration
> and drop to the generic (architected) PMU with only 4 counters and 2 events. That
> is, I am afraid, the best we could do.

Tony's test kernel (plus Jack's patch and my patch) boots on a mixed Montecito
and Madison system.  Perfmon runs, though I'm not sure what to look for
to tell if it is not functioning properly.


---------------------
saturn2-7:~ # profile.pl --kernel-only -T 10
profile.pl: found pfmon version 3.0.
profile.pl: run profile for 10 seconds.
profile.pl: no_dplace=1....c_opt=.
profile.pl: Samples/tick defaults to: 13940008 for event CPU_CYCLES.
profile.pl: pfmon command: /usr/bin/pfmon --system-wide --smpl-outfile=/tmp/sample.out.4022 --smpl-entries0000  -k --short-smpl-periods940008 --smpl-module=compact-ia64 --events=CPU_CYCLES --relative  -t 10
profile.pl: Running a timed profile for 10 seconds:
<session to end in 10 seconds>
profile.pl: Profile complete.
profile.pl: Checking the profile results.
profile.pl: Merging sample files into a single file.
profile.pl: my_partition_id=0 makemap_partition_id=0.
profile.pl: Running the profile analyzer.
profile.pl: analyze.pl kernel_only /tmp/sample.out.4022 profile.out  --system-map /proc/kallsyms
analyze,pl: Using /proc/kallsyms as the kernel map file.
analyze.pl: Read 13679 symbols from /proc/kallsyms.
analyze.pl: total observations: 1017
profile.pl: Profile results are in file: profile.out.
profile.pl: Removing the sample files.
profile.pl: Normal exit.
saturn2-7:~ # cat profile.out
user ticks:             0               0 %
kernel ticks:           1017            100 %
idle ticks:             1015            99.8 %

Using /proc/kallsyms as the kernel map file.
==================================
                           Kernel

      Ticks     Percent  Cumulative   Routine
                          Percent
--------------------------------------------------------------------
       1015       99.80    99.80      default_idle
          1        0.10    99.90      get_page_from_freelist
          1        0.10   100.00      hrtimer_run_queues
==================================



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
