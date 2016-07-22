From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:40 +0000
Subject: [RFC v3 06/13] ranges.h: add helpers to build and identify Linux section ranges
Message-Id: <1469222687-1600-7-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@linux-foun

Section ranges are on one of the types of custom sections
types used in Linux. This provides a series of helpers for
defining them and using them. Most importantly this also
enables us to avoid modifying the linker script when we
add new section range.

It turns out a lot of custom sections are actually section ranges,
and these are typically spelled out in their architecture specific
asm/sections.h file -- we anable architectures to override what asm
is used for section ranges but start by defult trusting the asm-generic
version all around.

v3: new in this series, uses copyleft-next

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 arch/alpha/include/asm/ranges.h      |  6 ++++
 arch/arc/include/asm/ranges.h        |  6 ++++
 arch/arm/include/asm/ranges.h        |  6 ++++
 arch/arm64/include/asm/ranges.h      |  6 ++++
 arch/avr32/include/asm/ranges.h      |  6 ++++
 arch/blackfin/include/asm/ranges.h   |  6 ++++
 arch/c6x/include/asm/ranges.h        |  6 ++++
 arch/cris/include/asm/ranges.h       |  6 ++++
 arch/frv/include/asm/ranges.h        |  6 ++++
 arch/h8300/include/asm/ranges.h      |  6 ++++
 arch/hexagon/include/asm/ranges.h    |  6 ++++
 arch/ia64/include/asm/ranges.h       |  6 ++++
 arch/m32r/include/asm/ranges.h       |  6 ++++
 arch/m68k/include/asm/ranges.h       |  6 ++++
 arch/metag/include/asm/ranges.h      |  6 ++++
 arch/microblaze/include/asm/ranges.h |  6 ++++
 arch/mips/include/asm/ranges.h       |  6 ++++
 arch/mn10300/include/asm/ranges.h    |  6 ++++
 arch/nios2/include/asm/ranges.h      |  6 ++++
 arch/openrisc/include/asm/ranges.h   |  6 ++++
 arch/parisc/include/asm/ranges.h     |  6 ++++
 arch/powerpc/include/asm/ranges.h    |  6 ++++
 arch/s390/include/asm/ranges.h       |  6 ++++
 arch/score/include/asm/ranges.h      |  6 ++++
 arch/sh/include/asm/ranges.h         |  6 ++++
 arch/sparc/include/asm/ranges.h      |  6 ++++
 arch/tile/include/asm/ranges.h       |  6 ++++
 arch/um/include/asm/ranges.h         |  6 ++++
 arch/unicore32/include/asm/ranges.h  |  6 ++++
 arch/x86/include/asm/ranges.h        |  6 ++++
 arch/xtensa/include/asm/ranges.h     |  6 ++++
 include/asm-generic/ranges.h         | 70 ++++++++++++++++++++++++++++++++++++
 include/linux/ranges.h               | 54 ++++++++++++++++++++++++++++
 33 files changed, 310 insertions(+)
 create mode 100644 arch/alpha/include/asm/ranges.h
 create mode 100644 arch/arc/include/asm/ranges.h
 create mode 100644 arch/arm/include/asm/ranges.h
 create mode 100644 arch/arm64/include/asm/ranges.h
 create mode 100644 arch/avr32/include/asm/ranges.h
 create mode 100644 arch/blackfin/include/asm/ranges.h
 create mode 100644 arch/c6x/include/asm/ranges.h
 create mode 100644 arch/cris/include/asm/ranges.h
 create mode 100644 arch/frv/include/asm/ranges.h
 create mode 100644 arch/h8300/include/asm/ranges.h
 create mode 100644 arch/hexagon/include/asm/ranges.h
 create mode 100644 arch/ia64/include/asm/ranges.h
 create mode 100644 arch/m32r/include/asm/ranges.h
 create mode 100644 arch/m68k/include/asm/ranges.h
 create mode 100644 arch/metag/include/asm/ranges.h
 create mode 100644 arch/microblaze/include/asm/ranges.h
 create mode 100644 arch/mips/include/asm/ranges.h
 create mode 100644 arch/mn10300/include/asm/ranges.h
 create mode 100644 arch/nios2/include/asm/ranges.h
 create mode 100644 arch/openrisc/include/asm/ranges.h
 create mode 100644 arch/parisc/include/asm/ranges.h
 create mode 100644 arch/powerpc/include/asm/ranges.h
 create mode 100644 arch/s390/include/asm/ranges.h
 create mode 100644 arch/score/include/asm/ranges.h
 create mode 100644 arch/sh/include/asm/ranges.h
 create mode 100644 arch/sparc/include/asm/ranges.h
 create mode 100644 arch/tile/include/asm/ranges.h
 create mode 100644 arch/um/include/asm/ranges.h
 create mode 100644 arch/unicore32/include/asm/ranges.h
 create mode 100644 arch/x86/include/asm/ranges.h
 create mode 100644 arch/xtensa/include/asm/ranges.h
 create mode 100644 include/asm-generic/ranges.h
 create mode 100644 include/linux/ranges.h

