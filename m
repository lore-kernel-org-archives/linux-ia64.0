From: Chuck Fleckenstein <cfleck@co.intel.com>
Date: Tue, 22 Feb 2000 18:14:27 +0000
Subject: Re: [Linux-ia64] CD intructions.
Message-Id: <marc-linux-ia64-105590678204953@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The CD David put together needs a doc update. Could we put something up
> on the web site? Here's a short howto:
> 
> Boot your system with the cd in the drive. At the EFI prompt type (note
> that "rescue" is missing from the docs:
> 
> eli vmlinux root=/dev/hda rescue
> 
> Log in as root (no password) and fdisk your drive:
> 
> fdisk /dev/sda
> 
> create a dos (fat16) partition (/dev/sda1) for later use by EFI
> create an ext2 filesystem for your root (/dev/sda2)
> create a swap partition (/dev/sda4)
> and format them:
> 
> mke2fs /dev/sda2
> mkdosfs /dev/sda1
> mkswap /dev/sda4
> 
> Now mount them using an existing directory and copy over the cd
> 
> mount /dev/sda2 /mnt/cdrom
> cd /
> cp -a README.IA-64 bin boot dev etc etc.simple home \
>  lib log root sbin tmp usr var /mnt/cdrom
> umount /mnt/cdrom
> mount /dev/sda1 /mnt/cdrom/
> cp /boot/* /mnt/cdrom/
> umount /mnt/cdrom
> 
> Now you should be ready to reboot off the hard drive. Take the CD out
> and reboot. The from the EFI prompt type:
> 
> eli vmlinux root=/dev/sda2
> 



I did something similar to this the other day and it worked.
The only thing I see missing from above is the change
to fstab file that was copied to the hard disk..



i.e.  

change your mount point of root, /,  to that of the sda2 instead of hdc1 (cdrom).

/dev/sda2               /                       ext2    defaults        1 1






Chuck






