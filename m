From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:39 +0000
Subject: [RFC v3 05/13] sections.h: add sections header to collect all section info
Message-Id: <1469222687-1600-6-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@linux-foun

Linux makes extensive use of custom ELF header sections,
documentation for these are well scatterred. Unify this
documentation in a central place and provide helpers to
build custom Linux sections.

We are now generalizing sections.h in code to enable
avoiding modifying the linker when we want to add new
custom Linux sections but to make this generally useful
we need to ensure all architectures also have their own
asm/sections.h, this is now also used by the custom series
of helpers to an architecture's linker script:

  asm-generic/vmlinux.lds.h.

v3:

o add missing sections.h for architectures that did not
  have it

o move generic sections to asm-generic/sections.h

o add generic asm helpers section_type(), section_type_asmtype(),
  push_section_type() -- these helpers enable easy use for
  for later declaring and using of custom linux sections using
  more standard APIs in both C code, asm code (C asm calls, or
  asm files), enabling future standardized section types to
  be more immediately accessible to asm code, not just C code.
  Note for ASM_CMD_SEP we use by default "\n", architectures needed
  to override can do so on their own sections.h prior to inclusion
  of asm-generic/sections.h

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 Documentation/DocBook/Makefile        |   3 +-
 Documentation/DocBook/sections.tmpl   | 112 +++++++++++++
 arch/alpha/include/asm/sections.h     |   6 +
 arch/arm64/include/asm/sections.h     |   6 +
 arch/avr32/include/asm/sections.h     |   6 +
 arch/cris/include/asm/sections.h      |   6 +
 arch/h8300/include/asm/sections.h     |   6 +
 arch/hexagon/include/asm/sections.h   |   6 +
 arch/m32r/include/asm/sections.h      |   6 +
 arch/m68k/include/asm/sections.h      |   6 +
 arch/metag/include/asm/sections.h     |   6 +
 arch/mips/include/asm/sections.h      |   6 +
 arch/mn10300/include/asm/sections.h   |   6 +
 arch/nios2/include/asm/sections.h     |   6 +
 arch/openrisc/include/asm/sections.h  |   6 +
 arch/score/include/asm/sections.h     |   6 +
 arch/unicore32/include/asm/sections.h |   6 +
 arch/xtensa/include/asm/sections.h    |   6 +
 include/asm-generic/sections.h        | 300 ++++++++++++++++++++++++++++++++++
 include/asm-generic/vmlinux.lds.h     |  27 +--
 include/linux/sections.h              | 123 ++++++++++++++
 21 files changed, 647 insertions(+), 14 deletions(-)
 create mode 100644 Documentation/DocBook/sections.tmpl
 create mode 100644 arch/alpha/include/asm/sections.h
 create mode 100644 arch/arm64/include/asm/sections.h
 create mode 100644 arch/avr32/include/asm/sections.h
 create mode 100644 arch/cris/include/asm/sections.h
 create mode 100644 arch/h8300/include/asm/sections.h
 create mode 100644 arch/hexagon/include/asm/sections.h
 create mode 100644 arch/m32r/include/asm/sections.h
 create mode 100644 arch/m68k/include/asm/sections.h
 create mode 100644 arch/metag/include/asm/sections.h
 create mode 100644 arch/mips/include/asm/sections.h
 create mode 100644 arch/mn10300/include/asm/sections.h
 create mode 100644 arch/nios2/include/asm/sections.h
 create mode 100644 arch/openrisc/include/asm/sections.h
 create mode 100644 arch/score/include/asm/sections.h
 create mode 100644 arch/unicore32/include/asm/sections.h
 create mode 100644 arch/xtensa/include/asm/sections.h
 create mode 100644 include/linux/sections.h

diff --git a/Documentation/DocBook/Makefile b/Documentation/DocBook/Makefile
index 8e6dd4b14314..1b2ac4731418 100644
--- a/Documentation/DocBook/Makefile
+++ b/Documentation/DocBook/Makefile
@@ -17,7 +17,8 @@ DOCBOOKS := z8530book.xml device-drivers.xml \
 	    80211.xml debugobjects.xml sh.xml regulator.xml \
 	    alsa-driver-api.xml writing-an-alsa-driver.xml \
 	    tracepoint.xml media_api.xml w1.xml \