diff --git a/arch/alpha/include/asm/ranges.h b/arch/alpha/include/asm/ranges.h
new file mode 100644
index 000000000000..b7bc4107bc75
--- /dev/null
+++ b/arch/alpha/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ALPHA_RANGES_H
+#define _ASM_ALPHA_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_ALPHA_RANGES_H */
diff --git a/arch/arc/include/asm/ranges.h b/arch/arc/include/asm/ranges.h
new file mode 100644
index 000000000000..a761243bf79f
--- /dev/null
+++ b/arch/arc/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ARC_RANGES_H
+#define _ASM_ARC_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_ARC_RANGES_H */
diff --git a/arch/arm/include/asm/ranges.h b/arch/arm/include/asm/ranges.h
new file mode 100644
index 000000000000..fb059e205f90
--- /dev/null
+++ b/arch/arm/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ARM_RANGES_H
+#define _ASM_ARM_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_ARM_RANGES_H */
diff --git a/arch/arm64/include/asm/ranges.h b/arch/arm64/include/asm/ranges.h
new file mode 100644
index 000000000000..0e0b52cc8d41
--- /dev/null
+++ b/arch/arm64/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ARM64_RANGES_H
+#define _ASM_ARM64_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_ARM64_RANGES_H */
diff --git a/arch/avr32/include/asm/ranges.h b/arch/avr32/include/asm/ranges.h
new file mode 100644
index 000000000000..0f50a1af03e1
--- /dev/null
+++ b/arch/avr32/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_AVR32_RANGES_H
+#define _ASM_AVR32_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_AVR32_RANGES_H */
diff --git a/arch/blackfin/include/asm/ranges.h b/arch/blackfin/include/asm/ranges.h
new file mode 100644
index 000000000000..e1d133639a45
--- /dev/null
+++ b/arch/blackfin/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_BLACKFIN_RANGES_H
+#define _ASM_BLACKFIN_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_BLACKFIN_RANGES_H */
diff --git a/arch/c6x/include/asm/ranges.h b/arch/c6x/include/asm/ranges.h
new file mode 100644
index 000000000000..0e8e6e149d55
--- /dev/null
+++ b/arch/c6x/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_C6X_RANGES_H
+#define _ASM_C6X_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_C6X_RANGES_H */
diff --git a/arch/cris/include/asm/ranges.h b/arch/cris/include/asm/ranges.h
new file mode 100644
index 000000000000..8567f55ae4ea
--- /dev/null
+++ b/arch/cris/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_CRIS_RANGES_H
+#define _ASM_CRIS_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_CRIS_RANGES_H */
diff --git a/arch/frv/include/asm/ranges.h b/arch/frv/include/asm/ranges.h
new file mode 100644
index 000000000000..f11a6f0fb0bd
--- /dev/null
+++ b/arch/frv/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_FRV_RANGES_H
+#define _ASM_FRV_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_FRV_RANGES_H */
diff --git a/arch/h8300/include/asm/ranges.h b/arch/h8300/include/asm/ranges.h
new file mode 100644
index 000000000000..ab08bd6bd067
--- /dev/null
+++ b/arch/h8300/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_H8300_RANGES_H
+#define _ASM_H8300_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_H8300_RANGES_H */
diff --git a/arch/hexagon/include/asm/ranges.h b/arch/hexagon/include/asm/ranges.h
new file mode 100644
index 000000000000..56e5241abc6b
--- /dev/null
+++ b/arch/hexagon/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_HEXAGON_RANGES_H
+#define _ASM_HEXAGON_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_HEXAGON_RANGES_H */
diff --git a/arch/ia64/include/asm/ranges.h b/arch/ia64/include/asm/ranges.h
new file mode 100644
index 000000000000..4e69cbcfd0e7
--- /dev/null
+++ b/arch/ia64/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_IA64_RANGES_H
+#define _ASM_IA64_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_IA64_RANGES_H */
diff --git a/arch/m32r/include/asm/ranges.h b/arch/m32r/include/asm/ranges.h
new file mode 100644
index 000000000000..dd33a0b94de4
--- /dev/null
+++ b/arch/m32r/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_M32R_RANGES_H
+#define _ASM_M32R_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_M32R_RANGES_H */
diff --git a/arch/m68k/include/asm/ranges.h b/arch/m68k/include/asm/ranges.h
new file mode 100644
index 000000000000..292a00baa73e
--- /dev/null
+++ b/arch/m68k/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_M68K_RANGES_H
+#define _ASM_M68K_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_M68K_RANGES_H */
diff --git a/arch/metag/include/asm/ranges.h b/arch/metag/include/asm/ranges.h
new file mode 100644
index 000000000000..42a77c098c85
--- /dev/null
+++ b/arch/metag/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_METAG_RANGES_H
+#define _ASM_METAG_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_METAG_RANGES_H */
diff --git a/arch/microblaze/include/asm/ranges.h b/arch/microblaze/include/asm/ranges.h
new file mode 100644
index 000000000000..48d58e38f1e1
--- /dev/null
+++ b/arch/microblaze/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MICROBLAZE_RANGES_H
+#define _ASM_MICROBLAZE_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_MICROBLAZE_RANGES_H */
diff --git a/arch/mips/include/asm/ranges.h b/arch/mips/include/asm/ranges.h
new file mode 100644
index 000000000000..675a55cd3719
--- /dev/null
+++ b/arch/mips/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MIPS_RANGES_H
+#define _ASM_MIPS_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_MIPS_RANGES_H */
diff --git a/arch/mn10300/include/asm/ranges.h b/arch/mn10300/include/asm/ranges.h
new file mode 100644
index 000000000000..fb7f43a3c19d
--- /dev/null
+++ b/arch/mn10300/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MN10300_RANGES_H
+#define _ASM_MN10300_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_MN10300_RANGES_H */
diff --git a/arch/nios2/include/asm/ranges.h b/arch/nios2/include/asm/ranges.h
new file mode 100644
index 000000000000..ab1991981c0f
--- /dev/null
+++ b/arch/nios2/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_NIOS2_RANGES_H
+#define _ASM_NIOS2_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_NIOS2_RANGES_H */
diff --git a/arch/openrisc/include/asm/ranges.h b/arch/openrisc/include/asm/ranges.h
new file mode 100644
index 000000000000..a64be842983f
--- /dev/null
+++ b/arch/openrisc/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_OPENRISC_RANGES_H
+#define _ASM_OPENRISC_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_OPENRISC_RANGES_H */
diff --git a/arch/parisc/include/asm/ranges.h b/arch/parisc/include/asm/ranges.h
new file mode 100644
index 000000000000..dd6b5c215941
--- /dev/null
+++ b/arch/parisc/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_PARISC_RANGES_H
+#define _ASM_PARISC_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_PARISC_RANGES_H */
diff --git a/arch/powerpc/include/asm/ranges.h b/arch/powerpc/include/asm/ranges.h
new file mode 100644
index 000000000000..240c51a210d4
--- /dev/null
+++ b/arch/powerpc/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_POWERPC_RANGES_H
+#define _ASM_POWERPC_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_POWERPC_RANGES_H */
diff --git a/arch/s390/include/asm/ranges.h b/arch/s390/include/asm/ranges.h
new file mode 100644
index 000000000000..d4788451f176
--- /dev/null
+++ b/arch/s390/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_S390_RANGES_H
+#define _ASM_S390_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_S390_RANGES_H */
diff --git a/arch/score/include/asm/ranges.h b/arch/score/include/asm/ranges.h
new file mode 100644
index 000000000000..d67f859eeda3
--- /dev/null
+++ b/arch/score/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SCORE_RANGES_H
+#define _ASM_SCORE_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_SCORE_RANGES_H */
diff --git a/arch/sh/include/asm/ranges.h b/arch/sh/include/asm/ranges.h
new file mode 100644
index 000000000000..99df0b65f40a
--- /dev/null
+++ b/arch/sh/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SH_RANGES_H
+#define _ASM_SH_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_SH_RANGES_H */
diff --git a/arch/sparc/include/asm/ranges.h b/arch/sparc/include/asm/ranges.h
new file mode 100644
index 000000000000..8ff4765ccd9b
--- /dev/null
+++ b/arch/sparc/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SPARC_RANGES_H
+#define _ASM_SPARC_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_SPARC_RANGES_H */
diff --git a/arch/tile/include/asm/ranges.h b/arch/tile/include/asm/ranges.h
new file mode 100644
index 000000000000..ceda3fb075e0
--- /dev/null
+++ b/arch/tile/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_TILE_RANGES_H
+#define _ASM_TILE_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_TILE_RANGES_H */
diff --git a/arch/um/include/asm/ranges.h b/arch/um/include/asm/ranges.h
new file mode 100644
index 000000000000..7c9c20e47879
--- /dev/null
+++ b/arch/um/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_UM_RANGES_H
+#define _ASM_UM_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_UM_RANGES_H */
diff --git a/arch/unicore32/include/asm/ranges.h b/arch/unicore32/include/asm/ranges.h
new file mode 100644
index 000000000000..92526340d73c
--- /dev/null
+++ b/arch/unicore32/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_UNICORE32_RANGES_H
+#define _ASM_UNICORE32_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_UNICORE32_RANGES_H */
diff --git a/arch/x86/include/asm/ranges.h b/arch/x86/include/asm/ranges.h
new file mode 100644
index 000000000000..4a0c824d4082
--- /dev/null
+++ b/arch/x86/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_X86_RANGES_H
+#define _ASM_X86_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_X86_RANGES_H */
diff --git a/arch/xtensa/include/asm/ranges.h b/arch/xtensa/include/asm/ranges.h
new file mode 100644
index 000000000000..c7360d1c9c85
--- /dev/null
+++ b/arch/xtensa/include/asm/ranges.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_XTENSA_RANGES_H
+#define _ASM_XTENSA_RANGES_H
+
+#include <asm-generic/ranges.h>
+
+#endif /* _ASM_XTENSA_RANGES_H */
diff --git a/include/asm-generic/ranges.h b/include/asm-generic/ranges.h
new file mode 100644
index 000000000000..0d54c632f714
--- /dev/null
+++ b/include/asm-generic/ranges.h
@@ -0,0 +1,70 @@
+#ifndef _ASM_GENERIC_RANGES_H_
+#define _ASM_GENERIC_RANGES_H_
+/*
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+#ifdef __KERNEL__
+# include <asm/sections.h>
+#endif /* __KERNEL__ */
+
+#define SECTION_TYPE_RANGES	rng
+
+#define SECTION_RNG(section, name)					\
+	SECTION_TYPE(section, SECTION_TYPE_RANGES, name,		\
+		     SECTION_ORDER_ANY)
+
+#define SECTION_RNG_LEVEL(section, name, level)				\
+	SECTION_TYPE(section, SECTION_TYPE_RANGES, name, level)
+
+#define SECTION_RANGE_ALL(section)					\
+	SECTION_TYPE_ALL(section,SECTION_TYPE_RANGES)
+
+#ifndef section_rng
+# define section_rng(section, name, flags)				\
+	 section_type(section, SECTION_TYPE_RANGES, name,		\
+		      SECTION_ORDER_ANY, flags)
+#endif
+
+#ifndef section_rng_asmtype
+# define section_rng_asmtype(section, name, flags, asmtype)		\
+	 section_type_asmtype(section, SECTION_TYPE_RANGES, name,	\
+			      SECTION_ORDER_ANY, flags, asmtype)
+#endif
+
+#ifndef section_rng_level
+# define section_rng_level(section, name, level, flags)			\
+	 section_type(section, SECTION_TYPE_RANGES, name, level, flags)
+#endif
+
+#ifndef push_section_rng
+# define push_section_rng(section, name, flags)				\
+	 push_section_type(section, SECTION_TYPE_RANGES, name,		\
+			  SECTION_ORDER_ANY, flags)
+#endif
+
+#ifndef push_section_rng_level
+# define push_section_rng_level(section, name, level, flags)		\
+	 push_section_type(section, SECTION_TYPE_RANGES, name,		\
+			  level, flags)
+#endif
+
+#if defined(__ASSEMBLER__) || defined(__ASSEMBLY__)
+
+# ifndef DECLARE_SECTION_RANGE
+#  define DECLARE_SECTION_RANGE(section, name)				\
+    push_section_rng_level(section, name,,) ;				\
+  .globl name ;								\
+name: ;									\
+  .popsection								\
+									\
+  push_section_rng_level(section, name, ~,) ;				\
+  .popsection
+# endif
+
+#endif /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
+
+#endif /* _ASM_GENERIC_RANGES_H_ */
diff --git a/include/linux/ranges.h b/include/linux/ranges.h
new file mode 100644
index 000000000000..1146c7225096
--- /dev/null
+++ b/include/linux/ranges.h
@@ -0,0 +1,54 @@
+#ifndef _LINUX_RANGES_H
+#define _LINUX_RANGES_H
+/*
+ * Linux section ranges
+ *
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+#ifdef __KERNEL__
+#include <linux/sections.h>
+# include <asm/ranges.h>
+#endif /* __KERNEL__ */
+
+#ifndef __ASSEMBLY__
+
+#define SECTION_ADDR_IN_RANGE(name, addr)				\
+	 (addr >= (unsigned long) LINUX_SECTION_START(name) &&		\
+          addr <  (unsigned long) LINUX_SECTION_END(name))
+
+#define DECLARE_SECTION_RANGE(name)					\
+	DECLARE_LINUX_SECTION_RO(char, name)
+
+#define SECTION_RANGE_BEGIN(name, __section)				\
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_RNG_LEVEL(__section, name, ))))
+
+#define SECTION_RANGE_END(name, __section)				\
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_RNG_LEVEL(__section, name, ~))))
+
+#define DEFINE_SECTION_RANGE(name, section)				\
+	DECLARE_LINUX_SECTION_RO(char, name);				\
+	SECTION_RANGE_BEGIN(name, section) VMLINUX_SYMBOL(name)[0] = {};\
+	SECTION_RANGE_END(name, section) VMLINUX_SYMBOL(name##__end)[0] = {};
+
+#define __LINUX_RANGE(section, name)					\
+	__attribute__((__aligned__(LINUX_SECTION_ALIGNMENT(name)),	\
+		       __section__(SECTION_RNG(section, name))))
+
+#define __LINUX_RANGE_ORDER(section, name, level)			\
+	__attribute__((__aligned__(LINUX_SECTION_ALIGNMENT(name)),	\
+		       __section__(SECTION_RNG_LEVEL(section, name, level))))
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _LINUX_RANGES_H */
-- 
2.8.4

