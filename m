From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:46 +0000
Subject: [RFC v3 12/13] kprobes: port .kprobes.text to section range
Message-Id: <1469222687-1600-13-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@linux-foun

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

$ sudo ./ftracetest
== Ftrace unit tests =[1] Basic trace file check      [PASS]
[2] Basic test for tracers      [PASS]
[3] Basic trace clock test      [PASS]
[4] Basic event tracing check   [PASS]
[5] event tracing - enable/disable with event level files       [PASS]
[6] event tracing - restricts events based on pid       [PASS]
[7] event tracing - enable/disable with subsystem level files   [PASS]
[8] event tracing - enable/disable with top level files [PASS]
[9] ftrace - function graph filters with stack tracer   [PASS]
[10] ftrace - function graph filters    [PASS]
[11] ftrace - function profiler with function tracing   [PASS]
[12] Test creation and deletion of trace instances while setting an event[PASS]
[13] Test creation and deletion of trace instances      [PASS]
[14] Kprobe dynamic event - adding and removing [PASS]
[15] Kprobe dynamic event - busy event check    [PASS]
[16] Kprobe dynamic event with arguments        [PASS]
[17] Kprobe dynamic event with function tracer  [PASS]
[18] Kretprobe dynamic event with arguments     [PASS]
[19] event trigger - test event enable/disable trigger  [PASS]
[20] event trigger - test trigger filter        [PASS]
[21] event trigger - test histogram modifiers   [PASS]
[22] event trigger - test histogram trigger     [PASS]
[23] event trigger - test multiple histogram triggers   [PASS]
[24] event trigger - test snapshot-trigger      [PASS]
[25] event trigger - test stacktrace-trigger    [PASS]
[26] event trigger - test traceon/off trigger   [PASS]

 # of passed:  26
 # of failed:  0
 # of unresolved:  0
 # of untested:  0
 # of unsupported:  0
 # of xfailed:  0
 # of undefined(test bug):  0

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
 arch/avr32/kernel/entry-avr32b.S     |  5 +++--
 arch/avr32/kernel/vmlinux.lds.S      |  1 -
 arch/blackfin/kernel/vmlinux.lds.S   |  1 -
 arch/c6x/kernel/vmlinux.lds.S        |  1 -
 arch/hexagon/kernel/vmlinux.lds.S    |  1 -
 arch/ia64/kernel/jprobes.S           |  3 ++-
 arch/ia64/kernel/vmlinux.lds.S       |  1 -
 arch/ia64/lib/flush.S                |  5 +++--
 arch/metag/kernel/vmlinux.lds.S      |  1 -
 arch/microblaze/kernel/vmlinux.lds.S |  1 -
 arch/mips/kernel/vmlinux.lds.S       |  1 -
 arch/mn10300/kernel/vmlinux.lds.S    |  1 -
 arch/nios2/kernel/vmlinux.lds.S      |  1 -
 arch/openrisc/kernel/vmlinux.lds.S   |  1 -
 arch/parisc/kernel/vmlinux.lds.S     |  1 -
 arch/powerpc/include/asm/ppc_asm.h   |  7 ++++---
 arch/powerpc/kernel/vmlinux.lds.S    |  1 -
 arch/s390/kernel/entry.S             |  5 +++--
 arch/s390/kernel/kprobes.c           |  6 +++---
 arch/s390/kernel/mcount.S            |  2 +-
 arch/s390/kernel/vmlinux.lds.S       |  1 -
 arch/score/kernel/vmlinux.lds.S      |  1 -
 arch/sh/kernel/vmlinux.lds.S         |  1 -
 arch/sparc/kernel/vmlinux.lds.S      |  1 -
 arch/sparc/mm/ultra.S                |  3 ++-
 arch/tile/kernel/vmlinux.lds.S       |  1 -
 arch/x86/kernel/kprobes/core.c       | 11 +++++------
 arch/x86/kernel/vmlinux.lds.S        |  1 -
 include/asm-generic/sections.h       |  2 --
 include/asm-generic/vmlinux.lds.h    |  6 ------
 include/linux/compiler.h             |  2 +-
 include/linux/kprobes.h              |  3 +++
 kernel/kprobes.c                     |  6 ++++--
 scripts/Makefile                     |  1 +
 scripts/mod/Makefile                 |  2 ++
 scripts/mod/modpost.c                |  8 +++++++-
 scripts/recordmcount.c               |  7 ++++++-
 scripts/recordmcount.pl              |  2 +-
 42 files changed, 53 insertions(+), 58 deletions(-)

