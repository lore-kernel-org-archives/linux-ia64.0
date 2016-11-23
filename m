From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Wed, 23 Nov 2016 20:37:57 +0000
Subject: GCC 4.9.4-compiled kernel: invalid slot number 1 for IMM64 errors while loading modules
Message-Id: <CAA9xbM7Lw8VgVaG+h74j+G3g+DMC+b+37MtO18jcThhPsLdfBA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

GCC 4.9.4 just got stabilized on Gentoo ia64, so I've rebuilt my
system packages, including kernel. This yields to a non-booting
kernel, with the following errors:

>> Loading modules
   :: Loading from pata:
   :: Loading from sata:
   :: Loading from scsi:
   :: Loading from usb: usb_storage: invalid slot number 1 for IMM64

   :: Loading from firewire:
   :: Loading from waitscan:
   :: Loading from dmraid:
   :: Loading from mdadm: raid0: invalid slot number 1 for IMM64
raid1: invalid slot number 1 for IMM64
async_tx: invalid slot number 1 for IMM64
async_tx: invalid slot number 1 for IMM64
async_tx: invalid slot number 1 for IMM64
raid10: invalid slot number 1 for IMM64

   :: Loading from fs: jbd2: invalid slot number 1 for IMM64
jbd2: invalid slot number 1 for IMM64
jbd2: invalid slot number 1 for IMM64
sunrpc: invalid slot number 1 for IMM64
fuse: invalid slot number 1 for IMM64

   :: Loading from net: libphy:

   :: Loading from iscsi:
>> Initializing root device...
>> Mounting /dev/sdb3 as root...
>> Detected fstype: ext4
>> Using mount fstype: ext4
>> Using mount opts: -o ro
jbd2: invalid slot number 1 for IMM64
mount: mounting /dev/sdb3 on /newroot failed: No such device
!! Cannot mount /dev/sdb3, trying with -t auto
UFS-fs: warning (device sdb3): udf_fill_super: No partition found (2)
mount: mounting /dev/sdb3 on /newroot failed: Invalid argument
!! Cannot mount /dev/sdb3 with -t auto, giving up
!! Could not mount specified ROOT, try again
!! Could not find the root block device in /dev/sdb3.
!! Please specify another value or:
!! - press Enter for the same
!! - type "shell" for a shell
!! - type "q" to skip...
root block device(/dev/sdb3) ::

These "invalid slot number 1 for IMM64" messages seem to originate
from arch/ia64/kernel/module.c, but I don't know how to deal with
them. It's noteworthy that the exact same kernel source built with GCC
4.5.4 or 4.9.3, using the same kernel configuration file, boots fine.

Does anybody have success building kernel with recent GCC? Am I seeing
a problem with GCC, the kernel or in-between?

Thanks,

     =C3=89meric
