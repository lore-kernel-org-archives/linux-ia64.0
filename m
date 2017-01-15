From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Sun, 15 Jan 2017 21:10:54 +0000
Subject: [PATCH v7 11/14] kprobes: move kprobe declarations to asm-generic/kprobes.h
Message-Id: <20170115211057.17167-12-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

Often all is needed is these small helpers, instead of compiler.h
or a full kprobes.h. This is important for asm helpers, in fact even
some asm/kprobes.h make use of these helpers... instead just keep a
generic asm file with helpers useful for asm code with the least amount
of clutter as possible.

Likewise we need now to also address what to do about this file for both
when architectures have CONFIG_HAVE_KPROBES, and when they do not. Then
for when architectures have CONFIG_HAVE_KPROBES but have disabled
CONFIG_KPROBES.

Right now most asm/kprobes.h do not have guards against CONFIG_KPROBES,
this means most architecture code cannot include asm/kprobes.h safely.
Correct this and add guards for architectures missing them. Additionally
provide architectures that not have kprobes support with the default
asm-generic solution. This lets us force asm/kprobes.h on the header
include/linux/kprobes.h always, but most importantly we can now safely
include just asm/kprobes.h on architecture code without bringing
the full kitchen sink of header files.

Two architectures already provided a guard against CONFIG_KPROBES on
its kprobes.h: sh, arch. The rest of the architectures needed gaurds
added. We avoid including any not-needed headers on asm/kprobes.h
unless kprobes have been enabled.

In a subsequent atomic change we can try now to remove compiler.h from
include/linux/kprobes.h.

During this sweep I've also identified a few architectures defining
a common macro needed for both kprobes and ftrace, that of the
definition of the breakput instruction up. Some refer to this as
BREAKPOINT_INSTRUCTION. This must be kept outside of the #ifdef
CONFIG_KPROBES guard.

v5:

o fix BREAKPOINT_INSTRUCTION dependency with kernel architecture
  ftrace implementations:  Although its correct to #ifdef CONFIG_KPROBES
  on the architecture arch/$(ARCH)/include/asm/kprobes.h when
  architectures support ftrace they will rely on the
  BREAKPOINT_INSTRUCTION definition, this needs to be kept out from
  CONFIG_KPROBES as ftrace can be enabled without kprobes. This
  fixes compilation on x86 where kprobes is disabled but ftrace is
  left enabled.

o include <asm/kprobes.h> on arch/arm64/kernel/probes/decode-insn.h

v4: introduced this patch into the series

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 MAINTAINERS                            |  1 +
 arch/alpha/include/asm/Kbuild          |  1 +
 arch/arc/include/asm/kprobes.h         |  6 ++++--
 arch/arm/include/asm/kprobes.h         |  4 ++++
 arch/arm/probes/decode.h               |  1 +
 arch/arm64/include/asm/kprobes.h       |  4 ++++
 arch/arm64/kernel/insn.c               |  1 +
 arch/arm64/kernel/probes/decode-insn.h |  2 ++
 arch/avr32/include/asm/kprobes.h       |  7 ++++++-
 arch/blackfin/include/asm/Kbuild       |  1 +
 arch/c6x/include/asm/Kbuild            |  1 +
 arch/cris/include/asm/Kbuild           |  1 +
 arch/frv/include/asm/Kbuild            |  1 +
 arch/h8300/include/asm/Kbuild          |  1 +
 arch/hexagon/include/asm/Kbuild        |  1 +
 arch/ia64/include/asm/kprobes.h        | 12 +++++++++---
 arch/m32r/include/asm/Kbuild           |  1 +
 arch/m68k/include/asm/Kbuild           |  1 +
 arch/metag/include/asm/Kbuild          |  1 +
 arch/microblaze/include/asm/Kbuild     |  1 +
 arch/mips/include/asm/kprobes.h        |  6 +++++-
 arch/mn10300/include/asm/kprobes.h     |  7 ++++++-
 arch/nios2/include/asm/Kbuild          |  1 +
 arch/openrisc/include/asm/Kbuild       |  1 +
 arch/parisc/include/asm/Kbuild         |  1 +
 arch/powerpc/include/asm/kprobes.h     |  3 +++
 arch/s390/include/asm/kprobes.h        |  7 ++++++-
 arch/score/include/asm/Kbuild          |  1 +
 arch/sh/include/asm/kprobes.h          |  5 ++++-
 arch/sparc/include/asm/kprobes.h       | 10 ++++++++--
 arch/tile/include/asm/kprobes.h        |  6 +++++-
 arch/um/include/asm/Kbuild             |  1 +
 arch/unicore32/include/asm/Kbuild      |  1 +
 arch/x86/include/asm/kprobes.h         |  9 ++++++++-
 arch/xtensa/include/asm/Kbuild         |  1 +
 include/asm-generic/kprobes.h          | 25 +++++++++++++++++++++++++
 include/linux/compiler.h               |  8 --------
 include/linux/kprobes.h                | 19 +++----------------
 38 files changed, 123 insertions(+), 38 deletions(-)
 create mode 100644 include/asm-generic/kprobes.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 99ca436e76d9..cee1efd50e04 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7250,6 +7250,7 @@ M:	Masami Hiramatsu <mhiramat@kernel.org>
 S:	Maintained
 F:	Documentation/kprobes.txt
 F:	include/linux/kprobes.h
