From: Robin Holt <holt@sgi.com>
Date: Fri, 08 Feb 2008 23:20:36 +0000
Subject: Re: [PATH] Reduce per_cpu allocations to minimum needed for boot
Message-Id: <20080208232036.GL3875@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080208225015.GK3875@sgi.com>
In-Reply-To: <20080208225015.GK3875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 08, 2008 at 03:10:25PM -0800, Luck, Tony wrote:
> > This patch could be using the cpu_possible_map instead of our own.
> > I was reluctant to do that, but there is nothing that prevents it.
> > Does anybody have an opinion?
> 
> I hate to see duplication ... your new "early_cpu_possible_map" should
> just end up with the same contents as "cpu_possible_map" ... won't it?
> 
> Is there some downside to using your new code to initialize the
> existing cpu_possible_map?
> 

Not that I can think of.  The early_cpu_possible_map will be a superset
of the cpu_possible_map.  If the machine does not have numa acpi
information, we will default to (currently 4 cpus) and initialize those
on node 0.  We will then later only set the actual number in the
cpu_possible_map.  There would be nothing (other than the lacking
hardware) which differentiates these processors from ones in the
cpu_possible_map.  If you would like to go with the cpu_possible_map, I
will happily do some testing with that over the weekend.

Could I get some direction on the number of cpus to define when there
are no numa tables?  Do you know what the hardware limitation is for
number of processors on a FSB?

Thanks,
Robin
