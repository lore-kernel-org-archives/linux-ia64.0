From: "Christopher D. Maestas" <cdmaest@sandia.gov>
Date: Thu, 17 Jan 2002 18:20:01 +0000
Subject: [Linux-ia64] Interactive installation with PXE booting
Message-Id: <marc-linux-ia64-105590698805871@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone been able to write an elilo.conf that allows for an interactive
network installation?  For example in pxelinux.cfg/default I can do:
---
label vgainteractiverh72
        kernel vmlinuz.rh72
        append vga=extended root=/dev/ram0 initrd=initrd.img.rh72 console=tty0
---

I tried in elilo.conf:
---
prompt
timeoutP
default=localdisk
verbose=5

image=vmlinuz.rh72-ia64
        label=vgainteractiveia64
        read-only
        append = "vga=extended console=tty0"
---

And them type in vgainteractiveia64 when prompted, but the kernel panics because
I didn't append a root option.  I've tried root=/dev/ram0 and that doesn't
work either.

Thanks,

On Thu, 17 Jan 2002, Egan Ford wrote:

> prompt
> timeoutP
> default=install
> 
> image=vmlinuz
> 	append="console=ttyS0,9600 ks=nfs:jupiter:/tftpboot/ia64.ks ksdevice=eth0"
>  	label=install
> 	read-only
> 	initrd=ramdisk.img
> 
> This is what I use to boot RH's installation kernel and initrd with elilo
> and tftp.

-- 
Christopher D. Maestas
Compaq Federal, LLC
Professional Services
Consulting Associate III
5951 Jefferson Blvd. N.E. 
Albuquerque, NM 87109
E-Mail: cdmaest@sandia.gov
        Christopher.Maestas@Compaq.Com
Sandia Office Phone: 1.505.284.3643
Pager: 1.800.759.8888 PIN # 1278656
Fax: 1.505.343.7027 



