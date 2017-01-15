From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Sun, 15 Jan 2017 21:10:55 +0000
Subject: [PATCH v7 12/14] kprobes: port .kprobes.text to section range
Message-Id: <20170115211057.17167-13-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

kprobe makes use of two custom sections, each custom section
is folded into one of the standard Linux sections types as follows,
it currently relies on the linker script to fold the custom section
onto the respective Linux section:

type  Linux-section custom section name  begin                    end
table .init.data    _kprobe_blacklist    __start_kprobe_blacklist __stop_kprobe_blacklist
range .text         .kprobes.text        __kprobes_text_start     __kprobes_text_end

This ports the .kprobes.text custom section to the standard
Linux ranges API allowing us remove all the custom kprobe section
declarations from the linker script.

Tested with CONFIG_KPROBES_SANITY_TEST, it passes with:

Kprobe smoke test: started
Kprobe smoke test: passed successfully

Then tested CONFIG_SAMPLE_KPROBES on do_fork, and the kprobe bites
and kicks as expected.

Also ran ./ftracetest with no issues:

sudo ./ftracetest
== Ftrace unit tests =[1] Basic trace file check	[PASS]
[2] Basic test for tracers	[PASS]
[3] Basic trace clock test	[PASS]
[4] Basic event tracing check	[PASS]
[5] event tracing - enable/disable with event level files	[PASS]
[6] event tracing - restricts events based on pid	[PASS]
[7] event tracing - enable/disable with subsystem level files	[PASS]
[8] event tracing - enable/disable with top level files	[PASS]
[9] ftrace - function graph filters with stack tracer	[PASS]
[10] ftrace - function graph filters	[PASS]
[11] ftrace - function glob filters	[PASS]
[12] ftrace - function profiler with function tracing	[PASS]
[13] Test creation and deletion of trace instances while setting an event	[PASS]
[14] Test creation and deletion of trace instances	[PASS]
[15] Kprobe dynamic event - adding and removing	[PASS]
[16] Kprobe dynamic event - busy event check	[PASS]
[17] Kprobe dynamic event with arguments	[PASS]
[18] Kprobes event arguments with types	[PASS]
[19] Kprobe dynamic event with function tracer	[PASS]
[20] Kretprobe dynamic event with arguments	[PASS]
[21] event trigger - test event enable/disable trigger	[PASS]
[22] event trigger - test trigger filter	[PASS]
[23] event trigger - test histogram modifiers	[PASS]
[24] event trigger - test histogram trigger	[PASS]
[25] event trigger - test multiple histogram triggers	[PASS]
[26] event trigger - test snapshot-trigger	[PASS]
[27] event trigger - test stacktrace-trigger	[PASS]
[28] event trigger - test traceon/off trigger	[PASS]

v5:

o Use ..rng.* instead of .rng.* as suggested by Nicholas Piggin.
  This is the typical way to avoid clash with compiler generated
  section.

o Replace section macros with section names

v4:

o arm64 build fixes with allmodconfig

o build fix suggested for avr32 with allnoconfig, otherwise we end up with:

arch/avr32/kernel/built-in.o: In function `save_full_context_ex':
(.ex.text+0x1c4): relocation truncated to fit: R_AVR32_16N_PCREL against
symbol `debug_trampoline' defined in .text.rng.kprobes.any section in
arch/avr32/kernel/built-in.o
arch/avr32/kernel/built-in.o: In function `debug_exit_work':
(.text.rng.kprobes.any+0xa8): relocation truncated to fit:
R_AVR32_16N_PCREL against `.ex.text'+3aa
make: *** [Makefile:953: vmlinux] Error 1

o open-code section use on scripts/ code -- folks to prefer the
  simplicity over dealing with having more tool code access kernel
  headers.

o NOPE: include #include <asm-generic/ranges.h> on compiler.h -- solves
  a few 0-day compilation issues

v3:

o after v2 arch/arm/kernel/vmlinux-xip.lds.S got kprobe support,
  this just removes the custom linker script reference to kprobes as
  that is no longer needed with linker tables.

o split kprobe linker table and kprobe section ranges use into
  two separate patches. This should make it easier to review and
  also demos both distinct use types, one a linker table another
  a simple section range.

