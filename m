From: Russ Anderson <rja@sgi.com>
Date: Fri, 03 Dec 2004 21:33:45 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <200412032133.iB3LXj81161506@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Nit: Patch needs to be applied with "patch -p2" ... rather
> than the preferred "patch -p1".

Sorry.  My new work area has the quilt patches directory at the
right level.
 
> The initialization of ar.k3 is quite messy, but when I tried
> to fix it I saw why.  I thought that I could just initialize
> it at the top of ia64_mmu_init() ... but that doesn't work because
> you use it in efi_map_pal_code(), which is called long before
> ia64_mmu_init().

That is the "fun" of the early init code. :-) 

> Your patch initializes it for non-boot cpus in discontig.c, which
> doesn't work for me because I have CONFIG_DISCONTIGMEM=n ... so
> all my non-boot cpus die on a bad dereference in efi_map_pal_code().

I was afraid that non-discontig may have problems.  I'll take that
into account.

> We either need to
> 1) add a contig.c equivalent initialization
> or
> 2) do something different in efi_map_pal_code() where we want to
> save the TR_PALCODE data in per-cpu space.
> 
> I'd prefer '2' because then we can make the ar.k3 initialization
> symmetric across boot and non-boot cpus ... but that leaves the
> problem of where to stash the TR_PALCODE information :-(

One alternative would be to have a stripped down version of
efi_map_pal_code() that is called later to get the pal_base
and pal_paddr.  That would avoid having to stash the values.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
