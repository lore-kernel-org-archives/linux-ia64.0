From: alext@fc.hp.com (Alex Tsariounov)
Date: Thu, 04 Nov 2004 17:32:36 +0000
Subject: Re: [RFC] prefer allocations from nodes w/o CPUs
Message-Id: <20041104173236.GB2516@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411040857.25664.jbarnes@engr.sgi.com>
In-Reply-To: <200411040857.25664.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 04, 2004 at 10:11:19AM -0700, Alex Williamson wrote:
> On Thu, 2004-11-04 at 08:57 -0800, Jesse Barnes wrote:
> > Small patch for the ia64 version of topology.h to make the zonelist building 
> > code prefer nodes w/o CPUs for allocations.  Do any platforms aside from 
> > Altix have nodes with only memory?  If not, then this will only affect sn2, 
> > otherwise I'm interested in hearing feedback.
> 
>    Yes, hp sx1000 systems represent interleaved memory in a separate
> node w/o cpus.

So what's the ramifications of this patch?  Does this mean that
interleaved memory will now be preferably allocated over cell
local memory on sx1000 systems?

Thanks,
Alex Tsariounov