v2: introduced this patch in this series

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 arch/arc/kernel/vmlinux.lds.S        |  1 -
 arch/arm/kernel/entry-armv.S         |  3 ++-
 arch/arm/kernel/vmlinux-xip.lds.S    |  1 -
 arch/arm/kernel/vmlinux.lds.S        |  1 -
 arch/arm64/kernel/armv8_deprecated.c |  1 +
 arch/arm64/kernel/probes/kprobes.c   |  4 ++--
 arch/arm64/kernel/vmlinux.lds.S      |  1 -
 arch/avr32/kernel/entry-avr32b.S     | 13 +++++++++++--
 arch/avr32/kernel/vmlinux.lds.S      |  1 -
 arch/blackfin/kernel/vmlinux.lds.S   |  1 -
 arch/c6x/kernel/vmlinux.lds.S        |  1 -
 arch/hexagon/kernel/vmlinux.lds.S    |  1 -
 arch/ia64/kernel/jprobes.S           |  3 ++-
 arch/ia64/kernel/vmlinux.lds.S       |  1 -
 arch/ia64/lib/flush.S                |  6 +++---
 arch/metag/kernel/vmlinux.lds.S      |  1 -
 arch/microblaze/kernel/vmlinux.lds.S |  1 -
 arch/mips/kernel/vmlinux.lds.S       |  1 -
 arch/mn10300/kernel/vmlinux.lds.S    |  1 -
 arch/nios2/kernel/vmlinux.lds.S      |  1 -
 arch/openrisc/kernel/vmlinux.lds.S   |  1 -
 arch/parisc/kernel/vmlinux.lds.S     |  1 -
 arch/powerpc/include/asm/ppc_asm.h   |  1 +
 arch/powerpc/kernel/vmlinux.lds.S    |  1 -
 arch/s390/kernel/entry.S             |  5 +++--
 arch/s390/kernel/kprobes.c           |  6 +++---
 arch/s390/kernel/mcount.S            |  3 ++-
 arch/s390/kernel/vmlinux.lds.S       |  1 -
 arch/score/kernel/vmlinux.lds.S      |  1 -
 arch/sh/kernel/vmlinux.lds.S         |  1 -
 arch/sparc/kernel/vmlinux.lds.S      |  1 -
 arch/sparc/mm/ultra.S                |  3 ++-
 arch/tile/kernel/vmlinux.lds.S       |  1 -
 arch/x86/kernel/kprobes/core.c       | 11 +++++------
 arch/x86/kernel/vmlinux.lds.S        |  1 -
 include/asm-generic/kprobes.h        |  3 ++-
 include/asm-generic/sections.h       |  2 --
 include/asm-generic/vmlinux.lds.h    |  2 +-
 include/linux/kprobes.h              |  3 +++
 kernel/kprobes.c                     |  6 ++++--
 scripts/mod/modpost.c                |  2 +-
 scripts/recordmcount.c               |  2 +-
 scripts/recordmcount.pl              |  2 +-
 43 files changed, 50 insertions(+), 54 deletions(-)

diff --git a/arch/arc/kernel/vmlinux.lds.S b/arch/arc/kernel/vmlinux.lds.S
index f35ed578e007..dd05c86eb96e 100644
--- a/arch/arc/kernel/vmlinux.lds.S
+++ b/arch/arc/kernel/vmlinux.lds.S
@@ -91,7 +91,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.fixup)
 		*(.gnu.warning)
 	}
diff --git a/arch/arm/kernel/entry-armv.S b/arch/arm/kernel/entry-armv.S
index 9f157e7c51e7..c455b491b6d3 100644
--- a/arch/arm/kernel/entry-armv.S
+++ b/arch/arm/kernel/entry-armv.S
@@ -34,6 +34,7 @@
 #include "entry-header.S"
 #include <asm/entry-macro-multi.S>
 #include <asm/probes.h>
