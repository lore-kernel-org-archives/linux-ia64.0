From: Russ Anderson <rja@sgi.com>
Date: Fri, 02 May 2008 20:27:45 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v2
Message-Id: <20080502202744.GA13285@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004425.GD12006@sgi.com> <87fxt0vbu4.fsf@basil.nowhere.org> <20080502185030.GH7246@sgi.com> <481B6CA2.8080006@firstfloor.org>
In-Reply-To: <481B6CA2.8080006@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

On Fri, May 02, 2008 at 09:33:54PM +0200, Andi Kleen wrote:
> Russ Anderson wrote:
> > 
> > The code migrates on the first correctable error on a page, so "excessive"
> > is one.  Yes, keeping a per page count gets problematic, especially as
> > memories get larger.  The issue of the right metric for when to migrate
> > will always be debatable and the "right" answer likely will depend on
> > the physical memory technology.
> 
> That doesn't sound like a good metric. What happens for example if you
> have a flakey memory controller or DIMM socket that just occasionally
> adds bit errors on transfer without the DIMM actually being bad? I doubt
> such a simple heuristic is a good one.

Then occasionally pages on that DIMM get marked bad and are no longer used.
There have been cases where there only one or two correctable errors
before it degrades to and uncorrectable.  The "right" answer likely will 
depend on the physical memory technology.

Keep in mind the discarded pages can be later be freed.

> The x86-64 machine check design has a database connected to a user space
> program that can keep track of errors. I suspect something like this is
> a better solution.

I'll have to find out more.

> >> Anyways I don't think this should be ia64 specific, but generic code.
> > 
> > The actual migration code is generic, in mm/migrate.c.
> > 
> > The ia64 kernel module piece is very arch specific.  It ties into the 
> > ia64 CPE handler.  It gets the page address from the CPE record, based
> > on the ia64 error handling spec.  Each arch will have a different way of
> > determining the physical address of the correctable error (for example).
> 
> Still at least part of the code should be generic.

Part is generic.  What other parts do you want generic?
I'm not opposed to the idea, but things like parsing the
CPE record is platform specific.

> Also in general it's good that you finally realized that trying to write
> lockless machine check handlers was a bad idea and that to do any
> meaninful handling requires a proper process context. But I still wonder
> when you move the rest of the ia64 machine check handling to that too so
> that e.g. the sched.c hacks for lockless handling can be removed?

Are you refereing to ia64 MCAs that can surface at any time?  That is
an Intel CPU design issue far outside anything I can control.  CPEs 
are regular interrupts, which is why they can be handled in a sane
manner.

> >> I also have my doubts about making such small code subsystems modules. Modules
> >> always get rounded to pages so it ultimatively just wastes memory.
> > 
> > CONFIG_IA64_CPE_MIGRATE=m builds it as module.
> 
> It's far too small for it.

Maybe I do not understand the issue.  Is the issue wasting part of one
page?   Does building CONFIG_IA64_CPE_MIGRATE=y waste memory?

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