diff --git a/arch/arc/kernel/vmlinux.lds.S b/arch/arc/kernel/vmlinux.lds.S
index 894e696bddaa..52f23df2b9b6 100644
--- a/arch/arc/kernel/vmlinux.lds.S
+++ b/arch/arc/kernel/vmlinux.lds.S
@@ -98,7 +98,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.fixup)
 		*(.gnu.warning)
 	}
diff --git a/arch/arm/kernel/entry-armv.S b/arch/arm/kernel/entry-armv.S
index bc5f50799d75..e56ba05eae34 100644
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
+	section_rng_asmtype(SECTION_TEXT, kprobes, ax, %progbits)
 #else
 	.text
 #endif
diff --git a/arch/arm/kernel/vmlinux-xip.lds.S b/arch/arm/kernel/vmlinux-xip.lds.S
index cba1ec899a69..3aea8834e3d2 100644
--- a/arch/arm/kernel/vmlinux-xip.lds.S
+++ b/arch/arm/kernel/vmlinux-xip.lds.S
@@ -99,7 +99,6 @@ SECTIONS
 			TEXT_TEXT
 			SCHED_TEXT
 			LOCK_TEXT
-			KPROBES_TEXT
 			*(.gnu.warning)
 			*(.glue_7)
 			*(.glue_7t)
diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S
index d24e5dd2aa7a..e88b77d01f0b 100644
--- a/arch/arm/kernel/vmlinux.lds.S
+++ b/arch/arm/kernel/vmlinux.lds.S
@@ -113,7 +113,6 @@ SECTIONS
 			SCHED_TEXT
 			LOCK_TEXT
 			HYPERVISOR_TEXT
-			KPROBES_TEXT
 			*(.gnu.warning)
 			*(.glue_7)
 			*(.glue_7t)
diff --git a/arch/avr32/kernel/entry-avr32b.S b/arch/avr32/kernel/entry-avr32b.S
index 7301f4806bbe..6a2cb50cb012 100644
--- a/arch/avr32/kernel/entry-avr32b.S
+++ b/arch/avr32/kernel/entry-avr32b.S
@@ -23,6 +23,7 @@
 #include <asm/sysreg.h>
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
+#include <asm/ranges.h>
 
 #ifdef CONFIG_PREEMPT
 # define preempt_stop		mask_interrupts
@@ -605,7 +606,7 @@ fault_exit_work:
 	brcc	fault_resume_user
 	rjmp	enter_monitor_mode
 
-	.section .kprobes.text, "ax", @progbits
+	section_rng_asmtype(SECTION_TEXT, kprobes, ax, @progbits)
 	.type	handle_debug, @function
 handle_debug:
 	sub	sp, 4		/* r12_orig */
@@ -826,7 +827,7 @@ irq_level\level:
 	IRQ_LEVEL 2
 	IRQ_LEVEL 3
 
