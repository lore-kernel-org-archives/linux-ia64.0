From: David Hildenbrand <david@redhat.com>
Date: Wed, 08 Jan 2020 12:43:51 +0000
Subject: Re: [PATCH v2 6/8] s390/mm: Thread pgprot_t through vmem_add_mapping()
Message-Id: <a5501f2a-ff8d-cea2-1540-1a70ea6bc2d2@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200107205959.7575-1-logang@deltatee.com>
 <20200107205959.7575-7-logang@deltatee.com>
In-Reply-To: <20200107205959.7575-7-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Badger <ebadger@gigaio.com>, Vasily Gorbik <gor@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>, Christoph Hellwig <hch@lst.de>

On 07.01.20 21:59, Logan Gunthorpe wrote:
> In prepartion to support a pgprot_t argument for arch_add_memory().
> 
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> ---
>  arch/s390/include/asm/pgtable.h |  3 ++-
>  arch/s390/mm/extmem.c           |  3 ++-
>  arch/s390/mm/init.c             |  2 +-
>  arch/s390/mm/vmem.c             | 10 +++++-----
>  4 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index 7b03037a8475..e667a1a96879 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -1640,7 +1640,8 @@ static inline swp_entry_t __swp_entry(unsigned long type, unsigned long offset)
>  
>  #define kern_addr_valid(addr)   (1)
>  
> -extern int vmem_add_mapping(unsigned long start, unsigned long size);
> +extern int vmem_add_mapping(unsigned long start, unsigned long size,
> +			    pgprot_t prot);
>  extern int vmem_remove_mapping(unsigned long start, unsigned long size);
>  extern int s390_enable_sie(void);
>  extern int s390_enable_skey(void);
> diff --git a/arch/s390/mm/extmem.c b/arch/s390/mm/extmem.c
> index fd0dae9d10f4..6cf7029a7b35 100644
> --- a/arch/s390/mm/extmem.c
> +++ b/arch/s390/mm/extmem.c
> @@ -313,7 +313,8 @@ __segment_load (char *name, int do_nonshared, unsigned long *addr, unsigned long
>  		goto out_free;
>  	}
>  
> -	rc = vmem_add_mapping(seg->start_addr, seg->end - seg->start_addr + 1);
> +	rc = vmem_add_mapping(seg->start_addr, seg->end - seg->start_addr + 1,
> +			      PAGE_KERNEL);
>  
>  	if (rc)
>  		goto out_free;
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index a0c88c1c9ad0..ef19522ddad2 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -277,7 +277,7 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	if (WARN_ON_ONCE(modifiers->altmap))
>  		return -EINVAL;
>  
> -	rc = vmem_add_mapping(start, size);
> +	rc = vmem_add_mapping(start, size, PAGE_KERNEL);
>  	if (rc)
>  		return rc;
>  
> diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
> index b403fa14847d..8a5e95f184a2 100644
> --- a/arch/s390/mm/vmem.c
> +++ b/arch/s390/mm/vmem.c
> @@ -66,7 +66,7 @@ pte_t __ref *vmem_pte_alloc(void)
>  /*
>   * Add a physical memory range to the 1:1 mapping.
>   */
> -static int vmem_add_mem(unsigned long start, unsigned long size)
> +static int vmem_add_mem(unsigned long start, unsigned long size, pgprot_t prot)
>  {
>  	unsigned long pgt_prot, sgt_prot, r3_prot;
>  	unsigned long pages4k, pages1m, pages2g;
> @@ -79,7 +79,7 @@ static int vmem_add_mem(unsigned long start, unsigned long size)
>  	pte_t *pt_dir;
>  	int ret = -ENOMEM;
>  
> -	pgt_prot = pgprot_val(PAGE_KERNEL);
> +	pgt_prot = pgprot_val(prot);
>  	sgt_prot = pgprot_val(SEGMENT_KERNEL);
>  	r3_prot = pgprot_val(REGION3_KERNEL);

So, if we map as huge/gigantic pages, the protection would be discarded?
That looks wrong.

s390x does not support ZONE_DEVICE yet. Maybe simply bail out for s390x
as you do for sh to make your life easier?

[...]

-- 
Thanks,

David / dhildenb
