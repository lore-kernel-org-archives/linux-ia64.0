From: Ameya Mitragotri <ameya.mitragotri@wipro.com>
Date: Fri, 22 Aug 2003 09:17:43 +0000
Subject: cross compiling ia64!
Message-Id: <marc-linux-ia64-106154319501965@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I have been trying ,rather unsuccessfully, to cross compile the linux
kernel 2.6-test3 using the compiler inside the NUE 1.2.

I get the following errors using gcc version 2.96-ia64-000717 snap
001117)

arch/ia64/scripts/check-gas-asm.S: Assembler messages:
arch/ia64/scripts/check-gas-asm.S:1: Error: Expected ':'
arch/ia64/scripts/check-gas-asm.S:1: Error: Rest of line ignored. First
ignored character is `:'.
arch/ia64/scripts/check-gas-asm.S:2: Error: backw. ref to unknown label
"1:", 0 assumed.
ia64-hp-linux-objdump: /tmp/out17472.o: No such file or directory
arch/ia64/scripts/check-gas: [: !=: unary operator expected
arch/ia64/Makefile:41: *** Sorry, your compiler is too old.  GCC v2.96
is known to generate bad code..  Stop

so I tried the following:
Replaced the gcc with 3.0.1 & binutils with 2.11. The binutils still
gave problems, replaced them with 2.14. This took care of the assembler
problem and gcc warning, but the kernel compile fails at
arch/ia64/kernel/signal.c

<snip>
  CC      arch/ia64/kernel/signal.o
arch/ia64/kernel/signal.c: In function `copy_siginfo_to_user':
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
make[1]: *** [arch/ia64/kernel/signal.o] Error 1
make: *** [arch/ia64/kernel] Error 2
<snip>

My guess that 3.0.1 may not be the correct version for compiling 2.6. I
have also tried to compile 2.95.3 (as suggested in the README) for ia64,
but it seem that 2.95.3 does not support ia64 configuration. Any
pointers/references to solve this?

thanks
ameya

the complete build output is as below:

warning: your linker cannot handle cross-segment segment-relative
relocations.
         please upgrade to a newer version (it is safe to use this
linker, but
         the kernel will be bigger than strictly necessary).
  HOSTCC  scripts/file2alias.o
  HOSTCC  scripts/modpost.o
  HOSTLD  scripts/modpost
  HOSTCC  scripts/pnmtologo
  SHIPPED scripts/kconfig/zconf.tab.h
  HOSTCC  scripts/kconfig/conf.o
  HOSTCC  scripts/kconfig/mconf.o
  SHIPPED scripts/kconfig/zconf.tab.c
  SHIPPED scripts/kconfig/lex.zconf.c
  HOSTCC  -fPIC scripts/kconfig/zconf.tab.o
  HOSTLLD -shared scripts/kconfig/libkconfig.so
  HOSTLD  scripts/kconfig/conf
