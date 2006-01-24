From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 23:54:51 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124173000.J90635@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Jan 2006, Chen, Kenneth W wrote:

> Brent Casavant wrote on Friday, January 20, 2006 12:01 PM
> > Regarding the direction Ingo sent me down, and considering what Jack
> > said about needing a hook for a future platform, I'm thinking of grabbing
> > a bit in task->thread.flags that IA64_HAS_EXTRA_STATE() could detect and
> > let ia64_{save,load}_extra() call new machvecs to perform this
> > chipset-specific context management.  It's a bit overengineered for
> > my particular case, but would allow Jack to plug in his work very
> > cleanly.
> 
> I wonder why you did not continue on this path.

Two main reasons:

1. Requires an arch hook in the main scheduler to set the flag in most
   places set_task_cpu() is called.  Ingo didn't seem fond of that
   (see my original patch and his response).
2. The initialization code gets kind of ugly.

I suppose I could solve the second problem with a machvec that is only
called once, during the contruction of the init task.  So really, the
first reason is the bulk of it.

> You can go even one step further that only set the bit for process that
> has the MMIO address mapped.  So on sn2, you won't pay the extra cost if
> it is not required for most of the processes.  Something workable?

Workable, but requires additions to the mm struct and modifications to
several device drivers.  Since migration is relatively infrequent to
begin with, I can't imagine this is worth doing in the abscence of an
observed problem.  But I'll keep it in mind for future optimization.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