+F:	include/asm-generic/kprobes.h
 F:	kernel/kprobes.c
 
 KS0108 LCD CONTROLLER DRIVER
diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index f3bdc31d3c97..54d388fd026f 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -13,3 +13,4 @@ generic-y += trace_clock.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/arc/include/asm/kprobes.h b/arch/arc/include/asm/kprobes.h
index 944dbedb38b5..00bdbe167615 100644
--- a/arch/arc/include/asm/kprobes.h
+++ b/arch/arc/include/asm/kprobes.h
@@ -9,6 +9,8 @@
 #ifndef _ARC_KPROBES_H
 #define _ARC_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
 #ifdef CONFIG_KPROBES
 
 typedef u16 kprobe_opcode_t;
@@ -55,6 +57,6 @@ void trap_is_kprobe(unsigned long address, struct pt_regs *regs);
 static void trap_is_kprobe(unsigned long address, struct pt_regs *regs)
 {
 }
-#endif
+#endif /* CONFIG_KPROBES */
 
-#endif
+#endif /* _ARC_KPROBES_H */
diff --git a/arch/arm/include/asm/kprobes.h b/arch/arm/include/asm/kprobes.h
index 3ea9be559726..59655459da59 100644
--- a/arch/arm/include/asm/kprobes.h
+++ b/arch/arm/include/asm/kprobes.h
@@ -16,6 +16,9 @@
 #ifndef _ARM_KPROBES_H
 #define _ARM_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#ifdef CONFIG_KPROBES
 #include <linux/types.h>
 #include <linux/ptrace.h>
 #include <linux/notifier.h>
@@ -83,4 +86,5 @@ struct arch_optimized_insn {
 	 */
 };
 
+#endif /* CONFIG_KPROBES */
 #endif /* _ARM_KPROBES_H */
diff --git a/arch/arm/probes/decode.h b/arch/arm/probes/decode.h
index f9b08ba7fe73..548d622a3159 100644
--- a/arch/arm/probes/decode.h
+++ b/arch/arm/probes/decode.h
@@ -22,6 +22,7 @@
 #include <linux/types.h>
 #include <linux/stddef.h>
 #include <asm/probes.h>
+#include <asm/kprobes.h>
 
 void __init arm_probes_decode_init(void);
 
diff --git a/arch/arm64/include/asm/kprobes.h b/arch/arm64/include/asm/kprobes.h
index 1737aecfcc5e..6deb8d726041 100644
--- a/arch/arm64/include/asm/kprobes.h
+++ b/arch/arm64/include/asm/kprobes.h
@@ -16,6 +16,9 @@
 #ifndef _ARM_KPROBES_H
 #define _ARM_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#ifdef CONFIG_KPROBES
 #include <linux/types.h>
 #include <linux/ptrace.h>
 #include <linux/percpu.h>
@@ -57,4 +60,5 @@ int kprobe_single_step_handler(struct pt_regs *regs, unsigned int esr);
 void kretprobe_trampoline(void);
 void __kprobes *trampoline_probe_handler(struct pt_regs *regs);
 
+#endif /* CONFIG_KPROBES */
 #endif /* _ARM_KPROBES_H */
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 022d4a9d1738..4e02fd369bf9 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -31,6 +31,7 @@
 #include <asm/debug-monitors.h>
 #include <asm/fixmap.h>
 #include <asm/insn.h>
