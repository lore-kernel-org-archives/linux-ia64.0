From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Dec 2004 21:35:22 +0000
Subject: RE: [patch] per cpu MCA/INIT save areas (take 3)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F028C1879@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
In-Reply-To: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Russ: Can you look again at efi.c ... just duplicating the whole
>> of efi_map_pal_code() and changing the last couple of lines to
>> switch from calling ia64_itr() to saving the address looks really
>> bad.  Can you extract all the duplicated code into a helper function
>> that each of efi_map_pal_code() and efi_get_pal_addr() can call.
>
>Do you mean something like this (below)? 

That would be an improvement ... though if you put *everything* into
the common function like that, it would be better to just rename
efi_map_pal_code() to something that describes its dual function and
add the flag argument.

I had thought more along the lines of:

static efi_memory_desc_t *
pal_code_memdesc(void)
{
	loop from old efi_map_pal_code() goes here to look
	up the md for the PAL.

	return md;
}

void
efi_map_pal_code(void)
{
	efi_memory_desc_t *md = pal_code_memdesc();

	if (md = NULL) {
		printk(KERN_INFO "no need to install ITR for PAL code\n");
		return;
	}
      psr = ia64_clear_ic();
      ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
               pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
               IA64_GRANULE_SHIFT);
      ia64_set_psr(psr);              /* restore psr */
      ia64_srlz_i();
}

void
efi_get_pal_addr(void)
{
	efi_memory_desc_t *md = pal_code_memdesc();

      if (md) {
		cpuinfo = (struct cpuinfo_ia64 *)__va(ia64_get_kr(IA64_KR_PA_CPU_INFO));
      	cpuinfo->pal_base = vaddr & mask;
		cpuinfo->pal_paddr = pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL));
	}
}
                        