+#include <asm/ranges.h>
 
 /*
  * Interrupt handling.
@@ -83,7 +84,7 @@
 	.endm
 
 #ifdef CONFIG_KPROBES
-	.section	.kprobes.text,"ax",%progbits
+	set_section_rng_type(.text, kprobes, ax, %progbits)
 #else
 	.text
 #endif
diff --git a/arch/arm/kernel/vmlinux-xip.lds.S b/arch/arm/kernel/vmlinux-xip.lds.S
index 37b2a11af345..1a84f84b8165 100644
--- a/arch/arm/kernel/vmlinux-xip.lds.S
+++ b/arch/arm/kernel/vmlinux-xip.lds.S
@@ -103,7 +103,6 @@ SECTIONS
 			SCHED_TEXT
 			CPUIDLE_TEXT
 			LOCK_TEXT
-			KPROBES_TEXT
 			*(.gnu.warning)
 			*(.glue_7)
 			*(.glue_7t)
diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S
index f7f55df0bf7b..1e278e6c3506 100644
--- a/arch/arm/kernel/vmlinux.lds.S
+++ b/arch/arm/kernel/vmlinux.lds.S
@@ -114,7 +114,6 @@ SECTIONS
 			CPUIDLE_TEXT
 			LOCK_TEXT
 			HYPERVISOR_TEXT
-			KPROBES_TEXT
 			*(.gnu.warning)
 			*(.glue_7)
 			*(.glue_7t)
diff --git a/arch/arm64/kernel/armv8_deprecated.c b/arch/arm64/kernel/armv8_deprecated.c
index 86032a012388..4043a14c9e36 100644
--- a/arch/arm64/kernel/armv8_deprecated.c
+++ b/arch/arm64/kernel/armv8_deprecated.c
@@ -21,6 +21,7 @@
 #include <asm/traps.h>
 #include <linux/uaccess.h>
 #include <asm/cpufeature.h>
+#include <asm/kprobes.h>
 
 #define CREATE_TRACE_POINTS
 #include "trace-events-emulation.h"
diff --git a/arch/arm64/kernel/probes/kprobes.c b/arch/arm64/kernel/probes/kprobes.c
index f0593c92279b..ec288dd165cb 100644
--- a/arch/arm64/kernel/probes/kprobes.c
+++ b/arch/arm64/kernel/probes/kprobes.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/stop_machine.h>
 #include <linux/stringify.h>
+#include <linux/ranges.h>
 #include <asm/traps.h>
 #include <asm/ptrace.h>
 #include <asm/cacheflush.h>
@@ -540,8 +541,7 @@ int __kprobes longjmp_break_handler(struct kprobe *p, struct pt_regs *regs)
 
 bool arch_within_kprobe_blacklist(unsigned long addr)
 {
-	if ((addr >= (unsigned long)__kprobes_text_start &&
-	    addr < (unsigned long)__kprobes_text_end) ||
+	if (SECTION_RANGE_ADDR_WITHIN(kprobes, addr) ||
 	    (addr >= (unsigned long)__entry_text_start &&
 	    addr < (unsigned long)__entry_text_end) ||
 	    (addr >= (unsigned long)__idmap_text_start &&
diff --git a/arch/arm64/kernel/vmlinux.lds.S b/arch/arm64/kernel/vmlinux.lds.S
index b8deffa9e1bf..c68e5d528706 100644
--- a/arch/arm64/kernel/vmlinux.lds.S
+++ b/arch/arm64/kernel/vmlinux.lds.S
@@ -124,7 +124,6 @@ SECTIONS
 			SCHED_TEXT
 			CPUIDLE_TEXT
 			LOCK_TEXT
-			KPROBES_TEXT
 			HYPERVISOR_TEXT
 			IDMAP_TEXT
 			HIBERNATE_TEXT
diff --git a/arch/avr32/kernel/entry-avr32b.S b/arch/avr32/kernel/entry-avr32b.S
index 7301f4806bbe..7b2a5c5ef047 100644
--- a/arch/avr32/kernel/entry-avr32b.S
+++ b/arch/avr32/kernel/entry-avr32b.S
@@ -23,6 +23,7 @@
 #include <asm/sysreg.h>
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
+#include <asm/ranges.h>
 
 #ifdef CONFIG_PREEMPT
 # define preempt_stop		mask_interrupts
@@ -605,7 +606,11 @@ fault_exit_work:
 	brcc	fault_resume_user
 	rjmp	enter_monitor_mode
 
-	.section .kprobes.text, "ax", @progbits
+#ifdef CONFIG_KPROBES
+	set_section_rng_type(.text, kprobes, ax, @progbits)
+#else
+	.text
+#endif
 	.type	handle_debug, @function
 handle_debug:
 	sub	sp, 4		/* r12_orig */
@@ -826,7 +831,11 @@ irq_level\level:
 	IRQ_LEVEL 2
 	IRQ_LEVEL 3
 
