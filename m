From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Thu, 06 Sep 2018 12:44:53 +0000
Subject: Re: [RFC PATCH 13/29] memblock: replace __alloc_bootmem_nopanic with memblock_alloc_from_nopanic
Message-Id: <20180906124453.GE27492@rapoport-lnx>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-14-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906075721.GV14951@dhcp22.suse.cz>
In-Reply-To: <20180906075721.GV14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 06, 2018 at 09:57:21AM +0200, Michal Hocko wrote:
> On Wed 05-09-18 18:59:28, Mike Rapoport wrote:
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> The translation is simpler here but still a word or two would be nice.
> Empty changelogs suck.

This is one of the things left to sort out :)
 
> To the change
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  arch/arc/kernel/unwind.c       | 4 ++--
> >  arch/x86/kernel/setup_percpu.c | 4 ++--
> >  2 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/arch/arc/kernel/unwind.c b/arch/arc/kernel/unwind.c
> > index 183391d..2a01dd1 100644
> > --- a/arch/arc/kernel/unwind.c
> > +++ b/arch/arc/kernel/unwind.c
> > @@ -181,8 +181,8 @@ static void init_unwind_hdr(struct unwind_table *table,
> >   */
> >  static void *__init unw_hdr_alloc_early(unsigned long sz)
> >  {
> > -	return __alloc_bootmem_nopanic(sz, sizeof(unsigned int),
> > -				       MAX_DMA_ADDRESS);
> > +	return memblock_alloc_from_nopanic(sz, sizeof(unsigned int),
> > +					   MAX_DMA_ADDRESS);
> >  }
> >  
> >  static void *unw_hdr_alloc(unsigned long sz)
> > diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
> > index 67d48e26..041663a 100644
> > --- a/arch/x86/kernel/setup_percpu.c
> > +++ b/arch/x86/kernel/setup_percpu.c
> > @@ -106,7 +106,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
> >  	void *ptr;
> >  
> >  	if (!node_online(node) || !NODE_DATA(node)) {
> > -		ptr = __alloc_bootmem_nopanic(size, align, goal);
> > +		ptr = memblock_alloc_from_nopanic(size, align, goal);
> >  		pr_info("cpu %d has no node %d or node-local memory\n",
> >  			cpu, node);
> >  		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
> > @@ -121,7 +121,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
> >  	}
> >  	return ptr;
> >  #else
> > -	return __alloc_bootmem_nopanic(size, align, goal);
> > +	return memblock_alloc_from_nopanic(size, align, goal);
> >  #endif
> >  }
> >  
> > -- 
> > 2.7.4
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
