From: Simon Horman <horms@verge.net.au>
Date: Mon, 05 Nov 2007 02:03:07 +0000
Subject: Re: [PATCH] iounmap after ioremap in efi_enter_virtual_mode, file arch/ia64/kernel/efi.c
Message-Id: <20071105020307.GC16909@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472D0486.8080604@tiscali.nl>
In-Reply-To: <472D0486.8080604@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Nov 04, 2007 at 12:30:14AM +0100, Roel Kluin wrote:
> I am less certain about this one, so please review
> --
> Iounmap when EFI won't switch to virtual mode
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
> index 3f7ea13..af925ab 100644
> --- a/arch/ia64/kernel/efi.c
> +++ b/arch/ia64/kernel/efi.c
> @@ -585,6 +585,8 @@ efi_enter_virtual_mode (void)
>  			       efi_desc_size, ia64_boot_param->efi_memdesc_version,
>  			       ia64_boot_param->efi_memmap);
>  	if (status != EFI_SUCCESS) {
> +		if ((md->attribute & EFI_MEMORY_UC) || (md->attribute & EFI_MEMORY_WC))
> +			iounmap(md->virt_addr);
>  		printk(KERN_WARNING "warning: unable to switch EFI into virtual mode "
>  		       "(status=%lu)\n", status);
>  		return;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi Roel,

I'm not really sure what the intention of this patch is.
But I'm pretty sure its not doing what you want it to do.

I guess that you wish to reverse all the calls to ioremap()
that are made in efi_enter_virtual_mode(). ioremap() is
called during iterating through efi_map_start, but you only
seem to call iounmap on whatever md happens to be set
to at the end of the iteration. Surely you need to run through
efi_map_start again?

The next thing that I wonder about is weather calling iounmap()
actually reverses ioremap() in this case. Though now that I look
at it and see that basically iounmap() will do nothing in
this case, which seems appropriate as in this case ioremap()
ends up being:

   return (void __iomem *) (__IA64_UNCACHED_OFFSET | phys_addr)

Its probably not to much of a bother that all the md->virt_addr have
been mangled and stay mangled. Though if we are concerned about such
things, perhaps it would be cleaner to zero them on error?


Some other issues that aren't part of your patch but are related.

1. Without the phys_efi patches that I posted to the linux-ia64 about
   a year ago, if EFI fails to switch to virtual mode then all
   SAL calls will fail. Which in turn means that the kernel will fail to
   boot (unless I am mistaken and some machines don't make SAL calls
   directly from the kernel).

   This is because currently the kernel doesn't have any mechanism to
   make SAL calls in physical mode.  My patches fixed this and
   introduced a switch, to force efi to stay in physical mode, for
   testing purpuses. But there was no interest in the code. Actually
   there were some suggestions that some machines simply couldn't
   perform some opperations with EFI in physical mode.

   Basically this means that the will fail to boot. That is,  unless I
   am mistaken and some machines don't make SAL calls directly from the
   kernel.

   Given that the kernel can't function with EFI in physical mode
   (without the phys_efi patches), I really have to conclude that in
   fact EFI never fails to switch itself into virtual mode.  Otherwise
   there would be machines out there that simply wouldn't boot.

   This being the case, there doesn't seem to be a whole lot of point in
   making sure the error path cleans up correctly. In fact, perhaps the
   error path should be removed all together or just changed to
   BUG("unable to switch EFI into virtual mode");

2. It seems to me that the loop in efi_enter_virtual_mode()
   could be rewritten as the following without changing its
   behaviour, other than debugging output. I have not tested
   this theory.

   for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
	md = p;
	if (! (md->attribute & EFI_MEMORY_RUNTIME))
		continue;
	md->virt_addr = (u64) ioremap(md->phys_addr, 0);
   }


-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

