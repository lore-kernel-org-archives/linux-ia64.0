From: Russ Anderson <rja@sgi.com>
Date: Tue, 14 Dec 2004 20:22:11 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 3)
Message-Id: <200412142022.iBEKMBof179357@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
In-Reply-To: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Russ: Can you look again at efi.c ... just duplicating the whole
> of efi_map_pal_code() and changing the last couple of lines to
> switch from calling ia64_itr() to saving the address looks really
> bad.  Can you extract all the duplicated code into a helper function
> that each of efi_map_pal_code() and efi_get_pal_addr() can call.

Do you mean something like this (below)? 

------------------------------------------------------------------------
#define EFI_MAP_PAL             1
#define EFI_SAVE_PAL_BASE       2

[...]

void
efi_pal_comon (int set_flag)
{
        void *efi_map_start, *efi_map_end, *p;
        efi_memory_desc_t *md;
        u64 efi_desc_size;
        int pal_code_count = 0;
        u64 mask, psr;
        u64 vaddr;

        efi_map_start = __va(ia64_boot_param->efi_memmap);
        efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
        efi_desc_size = ia64_boot_param->efi_memdesc_size;

        for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
                md = p;
                if (md->type != EFI_PAL_CODE)
                        continue;

                if (++pal_code_count > 1) {
                        printk(KERN_ERR "Too many EFI Pal Code memory ranges, dropped @ %lx\n",
                               md->phys_addr);
                        continue;
                }
                /*
                 * The only ITLB entry in region 7 that is used is the one installed by
                 * __start().  That entry covers a 64MB range.
                 */
                mask  = ~((1 << KERNEL_TR_PAGE_SHIFT) - 1);
                vaddr = PAGE_OFFSET + md->phys_addr;


                /*
                 * We must check that the PAL mapping won't overlap with the kernel
                 * mapping.
                 *
                 * PAL code is guaranteed to be aligned on a power of 2 between 4k and
                 * 256KB and that only one ITR is needed to map it. This implies that the
                 * PAL code is always aligned on its size, i.e., the closest matching page
                 * size supported by the TLB. Therefore PAL code is guaranteed never to
                 * cross a 64MB unless it is bigger than 64MB (very unlikely!).  So for
                 * now the following test is enough to determine whether or not we need a
                 * dedicated ITR for the PAL code.
                 */
                if ((vaddr & mask) = (KERNEL_START & mask)) {
                        printk(KERN_INFO "%s: no need to install ITR for PAL code\n",
                               __FUNCTION__);
                        continue;
                }

                if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
                        panic("Woah!  PAL code size bigger than a granule!");

                mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
#if EFI_DEBUG
                printk(KERN_INFO "CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
                        smp_processor_id(), md->phys_addr,
                        md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
                        vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
#endif

                if (set_flag = EFI_MAP_PAL) {
                        /*
                         * Cannot write to CRx with PSR.ic=1
                         */
                        psr = ia64_clear_ic();
                        ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
                                pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
                                IA64_GRANULE_SHIFT);
                        ia64_set_psr(psr);              /* restore psr */
                        ia64_srlz_i();
                } else if (set_flag = EFI_SAVE_PAL_BASE) {
                        struct cpuinfo_ia64 *cpuinfo;

                        /*
                         * Data for MCA recovery purposes
                         */
                        cpuinfo = (struct cpuinfo_ia64 *)__va(ia64_get_kr(IA64_KR_PA_CPU_INFO));
                        cpuinfo->pal_base = vaddr & mask;
                        cpuinfo->pal_paddr = pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL));
                        printk(KERN_INFO "RJA CPU %d: late efi pal_base 0x%lx pal_paddr 0x%lx\n",
                                smp_processor_id(), cpuinfo->pal_base, cpuinfo->pal_paddr);
                }

        }
}

void
efi_map_pal_code (void)
{
        efi_pal_comon(EFI_MAP_PAL);
}

/*
 * Put pal_base and pal_paddr in the cpuinfo structure.
 */
void
efi_get_pal_addr(void)
{
        efi_pal_comon(EFI_SAVE_PAL_BASE);
}
 


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
