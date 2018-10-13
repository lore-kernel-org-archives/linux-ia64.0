From: Joel Fernandes <joel@joelfernandes.org>
Date: Sat, 13 Oct 2018 01:35:40 +0000
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
Message-Id: <20181013013540.GA207108@joelaf.mtv.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181012013756.11285-2-joel@joelfernandes.org>
 <20181012113056.gxhcbrqyu7k7xnyv@kshutemo-mobl1>
 <20181012125046.GA170912@joelaf.mtv.corp.google.com>
 <20181012.111836.1569129998592378186.davem@davemloft.net>
In-Reply-To: <20181012.111836.1569129998592378186.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: kirill@shutemov.name, linux-kernel@vger.kernel.org, kernel-team@android.com, minchan@kernel.org, pantin@google.com, hughd@google.com, lokeshgidra@google.com, dancol@google.com, mhocko@kernel.org, akpm@linux-foundation.org, aryabinin@virtuozzo.com, luto@kernel.org, bp@alien8.de, catalin.marinas@arm.com, chris@zankel.net, dave.hansen@linux.intel.com, elfring@users.sourceforge.net, fenghua.yu@intel.com, geert@linux-m68k.org, gxt@pku.edu.cn, deller@gmx.de, mingo@redhat.com, jejb@parisc-linux.org, jdike@addtoit.com, jonas@southpole.se, Julia.Lawall@lip6.fr, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, lftan@altera.com, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.orgl

On Fri, Oct 12, 2018 at 11:18:36AM -0700, David Miller wrote:
> From: Joel Fernandes <joel@joelfernandes.org>
[...]
> > Also, do we not flush the caches from any path when we munmap
> > address space?  We do call do_munmap on the old mapping from mremap
> > after moving to the new one.
> 
> Sparc makes sure that shared mapping have consistent colors.  Therefore
> all that's left are private mappings and those will be initialized by
> block stores to clear the page out or similar.
> 
> Also, when creating new mappings, we flush the D-cache when necessary
> in update_mmu_cache().
> 
> We also maintain a bit in the page struct to track when a page which
> was potentially written to on one cpu ends up mapped into another
> address space and flush as necessary.
> 
> The cache is write-through, which simplifies the preconditions we have
> to maintain.

Makes sense, thanks. For the moment I sent patches to enable this on arm64
and x86. We can enable it on sparc as well at a later time as it sounds it
could be a safe optimization to apply to that architecture as well.

thanks,

 - Joel
