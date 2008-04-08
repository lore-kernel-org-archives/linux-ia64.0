From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 08 Apr 2008 02:51:09 +0000
Subject: Re: pv_ops progress & ask for suggestion
Message-Id: <20080408025109.GE27760%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A03000059@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A03000059@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 08, 2008 at 10:31:20AM +0800, Dong, Eddie wrote:
> >> 	Now we have 2 choices:
> >> 	Alt1:  Dual compile entry.S like IVT.s (dual compile all ASM
> >> files if it needs virtualization)
> >> 		pros: Same policy with iVT, use same MACRO to
> >> replacement.
> >> 		cons: There are other ASM files such as
> >> sn/kernel/pio_phys.S need to be dual compiled too.
> >> 			And unlike IVT table, the memory occupied by
> >> dual compiled code won't be able to be freed easily since the size is
> >> not fixed. Also all future ASM code touch privilege instruction may
> >> need to be dual compiled too.
> > 
> > I suppose the more generalized problem is
> > - The memory for unused pv code/data won't be executed/referenced
> >   so that it can be freed somehow.
> >   Is it worth while to do that? And how to do it?
> 
> For IVT table (64K) & gate page (1 page), it can be done except
> relocating
> those IP relative symbols.

Yes, IVT table and gate page is somewhat special so that they are
worth while to handle specialy.


> > This is not ia64 specific issues, and should be addressed
> > in arch generic way. This hasn't been addressed even on x86.
> 
> X86 doesn't use dual compile.

I meant by "more generalized" that freeing not only dual compiled
ones, but also all ones under xen directory (or lguest, vmi... on x86).

-- 
yamahata