-	    writing_musb_glue_layer.xml crypto-API.xml iio.xml
+	    writing_musb_glue_layer.xml crypto-API.xml iio.xml \
+	    sections.xml
 
 include Documentation/DocBook/media/Makefile
 
diff --git a/Documentation/DocBook/sections.tmpl b/Documentation/DocBook/sections.tmpl
new file mode 100644
index 000000000000..2d14eb20e99c
--- /dev/null
+++ b/Documentation/DocBook/sections.tmpl
@@ -0,0 +1,112 @@
+<?xml version="1.0" encoding="UTF-8"?>
+<!DOCTYPE set PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN"
+	"http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd" []>
+<set>
+  <setinfo>
+    <title>Linux ELF sections</title>
+    <subtitle>
+      Explains Linux ELF sections
+    </subtitle>
+
+    <copyright>
+      <year>2016</year>
+      <holder>Luis R. Rodriguez</holder>
+    </copyright>
+
+    <authorgroup>
+      <author>
+        <firstname>Luis</firstname>
+        <surname>Rodriguez</surname>
+        <affiliation>
+          <address><email>mcgrof@kernel.org</email></address>
+        </affiliation>
+      </author>
+    </authorgroup>
+
+    <legalnotice>
+      <para>
+        This documentation is free software; you can redistribute
+        it and/or modify it under the terms of the GNU General Public
+        License version 2 as published by the Free Software Foundation.
+      </para>
+      <para>
+        This documentation is distributed in the hope that it will be
+        useful, but WITHOUT ANY WARRANTY; without even the implied
+        warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+        See the GNU General Public License for more details.
+      </para>
+      <para>
+        You should have received a copy of the GNU General Public
+        License along with this documentation; if not, write to the Free
+        Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
+        MA 02111-1307 USA
+      </para>
+      <para>
+        For more details see the file COPYING in the source
+        distribution of Linux.
+      </para>
+    </legalnotice>
+
+    <abstract>
+      <para>
+        This book documents the different custom ELF sections used on the Linux
+	kernel and defined on Linux's custom linker script.
+      </para>
+    </abstract>
+  </setinfo>
+  <book id="linux-elf-sections">
+    <bookinfo>
+      <title>Linux kernel ELF sections</title>
+
+      <abstract>
+!Pinclude/asm-generic/sections.h Introduction
+      </abstract>
+    </bookinfo>
+
+      <chapter>
+      <title>Linux kernel sections helpers</title>
+!Pinclude/linux/sections.h Linux section helpers
+!Finclude/linux/sections.h LINUX_SECTION_ALIGNMENT
+!Finclude/linux/sections.h LINUX_SECTION_SIZE
+!Finclude/linux/sections.h LINUX_SECTION_EMPTY
+!Finclude/linux/sections.h LINUX_SECTION_START
+!Finclude/linux/sections.h LINUX_SECTION_END
+!Finclude/linux/sections.h DECLARE_LINUX_SECTION
+!Finclude/linux/sections.h DECLARE_LINUX_SECTION_RO
+!Finclude/linux/sections.h SECTION_TYPE
+      </chapter>
+
+      <chapter>
+      <title>Core Linux kernel sections</title>
+!Pinclude/asm-generic/sections.h Core Linux kernel sections
+!Finclude/asm-generic/sections.h SECTION_RODATA
+!Finclude/asm-generic/sections.h SECTION_TEXT
+!Finclude/asm-generic/sections.h SECTION_DATA
+      </chapter>
+
+      <chapter>
+      <title>Linux .init* sections</title>
+!Pinclude/asm-generic/sections.h Linux init sections
+!Finclude/asm-generic/sections.h SECTION_INIT_DATA
+!Finclude/asm-generic/sections.h SECTION_INIT_RODATA
+!Finclude/asm-generic/sections.h SECTION_INIT_CALL
+      </chapter>
+
+      <chapter>
+      <title>Linux .exit* sections</title>
+!Pinclude/asm-generic/sections.h Linux exit sections
+!Finclude/asm-generic/sections.h SECTION_EXIT
+!Finclude/asm-generic/sections.h SECTION_EXIT_DATA
+!Finclude/asm-generic/sections.h SECTION_EXIT_CALL
+      </chapter>
+
+      <chapter>
+      <title>Linux .ref* sections</title>
+!Pinclude/asm-generic/sections.h Linux references to init sections
+!Finclude/asm-generic/sections.h SECTION_REF
+!Finclude/asm-generic/sections.h SECTION_REF_DATA
+!Finclude/asm-generic/sections.h SECTION_REF_RODATA
+      </chapter>
+
+  </book>
+</set>
diff --git a/arch/alpha/include/asm/sections.h b/arch/alpha/include/asm/sections.h
new file mode 100644
index 000000000000..e58fc679fe15
--- /dev/null
+++ b/arch/alpha/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ALPHA_SECTIONS_H
+#define _ASM_ALPHA_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_ALPHA_SECTIONS_H */
diff --git a/arch/arm64/include/asm/sections.h b/arch/arm64/include/asm/sections.h
new file mode 100644
index 000000000000..cd20ecc157a0
--- /dev/null
+++ b/arch/arm64/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ARM64_SECTIONS_H
+#define _ASM_ARM64_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_ARM64_SECTIONS_H */
diff --git a/arch/avr32/include/asm/sections.h b/arch/avr32/include/asm/sections.h
new file mode 100644
index 000000000000..78b3ded34489
--- /dev/null
+++ b/arch/avr32/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_AVR32_SECTIONS_H
+#define _ASM_AVR32_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_AVR32_SECTIONS_H */
diff --git a/arch/cris/include/asm/sections.h b/arch/cris/include/asm/sections.h
new file mode 100644
index 000000000000..802a2433780b
--- /dev/null
+++ b/arch/cris/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_CRIS_SECTIONS_H
+#define _ASM_CRIS_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_CRIS_SECTIONS_H */
diff --git a/arch/h8300/include/asm/sections.h b/arch/h8300/include/asm/sections.h
new file mode 100644
index 000000000000..85ba9501a276
--- /dev/null
+++ b/arch/h8300/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_H8300_SECTIONS_H
+#define _ASM_H8300_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_H8300_SECTIONS_H */
diff --git a/arch/hexagon/include/asm/sections.h b/arch/hexagon/include/asm/sections.h
new file mode 100644
index 000000000000..f905cf754efd
--- /dev/null
+++ b/arch/hexagon/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_HEXAGON_SECTIONS_H
+#define _ASM_HEXAGON_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_HEXAGON_SECTIONS_H */
diff --git a/arch/m32r/include/asm/sections.h b/arch/m32r/include/asm/sections.h
new file mode 100644
index 000000000000..25cfc2068443
--- /dev/null
+++ b/arch/m32r/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_M32R_SECTIONS_H
+#define _ASM_M32R_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_M32R_SECTIONS_H */
diff --git a/arch/m68k/include/asm/sections.h b/arch/m68k/include/asm/sections.h
new file mode 100644
index 000000000000..d64967ecfec6
--- /dev/null
+++ b/arch/m68k/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_M68K_SECTIONS_H
+#define _ASM_M68K_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_M68K_SECTIONS_H */
diff --git a/arch/metag/include/asm/sections.h b/arch/metag/include/asm/sections.h
new file mode 100644
index 000000000000..bb76d9a1ec20
--- /dev/null
+++ b/arch/metag/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_METAG_SECTIONS_H
+#define _ASM_METAG_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_METAG_SECTIONS_H */
diff --git a/arch/mips/include/asm/sections.h b/arch/mips/include/asm/sections.h
new file mode 100644
index 000000000000..425b508acfc7
--- /dev/null
+++ b/arch/mips/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MIPS_SECTIONS_H
+#define _ASM_MIPS_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_MIPS_SECTIONS_H */
diff --git a/arch/mn10300/include/asm/sections.h b/arch/mn10300/include/asm/sections.h
new file mode 100644
index 000000000000..61a62637a860
--- /dev/null
+++ b/arch/mn10300/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MN10300_SECTIONS_H
+#define _ASM_MN10300_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_MN10300_SECTIONS_H */
diff --git a/arch/nios2/include/asm/sections.h b/arch/nios2/include/asm/sections.h
new file mode 100644
index 000000000000..b6fc5d8e2e77
--- /dev/null
+++ b/arch/nios2/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_NIOS2_SECTIONS_H
+#define _ASM_NIOS2_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_NIOS2_SECTIONS_H */
diff --git a/arch/openrisc/include/asm/sections.h b/arch/openrisc/include/asm/sections.h
new file mode 100644
index 000000000000..561ee5ac5ead
--- /dev/null
+++ b/arch/openrisc/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_OPENRISC_SECTIONS_H
+#define _ASM_OPENRISC_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_OPENRISC_SECTIONS_H */
diff --git a/arch/score/include/asm/sections.h b/arch/score/include/asm/sections.h
new file mode 100644
index 000000000000..9441d23af005
--- /dev/null
+++ b/arch/score/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SCORE_SECTIONS_H
+#define _ASM_SCORE_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_SCORE_SECTIONS_H */
diff --git a/arch/unicore32/include/asm/sections.h b/arch/unicore32/include/asm/sections.h
new file mode 100644
index 000000000000..ec4cd27c85be
--- /dev/null
+++ b/arch/unicore32/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_UNICORE32_SECTIONS_H
+#define _ASM_UNICORE32_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_UNICORE32_SECTIONS_H */
diff --git a/arch/xtensa/include/asm/sections.h b/arch/xtensa/include/asm/sections.h
new file mode 100644
index 000000000000..ab1176a674c9
--- /dev/null
+++ b/arch/xtensa/include/asm/sections.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_XTENSA_SECTIONS_H
+#define _ASM_XTENSA_SECTIONS_H
+
+#include <asm-generic/sections.h>
+
+#endif /* _ASM_XTENSA_SECTIONS_H */
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index efd51e70a8db..cd4313c3edf8 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -1,6 +1,306 @@
 #ifndef _ASM_GENERIC_SECTIONS_H_
 #define _ASM_GENERIC_SECTIONS_H_
 
