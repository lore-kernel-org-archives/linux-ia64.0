From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 28 May 2019 02:32:00 +0000
Subject: Re: [PATCH] ia64: fix build errors by exporting paddr_to_nid()
Message-Id: <877e524b-6b84-740e-a79b-5cec378bb22d@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <eaa72e00-e1ea-4a86-327e-8b8cca8ea492@infradead.org>
In-Reply-To: <eaa72e00-e1ea-4a86-327e-8b8cca8ea492@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

ping...

On 5/3/19 9:42 PM, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix build errors on ia64 when DISCONTIGMEM=y and NUMA=y by
> exporting paddr_to_nid().
> 
> Fixes these build errors:
> 
> ERROR: "paddr_to_nid" [sound/core/snd-pcm.ko] undefined!
> ERROR: "paddr_to_nid" [net/sunrpc/sunrpc.ko] undefined!
> ERROR: "paddr_to_nid" [fs/cifs/cifs.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/video/fbdev/core/fb.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/usb/mon/usbmon.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/usb/core/usbcore.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/md/raid1.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/md/dm-mod.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/md/dm-crypt.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/md/dm-bufio.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/ide/ide-core.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/ide/ide-cd_mod.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/gpu/drm/drm.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/char/agp/agpgart.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/block/nbd.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/block/loop.ko] undefined!
> ERROR: "paddr_to_nid" [drivers/block/brd.ko] undefined!
> ERROR: "paddr_to_nid" [crypto/ccm.ko] undefined!
> 
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> ---
>  arch/ia64/mm/numa.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- lnx-51-rc7.orig/arch/ia64/mm/numa.c
> +++ lnx-51-rc7/arch/ia64/mm/numa.c
> @@ -55,6 +55,7 @@ paddr_to_nid(unsigned long paddr)
>  
>  	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
>  }
> +EXPORT_SYMBOL(paddr_to_nid);
>  
>  #if defined(CONFIG_SPARSEMEM) && defined(CONFIG_NUMA)
>  /*
> 
> 


-- 
~Randy