-	.section .kprobes.text, "ax", @progbits
+#ifdef CONFIG_KPROBES
+	set_section_rng_type(.text, kprobes, ax, @progbits)
+#else
+	.text
+#endif
 	.type	enter_monitor_mode, @function
 enter_monitor_mode:
 	/*
diff --git a/arch/avr32/kernel/vmlinux.lds.S b/arch/avr32/kernel/vmlinux.lds.S
index 17f2730eb497..04627a9c178e 100644
--- a/arch/avr32/kernel/vmlinux.lds.S
+++ b/arch/avr32/kernel/vmlinux.lds.S
@@ -49,7 +49,6 @@ SECTIONS
 		_stext = .;
 		*(.ex.text)
 		*(.irq.text)
-		KPROBES_TEXT
 		TEXT_TEXT
 		SCHED_TEXT
 		CPUIDLE_TEXT
diff --git a/arch/blackfin/kernel/vmlinux.lds.S b/arch/blackfin/kernel/vmlinux.lds.S
index 68069a120055..93220ff65014 100644
--- a/arch/blackfin/kernel/vmlinux.lds.S
+++ b/arch/blackfin/kernel/vmlinux.lds.S
@@ -37,7 +37,6 @@ SECTIONS
 		LOCK_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
-		KPROBES_TEXT
 #ifdef CONFIG_ROMKERNEL
 		__sinittext = .;
 		INIT_TEXT
diff --git a/arch/c6x/kernel/vmlinux.lds.S b/arch/c6x/kernel/vmlinux.lds.S
index a1a5c166bc9b..a41d43b8254b 100644
--- a/arch/c6x/kernel/vmlinux.lds.S
+++ b/arch/c6x/kernel/vmlinux.lds.S
@@ -74,7 +74,6 @@ SECTIONS
 		LOCK_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
-		KPROBES_TEXT
 		*(.fixup)
 		*(.gnu.warning)
 	}
diff --git a/arch/hexagon/kernel/vmlinux.lds.S b/arch/hexagon/kernel/vmlinux.lds.S
index ec87e67feb19..7e6f68584b55 100644
--- a/arch/hexagon/kernel/vmlinux.lds.S
+++ b/arch/hexagon/kernel/vmlinux.lds.S
@@ -52,7 +52,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.fixup)
 	}
 	_etext = .;
diff --git a/arch/ia64/kernel/jprobes.S b/arch/ia64/kernel/jprobes.S
index f69389c7be1d..71adc7132e22 100644
--- a/arch/ia64/kernel/jprobes.S
+++ b/arch/ia64/kernel/jprobes.S
@@ -46,11 +46,12 @@
  */
 #include <asm/asmmacro.h>
 #include <asm/break.h>
+#include <asm/ranges.h>
 
 	/*
 	 * void jprobe_break(void)
 	 */
-	.section .kprobes.text, "ax"
+	set_section_rng(.text, kprobes, ax)
 ENTRY(jprobe_break)
 	break.m __IA64_BREAK_JPROBE
 END(jprobe_break)
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index f89d20c97412..3ff6edf913d2 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -48,7 +48,6 @@ SECTIONS {
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.gnu.linkonce.t*)
 	}
 
diff --git a/arch/ia64/lib/flush.S b/arch/ia64/lib/flush.S
index 9a5a2f9fad13..dec1b180d618 100644
--- a/arch/ia64/lib/flush.S
+++ b/arch/ia64/lib/flush.S
@@ -9,7 +9,7 @@
 
 #include <asm/asmmacro.h>
 #include <asm/export.h>
-
+#include <asm/ranges.h>
 
 	/*
 	 * flush_icache_range(start,end)
@@ -21,7 +21,7 @@
 	 *
 	 *	Note: "in0" and "in1" are preserved for debugging purposes.
 	 */
-	.section .kprobes.text,"ax"
+	set_section_rng(.text, kprobes, ax)
 GLOBAL_ENTRY(flush_icache_range)
 
 	.prologue
@@ -74,7 +74,7 @@ EXPORT_SYMBOL_GPL(flush_icache_range)
 	 *
 	 *	Note: "in0" and "in1" are preserved for debugging purposes.
 	 */
-	.section .kprobes.text,"ax"
+	set_section_rng(.text, kprobes, ax)
 GLOBAL_ENTRY(clflush_cache_range)
 
 	.prologue