+/**
+ * DOC: Introduction
+ *
+ * The Linux vmlinux binary uses a custom linker script which adds
+ * some custom specialized ELF sections. This aims to document those
+ * sections. Each section must document the goal of the section, and
+ * address concurrency considerations when applicable.
+ */
+
+/**
+ * DOC: Core Linux kernel sections
+ *
+ * These are the core Linux kernel sections.
+ */
+
+/**
+ * SECTION_RODATA - read only data
+ *
+ * Macro name for code which must be protected from write access.
+ */
+#define SECTION_RODATA			.rodata
+
+/**
+ * SECTION_TEXT - kernel code execution section, read-only
+ *
+ * Macro name used to annotate code (functions) used during regular
+ * kernel run time. This is combined with SECTION_RODATA, only this
+ * section also gets execution allowed.
+ *
+ */
+#define SECTION_TEXT			.text
+
+/**
+ * SECTION_DATA - for read-write data
+ *
+ * Macro name for read-write data.
+ */
+#define SECTION_DATA			.data
+
+/**
+ * DOC: Linux init sections
+ *
+ * These sections are used for code and data structures used during boot or
+ * module initialization. On architectures that support it (x86, x86_64), all
+ * this code is freed up by the kernel right before the fist userspace init
+ * process is called when built-in to the kernel, and if modular it is freed
+ * after module initialization. Since the code is freed so early, in theory
+ * there should be no races against freeing this code with other CPUs. Init
+ * section code and data structures should never be exported with
+ * EXPORT_SYMBOL*() as the code will quickly become unavailable to the kernel
+ * after bootup.
+ */
+
+/**
+ * SECTION_INIT - boot initialization code
+ *
+ * Macro name used to annotate code (functions) used only during boot or driver
+ * initialization.
+ *
+ */
+#define SECTION_INIT			.init.text
+
+/**
+ * SECTION_INIT_DATA - boot initialization data
+ *
+ * Macro name used to annotate data structures used only during boot or driver
+ * initialization.
+ */
+#define SECTION_INIT_DATA		.init.data
+
+/**
+ * SECTION_INIT_RODATA - boot read-only initialization data
+ *
+ * Macro name used to annotate read-only code (functions) used only during boot
+ * or driver initialization.
+ */
+#define SECTION_INIT_RODATA		.init.rodata
+
+/**
+ * SECTION_INIT_CALL - special init call
+ *
+ * Special macro name used to annotate subsystem init call. These calls are
+ * are now grouped by functionality into separate subsections. Ordering inside
+ * the subsections is determined by link order.
+ */
+#define SECTION_INIT_CALL		.initcall
+
+/**
+ * DOC: Linux exit sections
+ *
+ * These sections are used to declare a functions and data structures which
+ * are only required on exit, the function or data structure will be dropped
+ * if the code declaring this section is not compiled as a module on
+ * architectures that support this (x86, x86_64). There is no special case
+ * handling for this code when built-in to the kernel.
+ */
+
+/**
+ * SECTION_EXIT - module exit code
+ *
+ * Macro name used to annotate code (functions) used only during module
+ * unload.
+ */
+#define SECTION_EXIT			.exit.text
+
+/**
+ * SECTION_EXIT_DATA - module exit data structures
+ *
+ * Macro name used to annotate data structures used only during module
+ * unload.
+ */
+#define SECTION_EXIT_DATA		.exit.data
+
+/**
+ * SECTION_EXIT_CALL - special exit call
+ *
+ * Special macro name used to annotate an exit exit routine, order
+ * is important and maintained by link order.
+ */
+#define SECTION_EXIT_CALL		.exitcall.exit
+
+/**
+ * DOC: Linux references to init sections
+ *
+ * These sections are used to teach modpost to not warn about possible
+ * misuses of init section code from other sections. If you use this
+ * your use case should document why you are certain such use of init
+ * sectioned code is valid. For more details refer to include/linux/init.h
+ * __ref, __refdata, and __refconst documentation.
+ */
+
+/**
+ * SECTION_REF - code referencing init is valid
+ *
+ * Macro name used to annotate that code (functions) declared with this section
+ * has been vetteed as valid for its reference or use of other code (functions)
+ * or data structures which are part of the init sections.
+ */
+#define SECTION_REF			.ref.text
+
+/**
+ * SECTION_REF_DATA - reference data structure are valid
+ *
+ * Macro name used to annotate data structures declared with this section have
+ * been vetteed for its reference or use of other code (functions) or data
+ * structures part of the init sections.
+ */
+#define SECTION_REF_DATA		.ref.data
+
+/**
+ * SECTION_REF_RODATA - const code or data structure referencing init is valid
+ *
+ * Macro name used to annotate const code (functions) const data structures
+ * which has been vetteed for its reference or use of other code (functions)
+ * or data structures part of the init sections.
+ */
+#define SECTION_REF_RODATA		.ref.rodata
+
+#define SECTION_ORDER_ANY	any
+
+/*
+ * These section _ALL() helpers are for use on linker scripts and helpers
+ */
+#define SECTION_ALL(__section)						\
+	__section##.*
+#define SECTION_TYPE_ALL(__section, __type)				\
+	__section##.##__type##.*
+
+/* Can be used on foo.S for instance */
+#ifndef __section_type_asmtype
+# define __section_type_asmtype(__section, __type, __name,		\
+			        __level, __flags, __asm_type)		\
+	.section __section.__type.__name.__level, __flags, __asm_type
+#endif
+
+#ifndef __section_type
+# define __section_type(__section, __type, __name, __level, __flags)	\
+	.section __section.__type.__name.__level, __flags
+#endif
+
+#ifndef __push_section_type
+# define __push_section_type(__section, __type, __name, __level, __flags) \
+	.pushsection __section.__type.__name.__level, __flags
+#endif
+
+#ifdef __KERNEL__
+#include <linux/stringify.h>
+#endif
+
+#if defined(__ASSEMBLER__) || defined(__ASSEMBLY__)
+
+# ifdef LINKER_SCRIPT
+
+#  ifndef SECTION_TYPE
+#   define SECTION_TYPE(__section, __type, __name, __level)		\
+	__section.__type.__name.__level
+#  endif
+
+# else
+
+#  ifndef push_section_type
+#   define push_section_type(__section, __type, __name, __level, __flags) \
+	 __push_section_type(__section, __type, __name,			  \
+			     __level, __stringify(__flags))
+#  endif
+
+#  ifndef section_type
+#   define section_type(__section, __type, __name, __level, __flags)	\
+	__section_type(__section, __type, __name,			\
+		       __level, __stringify(__flags))
+#  endif
+
+#  ifndef section_type_asmtype
+#   define section_type_asmtype(__section, __type, __name,		\
+			        __level, __flags, __asmtype)		\
+	__section_type_asmtype(__section, __type, __name, __level,	\
+			       __stringify(__flags), __asmtype)
+#  endif
+
+#  ifndef SECTION_TYPE
+#   define SECTION_TYPE(__section, __type, __name, __level)		\
+	push_section_type(__section, __type, __name, __level, )
+#  endif
+
+# endif /* LINKER_SCRIPT */
+#else /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
+
+/*
+ * As per gcc's documentation a common asm separator is a new line followed
+ * by tab [0], it however seems possible to also just use a newline as its
+ * the most commonly empirically observed semantic and folks seem to agree
+ * this even works on S390. In case your architecture disagrees you may
+ * override this and define your own and keep the rest of the macros.
+ *
+ * [0] https://gcc.gnu.org/onlinedocs/gcc/Basic-Asm.html#Basic-Asm
+ */
+# ifndef ASM_CMD_SEP
+#  define ASM_CMD_SEP	"\n"
+# endif
+
+# ifndef section_type
+#  define section_type(__section, __type, __name, __level, __flags)	\
+	__stringify(__section_type(__section, __type, __name,		\
+				   __level, __stringify(__flags)))	\
+	ASM_CMD_SEP
+# endif
+
+/*
+ * Some architectures (arm, and avr32 are two examples on kprobes) seem
+ * currently explicitly specify the asm type [0] -- this can be any of
+ * the optional constants on ELF:
+ *
+ * @progbits - section contains data
+ * @nobits - section does not contain data (i.e., section only occupies space)
+ * @note - section contains data which is used by things other than the program
+ * @init_array - section contains an array of pointers to init functions
+ * @fini_array - section contains an array of pointers to finish functions
+ * @preinit_array - section contains an array of pointers to pre-init functions
+ *
+ * ARM requires % instead of @.
+ *
+ * At least as per nasm (x86/x86_64 only), in the absence of qualifiers the
+ * defaults are as follows:
+ *
+ * section .text    progbits  alloc   exec    nowrite  align
+ * section .rodata  progbits  alloc   noexec  nowrite  align=4
+ * section .lrodata progbits  alloc   noexec  nowrite  align=4
+ * section .data    progbits  alloc   noexec  write    align=4
+ * section .ldata   progbits  alloc   noexec  write    align=4
+ * section .bss     nobits    alloc   noexec  write    align=4
+ * section .lbss    nobits    alloc   noexec  write    align=4
+ * section .tdata   progbits  alloc   noexec  write    align=4    tls
+ * section .tbss    nobits    alloc   noexec  write    align=4    tls
+ * section .comment progbits  noalloc noexec  nowrite  align=1
+ * section other    progbits  alloc   noexec  nowrite  align=1
+ *
+ * gas should have sensible defaults for architectures...
+ *
+ * [0] http://www.nasm.us/doc/nasmdoc7.html
+ */
+# ifndef section_type_asmtype
+#  define section_type_asmtype(__section, __type, __name, __level,	\
+			     __flags, __asmtype)			\
+	__stringify(__section_type_asmtype(__section, __type,		\
+					   __name, __level,		\
+					   __stringify(__flags),	\
+					   asmtype))			\
+	ASM_CMD_SEP
+# endif
+
+# ifndef push_section_type
+#  define push_section_type(__section, __type, __name, __level, __flags)	\
+	__stringify(__push_section_type(__section, __type,		\
+					__name,	__level,		\
+					__stringify(__flags)))		\
+	ASM_CMD_SEP
+# endif
+
+#endif /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
+
 #if defined(__KERNEL__) && !defined(__ASSEMBLER__) && !defined(__ASSEMBLY__)
 
 /* References to section boundaries */
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 24563970ff7b..0042f30ff34b 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -55,6 +55,7 @@
 #endif
 
 #include <linux/export.h>