+#include <asm/kprobes.h>
 
 #define AARCH64_INSN_SF_BIT	BIT(31)
 #define AARCH64_INSN_N_BIT	BIT(22)
diff --git a/arch/arm64/kernel/probes/decode-insn.h b/arch/arm64/kernel/probes/decode-insn.h
index 76d3f315407f..192ab007bacb 100644
--- a/arch/arm64/kernel/probes/decode-insn.h
+++ b/arch/arm64/kernel/probes/decode-insn.h
@@ -16,6 +16,8 @@
 #ifndef _ARM_KERNEL_KPROBES_ARM64_H
 #define _ARM_KERNEL_KPROBES_ARM64_H
 
+#include <asm/kprobes.h>
+
 /*
  * ARM strongly recommends a limit of 128 bytes between LoadExcl and
  * StoreExcl instructions in a single thread of execution. So keep the
diff --git a/arch/avr32/include/asm/kprobes.h b/arch/avr32/include/asm/kprobes.h
index 45f563ed73fd..28dfc61ad384 100644
--- a/arch/avr32/include/asm/kprobes.h
+++ b/arch/avr32/include/asm/kprobes.h
@@ -11,10 +11,14 @@
 #ifndef __ASM_AVR32_KPROBES_H
 #define __ASM_AVR32_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#define BREAKPOINT_INSTRUCTION	0xd673	/* breakpoint */
+
+#ifdef CONFIG_KPROBES
 #include <linux/types.h>
 
 typedef u16	kprobe_opcode_t;
-#define BREAKPOINT_INSTRUCTION	0xd673	/* breakpoint */
 #define MAX_INSN_SIZE		2
 #define MAX_STACK_SIZE		64	/* 32 would probably be OK */
 