-	.section .kprobes.text, "ax", @progbits
+	section_rng_asmtype(SECTION_TEXT, kprobes, ax, @progbits)
 	.type	enter_monitor_mode, @function
 enter_monitor_mode:
 	/*
diff --git a/arch/avr32/kernel/vmlinux.lds.S b/arch/avr32/kernel/vmlinux.lds.S
index a4589176bed5..bf4f3f1f9dbb 100644
--- a/arch/avr32/kernel/vmlinux.lds.S
+++ b/arch/avr32/kernel/vmlinux.lds.S
@@ -49,7 +49,6 @@ SECTIONS
 		_stext = .;
 		*(.ex.text)
 		*(.irq.text)
-		KPROBES_TEXT
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
diff --git a/arch/blackfin/kernel/vmlinux.lds.S b/arch/blackfin/kernel/vmlinux.lds.S
index d920b959ff3a..8f7ca475c549 100644
--- a/arch/blackfin/kernel/vmlinux.lds.S
+++ b/arch/blackfin/kernel/vmlinux.lds.S
@@ -36,7 +36,6 @@ SECTIONS
 		LOCK_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
-		KPROBES_TEXT
 #ifdef CONFIG_ROMKERNEL
 		__sinittext = .;
 		INIT_TEXT
diff --git a/arch/c6x/kernel/vmlinux.lds.S b/arch/c6x/kernel/vmlinux.lds.S
index 50bc10f97bcb..e7aae42f632e 100644
--- a/arch/c6x/kernel/vmlinux.lds.S
+++ b/arch/c6x/kernel/vmlinux.lds.S
@@ -73,7 +73,6 @@ SECTIONS
 		LOCK_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
-		KPROBES_TEXT
 		*(.fixup)
 		*(.gnu.warning)
 	}
diff --git a/arch/hexagon/kernel/vmlinux.lds.S b/arch/hexagon/kernel/vmlinux.lds.S
index 5f268c1071b3..a358b699ec64 100644
--- a/arch/hexagon/kernel/vmlinux.lds.S
+++ b/arch/hexagon/kernel/vmlinux.lds.S
@@ -51,7 +51,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.fixup)
 	}
 	_etext = .;
diff --git a/arch/ia64/kernel/jprobes.S b/arch/ia64/kernel/jprobes.S
index f69389c7be1d..552204c758ac 100644
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
+	section_rng(SECTION_TEXT, kprobes, ax)
 ENTRY(jprobe_break)
 	break.m __IA64_BREAK_JPROBE
 END(jprobe_break)
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index dc506b05ffbd..884f36d38989 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -47,7 +47,6 @@ SECTIONS {
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.gnu.linkonce.t*)
 	}
 
diff --git a/arch/ia64/lib/flush.S b/arch/ia64/lib/flush.S
index 1d8c88860063..44b9d3416513 100644
--- a/arch/ia64/lib/flush.S
+++ b/arch/ia64/lib/flush.S
@@ -8,6 +8,7 @@
  */
 
 #include <asm/asmmacro.h>
+#include <asm/ranges.h>
 
 
 	/*
@@ -20,7 +21,7 @@
 	 *
 	 *	Note: "in0" and "in1" are preserved for debugging purposes.
 	 */
-	.section .kprobes.text,"ax"
+	section_rng(SECTION_TEXT, kprobes, ax)
 GLOBAL_ENTRY(flush_icache_range)
 
 	.prologue
@@ -72,7 +73,7 @@ END(flush_icache_range)
 	 *
 	 *	Note: "in0" and "in1" are preserved for debugging purposes.
 	 */
-	.section .kprobes.text,"ax"
+	section_rng(SECTION_TEXT, kprobes, ax)
 GLOBAL_ENTRY(clflush_cache_range)
 
 	.prologue
diff --git a/arch/metag/kernel/vmlinux.lds.S b/arch/metag/kernel/vmlinux.lds.S
index 150ace92c7ad..bee7031d6b65 100644
--- a/arch/metag/kernel/vmlinux.lds.S
+++ b/arch/metag/kernel/vmlinux.lds.S
@@ -22,7 +22,6 @@ SECTIONS
 	TEXT_TEXT
 	SCHED_TEXT
 	LOCK_TEXT
-	KPROBES_TEXT
 	IRQENTRY_TEXT
 	SOFTIRQENTRY_TEXT
 	*(.text.*)
diff --git a/arch/microblaze/kernel/vmlinux.lds.S b/arch/microblaze/kernel/vmlinux.lds.S
index 0a47f0410554..2da85501a97a 100644
--- a/arch/microblaze/kernel/vmlinux.lds.S
+++ b/arch/microblaze/kernel/vmlinux.lds.S
@@ -34,7 +34,6 @@ SECTIONS {
 		EXIT_CALL
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		. = ALIGN (4) ;
diff --git a/arch/mips/kernel/vmlinux.lds.S b/arch/mips/kernel/vmlinux.lds.S
index a82c178d0bb9..a4c1c9889bdf 100644
--- a/arch/mips/kernel/vmlinux.lds.S
+++ b/arch/mips/kernel/vmlinux.lds.S
@@ -56,7 +56,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.text.*)
diff --git a/arch/mn10300/kernel/vmlinux.lds.S b/arch/mn10300/kernel/vmlinux.lds.S
index 13c4814c29f8..ead5efc01802 100644
--- a/arch/mn10300/kernel/vmlinux.lds.S
+++ b/arch/mn10300/kernel/vmlinux.lds.S
@@ -31,7 +31,6 @@ SECTIONS
 	TEXT_TEXT
 	SCHED_TEXT
 	LOCK_TEXT
