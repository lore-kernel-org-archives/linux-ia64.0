From: Russ Anderson <rja@sgi.com>
Date: Wed, 15 Sep 2004 15:43:02 +0000
Subject: Re: [Patch] Per CPU MCA/INIT data save areas
Message-Id: <200409151543.i8FFh2GW029645@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
In-Reply-To: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

Thanks for the explanation, Keith.

My original intent was to avoid any off node accesses in recording the
per-CPU MCA/INIT info, by putting a pointer to the MCA/INIT save area
in the cpu_info structure.  Getting the physical address of that pointer 
is more difficult than I thought.

Unless anyone has a better solution, I think Keith's suggestion is the
next best alternative.  It is no worse than the current code (in terms of
off-node access) and allows forward progress on the rest of the code.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
