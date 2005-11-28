From: Jesse Barnes <jesse.barnes@intel.com>
Date: Mon, 28 Nov 2005 16:15:31 +0000
Subject: Re: initrd_size inflation breaks initramfs
Message-Id: <200511280815.31626.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1133159027.6062.98.camel@localhost>
In-Reply-To: <1133159027.6062.98.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday, November 27, 2005 10:23 pm, dann frazier wrote:
> hey,
>   I've been trying to track down why initramfs seems to be broken on
> ia64 when passed using the initrd= flag.  This appears to be due to an
> inflated ia64_boot_param->initrd_size.  In my case, initrd_size got
> set to 1957888 (which happens to be a multiple of 4K), when my
> initramfs file is actually 1957415 bytes.
>
> unpack_to_rootfs() expects gunzip() to succeed until it has reached
> the initrd_size.  Since it thinks the image is larger than it actually
> is, it runs off the end of the initrd and the initramfs footprinting
> fails. I can get unpack_to_rootfs to succeed by hardcoding my
> initrd_size.
>
> My guess is that this is a bug in elilo.
>
> initrd.c has:
>         /* round up to get required number of pages (4KB) */
>         initrd->pgcnt = pgcnt = EFI_SIZE_TO_PAGES(size);
>
> initrd->pgcnt is later used to calculate the initrd_size boot param,
> but it is now (size % 4096) bytes too big.

I thought this bug was fixed?  I remember Erik J. and I seeing the same 
thing, and iirc we corrected elilo and sent the patch upstream.  Or is 
this a different problem maybe?

Jesse
