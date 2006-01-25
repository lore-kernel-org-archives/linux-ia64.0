From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 00:29:31 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601250029.k0P0TVg16877@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Tuesday, January 24, 2006 3:55 PM
> > > Regarding the direction Ingo sent me down, and considering what Jack
> > > said about needing a hook for a future platform, I'm thinking of grabbing
> > > a bit in task->thread.flags that IA64_HAS_EXTRA_STATE() could detect and
> > > let ia64_{save,load}_extra() call new machvecs to perform this
> > > chipset-specific context management.  It's a bit overengineered for
> > > my particular case, but would allow Jack to plug in his work very
> > > cleanly.
> > 
> > I wonder why you did not continue on this path.
> 
> Two main reasons:
> 
> 1. Requires an arch hook in the main scheduler to set the flag in most
>    places set_task_cpu() is called.  Ingo didn't seem fond of that
>    (see my original patch and his response).
> 2. The initialization code gets kind of ugly.
> 

Well, maybe bad wording, I didn't meant to pursue scheduler hook in the
generic code.  Instead, idea is morphed into having a thread specific
bit to tell kernel whether it needs to do MMIO synchronization for that
task at context switch.  The beauty of it is that for task that doesn't
need to do any of MMIO synchronization, the cost is kept at minimal even
if task migrated.

In the event of task migration, your "take 4" patch will cause a cache
line update, another cache line read for the function pointer, followed
by an empty function call, on *all* non-sn2 platforms.  Even on sn2
platform, for process that *doesn't* do MMIO, you are still paying the
cost of accessing shub in sn_migrate(), which can be optimized away. I
hope you understand what I'm talking about.  Otherwise, I can do a patch
on top of yours.

- Ken