@@ -46,4 +50,5 @@ extern int kprobe_exceptions_notify(struct notifier_block *self,
 
 #define flush_insn_slot(p)	do { } while (0)
 
+#endif /* CONFIG_KPROBES */
 #endif /* __ASM_AVR32_KPROBES_H */
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index 9115b215fc7e..52351d3fd36e 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -50,3 +50,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index cede2a950fbf..c54f7cc1f63e 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -64,3 +64,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += kprobes.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 7062c1be7913..051d355feae3 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -48,3 +48,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 4a59cbda5091..b58b9fc49383 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index d79968d93c12..cfca7de52b37 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -78,3 +78,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index d59ac1c1858b..d7cc35451f30 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -63,3 +63,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/ia64/include/asm/kprobes.h b/arch/ia64/include/asm/kprobes.h
index d5505d6f2382..0302b3664789 100644
--- a/arch/ia64/include/asm/kprobes.h
+++ b/arch/ia64/include/asm/kprobes.h
@@ -23,14 +23,19 @@
  * 2005-Apr     Rusty Lynch <rusty.lynch@intel.com> and Anil S Keshavamurthy
  *              <anil.s.keshavamurthy@intel.com> adapted from i386
  */
+#include <asm-generic/kprobes.h>
+#include <asm/break.h>
+
+#define BREAK_INST	(long)(__IA64_BREAK_KPROBE << 6)
+
+#ifdef CONFIG_KPROBES
+
 #include <linux/types.h>
 #include <linux/ptrace.h>
 #include <linux/percpu.h>
-#include <asm/break.h>
 
 #define __ARCH_WANT_KPROBES_INSN_SLOT
 #define MAX_INSN_SIZE   2	/* last half is for kprobe-booster */
-#define BREAK_INST	(long)(__IA64_BREAK_KPROBE << 6)
 #define NOP_M_INST	(long)(1<<27)
 #define BRL_INST(i1, i2) ((long)((0xcL << 37) |	/* brl */ \
 				(0x1L << 12) |	/* many */ \
@@ -124,4 +129,5 @@ extern void invalidate_stacked_regs(void);
 extern void flush_register_stack(void);
 extern void arch_remove_kprobe(struct kprobe *p);
 
-#endif				/* _ASM_KPROBES_H */
+#endif /* CONFIG_KPROBES */
+#endif /* _ASM_KPROBES_H */
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index f3f1e51dd5be..60024b49b6bb 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -15,3 +15,4 @@ generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index c28bcdecc764..412dd23ab946 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -37,3 +37,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index c836f7e2a5e7..8371cc9b1b3c 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -58,3 +58,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index 01afb1b420f5..865ce3d96443 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -14,3 +14,4 @@ generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/mips/include/asm/kprobes.h b/arch/mips/include/asm/kprobes.h
index daba1f9a4f79..291846d9ba83 100644
--- a/arch/mips/include/asm/kprobes.h
+++ b/arch/mips/include/asm/kprobes.h
@@ -22,6 +22,9 @@
 #ifndef _ASM_KPROBES_H
 #define _ASM_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#ifdef CONFIG_KPROBES
 #include <linux/ptrace.h>
 #include <linux/types.h>
 
@@ -94,4 +97,5 @@ struct kprobe_ctlblk {
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
 
-#endif				/* _ASM_KPROBES_H */
+#endif /* CONFIG_KPROBES */
+#endif /* _ASM_KPROBES_H */
diff --git a/arch/mn10300/include/asm/kprobes.h b/arch/mn10300/include/asm/kprobes.h
index c800b590183a..7abea0bdb549 100644
--- a/arch/mn10300/include/asm/kprobes.h
+++ b/arch/mn10300/include/asm/kprobes.h
@@ -21,13 +21,17 @@
 #ifndef _ASM_KPROBES_H
 #define _ASM_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#define BREAKPOINT_INSTRUCTION	0xff
+
+#ifdef CONFIG_KPROBES
 #include <linux/types.h>
 #include <linux/ptrace.h>
 
 struct kprobe;
 
 typedef unsigned char kprobe_opcode_t;
-#define BREAKPOINT_INSTRUCTION	0xff
 #define MAX_INSN_SIZE 8
 #define MAX_STACK_SIZE 128
 
@@ -47,4 +51,5 @@ extern int kprobe_exceptions_notify(struct notifier_block *self,
 
 extern void arch_remove_kprobe(struct kprobe *p);
 
+#endif /* CONFIG_KPROBES */
 #endif /* _ASM_KPROBES_H */
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index ee6220dac1e8..d6ce7edee7e0 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -66,3 +66,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index ceafe458e295..1bf89a67317c 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -74,3 +74,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index aaae8a9f6099..19d5b7e12ecf 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -31,3 +31,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/powerpc/include/asm/kprobes.h b/arch/powerpc/include/asm/kprobes.h
index 97b8c1f83453..c7ee3fcbd6e2 100644
--- a/arch/powerpc/include/asm/kprobes.h
+++ b/arch/powerpc/include/asm/kprobes.h
@@ -1,5 +1,8 @@
 #ifndef _ASM_POWERPC_KPROBES_H
 #define _ASM_POWERPC_KPROBES_H
+
+#include <asm-generic/kprobes.h>
+
 #ifdef __KERNEL__
 /*
  *  Kernel Probes (KProbes)
diff --git a/arch/s390/include/asm/kprobes.h b/arch/s390/include/asm/kprobes.h
index 591e5a5279b0..84c0f9086483 100644
--- a/arch/s390/include/asm/kprobes.h
+++ b/arch/s390/include/asm/kprobes.h
@@ -27,6 +27,11 @@
  * 2005-Dec	Used as a template for s390 by Mike Grundy
  *		<grundym@us.ibm.com>
  */
+#include <asm-generic/kprobes.h>
+
+#define BREAKPOINT_INSTRUCTION	0x0002
+
+#ifdef CONFIG_KPROBES
 #include <linux/types.h>
 #include <linux/ptrace.h>
 #include <linux/percpu.h>
@@ -37,7 +42,6 @@ struct pt_regs;
 struct kprobe;
 
 typedef u16 kprobe_opcode_t;
-#define BREAKPOINT_INSTRUCTION	0x0002
 
 /* Maximum instruction size is 3 (16bit) halfwords: */
 #define MAX_INSN_SIZE		0x0003
@@ -91,4 +95,5 @@ int probe_is_insn_relative_long(u16 *insn);
 
 #define flush_insn_slot(p)	do { } while (0)
 
+#endif /* CONFIG_KPROBES */
 #endif	/* _ASM_S390_KPROBES_H */
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index 16ea15a3e432..6ac8a7f5c768 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -17,3 +17,4 @@ generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/sh/include/asm/kprobes.h b/arch/sh/include/asm/kprobes.h
index 134f3980e44a..f0986f9b3844 100644
--- a/arch/sh/include/asm/kprobes.h
+++ b/arch/sh/include/asm/kprobes.h
@@ -1,13 +1,16 @@
 #ifndef __ASM_SH_KPROBES_H
 #define __ASM_SH_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#define BREAKPOINT_INSTRUCTION	0xc33a
+
 #ifdef CONFIG_KPROBES
 
 #include <linux/types.h>
 #include <linux/ptrace.h>
 
 typedef insn_size_t kprobe_opcode_t;
-#define BREAKPOINT_INSTRUCTION	0xc33a
 
 #define MAX_INSN_SIZE 16
 #define MAX_STACK_SIZE 64
diff --git a/arch/sparc/include/asm/kprobes.h b/arch/sparc/include/asm/kprobes.h
index a145d798e112..49f8402035d7 100644
--- a/arch/sparc/include/asm/kprobes.h
+++ b/arch/sparc/include/asm/kprobes.h
@@ -1,13 +1,17 @@
 #ifndef _SPARC64_KPROBES_H
 #define _SPARC64_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#define BREAKPOINT_INSTRUCTION   0x91d02070 /* ta 0x70 */
+#define BREAKPOINT_INSTRUCTION_2 0x91d02071 /* ta 0x71 */
+
+#ifdef CONFIG_KPROBES
 #include <linux/types.h>
 #include <linux/percpu.h>
 
 typedef u32 kprobe_opcode_t;
 
-#define BREAKPOINT_INSTRUCTION   0x91d02070 /* ta 0x70 */
-#define BREAKPOINT_INSTRUCTION_2 0x91d02071 /* ta 0x71 */
 #define MAX_INSN_SIZE 2
 
 #define kretprobe_blacklist_size 0
@@ -48,4 +52,6 @@ int kprobe_exceptions_notify(struct notifier_block *self,
 int kprobe_fault_handler(struct pt_regs *regs, int trapnr);
 asmlinkage void __kprobes kprobe_trap(unsigned long trap_level,
 				      struct pt_regs *regs);
+
+#endif /* CONFIG_KPROBES */
 #endif /* _SPARC64_KPROBES_H */
diff --git a/arch/tile/include/asm/kprobes.h b/arch/tile/include/asm/kprobes.h
index d8f9a83943b1..4a8b1cadca24 100644
--- a/arch/tile/include/asm/kprobes.h
+++ b/arch/tile/include/asm/kprobes.h
@@ -17,10 +17,13 @@
 #ifndef _ASM_TILE_KPROBES_H
 #define _ASM_TILE_KPROBES_H
 
+#include <asm-generic/kprobes.h>
+
+#ifdef CONFIG_KPROBES
+
 #include <linux/types.h>
 #include <linux/ptrace.h>
 #include <linux/percpu.h>
-
 #include <arch/opcode.h>
 
 #define __ARCH_WANT_KPROBES_INSN_SLOT
@@ -76,4 +79,5 @@ void arch_remove_kprobe(struct kprobe *);
 extern int kprobe_exceptions_notify(struct notifier_block *self,
 			     unsigned long val, void *data);
 
+#endif /* CONFIG_KPROBES */
 #endif /* _ASM_TILE_KPROBES_H */
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index d2867aa09e23..ccc5ffeaeef5 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -29,3 +29,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 6671a1f08ead..5aacafb6d385 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -63,3 +63,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/arch/x86/include/asm/kprobes.h b/arch/x86/include/asm/kprobes.h
index d1d1e5094c28..200581691c6e 100644
--- a/arch/x86/include/asm/kprobes.h
+++ b/arch/x86/include/asm/kprobes.h
@@ -21,6 +21,12 @@
  *
  * See arch/x86/kernel/kprobes.c for x86 kprobes history.
  */
+
+#include <asm-generic/kprobes.h>
+
+#define BREAKPOINT_INSTRUCTION	0xcc
+
+#ifdef CONFIG_KPROBES
 #include <linux/types.h>
 #include <linux/ptrace.h>
 #include <linux/percpu.h>
@@ -32,7 +38,6 @@ struct pt_regs;
 struct kprobe;
 
 typedef u8 kprobe_opcode_t;
-#define BREAKPOINT_INSTRUCTION	0xcc
 #define RELATIVEJUMP_OPCODE 0xe9
 #define RELATIVEJUMP_SIZE 5
 #define RELATIVECALL_OPCODE 0xe8
@@ -116,4 +121,6 @@ extern int kprobe_exceptions_notify(struct notifier_block *self,
 				    unsigned long val, void *data);
 extern int kprobe_int3_handler(struct pt_regs *regs);
 extern int kprobe_debug_handler(struct pt_regs *regs);
+
+#endif /* CONFIG_KPROBES */
 #endif /* _ASM_X86_KPROBES_H */
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 7b41f32a2ba0..20f524ded00e 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -35,3 +35,4 @@ generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
 generic-y += tables.h
+generic-y += kprobes.h
diff --git a/include/asm-generic/kprobes.h b/include/asm-generic/kprobes.h
new file mode 100644
index 000000000000..57af9f21d148
--- /dev/null
+++ b/include/asm-generic/kprobes.h
@@ -0,0 +1,25 @@
+#ifndef _ASM_GENERIC_KPROBES_H
+#define _ASM_GENERIC_KPROBES_H
+
+#if defined(__KERNEL__) && !defined(__ASSEMBLY__)
+#ifdef CONFIG_KPROBES
+/*
+ * Blacklist ganerating macro. Specify functions which is not probed
+ * by using this macro.
+ */
+# define __NOKPROBE_SYMBOL(fname)				\
+static unsigned long __used					\
+	__attribute__((__section__("_kprobe_blacklist")))	\
+	_kbl_addr_##fname = (unsigned long)fname;
+# define NOKPROBE_SYMBOL(fname)	__NOKPROBE_SYMBOL(fname)
+/* Use this to forbid a kprobes attach on very low level functions */
+# define __kprobes	__attribute__((__section__(".kprobes.text")))
+# define nokprobe_inline	__always_inline
+#else
+# define NOKPROBE_SYMBOL(fname)
+# define __kprobes
+# define nokprobe_inline	inline
+#endif
+#endif /* defined(__KERNEL__) && !defined(__ASSEMBLY__) */
+
+#endif /* _ASM_GENERIC_KPROBES_H */
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index cf0fa5d86059..dca49b4099da 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -566,12 +566,4 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
 	(_________p1); \
 })
 
-/* Ignore/forbid kprobes attach on very low level functions marked by this attribute: */
-#ifdef CONFIG_KPROBES
-# define __kprobes	__attribute__((__section__(".kprobes.text")))
-# define nokprobe_inline	__always_inline
-#else
-# define __kprobes
-# define nokprobe_inline	inline
-#endif
 #endif /* __LINUX_COMPILER_H */
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 8f6849084248..985ed79ef431 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -29,7 +29,7 @@
  *		<jkenisto@us.ibm.com>  and Prasanna S Panchamukhi
  *		<prasanna@in.ibm.com> added function-return probes.
  */
-#include <linux/compiler.h>	/* for __kprobes */
+#include <linux/compiler.h>
 #include <linux/linkage.h>
 #include <linux/list.h>
 #include <linux/notifier.h>
@@ -40,9 +40,9 @@
 #include <linux/rcupdate.h>
 #include <linux/mutex.h>
 #include <linux/ftrace.h>
+#include <asm/kprobes.h>
 
 #ifdef CONFIG_KPROBES
-#include <asm/kprobes.h>
 
 /* kprobe_status settings */
 #define KPROBE_HIT_ACTIVE	0x00000001
@@ -51,6 +51,7 @@
 #define KPROBE_HIT_SSDONE	0x00000008
 
 #else /* CONFIG_KPROBES */
+#include <asm-generic/kprobes.h>
 typedef int kprobe_opcode_t;
 struct arch_specific_insn {
 	int dummy;
@@ -481,18 +482,4 @@ static inline int enable_jprobe(struct jprobe *jp)
 	return enable_kprobe(&jp->kp);
 }
 
-#ifdef CONFIG_KPROBES
-/*
- * Blacklist ganerating macro. Specify functions which is not probed
- * by using this macro.
- */
-#define __NOKPROBE_SYMBOL(fname)			\
-static unsigned long __used				\
-	__attribute__((section("_kprobe_blacklist")))	\
-	_kbl_addr_##fname = (unsigned long)fname;
-#define NOKPROBE_SYMBOL(fname)	__NOKPROBE_SYMBOL(fname)
-#else
-#define NOKPROBE_SYMBOL(fname)
-#endif
-
 #endif /* _LINUX_KPROBES_H */
-- 
2.11.0

