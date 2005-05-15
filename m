From: James Courtier-Dutton <James@superbug.co.uk>
Date: Sun, 15 May 2005 09:12:21 +0000
Subject: Re: IA64 implementation of timesource for new time of day subsystem
Message-Id: <428722E3.6040202@superbug.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1116029796.26454.2.camel@cog.beaverton.ibm.com>  <1116029872.26454.4.camel@cog.beaverton.ibm.com>  <1116029971.26454.7.camel@cog.beaverton.ibm.com>  <1116030058.26454.10.camel@cog.beaverton.ibm.com> <1116030139.26454.13.camel@cog.beaverton.ibm.com> <Pine.LNX.4.62.0505141251490.18681@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0505141251490.18681@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: john stultz <johnstul@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, Tim Schmielau <tim@physik3.uni-rostock.de>, George Anzinger <george@mvista.com>, albert@users.sourceforge.net, Ulrich Windl <ulrich.windl@rz.uni-regensburg.de>, Dominik Brodowski <linux@dominikbrodowski.de>, David Mosberger <davidm@hpl.hp.com>, Andi Kleen <ak@suse.de>, paulus@samba.org, schwidefsky@de.ibm.com, keith maanthey <kmannth@us.ibm.com>, Chris McDermott <lcm@us.ibm.com>, Max Asbock <masbock@us.ibm.com>, mahuja@us.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>, Darren Hart <darren@dvhart.com>, "Darrick J. Wong" <djwong@us.ibm.com>, Anton Blanchard <anton@samba.org>, donf@us.ibm.com, mpm@selenic.com, benh@kernel.crashing.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Fri, 13 May 2005, john stultz wrote:
> 
> 
>>I look forward to your comments and feedback.
> 
> 
> Here is the implementation of the IA64 timesources for the new time of 
> day subsystem.
> 
> This is quite straighforward. Thanks John. However, the ITC
> interpolator can no longer use MMIO in SMP situations since there is no 
> provision for jitter compensation in the new time of day subsystem. I have
> implemented that via a function now which will slow down clock access
> for non SGI IA64 hardware significantly since it will not be able to use
> the fastcall anymore.
> 
> I am working on the fastcall but I would need a couple of changes
> to the core code to make the following symbols non-static since they
> will need to be accessed from the fast syscall handler:
> 
> timesource
> system_time
> wall_time_offset
> offset_base
> 

Will this mean that Linux will have a monotonic time source?
For media players we need a timesource that does not change under any
circumstances. e.g. User changes the clock time, the monotonic time
source should not change. The monotonic time source should just start at
0 at power on, and continually increase accurately over time. I.e. A
very accurate "uptime" measurement.

James
