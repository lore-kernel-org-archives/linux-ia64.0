From: Russ Anderson <rja@sgi.com>
Date: Sat, 13 Nov 2004 23:24:33 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <200411132324.iADNOY5d133064@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> >>>>> On Fri, 12 Nov 2004 17:27:27 -0600 (CST), Russ Anderson <rja@sgi.com> said:
> 
>   Russ> Tony and all, This is a smaller version of the per cpu
>   Russ> MCA/INIT save area patch.  The main point is to get in the
>   Russ> infrastructure for the per cpu MCA/INIT save areas.  It
>   Russ> allocates a per cpu MCA/INIT save area and used ar.k3 to hold
>   Russ> a pointer to the area.
> 
> Can you remind me why k3?  Are you worried about the TR mapping the
> per-CPU region getting corrupted?

The issue was how the MCA assembler code running in physical mode
would determine the physical address of that cpus MCA/INIT save
area.  There may not be a valid TLB, so DATA_VA_TO_PA() cannot be
used in the MCA path.  LOAD_PHYSICAL() only works for physically
unique addresses at load time.

Tony got around the issue for the TLB recovery code with a global
array of entries then finding the right entry for your cpu.  It
works, but also entails off node references to figure out your own
cpu's save area.

As Tony said (below), if using ar.k3 is the wrong decision, we'll
use ia64_mca_tlb_list[].  Whatever it takes to make forward progress
on the rest of the code.

For the full discussion, the two threads are "RFC - freeing up ar.k5"
and "[Patch] Per CPU MCA/INIT data save areas".

From "RFC - freeing up ar.k5" thread:

Tony Luck wrote:
> This looks like a decision that could be undone without too much
> pain later ... so I'll say "yes", let's use ar.k3 for the physical
> address of the percpu area as a "preliminary decision" ... if it turns
> out to be bad, then I'll admit to being a "nincompoop", and we'll add
> more loops looking for cr.lid in the ia64_mca_tlb_list[] to get ar.k3
> free again.

From "[Patch] Per CPU MCA/INIT data save areas" thread:

Keith Owens wrote:
> On Tue, 14 Sep 2004 10:30:44 -0500 (CDT), Russ Anderson <rja@sgi.com> wrote:
> >Takao Indoh wrote:
> >> BTW, I used tpa to get physical address, but I am not sure TLB is valid
> >> in the OS_INIT. tpa is available?
> >
> >There may not be a valid TLB.  That's why DATA_VA_TO_PA() cannot be used
> >in the OS_MCA path.  LOAD_PHYSICAL() is used instead (in the original MCA code).
> >I'm not sure if LOAD_PHYSICAL() is sufficient either in this context (but that
> >may just be my lack of understanding).
>
> LOAD_PHYSICAL() only works for physically unique addresses (one to one
> mapping from virtual to physical address at load time), it does not
> work for replicated areas like the per cpu data area.  As Russ has
> said, tpa is not reliable in MCA/INIT paths, one of the possible
> reasons for taking an MCA is an invalid tlb load :(.  Which means that
> we need a second data area which contains the physical addresses of
> each of the per cpu data areas.  MCA/INIT can do a LOAD_PHYSICAL() on
> the start of that table, then index by cpu to get the physical address
> of the local per cpu table.



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