diff --git a/arch/metag/kernel/vmlinux.lds.S b/arch/metag/kernel/vmlinux.lds.S
index e6c700eaf207..b18386d2250f 100644
--- a/arch/metag/kernel/vmlinux.lds.S
+++ b/arch/metag/kernel/vmlinux.lds.S
@@ -23,7 +23,6 @@ SECTIONS
 	SCHED_TEXT
 	CPUIDLE_TEXT
 	LOCK_TEXT
-	KPROBES_TEXT
 	IRQENTRY_TEXT
 	SOFTIRQENTRY_TEXT
 	*(.text.*)
diff --git a/arch/microblaze/kernel/vmlinux.lds.S b/arch/microblaze/kernel/vmlinux.lds.S
index 289d0e7f3e3a..aadee2229ac6 100644
--- a/arch/microblaze/kernel/vmlinux.lds.S
+++ b/arch/microblaze/kernel/vmlinux.lds.S
@@ -35,7 +35,6 @@ SECTIONS {
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		. = ALIGN (4) ;
diff --git a/arch/mips/kernel/vmlinux.lds.S b/arch/mips/kernel/vmlinux.lds.S
index f0a0e6d62be3..44e21812c544 100644
--- a/arch/mips/kernel/vmlinux.lds.S
+++ b/arch/mips/kernel/vmlinux.lds.S
@@ -57,7 +57,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.text.*)
diff --git a/arch/mn10300/kernel/vmlinux.lds.S b/arch/mn10300/kernel/vmlinux.lds.S
index 2d5f1c3f1afb..552ef00a3da5 100644
--- a/arch/mn10300/kernel/vmlinux.lds.S
+++ b/arch/mn10300/kernel/vmlinux.lds.S
@@ -32,7 +32,6 @@ SECTIONS
 	SCHED_TEXT
 	CPUIDLE_TEXT
 	LOCK_TEXT
-	KPROBES_TEXT
 	*(.fixup)
 	*(.gnu.warning)
 	} = 0xcb
diff --git a/arch/nios2/kernel/vmlinux.lds.S b/arch/nios2/kernel/vmlinux.lds.S
index 6a8045bb1a77..aae4a00c4056 100644
--- a/arch/nios2/kernel/vmlinux.lds.S
+++ b/arch/nios2/kernel/vmlinux.lds.S
@@ -41,7 +41,6 @@ SECTIONS
 		LOCK_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
-		KPROBES_TEXT
 	} =0
 	_etext = .;
 
diff --git a/arch/openrisc/kernel/vmlinux.lds.S b/arch/openrisc/kernel/vmlinux.lds.S
index 00ddb7804be4..8ade6ccca6ac 100644
--- a/arch/openrisc/kernel/vmlinux.lds.S
+++ b/arch/openrisc/kernel/vmlinux.lds.S
@@ -57,7 +57,6 @@ SECTIONS
 	  SCHED_TEXT
 	  CPUIDLE_TEXT
 	  LOCK_TEXT
-	  KPROBES_TEXT
 	  IRQENTRY_TEXT
 	  SOFTIRQENTRY_TEXT
 	  *(.fixup)
diff --git a/arch/parisc/kernel/vmlinux.lds.S b/arch/parisc/kernel/vmlinux.lds.S
index 3d6ef1b29c6a..edbd6d9487dc 100644
--- a/arch/parisc/kernel/vmlinux.lds.S
+++ b/arch/parisc/kernel/vmlinux.lds.S
@@ -71,7 +71,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.text.do_softirq)
diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
index 025833b8df9f..0846413b3a2e 100644
--- a/arch/powerpc/include/asm/ppc_asm.h
+++ b/arch/powerpc/include/asm/ppc_asm.h
@@ -9,6 +9,7 @@
 #include <asm/processor.h>
 #include <asm/ppc-opcode.h>
 #include <asm/firmware.h>
+#include <asm/ranges.h>
 
 #ifdef __ASSEMBLY__
 
diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
index 8cd940c72895..2285664abb52 100644
--- a/arch/powerpc/kernel/vmlinux.lds.S
+++ b/arch/powerpc/kernel/vmlinux.lds.S
@@ -112,7 +112,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		MEM_KEEP(init.text)
diff --git a/arch/s390/kernel/entry.S b/arch/s390/kernel/entry.S
index 97298c58b2be..847e2e1df89c 100644
--- a/arch/s390/kernel/entry.S
+++ b/arch/s390/kernel/entry.S
@@ -24,6 +24,7 @@
 #include <asm/setup.h>
 #include <asm/nmi.h>
 #include <asm/export.h>
