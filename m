From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 04 Sep 2003 18:31:02 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106270067411142@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks Xavier, I've included this in the latest discontig patch, which
I'll post again next week I think (with the fixes David wanted for
reentrance).

Jesse

On Tue, Sep 02, 2003 at 07:27:53PM +0200, Xavier Bru wrote:
> Hello Martin,
> 
> I finally found the reason for crashing at init time:
> On node 0, our test configuration has:
>  2 GB of memory at address 0
>  2 GB of memory at address 6 GB (due to PCI hole).
> 
> Current code for acpi_numa_memory_affinity_init ignores physical
> memory bank if the hole (4GB) is bigger than the bank (2 GB).
> As the node_memblk is not present for address 6 GB, paddr_to_nid
> returns -1 and alloc_bootmem_pages_node crashes with a Null pointer.
> 
> As we now have CONFIG_VIRTUAL_MEM_MAP=y, I suppose we should also use
> sparse memory in same node. (Am I right ?)
> 
> Now 2.6.0 test4  boots OK in NUMA with:
> 
> . Jesse's discontig patch
> . Tony's trim patch
> . alloc_bootmem patch
> . and this small one :-)
> 
> diff --exclude-from /users/xb/proc/diff.exclude -Nur linux-2.6.0-test4/arch/ia64/kernel/acpi.c 0t4/arch/ia64/kernel/acpi.c
> --- linux-2.6.0-test4/arch/ia64/kernel/acpi.c	2003-08-23 01:55:43.000000000 +0200
> +++ 0t4/arch/ia64/kernel/acpi.c	2003-09-02 15:37:17.000000000 +0200
> @@ -423,9 +423,8 @@
>  
>  	if (min_hole_size) {
>  		if (min_hole_size > size) {
> -			printk(KERN_ERR "Too huge memory hole. Ignoring %ld MBytes at %lx\n",
> +			printk(KERN_WARNING "Huge memory hole. Using %ld MBytes at %lx\n",
>  			       size/(1024*1024), paddr);
> -			return;
>  		}
>  	}
>  
> Thanks again for your help.
> 
> Xavier
> -- 
> 
>  Sinc?res salutations.
> _____________________________________________________________________
>  
> Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
> tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
> fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
> addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
> _____________________________________________________________________
> 
>  > Martin Hicks writes:
>  >  > 
>  >  > 
>  >  > On Fri, Aug 29, 2003 at 06:41:56PM +0200, Xavier Bru wrote:
>  >  > > 
>  >  > > printing "On node %d totalpages:":
>  >  > > 
>  >  > > ifa=0xf000ff54f7c5722b
>  >  > > iip=0xa0000001007780d0
>  >  > > 0xa0000001007780d0 <__alloc_bootmem_core+592>:	[MII]       ld8 r17=[r19],8
>  >  > > 
>  >  > > 
>  >  > > I will try to look at this a bit more if I find some more time.
>  >  > 
>  >  > Do you have this changeset in your tree?  It sounds like a similar
>  >  > problem to what I was seeing.
>  >  > 
>  >  > ChangeSet@1.1292.1.3, 2003-08-25 12:23:20-07:00, mort@wildopensource.com
>  >  >   [PATCH] ia64: paddr_to_nid fixup
>  >  >   
>  >  >   Here is a small patch for paddr_to_nid().  This fix is already in 2.4
>  >  >   and is used in the case where a NUMA kernel is running on a machine
>  >  >   without a SRAT ACPI table.  Without this patch the node info is not
>  >  >   correctly located.
>  >  > 
>  >  > 
>  >  > mh
>  >  > 
>  >  > -- 
>  >  > Wild Open Source Inc.                  mort@wildopensource.com
>  >  > -
>  >  > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
>  >  > the body of a message to majordomo@vger.kernel.org
>  >  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