+#include <asm/sections.h>
 
 /* Align . to a 8 byte boundary equals to maximum function alignment. */
 #define ALIGN_FUNCTION()  . = ALIGN(8)
@@ -198,8 +199,8 @@
 
 /* .data section */
 #define DATA_DATA							\
-	*(.data)							\
-	*(.ref.data)							\
+	*(SECTION_DATA)							\
+	*(SECTION_REF_DATA)						\
 	*(.data..shared_aligned) /* percpu related */			\
 	MEM_KEEP(init.data)						\
 	MEM_KEEP(exit.data)						\
@@ -262,9 +263,9 @@
  */
 #define RO_DATA_SECTION(align)						\
 	. = ALIGN((align));						\
-	.rodata           : AT(ADDR(.rodata) - LOAD_OFFSET) {		\
+	SECTION_RODATA    : AT(ADDR(SECTION_RODATA) - LOAD_OFFSET) {	\
 		VMLINUX_SYMBOL(__start_rodata) = .;			\
-		*(.rodata) *(.rodata.*)					\
+		*(SECTION_RODATA) *(SECTION_ALL(SECTION_RODATA))	\
 		RO_AFTER_INIT_DATA	/* Read only after init */	\
 		*(__vermagic)		/* Kernel version magic */	\
 		. = ALIGN(8);						\
@@ -394,7 +395,7 @@
 									\
 	/* __*init sections */						\
 	__init_rodata : AT(ADDR(__init_rodata) - LOAD_OFFSET) {		\
-		*(.ref.rodata)						\
+		*(SECTION_REF_RODATA)					\
 		MEM_KEEP(init.rodata)					\
 		MEM_KEEP(exit.rodata)					\
 	}								\
@@ -432,8 +433,8 @@
  * during second ld run in second ld pass when generating System.map */
 #define TEXT_TEXT							\
 		ALIGN_FUNCTION();					\
-		*(.text.hot .text .text.fixup .text.unlikely)		\
-		*(.ref.text)						\
+		*(.text.hot SECTION_TEXT .text.fixup .text.unlikely)	\
+		*(SECTION_REF)						\
 	MEM_KEEP(init.text)						\
 	MEM_KEEP(exit.text)						\
 
@@ -527,11 +528,11 @@
 
 /* init and exit section handling */
 #define INIT_DATA							\
-	*(.init.data)							\
+	*(SECTION_INIT_DATA)						\
 	MEM_DISCARD(init.data)						\
 	KERNEL_CTORS()							\
 	MCOUNT_REC()							\
-	*(.init.rodata)							\
+	*(SECTION_INIT_RODATA)						\
 	FTRACE_EVENTS()							\
 	TRACE_SYSCALLS()						\
 	KPROBE_BLACKLIST()						\
@@ -549,24 +550,24 @@
 	EARLYCON_TABLE()
 
 #define INIT_TEXT							\
-	*(.init.text)							\
+	*(SECTION_INIT)							\
 	*(.text.startup)						\
 	MEM_DISCARD(init.text)
 
 #define EXIT_DATA							\
-	*(.exit.data)							\
+	*(SECTION_EXIT_DATA)						\
 	*(.fini_array)							\
 	*(.dtors)							\
 	MEM_DISCARD(exit.data)						\
 	MEM_DISCARD(exit.rodata)
 
 #define EXIT_TEXT							\
-	*(.exit.text)							\
+	*(SECTION_EXIT)							\
 	*(.text.exit)							\
 	MEM_DISCARD(exit.text)
 
 #define EXIT_CALL							\
-	*(.exitcall.exit)
+	*(SECTION_EXIT_CALL)
 
 /*
  * bss (Block Started by Symbol) - uninitialized data
diff --git a/include/linux/sections.h b/include/linux/sections.h
new file mode 100644
index 000000000000..118c46f884a7
--- /dev/null
+++ b/include/linux/sections.h
@@ -0,0 +1,123 @@
+#ifndef _LINUX_SECTIONS_H
+#define _LINUX_SECTIONS_H
+/*
+ * Linux de-facto sections
+ *
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+
+#ifdef __KERNEL__
+# include <asm/sections.h>
+#endif /* __KERNEL__ */
+
+#ifndef __ASSEMBLY__
+
+/**
+ * DOC: Linux section helpers
+ *
+ * Set of common helpers which can be used to against custom Linux sections.
+ */
+
+/**
+ * LINUX_SECTION_ALIGNMENT - get section alignment
+ *
+ * @name: section name
+ *
+ * Gives you the alignment for the section.
+ */
+#define LINUX_SECTION_ALIGNMENT(name)	__alignof__(*name)
+
+/**
+ * LINUX_SECTION_SIZE - get number of entries in the section
+ *
+ * @name: section name
+ *
+ * This gives you the number of entries in the section.
+ * Example usage:
+ *
+ *   unsigned int num_frobs = LINUX_SECTION_SIZE(frobnicator_fns);
+ */
+#define LINUX_SECTION_SIZE(name)	((name##__end) - (name))
+
+/**
+ * LINUX_SECTION_EMPTY - check if section has no entries
+ *
+ * @name: section name
+ *
+ * Returns true if section is emtpy.
+ *
+ *   bool is_empty = LINUX_SECTION_EMPTY(frobnicator_fns);
+ */
+#define LINUX_SECTION_EMPTY(name)	(LINUX_SECTION_SIZE(name) = 0)
+
+/**
+ * LINUX_SECTION_START - get address of start of section
+ *
+ * @name: section name
+ *
+ * This gives you the start address of the section.
+ * This should give you the address of the first entry.
+ *
+ */
+#define LINUX_SECTION_START(name)	name
+
+/**
+ * LINUX_SECTION_END - get address of end of the section
+ *
+ * @name: section name
+ *
+ * This gives you the end address of the section.
+ * This should give you the address of the end of the
+ * section. This will match the start address if the
+ * section is empty.
+ */
+#define LINUX_SECTION_END(name)	name##__end
+
+/**
+ * DECLARE_LINUX_SECTION - Declares a custom Linux section
+ *
+ * @type: type of custom Linux section
+ * @name: custom section name
+ *
+ * Declares a read-write custom Linux section
+ */
+#define DECLARE_LINUX_SECTION(type, name)				\
+	 extern type name[], name##__end[];
+
+/**
+ * DECLARE_LINUX_SECTION_RO - Declares a read-only custom Linux section
+ *
+ * @type: type of custom Linux section
+ * @name: custom section name
+ *
+ * Declares a read-only custom Linux section
+ */
+#define DECLARE_LINUX_SECTION_RO(type, name)				\
+	 extern const type name[], name##__end[];
+
+#define __SECTION_TYPE(section, type, name, level)			\
+	#section "." #type "." #name "." #level
+
+/**
+ * SECTION_TYPE - helper to construct a custom section type name
+ *
+ * @section: known de facto section, in asm-generic/sections.h
+ * @type: type of Linux section
+ * @name: custom section name
+ * @level: order level, used to help sort the section entries. The value
+ *	used should be a digit. Since ELF sections are strings there is
+ *	no technical restriction on the length of the number of digits
+ *	used.
+ *
+ * Helper to construct the name of a custom section type.
+ */
+#define SECTION_TYPE(section, type, name, level)                       	\
+	__SECTION_TYPE(section, type, name, level)
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _LINUX_SECTIONS_H */
-- 
2.8.4