./scripts/kconfig/conf -s arch/ia64/Kconfig
boolean symbol BINFMT_ZFLAT tested for 'm'? test forced to 'n'
#
# using defaults found in .config
#
  SPLIT   include/linux/autoconf.h -> include/config/*
[ -s include/asm-ia64/offsets.h ] \
 || echo "#define IA64_TASK_SIZE 0" > include/asm-ia64/offsets.h
touch include/asm-ia64/.offsets.h.stamp
  CC      arch/ia64/kernel/asm-offsets.s
  CHK     include/asm-ia64/offsets.h
  UPD     include/asm-ia64/offsets.h
  CC      init/main.o
  CHK     include/linux/compile.h
  UPD     include/linux/compile.h
  CC      init/version.o
  CC      init/do_mounts.o
  CC      init/do_mounts_rd.o
init/do_mounts_rd.c: In function `rd_load_image':
include/asm/unistd.h:338: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:338: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:338: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:338: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:339: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:339: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:338: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:338: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:334: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:334: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:333: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:333: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:339: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:339: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:339: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:339: warning: `dummy5' might be used uninitialized
in this function
init/do_mounts_rd.c: In function `fill_inbuf':
include/asm/unistd.h:334: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:334: warning: `dummy5' might be used uninitialized
in this function
init/do_mounts_rd.c: In function `flush_window':
include/asm/unistd.h:333: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:333: warning: `dummy5' might be used uninitialized
in this function
  LD      init/mounts.o
  CC      init/initramfs.o
  LD      init/built-in.o
  HOSTCC  usr/gen_init_cpio
  CPIO    usr/initramfs_data.cpio
  GZIP    usr/initramfs_data.cpio.gz
  AS      usr/initramfs_data.o
  LD      usr/built-in.o
  CC      arch/ia64/kernel/acpi.o
  AS      arch/ia64/kernel/entry.o
  CC      arch/ia64/kernel/efi.o
  AS      arch/ia64/kernel/efi_stub.o
  CPP     arch/ia64/kernel/gate.lds.s
  AS      arch/ia64/kernel/gate.o
  GATE arch/ia64/kernel/gate.so
  AS      arch/ia64/kernel/gate-data.o
  AS      arch/ia64/kernel/fsys.o
arch/ia64/kernel/fsys.S: Assembler messages:
arch/ia64/kernel/fsys.S:409: Warning: Use of 'mov.m' violates RAW
dependency 'PSR.si' (data)
arch/ia64/kernel/fsys.S:409: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/fsys.S:405: Warning: This is the location of the
conflicting usage
  CC      arch/ia64/kernel/ia64_ksyms.o
  CC      arch/ia64/kernel/irq.o
  CC      arch/ia64/kernel/irq_ia64.o
  CC      arch/ia64/kernel/irq_lsapic.o
  AS      arch/ia64/kernel/ivt.o
arch/ia64/kernel/ivt.S: Assembler messages:
arch/ia64/kernel/ivt.S:187: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:187: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:163: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:187: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:187: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:164: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:187: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:187: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:179: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:188: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:188: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:163: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:188: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:188: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:164: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:188: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:188: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:179: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:230: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:230: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:227: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:268: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:268: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:265: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:505: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:505: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:503: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:564: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:564: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:562: Warning: This is the location of the
conflicting usage
arch/ia64/kernel/ivt.S:612: Warning: Use of 'ld8' violates RAW
dependency 'DTC' (data)
arch/ia64/kernel/ivt.S:612: Warning: Only the first path encountering
the conflict is reported
arch/ia64/kernel/ivt.S:610: Warning: This is the location of the
conflicting usage
  CC      arch/ia64/kernel/machvec.o
  AS      arch/ia64/kernel/pal.o
  CC      arch/ia64/kernel/patch.o
  CC      arch/ia64/kernel/process.o
arch/ia64/kernel/process.c: In function `kernel_thread':
include/asm/unistd.h:341: warning: `dummy3' might be used uninitialized
in this function
include/asm/unistd.h:341: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:341: warning: `dummy5' might be used uninitialized
in this function
include/asm/unistd.h:344: warning: `dummy3' might be used uninitialized
in this function
include/asm/unistd.h:344: warning: `dummy4' might be used uninitialized
in this function
include/asm/unistd.h:344: warning: `dummy5' might be used uninitialized
in this function
  CC      arch/ia64/kernel/perfmon.o
  CC      arch/ia64/kernel/ptrace.o
  CC      arch/ia64/kernel/sal.o
  CC      arch/ia64/kernel/semaphore.o
  CC      arch/ia64/kernel/setup.o
  CC      arch/ia64/kernel/signal.o
arch/ia64/kernel/signal.c: In function `copy_siginfo_to_user':
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
arch/ia64/kernel/signal.c:195: cast to union type from type not present
in union
make[1]: *** [arch/ia64/kernel/signal.o] Error 1
make: *** [arch/ia64/kernel] Error 2