-	KPROBES_TEXT
 	*(.fixup)
 	*(.gnu.warning)
 	} = 0xcb
diff --git a/arch/nios2/kernel/vmlinux.lds.S b/arch/nios2/kernel/vmlinux.lds.S
index e23e89539967..51647b5c45db 100644
--- a/arch/nios2/kernel/vmlinux.lds.S
+++ b/arch/nios2/kernel/vmlinux.lds.S
@@ -40,7 +40,6 @@ SECTIONS
 		LOCK_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
-		KPROBES_TEXT
 	} =0
 	_etext = .;
 
diff --git a/arch/openrisc/kernel/vmlinux.lds.S b/arch/openrisc/kernel/vmlinux.lds.S
index d936de4c07ca..1e09dd42d7fa 100644
--- a/arch/openrisc/kernel/vmlinux.lds.S
+++ b/arch/openrisc/kernel/vmlinux.lds.S
@@ -48,7 +48,6 @@ SECTIONS
 	  TEXT_TEXT
 	  SCHED_TEXT
 	  LOCK_TEXT
-	  KPROBES_TEXT
 	  IRQENTRY_TEXT
 	  SOFTIRQENTRY_TEXT
 	  *(.fixup)
diff --git a/arch/parisc/kernel/vmlinux.lds.S b/arch/parisc/kernel/vmlinux.lds.S
index f3ead0b6ce46..c48399848674 100644
--- a/arch/parisc/kernel/vmlinux.lds.S
+++ b/arch/parisc/kernel/vmlinux.lds.S
@@ -70,7 +70,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.text.do_softirq)
diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
index d5d5b5e348f2..201c08d5895a 100644
--- a/arch/powerpc/include/asm/ppc_asm.h
+++ b/arch/powerpc/include/asm/ppc_asm.h
@@ -9,6 +9,7 @@
 #include <asm/processor.h>
 #include <asm/ppc-opcode.h>
 #include <asm/firmware.h>
+#include <asm/ranges.h>
 
 #ifndef __ASSEMBLY__
 #error __FILE__ should only be used in assembler files
@@ -218,7 +219,7 @@ name: \
 	.localentry name,.-name
 
 #define _KPROBE(name) \
-	.section ".kprobes.text","a"; \
+	section_rng(SECTION_TEXT, kprobes, a); \
 	.align 2 ; \
 	.type name,@function; \
 	.globl name; \
@@ -248,7 +249,7 @@ GLUE(.,name):
 #define _GLOBAL_TOC(name) _GLOBAL(name)
 
 #define _KPROBE(name) \
-	.section ".kprobes.text","a"; \
+	section_rng(SECTION_TEXT, kprobes, a); \
 	.align 2 ; \
 	.globl name; \
 	.globl GLUE(.,name); \
@@ -280,7 +281,7 @@ n:
 #define _GLOBAL_TOC(name) _GLOBAL(name)
 
 #define _KPROBE(n)	\
-	.section ".kprobes.text","a";	\
+	section_rng(SECTION_TEXT, kprobes, a); \
 	.globl	n;	\
 n:
 
diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
index b5fba689fca6..544856210081 100644
--- a/arch/powerpc/kernel/vmlinux.lds.S
+++ b/arch/powerpc/kernel/vmlinux.lds.S
@@ -53,7 +53,6 @@ SECTIONS
 		*(.text .fixup __ftr_alt_* .ref.text)
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 
diff --git a/arch/s390/kernel/entry.S b/arch/s390/kernel/entry.S
index c51650a1ed16..db7938a841ae 100644
--- a/arch/s390/kernel/entry.S
+++ b/arch/s390/kernel/entry.S
@@ -23,6 +23,7 @@
 #include <asm/vx-insn.h>
 #include <asm/setup.h>
 #include <asm/nmi.h>
+#include <asm/ranges.h>
 
 __PT_R0      =	__PT_GPRS
 __PT_R1      =	__PT_GPRS + 8
@@ -162,7 +163,7 @@ _PIF_WORK	= (_PIF_PER_TRAP)
 		tm	off+\addr, \mask
 	.endm
 
