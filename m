From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 08 Sep 2004 22:10:08 +0000
Subject: Re: [PATCH] general config option cleanup
Message-Id: <200409081510.08823.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409081447.38703.jbarnes@engr.sgi.com>
In-Reply-To: <200409081447.38703.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, September 8, 2004 3:03 pm, Matthew Wilcox wrote:
> On Wed, Sep 08, 2004 at 02:47:38PM -0700, Jesse Barnes wrote:
> > As threatened, here's a patch that unifies the ia64 memory init and
> > memmap codepaths by unconditionalizing the CONFIG_VIRTUAL_MEM_MAP code
> > and making CONFIG_DISCONTIGMEM required.  It also allows building with
> > CONFIG_SMP=n and/or CONFIG_NUMA=n.  The end result should be easier to
> > understand and hack on, and should make things like memory hotplug that
> > much easier since people will only have to worry about one code path
> > instead of every combination of the three options.
>
> I don't really like this.  It penalises platforms like Intel's Tiger box
> that have contiguous memory.  I'd really like to see VIRTUAL_MEM_MAP go
> away and the DISCONTIGMEM code be usable for both zx1/sx1000 and sn2.

Have you tried to measure the penalty for discontigmem?  I have, and without 
writing a kernel module that counts the number of alloc_pages calls one could 
do in a tight loop, I don't think it's measurable.  virtual memmap is a 
little more expensive (i.e. it shows up on benchmarks as something slightly 
more than noise), but isn't the simplification worth it?  We've had 
CONFIG_DISCONTIGMEM=y/n and/or CONFIG_VIRTUAL_MEM_MAP=y/n breakages several 
times now...

Jesse
