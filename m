From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jun 2007 04:39:29 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <617E1C2C70743745A92448908E030B2A01A4962E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> At one time, there were file system issues with 64K pages. I _hope_ that these have
> been fixed. I'll cc Dave Chinner for his 2 cents. 

There was also a SCSI issue way, way back.  But I've been
periodically building 64K pagesize kernels for a while and
haven't seen a problem (not that I've done particularly
extensive testing on a 64K pagesize kernel).

On the filesystem front I recall someone saying that you
could configure a 64K blocksize filesystem ... but then
you would not be able to mount that on any other Linux
machine.

Another possible area might be NFS ... again there used
to be a problem even with a 16K pagesize because NFS would
never do any readahead (or something like that).

> Note that changing the IA64 default doesn't really help customers - the
> distros also need to change. Changing the default to 64K will
> help determine if there are any additional issues that need to be fixed.
> Distros will have more confidence in 64K if it's the default in the
> community kernel.

Yes.  We have to demonstrate confidence in 64K pagesize before
the distros will be willing to switch.

-Tony




> 
> See the paper of the researchers at the TU Dresden on TLB issues:
> http://www.cs.utah.edu/wmpi/2006/final-version/wmpi-posters-3-Juckeland.pdf
> and my presentation
> http://ftp.kernel.org/pub/linux/kernel/people/christoph/gelato/gelato2007-tlb-tricks.pdf.
> 
> SLUB can also take advantage of the larger page sizes. A kernel compile is 
> already ~5-10% faster with 16k. This will increase the speed even more. It 
> will also increase the effectiveness of slab reclaim because more objects 
> can be processed with a single acquisition of the dcache or inode lock.
> 
> We at SGI have begun to see livelocks because of too much activity on various
> locks. This is simply because there are too many pages in the system which
> require frequent taking of locks. Going to 64k page size will reduce the frequency
> of taking locks by a factor of 4.
> 
> IA64 systems typically have very large memory capacities. Going to 64k will increase
> the memory footprint but I think we are willling to make that sacrifice for the
> speed the larger page size brings us.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: slub/arch/ia64/Kconfig
> =================================> --- slub.orig/arch/ia64/Kconfig	2007-05-31 11:44:50.000000000 -0700
> +++ slub/arch/ia64/Kconfig	2007-06-07 17:39:02.000000000 -0700
> @@ -168,7 +168,7 @@ endchoice
>  
>  choice
>  	prompt "Kernel page size"
> -	default IA64_PAGE_SIZE_16KB
> +	default IA64_PAGE_SIZE_64KB
>  
>  config IA64_PAGE_SIZE_4KB
>  	bool "4KB"
> Index: slub/arch/ia64/configs/sn2_defconfig
> =================================> --- slub.orig/arch/ia64/configs/sn2_defconfig	2007-06-07 17:41:22.000000000 -0700
> +++ slub/arch/ia64/configs/sn2_defconfig	2007-06-07 17:56:34.000000000 -0700
> @@ -110,8 +110,8 @@ CONFIG_IA64_SGI_SN2=y
>  CONFIG_MCKINLEY=y
>  # CONFIG_IA64_PAGE_SIZE_4KB is not set
>  # CONFIG_IA64_PAGE_SIZE_8KB is not set
> -CONFIG_IA64_PAGE_SIZE_16KB=y
> -# CONFIG_IA64_PAGE_SIZE_64KB is not set
> +# CONFIG_IA64_PAGE_SIZE_16KB is not set
> +CONFIG_IA64_PAGE_SIZE_64KB=y
>  # CONFIG_PGTABLE_3 is not set
>  CONFIG_PGTABLE_4=y
>  # CONFIG_HZ_100 is not set
> Index: slub/arch/ia64/configs/gensparse_defconfig
> =================================> --- slub.orig/arch/ia64/configs/gensparse_defconfig	2007-06-07 17:56:54.000000000 -0700
> +++ slub/arch/ia64/configs/gensparse_defconfig	2007-06-07 17:57:24.000000000 -0700
> @@ -101,8 +101,8 @@ CONFIG_IA64_GENERIC=y
>  CONFIG_MCKINLEY=y
>  # CONFIG_IA64_PAGE_SIZE_4KB is not set
>  # CONFIG_IA64_PAGE_SIZE_8KB is not set
> -CONFIG_IA64_PAGE_SIZE_16KB=y
> -# CONFIG_IA64_PAGE_SIZE_64KB is not set
> +# CONFIG_IA64_PAGE_SIZE_16KB is not set
> +CONFIG_IA64_PAGE_SIZE_64KB=y
>  CONFIG_PGTABLE_3=y
>  # CONFIG_PGTABLE_4 is not set
>  # CONFIG_HZ_100 is not set
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.