-	.section .kprobes.text, "ax"
+	section_rng(SECTION_TEXT, kprobes, ax)
 .Ldummy:
 	/*
 	 * This nop exists only in order to avoid that __switch_to starts at
@@ -975,7 +976,7 @@ ENTRY(restart_int_handler)
 	brc	2,2b
 3:	j	3b
 
-	.section .kprobes.text, "ax"
+	section_rng(SECTION_TEXT, kprobes, ax)
 
 #ifdef CONFIG_CHECK_STACK
 /*
diff --git a/arch/s390/kernel/kprobes.c b/arch/s390/kernel/kprobes.c
index 250f5972536a..4c75c9cc64af 100644
--- a/arch/s390/kernel/kprobes.c
+++ b/arch/s390/kernel/kprobes.c
@@ -287,9 +287,9 @@ static void kprobe_reenter_check(struct kprobe_ctlblk *kcb, struct kprobe *p)
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
index e499370fbccb..813949240960 100644
--- a/arch/s390/kernel/mcount.S
+++ b/arch/s390/kernel/mcount.S
@@ -10,7 +10,7 @@
 #include <asm/ftrace.h>
 #include <asm/ptrace.h>
 
-	.section .kprobes.text, "ax"
+	section_rng(SECTION_TEXT, kprobes, ax,)
 
 ENTRY(ftrace_stub)
 	br	%r14
diff --git a/arch/s390/kernel/vmlinux.lds.S b/arch/s390/kernel/vmlinux.lds.S
index 429bfd111961..33b0baf2233c 100644
--- a/arch/s390/kernel/vmlinux.lds.S
+++ b/arch/s390/kernel/vmlinux.lds.S
@@ -36,7 +36,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.fixup)
diff --git a/arch/score/kernel/vmlinux.lds.S b/arch/score/kernel/vmlinux.lds.S
index 7274b5c4287e..36ebcb3b1215 100644
--- a/arch/score/kernel/vmlinux.lds.S
+++ b/arch/score/kernel/vmlinux.lds.S
@@ -41,7 +41,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		*(.text.*)
 		*(.fixup)
 		. = ALIGN (4) ;
diff --git a/arch/sh/kernel/vmlinux.lds.S b/arch/sh/kernel/vmlinux.lds.S
index 235a4101999f..d8ae0a60cdf2 100644
--- a/arch/sh/kernel/vmlinux.lds.S
+++ b/arch/sh/kernel/vmlinux.lds.S
@@ -37,7 +37,6 @@ SECTIONS
 		EXTRA_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.fixup)
diff --git a/arch/sparc/kernel/vmlinux.lds.S b/arch/sparc/kernel/vmlinux.lds.S
index d79b3b734245..017eb4d7ccca 100644
--- a/arch/sparc/kernel/vmlinux.lds.S
+++ b/arch/sparc/kernel/vmlinux.lds.S
@@ -50,7 +50,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
 		*(.gnu.warning)
diff --git a/arch/sparc/mm/ultra.S b/arch/sparc/mm/ultra.S
index b4f4733abc6e..6762b7db82c4 100644
--- a/arch/sparc/mm/ultra.S
+++ b/arch/sparc/mm/ultra.S
@@ -16,6 +16,7 @@
 #include <asm/cacheflush.h>
 #include <asm/hypervisor.h>
 #include <asm/cpudata.h>
+#include <asm/ranges.h>
 
 	/* Basically, most of the Spitfire vs. Cheetah madness
 	 * has to do with the fact that Cheetah does not support
@@ -148,7 +149,7 @@ __spitfire_flush_tlb_mm_slow:
 /*
  * The following code flushes one page_size worth.
  */
-	.section .kprobes.text, "ax"
+	section_rng(SECTION_TEXT, kprobes, ax)
 	.align		32
 	.globl		__flush_icache_page
 __flush_icache_page:	/* %o0 = phys_page */
diff --git a/arch/tile/kernel/vmlinux.lds.S b/arch/tile/kernel/vmlinux.lds.S
index 9d449caf8910..c222cea90b7a 100644
--- a/arch/tile/kernel/vmlinux.lds.S
+++ b/arch/tile/kernel/vmlinux.lds.S
@@ -43,7 +43,6 @@ SECTIONS
     HEAD_TEXT
     SCHED_TEXT
     LOCK_TEXT
-    KPROBES_TEXT
     IRQENTRY_TEXT
     SOFTIRQENTRY_TEXT
     __fix_text_end = .;   /* tile-cpack won't rearrange before this */
diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 7847e5c0e0b5..5a08b2e7196d 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -579,9 +579,9 @@ static int reenter_kprobe(struct kprobe *p, struct pt_regs *regs,
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
@@ -1128,10 +1128,9 @@ NOKPROBE_SYMBOL(longjmp_break_handler);
 
 bool arch_within_kprobe_blacklist(unsigned long addr)
 {
-	return  (addr >= (unsigned long)__kprobes_text_start &&
-		 addr < (unsigned long)__kprobes_text_end) ||
+	return  (SECTION_ADDR_IN_RANGE(kprobes, addr) ||
 		(addr >= (unsigned long)__entry_text_start &&
-		 addr < (unsigned long)__entry_text_end);
+		 addr < (unsigned long)__entry_text_end));
 }
 
 int __init arch_init_kprobes(void)
diff --git a/arch/x86/kernel/vmlinux.lds.S b/arch/x86/kernel/vmlinux.lds.S
index 9297a002d8e5..8a5dfa38fde3 100644
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -98,7 +98,6 @@ SECTIONS
 		TEXT_TEXT
 		SCHED_TEXT
 		LOCK_TEXT
-		KPROBES_TEXT
 		ENTRY_TEXT
 		IRQENTRY_TEXT
 		SOFTIRQENTRY_TEXT
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index cd4313c3edf8..fa004a67ad53 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -324,7 +324,6 @@
  * Following global variables are optional and may be unavailable on some
  * architectures and/or kernel configurations.
  *	_text, _data
- *	__kprobes_text_start, __kprobes_text_end
  *	__entry_text_start, __entry_text_end
  *	__ctors_start, __ctors_end
  */
@@ -335,7 +334,6 @@ extern char __init_begin[], __init_end[];
 extern char _sinittext[], _einittext[];
 extern char _end[];
 extern char __per_cpu_load[], __per_cpu_start[], __per_cpu_end[];
-extern char __kprobes_text_start[], __kprobes_text_end[];
 extern char __entry_text_start[], __entry_text_end[];
 extern char __start_rodata[], __end_rodata[];
 
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 8048242b6a76..1664050e6560 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -444,12 +444,6 @@
 		*(.spinlock.text)					\
 		VMLINUX_SYMBOL(__lock_text_end) = .;
 
-#define KPROBES_TEXT							\
-		ALIGN_FUNCTION();					\
-		VMLINUX_SYMBOL(__kprobes_text_start) = .;		\
-		*(.kprobes.text)					\
-		VMLINUX_SYMBOL(__kprobes_text_end) = .;
-
 #define ENTRY_TEXT							\
 		ALIGN_FUNCTION();					\
 		VMLINUX_SYMBOL(__entry_text_start) = .;			\
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index d7a0b579442c..a651a4fd537d 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -544,7 +544,7 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
 
 /* Ignore/forbid kprobes attach on very low level functions marked by this attribute: */
 #ifdef CONFIG_KPROBES
-# define __kprobes	__attribute__((__section__(".kprobes.text")))
+# define __kprobes	__LINUX_RANGE(SECTION_TEXT, kprobes)
 # define nokprobe_inline	__always_inline
 #else
 # define __kprobes
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 8f6849084248..3f46b282a3f9 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -42,8 +42,11 @@
 #include <linux/ftrace.h>
 
 #ifdef CONFIG_KPROBES
+#include <linux/ranges.h>
 #include <asm/kprobes.h>
 
+DECLARE_SECTION_RANGE(kprobes);
+
 /* kprobe_status settings */
 #define KPROBE_HIT_ACTIVE	0x00000001
 #define KPROBE_HIT_SS		0x00000002
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index d10ab6b9b5e0..387605682622 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1328,8 +1328,7 @@ out:
 bool __weak arch_within_kprobe_blacklist(unsigned long addr)
 {
 	/* The __kprobes marked functions and entry code must not be probed */
-	return addr >= (unsigned long)__kprobes_text_start &&
-	       addr < (unsigned long)__kprobes_text_end;
+	return SECTION_ADDR_IN_RANGE(kprobes, addr);
 }
 
 bool within_kprobe_blacklist(unsigned long addr)
