From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 24 Oct 2000 01:04:31 +0000
Subject: Re: [Linux-ia64] Making a CD that is readable under efi
Message-Id: <marc-linux-ia64-105590678205611@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205609@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205609@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Randall G Chan/Fremont/IBM wrote:

> I was wondering if someone could explain how I would make a small partition
> that is readable under efi (~50-100 megs) and then including about 500 or
> so megs of data.  I have tried just creating a ISO9660 CD-Rom, but I can't
> read any of it's contents under efi.

The trick to have larger MS-DOS partitions is to create a file called boot.img
and format it as MS-DOS partition.  Place the file in the root directory of
the ISO9660 filesystem that you wish to burn on the CD.  For example, this
script will create a 50M boot.img file and copy stuff from /boot/efi into it:

     dd if=/dev/zero of=boot.img bs24k countP
     /sbin/mkdosfs boot.img
     mount -t msdos -o loop boot.img /mnt
     cp -av /boot/efi/* /mnt
     df /mnt
     umount /mnt

Be careful with 2.4.0 kernels -- the loop device is broken.  Run the above
script on a 2.2 kernel.

Create ISO image with mkisofs (we use version 1.13a05) as follows:

     mkisofs  -no-emul-boot -b boot.img -c boot.catalog \
         -R -T -J -o cdrom.img /path/to/the/cd/root

When you burn the ISO image be sure to disable MS Jolliet extensions.

Hope this helps,
Uros

--
Uros Prestor
uros@turbolinux.com




