From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 26 Jan 2005 17:53:55 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200501260953.55632.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, January 26, 2005 9:48 am, David Mosberger wrote:
> The patch just removes per_cpu_init() in the non-SMP-case.  That would
> have to be changed to be in sync with the contig.c per_cpu_init().

It doesn't totally remove it, I tried to keep the MCA initialization.  
per_cpu_init for discontig is different than contig, since the memory has 
already been allocated.  All we need to do is assign the pointers.

> Perhaps a better solution would be to disassociate the MCA allocations
> from per_cpu_init().  For example, we could have a separate
> alloc_per_cpu_mca_data() in {dis,}contig.c.

That might be clearer.

Jesse
