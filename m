From: john stultz <johnstul@us.ibm.com>
Date: Thu, 29 Jul 2004 18:37:51 +0000
Subject: Re: [PATCH] minor cyclone cleanup
Message-Id: <1091126270.1388.622.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407291054.05720.bjorn.helgaas@hp.com>
In-Reply-To: <200407291054.05720.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-07-29 at 10:13, Bjorn Helgaas wrote:
> On Thursday 29 July 2004 11:02 am, john stultz wrote:
> > Stay tuned! As soon as I finish reworking the NTP code bI'll be mailing
> > out code. 
> 
> Ah, an NTP expert :-)  

Ha! Hardly. Although after looking at the kernel code, I'm starting to
wonder if anyone was ever. And even if I learn a thing or two about the
topic, I'm sure to disavow all knowledge for fear of being pigeon-holed
for the rest of my life ;)

> What do you think about adding an RTC driver
> to NTP?  On our boxes (and I suspect many others), the system clock
> is driven by  the interval timer.  But the RTC is much more accurate,
> so it'd be nice if NTP knew how to use it.

With my re-work, the system clock is driven from a time-source, not the
interval timer. That time-source is the only semi-arch-specific bit in
the code, so it can be the ITC, the cyclone counter, HPET, or even the
RTC. Its not all that different then ia64's time_interpolator
infrastructure, just cleaned up and simplified a bit. 

> The RTC is terribly slow and has low resolution, but in the absence of
> anything better, it'd be nice if we could use it.

Indeed, using the RTC for gettimeofday and friends would be quite
painful, and almost so low res as to be worthless, so I doubt you'd
really want to use it. 

> Is this possible?  Feasible?  I know the NTP guys would probably
> laugh us out of the room, but not everybody has a fancy clock
> attached to their box.

Another idea would be to make a userspace daemon who would read the RTC
and use the kernel's adjtimex() syscall to manipulate time. This would
be just like the userspace NTP daemon, only using the RTC instead of a
timeserver. Not having sub-second resolution would mean it would have to
be conservative and take quite some time to sync up, but it would be
possible. 

Whats wrong with using regular NTP, btw?

thanks
-john

