From: Dave Young <dyoung@redhat.com>
Date: Fri, 30 Nov 2018 03:49:01 +0000
Subject: Re: [PATCH 1/2 v8] resource: add the new I/O resource descriptor 'IORES_DESC_RESERVED'
Message-Id: <20181130034901.GA26880@dhcp-128-65.nay.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181129080956.20776-1-lijiang@redhat.com>
 <20181129080956.20776-2-lijiang@redhat.com>
 <20181130033703.GA23624@dhcp-128-65.nay.redhat.com>
In-Reply-To: <20181130033703.GA23624@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lianbo Jiang <lijiang@redhat.com>
Cc: linux-kernel@vger.kernel.org, kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, bhe@redhat.com, Tom Lendacky <thomas.lendacky@amd.com>, Toshi Kani <toshi.kani@hpe.com>, Dan Williams <dan.j.williams@intel.com>

Correct Toshi's email addr
On 11/30/18 at 11:37am, Dave Young wrote:
> + more people
> 
> On 11/29/18 at 04:09pm, Lianbo Jiang wrote:
> > When doing kexec_file_load, the first kernel needs to pass the e820
> > reserved ranges to the second kernel. But kernel can not exactly
> > match the e820 reserved ranges when walking through the iomem resources
> > with the descriptor 'IORES_DESC_NONE', because several e820 types(
> > e.g. E820_TYPE_RESERVED_KERN/E820_TYPE_RAM/E820_TYPE_UNUSABLE/E820
> > _TYPE_RESERVED) are converted to the descriptor 'IORES_DESC_NONE'. It
> > may pass these four types to the kdump kernel, that is not desired result.
> > 
> > So, this patch adds a new I/O resource descriptor 'IORES_DESC_RESERVED'
> > for the iomem resources search interfaces. It is helpful to exactly
> > match the reserved resource ranges when walking through iomem resources.
> > 
> > In addition, since the new descriptor 'IORES_DESC_RESERVED' is introduced,
> > these code originally related to the descriptor 'IORES_DESC_NONE' need to
> > be updated. Otherwise, it will be easily confused and also cause some
> > errors. Because the 'E820_TYPE_RESERVED' type is converted to the new
> > descriptor 'IORES_DESC_RESERVED' instead of 'IORES_DESC_NONE', it has been
> > changed.
> > 
> > Suggested-by: Dave Young <dyoung@redhat.com>
> > Signed-off-by: Lianbo Jiang <lijiang@redhat.com>
> > ---
> >  arch/ia64/kernel/efi.c |  4 ++++
> >  arch/x86/kernel/e820.c |  2 +-
> >  arch/x86/mm/ioremap.c  | 13 ++++++++++++-
> >  include/linux/ioport.h |  1 +
> >  kernel/resource.c      |  6 +++---
> >  5 files changed, 21 insertions(+), 5 deletions(-)
> > 
> > diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
> > index 8f106638913c..1841e9b4db30 100644
> > --- a/arch/ia64/kernel/efi.c
> > +++ b/arch/ia64/kernel/efi.c
> > @@ -1231,6 +1231,10 @@ efi_initialize_iomem_resources(struct resource *code_resource,
> >  				break;
> >  
> >  			case EFI_RESERVED_TYPE:
> > +				name = "reserved";
> 
> Ingo updated X86 code to use "Reserved",  I think it would be good to do
> same for this case as well
> 
> > +				desc = IORES_DESC_RESERVED;
> > +				break;
> > +
> >  			case EFI_RUNTIME_SERVICES_CODE:
> >  			case EFI_RUNTIME_SERVICES_DATA:
> >  			case EFI_ACPI_RECLAIM_MEMORY:
> 
> Originally, above 3 are all "reserved", so probably they all should be
> IORES_DESC_RESERVED.
> 
> Can any IA64 people to review this?
> 
> > diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> > index 50895c2f937d..57fafdafb860 100644
> > --- a/arch/x86/kernel/e820.c
> > +++ b/arch/x86/kernel/e820.c
> > @@ -1048,10 +1048,10 @@ static unsigned long __init e820_type_to_iores_desc(struct e820_entry *entry)
> >  	case E820_TYPE_NVS:		return IORES_DESC_ACPI_NV_STORAGE;
> >  	case E820_TYPE_PMEM:		return IORES_DESC_PERSISTENT_MEMORY;
> >  	case E820_TYPE_PRAM:		return IORES_DESC_PERSISTENT_MEMORY_LEGACY;
> > +	case E820_TYPE_RESERVED:	return IORES_DESC_RESERVED;
> >  	case E820_TYPE_RESERVED_KERN:	/* Fall-through: */
> >  	case E820_TYPE_RAM:		/* Fall-through: */
> >  	case E820_TYPE_UNUSABLE:	/* Fall-through: */
> > -	case E820_TYPE_RESERVED:	/* Fall-through: */
> >  	default:			return IORES_DESC_NONE;
> >  	}
> >  }
> > diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> > index 5378d10f1d31..fea2ef99415d 100644
> > --- a/arch/x86/mm/ioremap.c
> > +++ b/arch/x86/mm/ioremap.c
> > @@ -83,7 +83,18 @@ static bool __ioremap_check_ram(struct resource *res)
> >  
> >  static int __ioremap_check_desc_other(struct resource *res)
> >  {
> > -	return (res->desc != IORES_DESC_NONE);
> > +	/*
> > +	 * But now, the 'E820_TYPE_RESERVED' type is converted to the new
> > +	 * descriptor 'IORES_DESC_RESERVED' instead of 'IORES_DESC_NONE',
> > +	 * it has been changed. And the value of 'mem_flags.desc_other'
> > +	 * is equal to 'true' if we don't strengthen the condition in this
> > +	 * function, that is wrong. Because originally it is equal to
> > +	 * 'false' for the same reserved type.
> > +	 *
> > +	 * So, that would be nice to keep it the same as before.
> > +	 */
> > +	return ((res->desc != IORES_DESC_NONE) &&
> > +		(res->desc != IORES_DESC_RESERVED));
> >  }
> 
> Added Tom since he added the check function.  Is it possible to only
> check explict valid desc types instead of exclude IORES_DESC_NONE?
> 
> >  
> >  static int __ioremap_res_check(struct resource *res, void *arg)
> > diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> > index da0ebaec25f0..6ed59de48bd5 100644
> > --- a/include/linux/ioport.h
> > +++ b/include/linux/ioport.h
> > @@ -133,6 +133,7 @@ enum {
> >  	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
> >  	IORES_DESC_DEVICE_PRIVATE_MEMORY	= 6,
> >  	IORES_DESC_DEVICE_PUBLIC_MEMORY		= 7,
> > +	IORES_DESC_RESERVED			= 8,
> >  };
> >  
> >  /* helpers to define resources */
> > diff --git a/kernel/resource.c b/kernel/resource.c
> > index b0fbf685c77a..f34a632c4169 100644
> > --- a/kernel/resource.c
> > +++ b/kernel/resource.c
> > @@ -994,7 +994,7 @@ __reserve_region_with_split(struct resource *root, resource_size_t start,
> >  	res->start = start;
> >  	res->end = end;
> >  	res->flags = type | IORESOURCE_BUSY;
> > -	res->desc = IORES_DESC_NONE;
> > +	res->desc = IORES_DESC_RESERVED;
> >  
> >  	while (1) {
> >  
> > @@ -1029,7 +1029,7 @@ __reserve_region_with_split(struct resource *root, resource_size_t start,
> >  				next_res->start = conflict->end + 1;
> >  				next_res->end = end;
> >  				next_res->flags = type | IORESOURCE_BUSY;
> > -				next_res->desc = IORES_DESC_NONE;
> > +				next_res->desc = IORES_DESC_RESERVED;
> >  			}
> >  		} else {
> >  			res->start = conflict->end + 1;
> > @@ -1477,7 +1477,7 @@ static int __init reserve_setup(char *str)
> >  			res->start = io_start;
> >  			res->end = io_start + io_num - 1;
> >  			res->flags |= IORESOURCE_BUSY;
> > -			res->desc = IORES_DESC_NONE;
> > +			res->desc = IORES_DESC_RESERVED;
> >  			res->child = NULL;
> >  			if (request_resource(parent, res) = 0)
> >  				reserved = x+1;
> > -- 
> > 2.17.1
> > 
> 
> 
> There are a lot of places call region_intersects which use DESC_NONE,
> I'm not sure if needed changes accordingly.  Cced Dan and Toshi.
> 
> 
> Thanks
> Dave
