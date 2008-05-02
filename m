From: Russ Anderson <rja@sgi.com>
Date: Fri, 02 May 2008 17:30:17 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v2
Message-Id: <20080502173017.GF7246@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004425.GD12006@sgi.com> <84144f020805020258x56d4f915u5d826d8f19294d62@mail.gmail.com> <20080502164044.GB7246@sgi.com> <Pine.LNX.4.64.0805021945001.3341@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0805021945001.3341@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>, gregkh@suse.de

On Fri, May 02, 2008 at 07:57:44PM +0300, Pekka J Enberg wrote:
> Hi Russ,
> 
> On Fri, 2 May 2008, Russ Anderson wrote:
> > > I think sparse and checkpatch would have caught most of these but here goes:
> > 
> > I did run checkpatch.pl.  The two warnings were a false positive and
> > the other I let slide.  I'll make the rest of your suggested changes.
> > 
> > WARNING: consider using strict_strtoul in preference to simple_strtoul
> > #340: FILE: arch/ia64/kernel/cpe_migrate.c:301:
> > +       opt = simple_strtoul(optstr, NULL, 0);
> 
> Why do you think this is a false positive?

The false positive is:
---
WARNING: Use #include <linux/mca.h> instead of <asm/mca.h>
#77: FILE: arch/ia64/kernel/cpe_migrate.c:40:
+#include <asm/mca.h>
---

linux/mca.h is a different file than asm-ia64/mca.h, so using
<linux/mca.h> instead of <asm/mca.h> will cause build problems.


>                       We just converted SLUB over to 
> use strict_stroul() as suggested by Andrew.

I'll use strict_stroul().

> > > >  +       if (cpe_paddr[cpe_head] = 0) {
> > > >  +               cpe_paddr[cpe_head] = paddr;
> > > >  +               cpe_node[cpe_head] = node;
> > > >  +
> > > >  +               if (++cpe_head >= CE_HISTORY_LENGTH)
> > > >  +                       cpe_head = 0;
> > > >  +       }
> > > >  +
> > > >  +       if (!work_scheduled) {
> > > >  +               work_scheduled = 1;
> > > >  +               schedule_work(&cpe_enable_work);
> > > 
> > > So you must not schedule cpe_enable_work if it's already in progress. Why?
> > 
> > If there is already a worker thread scheduled, it will process all
> > the addresses on the queue, including new entries.  So all ce_setup_migrate()
> > needs to do is add the new entry to the queue.  The CPE interrupt can come in faster
> > than the worker thread can migrate the pages.  Scheduling another worker 
> > thread on each CPE interrupt when there is already one scheduled/running
> > would be overkill.
> 
> Okay. Maybe a kthread would be cleaner here then (which sleeps when the 
> buffer is empty)? I didn't notice any locking for cpe_paddr and cpe_node. 
> Why is that?

Do you mean a lock so that cpe_paddr & cpe_node are updated atomicly?
The hole being the new page is allocated on a different node than the
old page.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
