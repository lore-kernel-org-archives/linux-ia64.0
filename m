From: Jack Steiner <steiner@sgi.com>
Date: Thu, 13 May 2004 14:00:45 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040513140044.GA14588@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 12, 2004 at 09:23:35PM -0700, Dave Hansen wrote:
> On Wed, 2004-05-12 at 20:51, Paul Jackson wrote:
> > Could someone explain to me who's doing what with cpu, memory and node
> > hotplug?
> >
> > And I also just noticed the thread on lkml by Keiichiro, with comments
> > from Dave, mentioning Matthew, hinting at additional interactions that
> > might be desirable between various efforts here.  I even see some SGI
> > work here. 
> 
> I'm working on a little corner of memory hotplug: resizing existing
> zones.  I'll be doing it on hardware that is both NUMA and flat SMP
> systems, with no removal of entire NUMA nodes, at least not yet.  
> 
> We've decided to use CONFIG_NONLINEAR, which has been discussed quite a
> bit before.  It allows you to take discontiguous, nonlinear physical
> memory, and rearrange it so that it can be managed in linear pieces. 
> Basically, this lets us keep the struct zone virtually unchanged because
> we can map any physical memory to any pfn that we like (in certain size
> sections, of course).  This is done for x86, and we're working on
> ppc64.  This code has the potential to replace much of
> CONFIG_DISCONTIGMEM.

Where can I find a copy of the latest CONFIG_NONLINEAR patch? I recall
one that was posted by Dave McCracken in early Apr. Is that the one I should
review?

When we did the initial implementation of CONFIG_DISCONTIGMEM, we
looked briefly at the CONFIG_NONLINEAR patch (or idea) that was
floating around at that time. The patch may have changed so some of 
my initial concerns may no longer apply, but the early patch would
not have performed very well on the SGI hardware. 

The SGI architecture has an absurdly sparse address space. The smallest
memory block is 64MB but the max physical address is 49 bits (500TB).  
IIRC, this resulted in some very large tables used to convert between 
logical & physical addresses. Because of the size of these tables, cache
misses would be common on references to these tables. Is this still a 
valid concern???

Anyway, I'd like to study the latest patch & see how well it would work on our
hardware......


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


