From: gowda_avinash@emc.com
Date: Fri, 03 Sep 2004 21:29:28 +0000
Subject: FW: compiling 2.4.21 vanilla kernel
Message-Id: <50C05B7AA7D6924FB5E384EF14BC647B0DB8D9@inba1mx2.corp.emc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50C05B7AA7D6924FB5E384EF14BC647B0DB8C7@inba1mx2.corp.emc.com>
In-Reply-To: <50C05B7AA7D6924FB5E384EF14BC647B0DB8C7@inba1mx2.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org




-----Original Message-----
From: Alex Williamson [mailto:alex.williamson@hp.com] 
Sent: Thursday, September 02, 2004 8:55 PM
To: gowda_avinash@emc.com
Cc: linux-ia64@vger.kernel.org
Subject: Re: compiling 2.4.21 vanilla kernel


   You're still applying the 2.4.21-ia64 patch, right? 

[avinash] 
this is the patch I am applying 
linux-2.4.21-ia64-030702.diff 
the one from kernel.org

 There are a
couple things to check:

     1. The ia64 patch adds a -g build option, which makes all the
        binaries very large.  mkinitrd often silently fails if the
        modules don't fit in the ramdisk.  Use a '-v' option to mkinitrd
        to see if you're being bitten by this.  If you are, edit the
        mkinitrd script to make a bigger ramdisk (search for ia64) or
        build your kernel w/o -g.
[avinash] 
 Yes. Makefile has the -g option enabled. I also updated the modutils.


     2. Seems like RH renamed one of the sym53c8xx scsi modules, but I
        forget the details.  You may not be loading the right scsi
        driver into your ramdisk.  Running mkinitrd w/ the '-v' option
        should shed some light on what's getting included.

[avinash]  
The mkinitrd -v option does not give out any warnings. This is the output of
mkinitrd -f -v option 

Looking for deps of module scsi_mod     
Looking for deps of module sd_mod       
Looking for deps of module unknown      
Looking for deps of module mptbase      
Looking for deps of module mptscsih     mptbase
Looking for deps of module mptbase      
Looking for deps of module qla2300      
Looking for deps of module ide-disk     
Looking for deps of module ext3 
Using modules:  ./kernel/drivers/message/fusion/mptbase.o
./kernel/drivers/message/fusion/mptscsih.o ./kernel/drivers/scsi/qla2300.o
Using loopback device /dev/loop0
/sbin/nash -> /tmp/initrd.KGuZIV/bin/nash
/sbin/insmod.static -> /tmp/initrd.KGuZIV/bin/insmod
`/lib/modules/2.4.21/./kernel/drivers/message/fusion/mptbase.o' ->
`/tmp/initrd.KGuZIV/lib/mptbase.o'
`/lib/modules/2.4.21/./kernel/drivers/message/fusion/mptscsih.o' ->
`/tmp/initrd.KGuZIV/lib/mptscsih.o'
`/lib/modules/2.4.21/./kernel/drivers/scsi/qla2300.o' ->
`/tmp/initrd.KGuZIV/lib/qla2300.o'
Loading module mptbase
Loading module mptscsih
Loading module qla2300

This looks like a good initrd output. 

If you're still having problem, please provide more details, like what
box this is and a console log of the failure.  Also, there are much
newer kernels out there than 2.4.21...

[avinash] 
It is a Dell 3250 Poweredge.
I am trying to get kdb running on tht kernel. So that is the reason I am
looking at 2.4.21. 
I did try 2.4.25 kernel but this is the message I am getting
arch/ia64/Makefile:38: Warning: Found binutils that supports hint
instruction


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