+#include <asm/ranges.h>
 
 __PT_R0      =	__PT_GPRS
 __PT_R1      =	__PT_GPRS + 8
@@ -169,7 +170,7 @@ _PIF_WORK	= (_PIF_PER_TRAP)
 		tm	off+\addr, \mask
 	.endm
 
-	.section .kprobes.text, "ax"
+	set_section_rng(.text, kprobes, ax)
 .Ldummy:
 	/*
 	 * This nop exists only in order to avoid that __switch_to starts at
@@ -986,7 +987,7 @@ ENTRY(restart_int_handler)
 	brc	2,2b
 3:	j	3b
 
-	.section .kprobes.text, "ax"
+	set_section_rng(.text, kprobes, ax)
 
 #ifdef CONFIG_CHECK_STACK
 /*
diff --git a/arch/s390/kernel/kprobes.c b/arch/s390/kernel/kprobes.c
index 84e0557b16fe..94a4918b5968 100644
--- a/arch/s390/kernel/kprobes.c
+++ b/arch/s390/kernel/kprobes.c
@@ -289,9 +289,9 @@ static void kprobe_reenter_check(struct kprobe_ctlblk *kcb, struct kprobe *p)
 	case KPROBE_REENTER:
 	default:
 		/*
-		 * A kprobe on the code path to single step an instruction
-		 * is a BUG. The code path resides in the .kprobes.text
-		 * section and is executed with interrupts disabled.
+		 * A kprobe on the code path to single step an instruction is a
+		 * BUG. The code path resides in the kprobes section range and
+		 * is executed with interrupts disabled.
 		 */
 		printk(KERN_EMERG "Invalid kprobe detected at %p.\n", p->addr);
 		dump_kprobe(p);
diff --git a/arch/s390/kernel/mcount.S b/arch/s390/kernel/mcount.S
index 9a17e4475d27..9d76056609f7 100644
--- a/arch/s390/kernel/mcount.S
+++ b/arch/s390/kernel/mcount.S
@@ -10,8 +10,9 @@
 #include <asm/ftrace.h>
 #include <asm/ptrace.h>
 #include <asm/export.h>
+#include <asm/ranges.h>
 
-	.section .kprobes.text, "ax"
+	set_section_rng(.text, kprobes, ax)
 
 ENTRY(ftrace_stub)
 	br	%r14
diff --git a/arch/s390/kernel/vmlinux.lds.S b/arch/s390/kernel/vmlinux.lds.S
index 3667d20e997f..b2df6d9bab09 100644
--- a/arch/s390/kernel/vmlinux.lds.S
+++ b/arch/s390/kernel/vmlinux.lds.S
@@ -37,7 +37,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.fixup)
diff --git a/arch/score/kernel/vmlinux.lds.S b/arch/score/kernel/vmlinux.lds.S
index 4117890b1db1..a8b14f3ed474 100644
--- a/arch/score/kernel/vmlinux.lds.S
+++ b/arch/score/kernel/vmlinux.lds.S
@@ -42,7 +42,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.text.*)
 		*(.fixup)
 		. = ALIGN (4) ;
diff --git a/arch/sh/kernel/vmlinux.lds.S b/arch/sh/kernel/vmlinux.lds.S
index 5b9a3cc90c58..58d9ba796f7a 100644
--- a/arch/sh/kernel/vmlinux.lds.S
+++ b/arch/sh/kernel/vmlinux.lds.S
@@ -38,7 +38,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.fixup)
diff --git a/arch/sparc/kernel/vmlinux.lds.S b/arch/sparc/kernel/vmlinux.lds.S
index 572db686f845..0ee41b0071e5 100644
--- a/arch/sparc/kernel/vmlinux.lds.S
+++ b/arch/sparc/kernel/vmlinux.lds.S
@@ -51,7 +51,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.gnu.warning)
diff --git a/arch/sparc/mm/ultra.S b/arch/sparc/mm/ultra.S
index 5d2fd6cd3189..ee9f648549c0 100644
--- a/arch/sparc/mm/ultra.S
+++ b/arch/sparc/mm/ultra.S
@@ -16,6 +16,7 @@
 #include <asm/cacheflush.h>
 #include <asm/hypervisor.h>
 #include <asm/cpudata.h>
