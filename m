From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 04 Oct 2010 02:20:23 +0000
Subject: [RFC][PATCH] [ia64] Raise minimum binutils version and remove
Message-Id: <1286158823.3916.227.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I believe all these bugs were fixed by 2.16, and that's old enough
now that it seems reasonable to require it as a minimum version.

This is an RFC only for now since I'm not really familiar with ia64.  In
Debian we've been patching these checks out for a while so that they
don't run when building OOT modules.

Ben.
---
 Documentation/Changes                |    2 +-
 arch/ia64/Makefile                   |   17 +--------
 arch/ia64/include/asm/asmmacro.h     |   20 ++---------
 arch/ia64/include/asm/gcc_intrin.h   |    9 +----
 arch/ia64/include/asm/percpu.h       |    4 +--
 arch/ia64/kernel/paravirt.c          |    4 --
 arch/ia64/scripts/check-gas          |   15 --------
 arch/ia64/scripts/check-gas-asm.S    |    2 -
 arch/ia64/scripts/check-model.c      |    1 -
 arch/ia64/scripts/check-segrel.S     |    4 --
 arch/ia64/scripts/check-segrel.lds   |   12 ------
 arch/ia64/scripts/check-serialize.S  |    2 -
 arch/ia64/scripts/check-text-align.S |    6 ---
 arch/ia64/scripts/toolchain-flags    |   53 ----------------------------
 arch/ia64/scripts/unwcheck.py        |   64 ------------------------------=
----
 15 files changed, 8 insertions(+), 207 deletions(-)
 delete mode 100755 arch/ia64/scripts/check-gas
 delete mode 100644 arch/ia64/scripts/check-gas-asm.S
 delete mode 100644 arch/ia64/scripts/check-model.c
 delete mode 100644 arch/ia64/scripts/check-segrel.S
 delete mode 100644 arch/ia64/scripts/check-segrel.lds
 delete mode 100644 arch/ia64/scripts/check-serialize.S
 delete mode 100644 arch/ia64/scripts/check-text-align.S
 delete mode 100755 arch/ia64/scripts/toolchain-flags
 delete mode 100644 arch/ia64/scripts/unwcheck.py

diff --git a/Documentation/Changes b/Documentation/Changes
index 4fb88f1..23fc499 100644
--- a/Documentation/Changes
+++ b/Documentation/Changes
@@ -30,7 +30,7 @@ isdn4k-utils.
=20
 o  Gnu C                  3.2                     # gcc --version
 o  Gnu make               3.80                    # make --version
-o  binutils               2.12                    # ld -v
+o  binutils               2.12 (2.16 for ia64)    # ld -v
 o  util-linux             2.10o                   # fdformat --version
 o  module-init-tools      0.9.10                  # depmod -V
 o  e2fsprogs              1.41.4                  # e2fsck -V
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index be7bfa1..9feddc4 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -30,17 +30,6 @@ cflags-y	:=3D -pipe $(EXTRA) -ffixed-r13 -mfixed-range=
=F12-f15,f32-f127 \
 		   -falign-functions2 -frename-registers -fno-optimize-sibling-calls
 KBUILD_CFLAGS_KERNEL :=3D -mconstant-gp
