From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 09 Nov 2006 12:42:21 +0000
Subject: Re: elilo.efi causing Kernel Panic
Message-Id: <20061109124221.GL16952@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 09, 2006 at 06:04:04PM +0530, Karthik Gopalakrishnan wrote:
> image=vmlinuz-2.6.9-22.EL
>        label=linux
>        initrd=initrd-2.6.9-22.EL.img
>        read-only
>        append="console=ttyS0 rhgb quiet root=LABEL=/"

If you take the "quiet" out, you'll get a lot more information during
the boot, and we may be able to diagnose your problem.

> fs0:\EFI\redhat> elilo
> 
> ELILO boot: Uncompressing Linux... done
> Loading initrd initrd-2.6.9-22.EL.img...done
> i8042.c: No controller found.
> ernel panic - not syncing: VFS: Unable to mount root fs on 
> unknown-block(0,0)
> 
>    Any help will be greatly appreciated.
> 
> Regards,
> Karthik
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