+#include <asm/ranges.h>
 
 	/* Basically, most of the Spitfire vs. Cheetah madness
 	 * has to do with the fact that Cheetah does not support
@@ -185,7 +186,7 @@ __spitfire_flush_tlb_mm_slow:
 /*
  * The following code flushes one page_size worth.
  */
-	.section .kprobes.text, "ax"
+	set_section_rng(.text, kprobes, ax)
 	.align		32
 	.globl		__flush_icache_page
 __flush_icache_page:	/* %o0 = phys_page */
diff --git a/arch/tile/kernel/vmlinux.lds.S b/arch/tile/kernel/vmlinux.lds.S
index e1baf094fba4..85d03ce6c0a0 100644
--- a/arch/tile/kernel/vmlinux.lds.S
+++ b/arch/tile/kernel/vmlinux.lds.S
@@ -44,7 +44,6 @@ SECTIONS
     SCHED_TEXT
     CPUIDLE_TEXT
     LOCK_TEXT
-    KPROBES_TEXT
     IRQENTRY_TEXT
     SOFTIRQENTRY_TEXT
     __fix_text_end = .;   /* tile-cpack won't rearrange before this */
diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index eb3509338ae0..95e4b172e923 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -580,9 +580,9 @@ static int reenter_kprobe(struct kprobe *p, struct pt_regs *regs,
 	case KPROBE_REENTER:
 		/* A probe has been hit in the codepath leading up to, or just
 		 * after, single-stepping of a probed instruction. This entire
-		 * codepath should strictly reside in .kprobes.text section.
-		 * Raise a BUG or we'll continue in an endless reentering loop
-		 * and eventually a stack overflow.
+		 * codepath should strictly reside in the kprobes section
+		 * range. Raise a BUG or we'll continue in an endless
+		 * reentering loop and eventually a stack overflow.
 		 */
 		printk(KERN_WARNING "Unrecoverable kprobe detected at %p.\n",
 		       p->addr);
@@ -1133,10 +1133,9 @@ NOKPROBE_SYMBOL(longjmp_break_handler);
 
 bool arch_within_kprobe_blacklist(unsigned long addr)
 {
-	return  (addr >= (unsigned long)__kprobes_text_start &&
-		 addr < (unsigned long)__kprobes_text_end) ||
+	return  (SECTION_RANGE_ADDR_WITHIN(kprobes, addr) ||
 		(addr >= (unsigned long)__entry_text_start &&
-		 addr < (unsigned long)__entry_text_end);
+		 addr < (unsigned long)__entry_text_end));
 }
 
 int __init arch_init_kprobes(void)
diff --git a/arch/x86/kernel/vmlinux.lds.S b/arch/x86/kernel/vmlinux.lds.S
index e79f15f108a8..4c16fadb9ac6 100644
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -99,7 +99,6 @@ SECTIONS
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		ENTRY_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
diff --git a/include/asm-generic/kprobes.h b/include/asm-generic/kprobes.h
index 57af9f21d148..02a26b975187 100644
--- a/include/asm-generic/kprobes.h
+++ b/include/asm-generic/kprobes.h
@@ -3,6 +3,7 @@
 
 #if defined(__KERNEL__) && !defined(__ASSEMBLY__)
 #ifdef CONFIG_KPROBES
+#include <asm/ranges.h>
 /*
  * Blacklist ganerating macro. Specify functions which is not probed
  * by using this macro.
@@ -13,7 +14,7 @@ static unsigned long __used					\
 	_kbl_addr_##fname = (unsigned long)fname;
 # define NOKPROBE_SYMBOL(fname)	__NOKPROBE_SYMBOL(fname)
 /* Use this to forbid a kprobes attach on very low level functions */
-# define __kprobes	__attribute__((__section__(".kprobes.text")))
+# define __kprobes	__LINUX_RANGE(.text, kprobes)
 # define nokprobe_inline	__always_inline
 #else
 # define NOKPROBE_SYMBOL(fname)
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index b145ae8d9cbe..f3340f2772bb 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -26,7 +26,6 @@
  * Following global variables are optional and may be unavailable on some
  * architectures and/or kernel configurations.
  *	_text, _data
- *	__kprobes_text_start, __kprobes_text_end
  *	__entry_text_start, __entry_text_end
  *	__ctors_start, __ctors_end
  */
