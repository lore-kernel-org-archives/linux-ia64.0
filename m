From: "Egan Ford" <egan@sense.net>
Date: Thu, 17 Jan 2002 19:23:58 +0000
Subject: RE: [Linux-ia64] Interactive installation with PXE booting
Message-Id: <marc-linux-ia64-105590698805875@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805871@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805871@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

prompt
timeoutP
default=install

image=vmlinuz
	label=install
	read-only
	initrd=ramdisk.img

Works, if you use the vmlinuz from CD/kernels and the ramdisk.img from
CD/images with RH7.1.  I have not receive my 7.2 CDs yet so I have not
tested.

> -----Original Message-----
> From: Christopher D. Maestas [mailto:cdmaest@sandia.gov]
> Sent: Thursday, January 17, 2002 11:20 AM
> To: Egan Ford
> Cc: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Interactive installation with PXE booting
>
>
> Has anyone been able to write an elilo.conf that allows for an interactive
> network installation?  For example in pxelinux.cfg/default I can do:
> ---
> label vgainteractiverh72
>         kernel vmlinuz.rh72
>         append vga=extended root=/dev/ram0 initrd=initrd.img.rh72
> console=tty0
> ---
>
> I tried in elilo.conf:
> ---
> prompt
> timeoutP
> default=localdisk
> verbose=5
>
> image=vmlinuz.rh72-ia64
>         label=vgainteractiveia64
>         read-only
>         append = "vga=extended console=tty0"
> ---
>
> And them type in vgainteractiveia64 when prompted, but the kernel
> panics because
> I didn't append a root option.  I've tried root=/dev/ram0 and that doesn't
> work either.
>
> Thanks,
>
> On Thu, 17 Jan 2002, Egan Ford wrote:
>
> > prompt
> > timeoutP
> > default=install
> >
> > image=vmlinuz
> > 	append="console=ttyS0,9600 ks=nfs:jupiter:/tftpboot/ia64.ks
> ksdevice=eth0"
> >  	label=install
> > 	read-only
> > 	initrd=ramdisk.img
> >
> > This is what I use to boot RH's installation kernel and initrd
> with elilo
> > and tftp.
>
> --
> Christopher D. Maestas
> Compaq Federal, LLC
> Professional Services
> Consulting Associate III
> 5951 Jefferson Blvd. N.E.
> Albuquerque, NM 87109
> E-Mail: cdmaest@sandia.gov
>         Christopher.Maestas@Compaq.Com
> Sandia Office Phone: 1.505.284.3643
> Pager: 1.800.759.8888 PIN # 1278656
> Fax: 1.505.343.7027
>


