From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 01 Dec 2003 17:22:12 +0000
Subject: Re: Missing code in bootmem.c for discontigmem
Message-Id: <marc-linux-ia64-107029975108792@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106994770902664@msgid-missing>
In-Reply-To: <marc-linux-ia64-106994770902664@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yeah, sorry about that, I knew there would be a problem.  We need to fix
the ia64 discontig code to init the boot memory in the correct order
instead since the below change breaks other discontig platforms.

Jesse

On Thu, Nov 27, 2003 at 04:42:12PM +0100, Xavier Bru wrote:
> Hello all,
> 
> Booting 2.6.0-test10 on Numa system, we fall in:
>    Kernel panic: map_single: bounce buffer is not DMA'ble
> due to alloc_bootmem_low_pages() returning a highmem address at sw IO TLB
> initialization:
>    Placing software IO TLB between 0xe0000030014e4000 - 0xe0000030016e4000
> This was OK in test9 due to init_bootmem_core() sorting the pgdat_list.
> Restoring the previous code, system boots OK (using the last scsi 
> patches :-)
> Herafter the patch:
> 
> diff --exclude-from /home2/xb/proc/diff.exclude -Nur 0t10/mm/bootmem.c 
> linux-2.6.0-test10.old/mm/bootmem.c
> --- 0t10/mm/bootmem.c    2003-11-24 02:31:28.000000000 +0100
> +++ linux-2.6.0-test10.old/mm/bootmem.c    2003-11-27 15:19:53.000000000 
> +0100
> @@ -48,8 +48,24 @@
>     bootmem_data_t *bdata = pgdat->bdata;
>     unsigned long mapsize = ((end - start)+7)/8;
> 
> -    pgdat->pgdat_next = pgdat_list;
> -    pgdat_list = pgdat;
> +
> +    /*
> +     * sort pgdat_list so that the lowest one comes first,
> +     * which makes alloc_bootmem_low_pages work as desired.
> +     */
> +    if (!pgdat_list || pgdat_list->node_start_pfn > 
> pgdat->node_start_pfn) {
> +        pgdat->pgdat_next = pgdat_list;
> +        pgdat_list = pgdat;
> +    } else {
> +        pg_data_t *tmp = pgdat_list;
> +        while (tmp->pgdat_next) {
> +            if (tmp->pgdat_next->node_start_pfn > pgdat->node_start_pfn)
> +                break;
> +            tmp = tmp->pgdat_next;
> +        }
> +        pgdat->pgdat_next = tmp->pgdat_next;
> +        tmp->pgdat_next = pgdat;
> +    }
> 
>     mapsize = (mapsize + (sizeof(long) - 1UL)) & ~(sizeof(long) - 1UL);
>     bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);
> 
> -- 
> 
> Sinc?res salutations.
> _____________________________________________________________________
> 
> Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
> tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
> fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
> addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
> _____________________________________________________________________
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
