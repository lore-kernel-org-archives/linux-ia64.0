From: lijiang <lijiang@redhat.com>
Date: Wed, 28 Nov 2018 03:51:03 +0000
Subject: Re: [PATCH 1/2 RESEND v7] resource: add the new I/O resource descriptor 'IORES_DESC_RESERVED'
Message-Id: <d84fbefb-f856-c600-5207-c63f48b1b308@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181124051223.19994-1-lijiang@redhat.com>
 <20181124051223.19994-2-lijiang@redhat.com>
 <ae405fe9-94fd-3fb7-decd-c7821cf95b7d@intel.com>
 <460c5552-a48e-3523-275a-7f94d0f08f9b@redhat.com>
 <703ce20d-be09-9b8d-d457-5b002a50dff7@intel.com>
In-Reply-To: <703ce20d-be09-9b8d-d457-5b002a50dff7@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org
Cc: kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, dyoung@redhat.com, bhe@redhat.com

在 2018年11月27日 23:34, Dave Hansen 写道:
> On 11/27/18 2:04 AM, lijiang wrote:
>> What happens if we don't modify this functions
>> __ioremap_check_desc_other()? -When SEV is active, it might map these
>> reserved regions with the encryption mask. That is incorrect. 
> 
> This is missing another sentence or two to "connect the dots".
> 
> SEV uses data that comes from the e820 table to tell whether or not the
> memory should be encrypted?  If we don't reflect these reserved areas in
> the e820 table, the SEV code will set up encrypted mappings for device
> memory, for instance?
> 

For the convenience of description, here copy some code fragments and put them at the end.
Please refer to these codes.

When the SEV is active, the page being mapped will determine whether to use the memory
encryption attribute for mapping based on the 'mem_flags.desc_other'.

But the value of 'mem_flags.desc_other' is set according to the returned result of this
function __ioremap_check_desc_other().

Originally, the 'E820_TYPE_RESERVED' type is converted to the descriptor 'IORES_DESC_NONE',
therefore, for the e820 reserved type, the value of 'mem_flags.desc_other' is equal to
'false'.

But now, the 'E820_TYPE_RESERVED' type is converted to the descriptor 'IORES_DESC_RESERVED'
instead of 'IORES_DESC_NONE', it has been changed and the value of 'mem_flags.desc_other'
is equal to 'true'. This is wrong.

So that would be nice to keep it the same as before, that is to say, this function has to
be improved like this.
static int __ioremap_check_desc_other(struct resource *res)
{
    return ((res->desc != IORES_DESC_NONE) &&
            (res->desc != IORES_DESC_RESERVED));
}


Please look at the following function __ioremap_caller(), and also list the call trace path.

Call trace path:
   __ioremap_caller()->
__ioremap_check_mem()->
       walk_mem_res()->
__ioremap_res_check()-> 
__ioremap_check_desc_other()

static void __iomem *__ioremap_caller(resource_size_t phys_addr,
                unsigned long size, enum page_cache_mode pcm,
                void *caller, bool encrypted)
{
        unsigned long offset, vaddr;
        resource_size_t last_addr;
        const resource_size_t unaligned_phys_addr = phys_addr;
        const unsigned long unaligned_size = size;
        struct ioremap_mem_flags mem_flags;

	/* skip some codes...*/

        __ioremap_check_mem(phys_addr, size, &mem_flags);

	/* skip some codes...*/

	/*
         * If the page being mapped is in memory and SEV is active then
         * make sure the memory encryption attribute is enabled in the
         * resulting mapping.
         */
        prot = PAGE_KERNEL_IO;
        if ((sev_active() && mem_flags.desc_other) || encrypted)
                prot = pgprot_encrypted(prot);

	/* skip some codes...*/
}

Thanks.
Lianbo