=20
-GAS_STATUS	=3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(O=
BJDUMP)")
-KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-flags =
"$(CC)" "$(OBJDUMP)" "$(READELF)")
-
-ifeq ($(GAS_STATUS),buggy)
-$(error Sorry, you need a newer version of the assember, one that is built=
 from	\
-	a source-tree that post-dates 18-Dec-2002.  You can find a pre-compiled	\
-	static binary of such an assembler at:					\
-										\
-		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
-endif
-
 KBUILD_CFLAGS +=3D $(cflags-y)
 head-y :=3D arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
=20
@@ -68,7 +57,7 @@ boot :=3D arch/ia64/hp/sim/boot
=20
 PHONY +=3D boot compressed check
=20
-all: compressed unwcheck
+all: compressed
=20
 compressed: vmlinux.gz
=20
@@ -77,9 +66,6 @@ vmlinuz: vmlinux.gz
 vmlinux.gz: vmlinux
 	$(Q)$(MAKE) $(build)=3D$(boot) $@
=20
-unwcheck: vmlinux
-	-$(Q)READELF=3D$(READELF) python $(srctree)/arch/ia64/scripts/unwcheck.py=
 $<
-
 archclean:
 	$(Q)$(MAKE) $(clean)=3D$(boot)
=20
@@ -95,7 +81,6 @@ define archhelp
   echo '* compressed	- Build compressed kernel image'
   echo '  install	- Install compressed kernel image'
   echo '  boot		- Build vmlinux and bootloader for Ski simulator'
-  echo '* unwcheck	- Check vmlinux for invalid unwind info'
 endef
=20
 archprepare: make_nr_irqs_h FORCE
diff --git a/arch/ia64/include/asm/asmmacro.h b/arch/ia64/include/asm/asmma=
cro.h
index 3ab6d75..003106b 100644
--- a/arch/ia64/include/asm/asmmacro.h
+++ b/arch/ia64/include/asm/asmmacro.h
@@ -113,23 +113,9 @@ name:
 [1:]	adds reg=3DIA64_NUM_PHYS_STACK_REG*8+8,r0;	\
 	.xdata4 ".data..patch.phys_stack_reg", 1b-.
=20
-/*
- * Up until early 2004, use of .align within a function caused bad unwind =
info.
- * TEXT_ALIGN(n) expands into ".align n" if a fixed GAS is available or in=
to nothing
- * otherwise.
- */
-#ifdef HAVE_WORKING_TEXT_ALIGN
-# define TEXT_ALIGN(n)	.align n
-#else
-# define TEXT_ALIGN(n)
-#endif
+#define TEXT_ALIGN(n)	.align n
=20
-#ifdef HAVE_SERIALIZE_DIRECTIVE
-# define dv_serialize_data		.serialize.data
-# define dv_serialize_instruction	.serialize.instruction
-#else
-# define dv_serialize_data
-# define dv_serialize_instruction
-#endif
+#define dv_serialize_data		.serialize.data
+#define dv_serialize_instruction	.serialize.instruction
=20
 #endif /* _ASM_IA64_ASMMACRO_H */
diff --git a/arch/ia64/include/asm/gcc_intrin.h b/arch/ia64/include/asm/gcc=
_intrin.h
index 21ddee5..18f2efb 100644
--- a/arch/ia64/include/asm/gcc_intrin.h
+++ b/arch/ia64/include/asm/gcc_intrin.h
@@ -396,13 +396,8 @@ register unsigned long ia64_r13 asm ("r13") __used;
 #define ia64_srlz_i()	asm volatile (";; srlz.i ;;" ::: "memory")
 #define ia64_srlz_d()	asm volatile (";; srlz.d" ::: "memory");
=20
-#ifdef HAVE_SERIALIZE_DIRECTIVE
-# define ia64_dv_serialize_data()		asm volatile (".serialize.data");
-# define ia64_dv_serialize_instruction()	asm volatile (".serialize.instruc=
tion");
-#else
-# define ia64_dv_serialize_data()
-# define ia64_dv_serialize_instruction()
-#endif
+#define ia64_dv_serialize_data()	asm volatile (".serialize.data");
+#define ia64_dv_serialize_instruction()	asm volatile (".serialize.instruct=
ion");
=20
 #define ia64_nop(x)	asm volatile ("nop %0"::"i"(x));
=20
diff --git a/arch/ia64/include/asm/percpu.h b/arch/ia64/include/asm/percpu.h
index 14aa1c5..59728d3 100644
--- a/arch/ia64/include/asm/percpu.h
+++ b/arch/ia64/include/asm/percpu.h
@@ -17,9 +17,7 @@
=20
 #ifdef CONFIG_SMP
=20
-#ifdef HAVE_MODEL_SMALL_ATTRIBUTE
-# define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
-#endif
+#define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
=20
 #define __my_cpu_offset	__ia64_per_cpu_var(local_per_cpu_offset)
=20
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index a21d7bb..e5c093a 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -488,9 +488,7 @@ __DEFINE_FUNC(setreg,
 	      "cmp.eq p6, p0 =3D r2, r9\n"
 	      ";;\n"
 	      "(p6) mov psr.l =3D r8\n"
-#ifdef HAVE_SERIALIZE_DIRECTIVE
 	      ".serialize.data\n"
-#endif
 	      "(p6) br.cond.sptk.many b6\n"
 	      __DEFINE_SET_REG(GP, gp)
 	      __DEFINE_SET_REG(SP, sp)
@@ -682,9 +680,7 @@ IA64_NATIVE_PATCH_DEFINE_GET_REG(tp, tp);
 __DEFINE_FUNC(set_psr_l,
 	      ";;\n"
 	      "mov psr.l =3D r8\n"
-#ifdef HAVE_SERIALIZE_DIRECTIVE
 	      ".serialize.data\n"
-#endif
 	      ";;\n");
=20
 IA64_NATIVE_PATCH_DEFINE_REG(gp, gp);
diff --git a/arch/ia64/scripts/check-gas b/arch/ia64/scripts/check-gas
deleted file mode 100755
index 2499e0b..0000000
--- a/arch/ia64/scripts/check-gas
+++ /dev/null
@@ -1,15 +0,0 @@
-#!/bin/sh
-dir=3D$(dirname $0)
-CC=3D$1
-OBJDUMP=3D$2
-tmp=3D${TMPDIR:-/tmp}
-out=3D$tmp/out$$.o
-$CC -c $dir/check-gas-asm.S -o $out
-res=3D$($OBJDUMP -r --section .data $out | fgrep 00004 | tr -s ' ' |cut -f=
3 -d' ')
-rm -f $out
-if [ $res !=3D ".text" ]; then
-	echo buggy
-else
-	echo good
-fi
-exit 0
diff --git a/arch/ia64/scripts/check-gas-asm.S b/arch/ia64/scripts/check-ga=
s-asm.S
deleted file mode 100644
index 010e1d2..0000000
--- a/arch/ia64/scripts/check-gas-asm.S
+++ /dev/null
@@ -1,2 +0,0 @@
-[1:]	nop 0
-	.xdata4 ".data", 0, 1b-.
diff --git a/arch/ia64/scripts/check-model.c b/arch/ia64/scripts/check-mode=
l.c
deleted file mode 100644
index e1d4e86..0000000
--- a/arch/ia64/scripts/check-model.c
+++ /dev/null
@@ -1 +0,0 @@
-int __attribute__ ((__model__ (__small__))) x;
diff --git a/arch/ia64/scripts/check-segrel.S b/arch/ia64/scripts/check-seg=
rel.S
deleted file mode 100644
index 3be4e3d..0000000
--- a/arch/ia64/scripts/check-segrel.S
+++ /dev/null
@@ -1,4 +0,0 @@
-	.rodata
-	data4 @segrel(start)
-	.data
-start:
diff --git a/arch/ia64/scripts/check-segrel.lds b/arch/ia64/scripts/check-s=
egrel.lds
deleted file mode 100644
index 85a0d54..0000000
--- a/arch/ia64/scripts/check-segrel.lds
+++ /dev/null
@@ -1,12 +0,0 @@
-SECTIONS {
-	. =3D SIZEOF_HEADERS;
-	.rodata : { *(.rodata) } :ro
-	.note : { *(.note*) }
-	. =3D 0xa0000;
-	.data : { *(.data) } :dat
-	/DISCARD/ : { *(*) }
-}
-PHDRS {
-  ro PT_LOAD FILEHDR PHDRS;
-  dat PT_LOAD;
-}
diff --git a/arch/ia64/scripts/check-serialize.S b/arch/ia64/scripts/check-=
serialize.S
deleted file mode 100644
index 0400c10..0000000
--- a/arch/ia64/scripts/check-serialize.S
+++ /dev/null
@@ -1,2 +0,0 @@
-	.serialize.data
-	.serialize.instruction
diff --git a/arch/ia64/scripts/check-text-align.S b/arch/ia64/scripts/check=
-text-align.S
deleted file mode 100644
index 03f586a..0000000
--- a/arch/ia64/scripts/check-text-align.S
+++ /dev/null
@@ -1,6 +0,0 @@
-	.proc foo
-	.prologue
-foo:	.save rp, r2
-	nop 0
-	.align 64
-	.endp foo
diff --git a/arch/ia64/scripts/toolchain-flags b/arch/ia64/scripts/toolchai=
n-flags
deleted file mode 100755
index 3f0c2ad..0000000
--- a/arch/ia64/scripts/toolchain-flags
+++ /dev/null
@@ -1,53 +0,0 @@
-#!/bin/sh
-#
-# Check whether linker can handle cross-segment @segrel():
-#
-CPPFLAGS=3D""
-CC=3D$1
-OBJDUMP=3D$2
-READELF=3D$3
-dir=3D$(dirname $0)
-tmp=3D${TMPDIR:-/tmp}
-out=3D$tmp/out$$
-
-# Check whether cross-segment segment-relative relocs work fine.  We need
-# that for building the gate DSO:
-
-$CC -nostdlib -static -Wl,-T$dir/check-segrel.lds $dir/check-segrel.S -o $=
out
-res=3D$($OBJDUMP --full --section .rodata $out | fgrep 000 | cut -f3 -d' ')
-rm -f $out
-if [ $res !=3D 00000a00 ]; then
-    CPPFLAGS=3D"$CPPFLAGS -DHAVE_BUGGY_SEGREL"
-    cat >&2 <<EOF
-warning: your linker cannot handle cross-segment segment-relative relocati=
ons.
-         please upgrade to a newer version (it is safe to use this linker,=
 but
-         the kernel will be bigger than strictly necessary).
-EOF
-fi
-
-# Check whether .align inside a function works as expected.
-
-$CC -c $dir/check-text-align.S -o $out
-$READELF -u $out | fgrep -q 'prologue(rlen=12)'
-res=3D$?
-rm -f $out
-if [ $res -eq 0 ]; then
-    CPPFLAGS=3D"$CPPFLAGS -DHAVE_WORKING_TEXT_ALIGN"
-fi
-
-if ! $CC -c $dir/check-model.c -o $out 2>&1 | grep  __model__ | grep -q at=
trib
-then
-    CPPFLAGS=3D"$CPPFLAGS -DHAVE_MODEL_SMALL_ATTRIBUTE"
-fi
-rm -f $out
-
-# Check whether assembler supports .serialize.{data,instruction} directive.
-
-$CC -c $dir/check-serialize.S -o $out 2>/dev/null
-res=3D$?
-rm -f $out
-if [ $res -eq 0 ]; then
-    CPPFLAGS=3D"$CPPFLAGS -DHAVE_SERIALIZE_DIRECTIVE"
-fi
-
-echo $CPPFLAGS
diff --git a/arch/ia64/scripts/unwcheck.py b/arch/ia64/scripts/unwcheck.py
deleted file mode 100644
index 2bfd941..0000000
--- a/arch/ia64/scripts/unwcheck.py
+++ /dev/null
@@ -1,64 +0,0 @@
-#!/usr/bin/python
-#
-# Usage: unwcheck.py FILE
-#
-# This script checks the unwind info of each function in file FILE
-# and verifies that the sum of the region-lengths matches the total
-# length of the function.
-#
-# Based on a shell/awk script originally written by Harish Patil,
-# which was converted to Perl by Matthew Chapman, which was converted
-# to Python by David Mosberger.
-#
-import os
-import re
-import sys
-
-if len(sys.argv) !=3D 2:
-    print "Usage: %s FILE" % sys.argv[0]
-    sys.exit(2)
-
-readelf =3D os.getenv("READELF", "readelf")
-
-start_pattern =3D re.compile("<([^>]*)>: \[0x([0-9a-f]+)-0x([0-9a-f]+)\]")
-rlen_pattern  =3D re.compile(".*rlen=3D([0-9]+)")
-
-def check_func (func, slots, rlen_sum):
-    if slots !=3D rlen_sum:
-        global num_errors
-        num_errors +=3D 1
-        if not func: func =3D "[%#x-%#x]" % (start, end)
-        print "ERROR: %s: %lu slots, total region length =3D %lu" % (func,=
 slots, rlen_sum)
-    return
-
-num_funcs =3D 0
-num_errors =3D 0
-func =3D False
-slots =3D 0
-rlen_sum =3D 0
-for line in os.popen("%s -u %s" % (readelf, sys.argv[1])):
-    m =3D start_pattern.match(line)
-    if m:
-        check_func(func, slots, rlen_sum)
-
-        func  =3D m.group(1)
-        start =3D long(m.group(2), 16)
-        end   =3D long(m.group(3), 16)
-        slots =3D 3 * (end - start) / 16
-        rlen_sum =3D 0L
-        num_funcs +=3D 1
-    else:
-        m =3D rlen_pattern.match(line)
-        if m:
-            rlen_sum +=3D long(m.group(1))
-check_func(func, slots, rlen_sum)
-
-if num_errors =3D 0:
-    print "No errors detected in %u functions." % num_funcs
-else:
-    if num_errors > 1:
-        err=3D"errors"
-    else:
-        err=3D"error"
-    print "%u %s detected in %u functions." % (num_errors, err, num_funcs)
-    sys.exit(1)
--=20
1.7.1