@@ -2129,6 +2128,9 @@ static struct notifier_block kprobe_module_nb = {
 extern unsigned long __start_kprobe_blacklist[];
 extern unsigned long __stop_kprobe_blacklist[];
 
+/* Actual kprobes section range */
+DEFINE_SECTION_RANGE(kprobes, SECTION_TEXT);
+
 static int __init init_kprobes(void)
 {
 	int i, err = 0;
diff --git a/scripts/Makefile b/scripts/Makefile
index 1d80897a9644..77a0cc91628c 100644
--- a/scripts/Makefile
+++ b/scripts/Makefile
@@ -10,6 +10,7 @@
 # check-lc_ctype: Used in Documentation/DocBook
 
 HOST_EXTRACFLAGS += -I$(srctree)/tools/include
+HOST_EXTRACFLAGS += -U__KERNEL__
 
 hostprogs-$(CONFIG_KALLSYMS)     += kallsyms
 hostprogs-$(CONFIG_LOGO)         += pnmtologo
diff --git a/scripts/mod/Makefile b/scripts/mod/Makefile
index 8257ef422c0a..76905d4ac0d0 100644
--- a/scripts/mod/Makefile
+++ b/scripts/mod/Makefile
@@ -1,5 +1,7 @@
 OBJECT_FILES_NON_STANDARD := y
 
+HOST_EXTRACFLAGS += -U__KERNEL__
+
 hostprogs-y	:= modpost mk_elfconfig
 always		:= $(hostprogs-y) empty.o
 
diff --git a/scripts/mod/modpost.c b/scripts/mod/modpost.c
index 48958d3cec9e..12ddced5df84 100644
--- a/scripts/mod/modpost.c
+++ b/scripts/mod/modpost.c
@@ -19,10 +19,16 @@
 #include <stdbool.h>
 #include <errno.h>
 #include "modpost.h"
+
 #include "../../include/generated/autoconf.h"
 #include "../../include/linux/license.h"
 #include "../../include/linux/export.h"
 
+#include "../../include/linux/sections.h"
+#include "../../include/asm-generic/sections.h"
+#include "../../include/linux/ranges.h"
+#include "../../include/asm-generic/ranges.h"
+
 /* Are we using CONFIG_MODVERSIONS? */
 static int modversions = 0;
 /* Warn about undefined symbols? (do so if we have vmlinux) */
@@ -888,7 +894,7 @@ static void check_section(const char *modname, struct elf_info *elf,
 
 #define DATA_SECTIONS ".data", ".data.rel"
 #define TEXT_SECTIONS ".text", ".text.unlikely", ".sched.text", \
-		".kprobes.text"
+		SECTION_RNG(SECTION_TEXT, kprobes)
 #define OTHER_TEXT_SECTIONS ".ref.text", ".head.text", ".spinlock.text", \
 		".fixup", ".entry.text", ".exception.text", ".text.*", \
 		".coldtext"
diff --git a/scripts/recordmcount.c b/scripts/recordmcount.c
index e167592793a7..8381d75235d4 100644
--- a/scripts/recordmcount.c
+++ b/scripts/recordmcount.c
@@ -33,6 +33,11 @@
 #include <string.h>
 #include <unistd.h>
 
+#include "../../include/linux/sections.h"
+#include "../../include/asm-generic/sections.h"
+#include "../../include/linux/ranges.h"
+#include "../../include/asm-generic/ranges.h"
+
 #ifndef EM_METAG
 /* Remove this when these make it to the standard system elf.h. */
 #define EM_METAG      174
@@ -356,7 +361,7 @@ is_mcounted_section_name(char const *const txtname)
 		strcmp(".sched.text",    txtname) = 0 ||
 		strcmp(".spinlock.text", txtname) = 0 ||
 		strcmp(".irqentry.text", txtname) = 0 ||
-		strcmp(".kprobes.text", txtname) = 0 ||
+		strcmp(SECTION_RNG(SECTION_TEXT, kprobe), txtname) = 0 ||
 		strcmp(".text.unlikely", txtname) = 0;
 }
 
diff --git a/scripts/recordmcount.pl b/scripts/recordmcount.pl
index 96e2486a6fc4..f663a7c5d6ab 100755
--- a/scripts/recordmcount.pl
+++ b/scripts/recordmcount.pl
@@ -134,7 +134,7 @@ my %text_sections = (
      ".sched.text" => 1,
      ".spinlock.text" => 1,
      ".irqentry.text" => 1,
-     ".kprobes.text" => 1,
+     ".text.rng.kprobes.any" => 1,
      ".text.unlikely" => 1,
 );
 
-- 
2.8.4

