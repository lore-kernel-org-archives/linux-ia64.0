From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 04 Nov 2004 17:16:28 +0000
Subject: Re: [RFC] prefer allocations from nodes w/o CPUs
Message-Id: <200411040916.28946.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411040857.25664.jbarnes@engr.sgi.com>
In-Reply-To: <200411040857.25664.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, November 4, 2004 9:11 am, Alex Williamson wrote:
> On Thu, 2004-11-04 at 08:57 -0800, Jesse Barnes wrote:
> > Small patch for the ia64 version of topology.h to make the zonelist
> > building code prefer nodes w/o CPUs for allocations.  Do any platforms
> > aside from Altix have nodes with only memory?  If not, then this will
> > only affect sn2, otherwise I'm interested in hearing feedback.
>
>    Yes, hp sx1000 systems represent interleaved memory in a separate
> node w/o cpus.

So does this patch make sense for those platforms too?  Or do we need 
something fancier?  It'll make nodes w/o CPUs come before nodes with CPUs in 
the zonelist (after the local node of course), even if the nodes with CPUs 
are closer.

Jesse
