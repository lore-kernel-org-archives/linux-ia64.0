From: "Egan Ford" <egan@sense.net>
Date: Thu, 17 Jan 2002 15:52:52 +0000
Subject: RE: [Linux-ia64] PXE booting, one last question
Message-Id: <marc-linux-ia64-105590698805870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805860@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805860@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

prompt
timeoutP
default=install

image=vmlinuz
	append="console=ttyS0,9600 ks=nfs:jupiter:/tftpboot/ia64.ks ksdevice=eth0"
 	label=install
	read-only
	initrd=ramdisk.img

This is what I use to boot RH's installation kernel and initrd with elilo
and tftp.


> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org
> [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Michael Madore
> Sent: Wednesday, January 16, 2002 1:38 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] PXE booting, one last question
>
>
> Hi,
>
> Does anyone have a sample elilo.conf file for booting the kernel and
> then mounting an initial ramdisk?  I have an elilo.conf that works for
> loading and mounting a ramdisk from an LS-120, but it can't mount the
> ramdisk when booting via the network.  I checked my tftpd log, and the
> initial ramdisk is getting transferred to the client.
>
> Mike
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


