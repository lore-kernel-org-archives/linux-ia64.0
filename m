From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 07 Jul 2004 16:20:09 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200407070920.09894.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, July 6, 2004 4:45 pm, David Mosberger wrote:
> >>>>> On Wed, 30 Jun 2004 11:11:04 -0700, Jesse Barnes
> >>>>> <jbarnes@engr.sgi.com> said:
>   >>
>   >> Looks like there are more places where kernel does "virt -> phys ->
>   >> virt". And conversion from phys to virt is setting 3 msb to 1.
>
>   Jesse> Yep, that looks like a problem.  The kernel hangs right after
>   Jesse> the local_flush_tlb_all in ia64_tlb_init, and if I comment it
>   Jesse> out I get a "Unable to handle kernel paging request at
>   Jesse> virtual address a000003004289f70" which, on sn2, looks like a
>   Jesse> virt -> phys -> virt conversion (i.e. 0x3004289f70 is a valid
>   Jesse> physical address).
>
> I'm not sure this is related.  local_flush_tlb_all() simply flushes
> the entire tlb it doesn't touch the "current" pointer in any shape or
> fashion.  Not doing that flush will leave the kernel with stale TLB
> entries, so all bets are off.

Yeah, this is happening later, so it's probably a separate issue (and maybe 
not an issue at all).  Nonetheless, we still see a hang at boot with the 
latest BK tree.

Jesse
