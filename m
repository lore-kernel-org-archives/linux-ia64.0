From: Grant Grundler <grundler@cup.hp.com>
Date: Sat, 05 Jan 2002 03:21:30 +0000
Subject: Re: [Linux-ia64] Compiling kernel 2.4.17 fails at link stage
Message-Id: <marc-linux-ia64-105590698805746@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805743@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805743@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"H . J . Lu" wrote:
> Use --noinhibit-exec.

It didn't complain. But it didn't help either:

ld -static -T arch/ia64/vmlinux.lds --noinhibit-exec arch/ia64/kernel/head.=
o arch/ia64/kernel/init_task.o init/main.o init/version.o \
        --start-group \
        arch/ia64/kernel/kernel.o arch/ia64/mm/mm.o arch/ia64/ia32/ia32.o a=
rch/ia64/dig/dig.a kernel/kernel.o mm/mm.o fs/fs.o ipc/ipc.o \
         drivers/acpi/acpi.o drivers/char/char.o drivers/block/block.o driv=
ers/misc/misc.o drivers/net/net.o drivers/media/media.o drivers/char/agp/ag=
p.o drivers/char/drm/drm.o drivers/net/fc/fc.o drivers/ide/idedriver.o driv=
ers/scsi/scsidrv.o drivers/cdrom/driver.o drivers/sound/sounddrivers.o driv=
ers/pci/driver.o drivers/video/video.o drivers/usb/usbdrv.o drivers/input/i=
nputdrv.o \
        net/network.o \
        /usr/src/2.4.17/arch/ia64/lib/lib.a /usr/src/2.4.17/lib/lib.a /usr/=
src/2.4.17/arch/ia64/lib/lib.a \
        --end-group \
        -o vmlinux
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x0): undefined reference=
 to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x8): undefined reference=
 to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x18): undefined referenc=
e to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x20): undefined referenc=
e to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x30): undefined referenc=
e to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x38): more undefined ref=
erences to `local symbols in discarded section .text.exit' follow
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x0): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x8): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x18): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x20): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x30): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x38): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x48): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x50): unsupported reloc
make: *** [vmlinux] Error 1
grundler <511>

More info appended.
BTW, binaries I'm using are Debian "woody".

thanks,
grant

hpntcv6:/home/grundler \<521\>ld -v
GNU ld version 2.11.92.0.12.3 20011121 Debian/GNU Linux

hpntcv6:/var/cache/apt/archives# dpkg -l binutils
Desired=3DUnknown/Install/Remove/Purge/Hold
| Status=3DNot/Installed/Config-files/Unpacked/Failed-config/Half-installed
|/ Err?=3D(none)/Hold/Reinst-required/X=3Dboth-problems (Status,Err: upperc=
ase=BAd)
||/ Name           Version        Description
+++-=3D=3D=3D=3D=3D=3D=3D-=3D=3D=3D=3D=3D=3D=3D-=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
ii  binutils       2.11.92.0.12.3 The GNU assembler, linker and binary util=
iti

hpntcv6:/var/cache/apt/archives# ls -l binutils_*
-rw-r--r--    1 root     root      1993810 Nov 25 17:27 binutils_2.11.92.0.=
10-4_ia64.deb
-rw-r--r--    1 root     root      2221132 Dec  6 11:35 binutils_2.11.92.0.=
12.3-2_ia64.deb
-rw-r--r--    1 root     root      2221386 Dec  9 16:06 binutils_2.11.92.0.=
12.3-3_ia64.deb
-rw-r--r--    1 root     root      2221136 Dec 27 00:54 binutils_2.11.92.0.=
12.3-4_ia64.deb


