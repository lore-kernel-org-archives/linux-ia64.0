From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 22 Mar 2002 00:28:04 +0000
Subject: Re: [Linux-ia64] Trouble building cross compilers
Message-Id: <marc-linux-ia64-105590701905320@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905309@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905309@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 21, 2002 at 01:01:18PM -0800, Jim Wilson wrote:
> Yes.

Excellent.
 
> Andreas Schwab mentioned --with-headers=.  There is also a --with-libs= option.
> You need to set up IA-64 .../usr/include and .../use/lib trees on the x86
> host, and use these configure options to point at the IA-64 headers and libs
> respectively.

That more or less did the trick.  I did
--with-headers=<target_usr_include> and --with-libs=<target_usr_lib>,
though the build complained that crt.* and libc.so didn't exist, so I
copied from a target machine's /usr/lib directory and created a
libc.so -> libc-2.2.4.so symlink.  After that was done, gcc-3.0 built
and installed as a cross compiler.  The target machine I got
everything from was a Red Hat 7.1 box with the updated glibc-2.2.4
packages.

However, upon linking the kernel, I got the following errors.  Do I
need a different version of binutils or something?  I'm running 2.12.

/tmp/ia64-cross-3.0/bin/ia64-linux-ld -static -T arch/ia64/vmlinux.lds arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o init/main.o init/version.o --start-group arch/ia64/kernel/kernel.o arch/ia64/mm/mm.o arch/ia64/ia32/ia32.o arch/ia64/sn/kernel/sn.o arch/ia64/sn/io/sgiio.o kernel/kernel.o mm/mm.o fs/fs.o ipc/ipc.o kdb/kdb.o  drivers/acpi/acpi.o drivers/char/char.o drivers/block/block.o drivers/misc/misc.o drivers/net/net.o drivers/media/media.o drivers/ide/idedriver.o drivers/xscsi/xscsidrv.o drivers/x1394/x1394drv.o drivers/sgi/sn/sn_drivers.a drivers/pci/driver.o drivers/md/mddev.o net/network.o /home/jbarnes/working/snlinux-tot/linux/arch/ia64/lib/lib.a /home/jbarnes/working/snlinux-tot/linux/lib/lib.a /home/jbarnes/working/snlinux-tot/linux/arch/ia64/kdb/kdba.o /home/jbarnes/working/snlinux-tot/linux/arch/ia64/lib/lib.a --end-group -o .tmp_vmlinux1
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x0): undefined reference to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x8): undefined reference to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x18): undefined reference to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x20): undefined reference to `local symbols in discarded section .text.exit'
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x0): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x8): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x18): unsupported reloc
arch/ia64/kernel/kernel.o(.IA_64.unwind.text.exit+0x20): unsupported reloc
make[1]: *** [kallsyms] Error 1
make[1]: Leaving directory `/home/jbarnes/working/snlinux-tot/linux'
make: *** [vmlinux] Error 2

> There is also the matter that gcc 3.0 out of the box does not support cross
> compiling from a 32-bit host to a 64-bit target.  This was fixed for gcc 3.1,
> but could not be fixed in gcc 3.0 because of latent problems with the powerpc
> (rs6000) port.  I've already pointed at the recommended solution:
> http://gcc.gnu.org/ml/gcc/2002-02/msg00643.html

Yeah, that was the easy part to fix...

> With these two changes, it should work, however, because gcc is big and
> complicated and there are lots of things that can go wrong in a build.  Cross
> compilers are much harder to get right than native compilers.  Personally, I
> stopped building cross compilers once the ia64-linux systems were stable enough
> such that I never had to worry about my native builds failing.

I prefer cross compiling when possible as it's *much* faster than
native compiling.

> If you use the solution suggested by Steve Christiansen, then your cross
> compiled code will be very different, mainly bigger and slower.  If you
> use the solution I suggested, the code should be the same in theory, but
> I don't know of anyone who has tried to verify this.

I'll definitely check this out once I have the cross compiler fully
working.  Thanks for all your help.

Jesse