@@ -38,7 +37,6 @@ extern char _sinittext[], _einittext[];
 extern char __start_data_ro_after_init[], __end_data_ro_after_init[];
 extern char _end[];
 extern char __per_cpu_load[], __per_cpu_start[], __per_cpu_end[];
-extern char __kprobes_text_start[], __kprobes_text_end[];
 extern char __entry_text_start[], __entry_text_end[];
 extern char __start_rodata[], __end_rodata[];
 
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 37b99537d5a9..499caf5b4361 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -471,7 +471,7 @@
 #define KPROBES_TEXT							\
 		ALIGN_FUNCTION();					\
 		VMLINUX_SYMBOL(__kprobes_text_start) = .;		\
-		*(.kprobes.text)					\
+		*(.text..rng.kprobes.any)				\
 		VMLINUX_SYMBOL(__kprobes_text_end) = .;
 
 #define ENTRY_TEXT							\
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 985ed79ef431..445cc6fe7afa 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -43,6 +43,9 @@
 #include <asm/kprobes.h>
 
 #ifdef CONFIG_KPROBES
+#include <linux/ranges.h>
+
+DECLARE_SECTION_RANGE(kprobes);
 
 /* kprobe_status settings */
 #define KPROBE_HIT_ACTIVE	0x00000001
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 43460104f119..82191f328e21 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1328,8 +1328,7 @@ static int register_aggr_kprobe(struct kprobe *orig_p, struct kprobe *p)
 bool __weak arch_within_kprobe_blacklist(unsigned long addr)
 {
 	/* The __kprobes marked functions and entry code must not be probed */
-	return addr >= (unsigned long)__kprobes_text_start &&
-	       addr < (unsigned long)__kprobes_text_end;
+	return SECTION_RANGE_ADDR_WITHIN(kprobes, addr);
 }
 
 bool within_kprobe_blacklist(unsigned long addr)
@@ -2129,6 +2128,9 @@ static struct notifier_block kprobe_module_nb = {
 extern unsigned long __start_kprobe_blacklist[];
 extern unsigned long __stop_kprobe_blacklist[];
 
+/* Actual kprobes section range */
+DEFINE_SECTION_RANGE(kprobes, .text);
+
 static int __init init_kprobes(void)
 {
 	int i, err = 0;
diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
index 29c89a6bad3d..2b442234c69b 100644
--- a/scripts/mod/modpost.c
+++ b/scripts/mod/modpost.c
@@ -894,7 +894,7 @@ static void check_section(const char *modname, struct elf_info *elf,
 
 #define DATA_SECTIONS ".data", ".data.rel"
 #define TEXT_SECTIONS ".text", ".text.unlikely", ".sched.text", \
-		".kprobes.text", ".cpuidle.text"
+		".text..rng.kprobes.any", ".cpuidle.text"
 #define OTHER_TEXT_SECTIONS ".ref.text", ".head.text", ".spinlock.text", \
 		".fixup", ".entry.text", ".exception.text", ".text.*", \
 		".coldtext"
diff --git a/scripts/recordmcount.c b/scripts/recordmcount.c
index aeb34223167c..6e95f3f87db1 100644
--- a/scripts/recordmcount.c
+++ b/scripts/recordmcount.c
@@ -417,7 +417,7 @@ is_mcounted_section_name(char const *const txtname)
 		strcmp(".spinlock.text", txtname) = 0 ||
 		strcmp(".irqentry.text", txtname) = 0 ||
 		strcmp(".softirqentry.text", txtname) = 0 ||
-		strcmp(".kprobes.text", txtname) = 0 ||
+		strcmp(".text..rng.kprobes.any", txtname) = 0 ||
 		strcmp(".cpuidle.text", txtname) = 0 ||
 		strcmp(".text.unlikely", txtname) = 0;
 }
diff --git a/scripts/recordmcount.pl b/scripts/recordmcount.pl
index 0b6002b36f20..15e2fa37c489 100755
--- a/scripts/recordmcount.pl
+++ b/scripts/recordmcount.pl
@@ -135,7 +135,7 @@ my %text_sections = (
      ".spinlock.text" => 1,
      ".irqentry.text" => 1,
      ".softirqentry.text" => 1,
-     ".kprobes.text" => 1,
+     ".text..rng.kprobes.any" => 1,
      ".cpuidle.text" => 1,
      ".text.unlikely" => 1,
 );
-- 
2.11.0

