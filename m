From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 13 May 2004 04:23:35 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <1084422215.974.25.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-05-12 at 20:51, Paul Jackson wrote:
> Could someone explain to me who's doing what with cpu, memory and node
> hotplug?
>
> And I also just noticed the thread on lkml by Keiichiro, with comments
> from Dave, mentioning Matthew, hinting at additional interactions that
> might be desirable between various efforts here.  I even see some SGI
> work here. 

I'm working on a little corner of memory hotplug: resizing existing
zones.  I'll be doing it on hardware that is both NUMA and flat SMP
systems, with no removal of entire NUMA nodes, at least not yet.  

We've decided to use CONFIG_NONLINEAR, which has been discussed quite a
bit before.  It allows you to take discontiguous, nonlinear physical
memory, and rearrange it so that it can be managed in linear pieces. 
Basically, this lets us keep the struct zone virtually unchanged because
we can map any physical memory to any pfn that we like (in certain size
sections, of course).  This is done for x86, and we're working on
ppc64.  This code has the potential to replace much of
CONFIG_DISCONTIGMEM.

The second bit of work that I have my eyes on are the sysfs interfaces
which will end up being the hotplug memory API to userspace.  I hope to
keep these as simple as possible inside the kernel, exposing enough
information to userspace that it can do most of the work.  For instance,
I certainly hope that an offline procedure for an entire node would
consist of more than one call into the kernel.  offline each memory
section ... offline each cpu ... offline the struct node ...

Although I haven't thought about it much, I would imagine that most of
the node hotplug work will involve very similar operations to the cpu
hotplug work: going through all of the for_each_node() loops and adding
some locking along with some node_possible() vs. node_online() checks.  

-- Dave

