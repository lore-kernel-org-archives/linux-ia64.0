From: Keith Owens <kaos@sgi.com>
Date: Fri, 22 Mar 2002 00:57:28 +0000
Subject: Re: [Linux-ia64] Trouble building cross compilers
Message-Id: <marc-linux-ia64-105590701905322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905309@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905309@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 21 Mar 2002 16:28:04 -0800, 
Jesse Barnes <jbarnes@sgi.com> wrote:
>However, upon linking the kernel, I got the following errors.  Do I
>need a different version of binutils or something?  I'm running 2.12.
>
>/tmp/ia64-cross-3.0/bin/ia64-linux-ld -static -T arch/ia64/vmlinux.lds arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o init/main.o init/version.o --start-group arch/ia64/kernel/kernel.o arch/ia64/mm/mm.o arch/ia64/ia32/ia32.o arch/ia64/sn/kernel/sn.o arch/ia64/sn/io/sgiio.o kernel/kernel.o mm/mm.o fs/fs.o ipc/ipc.o kdb/kdb.o  drivers/acpi/acpi.o drivers/char/char.o drivers/block/block.o drivers/misc/misc.o drivers/net/net.o drivers/media/media.o drivers/ide/idedriver.o drivers/xscsi/xscsidrv.o drivers/x1394/x1394drv.o drivers/sgi/sn/sn_drivers.a drivers/pci/driver.o drivers/md/mddev.o net/network.o /home/jbarnes/working/snlinux-tot/linux/arch/ia64/lib/lib.a /home/jbarnes/working/snlinux-tot/linux/lib/lib.a /home/jbarnes/working/snlinux-tot/linux/arch/ia64/kdb/kdba.o /home/jbarnes/working/snlinux-tot/linux/arch/ia64/lib/lib.a --end-group -o .tmp_vmlinux1
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x0): undefined reference to `local symbols in discarded section .text.exit'
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x8): undefined reference to `local symbols in discarded section .text.exit'
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x18): undefined reference to `local symbols in discarded section .text.exit'
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x20): undefined reference to `local symbols in discarded section .text.exit'
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x0): unsupported reloc
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x8): unsupported reloc
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x18): unsupported reloc
>arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x20): unsupported reloc
>make[1]: *** [kallsyms] Error 1
>make[1]: Leaving directory `/home/jbarnes/working/snlinux-tot/linux'
>make: *** [vmlinux] Error 2

Recent binutils complain about dangling references to discarded
sections.  binutils is up to date, check arch.ia64/vmlinux.lds.S, it
should have

  /* Sections to be discarded */
  /DISCARD/ : {
        *(.text.exit)
        *(.data.exit)
        *(.exitcall.exit)
        *(.IA_64.unwind.text.exit)
        *(.IA_64.unwind_info.text.exit)
        }


