From: Uros Prestor <uros@turbolinux.com>
Date: Wed, 12 Jul 2000 02:38:31 +0000
Subject: Re: [Linux-ia64] issues of Linux 2.3.99 installed on BigSur EFI 1.00
Message-Id: <marc-linux-ia64-105590678205195@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205194@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205194@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

yiding_wang@agilent.com wrote:

> Problem - System booted fine and most IO test OK before the upgrade.  After
> upgrade,
>                BIOS can see the scsi device
>                EFI also see the files on the drive
>                "eli vmlinux root=/dev/sda3" will fail due to cannot found
> /dev/sda3
>                Tried other possible device node but none of them works.

Could you send the dmesg output?  This will tell us the kernel version and the
devices kernel recognizes.

To get the dmesg output boot from CD and set root to your
CD-ROM (root=/dev/hda, /dev/hdb, ...).  Once you are in the installer press
Alt-F2 and you should see a bash prompt.  Now mount a LS-120 floppy on
/mnt/floppy (your LS-120 might be something other than /dev/hdb):

     # mount /dev/hdb /mnt/floppy
     # dmesg >/mnt/floppy/dmesg.out
     # umount /mnt/floppy

> Problem - System failed during the boot.  All scsi command timed out and
> aborted after
>                BIOS, EFI and eli sees the device.

SCSI timeouts usually happen when eli passes incorrect interrupt vectors to the
kernel.  I suggest that you update the eli on your system.  The latest eli RPM
is available at:

     ftp://ftp.turbolinux.com/pub/ia64/0505/updates/RPMS/ia64/eli-0.4.0-2.ia64.rpm

Uros

--
Uros Prestor
uros@turbolinux.com





