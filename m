From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 02 Sep 2004 15:25:16 +0000
Subject: Re: compiling 2.4.21 vanilla kernel
Message-Id: <1094138716.5156.25.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <50C05B7AA7D6924FB5E384EF14BC647B0DB8C7@inba1mx2.corp.emc.com>
In-Reply-To: <50C05B7AA7D6924FB5E384EF14BC647B0DB8C7@inba1mx2.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   You're still applying the 2.4.21-ia64 patch, right?  There are a
couple things to check:

     1. The ia64 patch adds a -g build option, which makes all the
        binaries very large.  mkinitrd often silently fails if the
        modules don't fit in the ramdisk.  Use a '-v' option to mkinitrd
        to see if you're being bitten by this.  If you are, edit the
        mkinitrd script to make a bigger ramdisk (search for ia64) or
        build your kernel w/o -g.
     2. Seems like RH renamed one of the sym53c8xx scsi modules, but I
        forget the details.  You may not be loading the right scsi
        driver into your ramdisk.  Running mkinitrd w/ the '-v' option
        should shed some light on what's getting included.

If you're still having problem, please provide more details, like what
box this is and a console log of the failure.  Also, there are much
newer kernels out there than 2.4.21...

	Alex

On Thu, 2004-09-02 at 12:00 +0100, gowda_avinash@emc.com wrote:
> All: 
> I have been trying to boot of a vanilla kernel (2.4.21) which I compiled.
> When I boot of my new kernel I get this message 
> 
> Kernel Panic: VFS: Unable to mount root fs on unknown-block(0,0)
> 
> This looks like a trivial booking keeping elilo.conf issue, but I am not
> able to figure out what the problem is. 
> 
> This is a snapshot of my elilo.conf
> 
> 
> <snip>
> 
> prompt
> timeout0
> default=2.4.21
> 
> image=vmlinuz-2.4.21
>         label=2.4.21
>         initrd=initrd-2.4.21.img
>         read-only
>         append="root=LABEL=/"
> 
> image=vmlinuz-2.4.21-15.0.4.EL
>         label=hack
>         initrd=initrd-2.4.21-15.0.4.EL.img
>         read-only
>         append="root=LABEL=/"
> 
> image=vmlinuz-2.4.21-15.0.4.EL
>         label=2.4.21-15.0.4.EL
>         initrd=initrd-2.4.21-15.0.4.EL.img
>         read-only
>         append="root=LABEL=/"
> 
> <snip>
> 
> I am not able to boot off only the first one in the list. 
> 
> This is how I am compiling the kernel. 
> make mrproper
> make clean
> make menuconfig
> make dep
> make vmlinux 
> I copied the vmlinux to /boot/efi/efi/Redhat (where all my images are) and 
> Lastly did the mkinitrd. 
> 
> I am wondering where I am going wrong. 
> 
> 
> 
> TIA
> 
> avinash
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
-- 
Alex Williamson                             HP Linux & Open Source Lab

