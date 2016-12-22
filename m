From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 22 Dec 2016 02:38:00 +0000
Subject: [PATCH v5 04/14] tables.h: add linker table support
Message-Id: <20161222023811.21246-5-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <20161222023811.21246-1-mcgrof@kernel.org>
In-Reply-To: <20161222023811.21246-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

A linker table is a data structure that is stitched together from items
in multiple object files. Linux has historically implicitly used linker
tables for ages, however they were all built in an adhoc manner which
requires linker script modifications, per architecture. This adds a
general linker table solution so that a new linker table can be
implemented by changing C code only. The Linux linker table was
inspired by Michael Brown's iPXE's linker table solution, it has been
been completely re-written and adapted for integration and use on Linux.

The same philosophy is borrowed, extended and further simplified:

Linker tables enable an extremely light weight linker build time
solution for feature ordering and selection, this can help to both
simplify init sequences in a generic fashion and helps avoiding code
bit-rotting when desirable. Further changes will be added later
which will make more evident how code bit rot can be avoided using
linker tables.

v5:
o Use ..tbl.* instead of .tbl.* as suggested by Nicholas Piggin.
  This is the typical way to avoid clashes with compiler generated
  sections.
o Replace section macros with section names
o Dropped SECTION_RNG_ALL()
o Fix documentation typos
o To make this easier to read, as per Nicholas Piggin, add our own
  LINKTABLE_START(), LINKTABLE_END(). After reviewing the changes
  affected by this it seemed clearer and better then to also
  use our own specific LINKTABLE_SIZE(), LINKTABLE_EMPTY() and
  LINKTABLE_ALIGNMENT() as well.
o Clarifies SECTION_TBL_RO needs to be kept since some toolchains
  are buggy, and so we also add SECTION_TBL_RO_STR.
o We were using LINUX_SECTION_START() and LINUX_SECTION_END() in some places
  but in some other places VMLINUX_SYMBOL(name), VMLINUX_SYMBOL(name##__end).
  Since we are adding LINKTABLE_START() and LINKTABLE_END() just use those
  consistently.
o Fix DEFINE_LINKTABLE_INIT() by making it use DECLARE_LINKTABLE_RO()
  which forces const.
o Fix powerpc .text use: it does not use TEXT_TEXT so we must
  add our *(SORT(.text.tbl.*)) to its linker script manually.

v4:

o Split out kbuild additions to help with code bit rot into
  its own patch
o tons of documentation love
o fix arch/x86/tools/relocs.c typo - which caused compilation issues
  on old toolchains
o add c6x toolchain work around as discussed with Mark Salter
o sprinkle a few more needed VMLINUX_SYMBOL() - fixes
  compilation on blackfin
o suggested name changes by boris:
- %s/SECTION_TYPE_RANGES/rng/g
- %s/SECTION_TYPE/SECTION_CORE/g
- %s/section_type_asmtype/section_core_type/g
- %s/section_type/section_core/g
- %s/section_rng/set_section_rng/g
- Drop DECLARE_SECTION_TBL() -- this is an asm equivalent
  DEFINE_LINKTABLE() -- this however is not used yet, and it requires
  a bit more work to match the C code definitions.
o drop tools/include/linux/sections.h in favor of the more popular open
  coding the names for tools
o expand documentation to include module support
o add maintaners
o Use generic-y
o move .text.tbl before unlikely to match the other sections

v3:

o addressed initial modular support test cases
o added generic asm macros so linker tables can be used in
  asm code / C asm calls
o section ranges are now split up into their own set of files
o use asm/sections.h instead of linux/sections.h for the linker
  script
o add a sections.h file for each architecture that was missing one,
  this is needed now as we'll be relying on sections.h for custom
  section types in code rather than custom architecture specific
  linker script hacks.
o full rewrite at this point, decided to pick copyleft-next license
  for this work

v2:

o modified completely to match feedback by community, made equivalent
  modifications to userspace solution. This is pretty much a complete
  rewrite of how we present and use linker tables. By using standard
  sections we no longer have to make custom linker script extensions
  for each new linker table solution, you just pick a linker table
  type by section type.
o extend documention considerably, including use of kdoc
o drop ICC hacks per popular request to ignore such issues for now
o use sections.h - this lets us streamline a clean use case of
  well documented sections. To help further with this make use of
  SECTION_TBL() to allow use of these in code and SECTION_TBL_ALL()
  on linker scripts, as well as SECTION_TBL_ALL_STR() on relocs.c
  when needed.

Cc: Michael Brown <mcb30@ipxe.org>
Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 Documentation/sections/index.rst         |   1 +
 Documentation/sections/linker-tables.rst | 212 +++++++++++
 MAINTAINERS                              |  10 +
 arch/alpha/include/asm/Kbuild            |   1 +
 arch/arc/include/asm/Kbuild              |   1 +
 arch/arm/include/asm/Kbuild              |   1 +
 arch/arm64/include/asm/Kbuild            |   1 +
 arch/avr32/include/asm/Kbuild            |   1 +
 arch/blackfin/include/asm/Kbuild         |   1 +
 arch/c6x/include/asm/tables.h            |  26 ++
 arch/cris/include/asm/Kbuild             |   1 +
 arch/frv/include/asm/Kbuild              |   1 +
 arch/h8300/include/asm/Kbuild            |   1 +
 arch/hexagon/include/asm/Kbuild          |   1 +
 arch/ia64/include/asm/Kbuild             |   1 +
 arch/m32r/include/asm/Kbuild             |   1 +
 arch/m68k/include/asm/Kbuild             |   1 +
 arch/metag/include/asm/Kbuild            |   1 +
 arch/microblaze/include/asm/Kbuild       |   1 +
 arch/mips/include/asm/Kbuild             |   1 +
 arch/mn10300/include/asm/Kbuild          |   1 +
 arch/nios2/include/asm/Kbuild            |   1 +
 arch/openrisc/include/asm/Kbuild         |   1 +
 arch/parisc/include/asm/Kbuild           |   1 +
 arch/powerpc/include/asm/Kbuild          |   1 +
 arch/powerpc/kernel/vmlinux.lds.S        |   1 +
 arch/s390/include/asm/Kbuild             |   1 +
 arch/score/include/asm/Kbuild            |   1 +
 arch/sh/include/asm/Kbuild               |   1 +
 arch/sparc/include/asm/Kbuild            |   1 +
 arch/tile/include/asm/Kbuild             |   1 +
 arch/um/include/asm/Kbuild               |   1 +
 arch/unicore32/include/asm/Kbuild        |   1 +
 arch/x86/include/asm/Kbuild              |   1 +
 arch/x86/tools/relocs.c                  |   2 +
 arch/xtensa/include/asm/Kbuild           |   1 +
 include/asm-generic/tables.h             |  48 +++
 include/asm-generic/vmlinux.lds.h        |   6 +
 include/linux/tables.h                   | 612 +++++++++++++++++++++++++++++++
 39 files changed, 948 insertions(+)
 create mode 100644 Documentation/sections/linker-tables.rst
 create mode 100644 arch/c6x/include/asm/tables.h
 create mode 100644 include/asm-generic/tables.h
 create mode 100644 include/linux/tables.h

diff --git a/Documentation/sections/index.rst b/Documentation/sections/index.rst
index 4a1df389fa91..7c7c1adf955c 100644
--- a/Documentation/sections/index.rst
+++ b/Documentation/sections/index.rst
@@ -16,3 +16,4 @@ common a set of Linux helpers for ELF sections are also documented.
    background
    section-core
    ranges
+   linker-tables
diff --git a/Documentation/sections/linker-tables.rst b/Documentation/sections/linker-tables.rst
new file mode 100644
index 000000000000..71704159e90e
--- /dev/null
+++ b/Documentation/sections/linker-tables.rst
@@ -0,0 +1,212 @@
+=========+Linux linker tables
+=========+
+This documents Linux linker tables, it explains what they are, where they
+came from, how they work, the benefits of using them and more importantly
+how you can use them.
+
+About Linker tables
+=========+.. kernel-doc:: include/linux/tables.h
+   :doc: Introduction
+
+Linker table provenance
+---------------------------------------------
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Linker table provenance
+
+Benefits of using Linker tables
+===============+
+Avoids modifying architecture linker scripts
+----------------------------------------------
+.. kernel-doc:: include/linux/tables.h
+   :doc: Avoids modifying architecture linker scripts
+
+How linker tables simplify initialization code
+----------------------------------------------
+.. kernel-doc:: include/linux/tables.h
+   :doc: How linker tables simplify initialization code
+
+Using linker tables in Linux
+==============
+
+Linker table module support
+---------------------------
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Linker table module support
+
+Linker table helpers
+==========
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Linker table helpers
+
+LINKTABLE_START
+---------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_START
+
+LINKTABLE_END
+-------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_END
+
+LINKTABLE_SIZE
+--------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_SIZE
+
+LINKTABLE_EMPTY
+---------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_EMPTY
+
+LINKTABLE_ADDR_WITHIN
+---------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_ADDR_WITHIN
+
+LINKTABLE_ALIGNMENT
+-------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_ALIGNMENT
+
+Constructing linker tables
+=============
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Constructing linker tables
+
+Weak linker tables constructors
+-------------------------------
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Weak linker tables constructors
+
+LINKTABLE_WEAK
+--------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_WEAK
+
+LINKTABLE_TEXT_WEAK
+-------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_TEXT_WEAK
+
+LINKTABLE_RO_WEAK
+-----------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_RO_WEAK
+
+LINKTABLE_INIT_WEAK
+-------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_INIT_WEAK
+
+LINKTABLE_INIT_DATA_WEAK
+------------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_INIT_DATA_WEAK
+
+Regular linker linker table constructors
+----------------------------------------
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Regular linker linker table constructors
+
+LINKTABLE
+---------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE
+
+LINKTABLE_TEXT
+--------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_TEXT
+
+LINKTABLE_RO
+------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_RO
+
+LINKTABLE_INIT
+--------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_INIT
+
+LINKTABLE_INIT_DATA
+-------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_INIT_DATA
+
+Declaring Linker tables
+===========+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Declaring Linker tables
+
+DECLARE_LINKTABLE
+----------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: DECLARE_LINKTABLE
+
+DECLARE_LINKTABLE_RO
+--------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: DECLARE_LINKTABLE_RO
+
+Defining Linker tables
+===========
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Defining Linker tables
+
+DEFINE_LINKTABLE
+----------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: DEFINE_LINKTABLE
+
+DEFINE_LINKTABLE_TEXT
+---------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: DEFINE_LINKTABLE_TEXT
+
+DEFINE_LINKTABLE_RO
+-------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: DEFINE_LINKTABLE_RO
+
+DEFINE_LINKTABLE_INIT
+---------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: DEFINE_LINKTABLE_INIT
+
+DEFINE_LINKTABLE_INIT_DATA
+--------------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: DEFINE_LINKTABLE_INIT_DATA
+
+Iterating over Linker tables
+==============
+
+.. kernel-doc:: include/linux/tables.h
+   :doc: Iterating over Linker tables
+
+LINKTABLE_FOR_EACH
+------------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_FOR_EACH
+
+LINKTABLE_RUN_ALL
+-----------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_RUN_ALL
+
+LINKTABLE_RUN_ERR
+-----------------
+.. kernel-doc:: include/linux/tables.h
+   :functions: LINKTABLE_RUN_ERR
diff --git a/MAINTAINERS b/MAINTAINERS
index 93bebccad674..c57ba50e2348 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5405,6 +5405,16 @@ S:	Maintained
 F:	include/asm-generic/
 F:	include/uapi/asm-generic/
 
+GENERIC LINKER TABLES
+M:	"Luis R. Rodriguez" <mcgrof@kernel.org>
+M:	"H. Peter Anvin" <hpa@zytor.com>
+L:	linux-arch@vger.kernel.org
+L:	linux-kernel@vger.kernel.org
+S:	Supported
+F:	include/asm-generic/tables.h
+F:	include/linux/tables.h
+F:	Documentation/sections/linker-tables.rst
+
 GENERIC PHY FRAMEWORK
 M:	Kishon Vijay Abraham I <kishon@ti.com>
 L:	linux-kernel@vger.kernel.org
diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index e44c896b91c4..f3bdc31d3c97 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -12,3 +12,4 @@ generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index a374b7f83888..ccfa69ce2608 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -53,3 +53,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 0d47f98ccbc0..b70d4b78d577 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -43,3 +43,4 @@ generated-y += mach-types.h
 generated-y += unistd-nr.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index e9939cbd9067..0c1e781ab10b 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -47,3 +47,4 @@ generic-y += vga.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index edc176348d7c..a6cd145515ae 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -24,3 +24,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index 3428415b1996..9115b215fc7e 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -49,3 +49,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/c6x/include/asm/tables.h b/arch/c6x/include/asm/tables.h
new file mode 100644
index 000000000000..90a0d3df35c8
--- /dev/null
+++ b/arch/c6x/include/asm/tables.h
@@ -0,0 +1,26 @@
+#ifndef _ASM_C6X_ASM_TABLES_H
+#define _ASM_C6X_ASM_TABLES_H
+/*
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+
+/*
+ * The c6x toolchain has a bug present even on gcc-6 when non-weak attributes
+ * are used and sends them to .rodata even though const data with weak
+ * attributes are put in .const, this forces the linker to believe the address
+ * is relative relative to the a base + offset and you end up with SB-relative
+ * reloc error upon linking. Work around this by by forcing both start and
+ * ending const RO weak linker table entry to be .const to fix this for now.
+ *
+ * [0] https://lkml.kernel.org/r/1470798247.3551.94.camel@redhat.com
+ */
+
+#define SECTION_TBL_RO		.const
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_C6X_ASM_TABLES_H */
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index fb8bb4112773..7062c1be7913 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -47,3 +47,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 5191fec655d7..4a59cbda5091 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -10,3 +10,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 7929a992566c..d79968d93c12 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -77,3 +77,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index af17ee334788..d59ac1c1858b 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -62,3 +62,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index d8f226b35a0a..76540f143473 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += vtime.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 1c6504d29312..24088f3c733c 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -13,3 +13,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index 006e2863ad37..c28bcdecc764 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -36,3 +36,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 4a8471434a3e..c836f7e2a5e7 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -57,3 +57,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index 63c083a1f8da..01afb1b420f5 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -13,3 +13,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 288e21b64170..579f494914f5 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -22,3 +22,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 656af7b69940..6c8d12f3fe44 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -12,3 +12,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index c55880659d67..ee6220dac1e8 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -65,3 +65,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 7d6a704b808c..ceafe458e295 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -73,3 +73,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index f11d1249738f..aaae8a9f6099 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -30,3 +30,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 60d8349241a7..7c06627a0a0d 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -10,3 +10,4 @@ generic-y += rwsem.h
 generic-y += vtime.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
index fcfc9d102348..8cd940c72895 100644
--- a/arch/powerpc/kernel/vmlinux.lds.S
+++ b/arch/powerpc/kernel/vmlinux.lds.S
@@ -108,6 +108,7 @@ SECTIONS
 		/* careful! __ftr_alt_* sections need to be close to .text */
 		*(.text .fixup __ftr_alt_* .ref.text)
 		*(SORT(.text.rng.*))
+		*(SORT(.text..tbl.*))
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index c1b85a361e5d..96dd69931427 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -10,3 +10,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index f0cdb2cbca4d..16ea15a3e432 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -16,3 +16,4 @@ generic-y += serial.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index c9bb7932a3d1..d0ea768d15ae 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -41,3 +41,4 @@ generic-y += ucontext.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index 28280887ac79..23a2216f4146 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -23,3 +23,4 @@ generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index 33f7069763ae..a599f6f4ee0a 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -42,3 +42,4 @@ generic-y += types.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index b952dcb3e216..d2867aa09e23 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -28,3 +28,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 93abbfdab543..6671a1f08ead 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -62,3 +62,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index f672f2fc181d..4cb511f1067c 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -14,3 +14,4 @@ generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/arch/x86/tools/relocs.c b/arch/x86/tools/relocs.c
index f96fa2ddf7c9..484a24c309fb 100644
--- a/arch/x86/tools/relocs.c
+++ b/arch/x86/tools/relocs.c
@@ -69,7 +69,9 @@ static const char * const sym_regex_kernel[S_NSYMTYPES] = {
 	"__initramfs_start|"
 	"(jiffies|jiffies_64)|"
 	".rodata..rng.*|"
+	".rodata..tbl.*|"
 	".init.text..rng.*|"
+	".init.text..tbl.*|"
 #if ELF_BITS = 64
 	"__per_cpu_load|"
 	"init_per_cpu__.*|"
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 2b7fe48c0225..7b41f32a2ba0 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -34,3 +34,4 @@ generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
 generic-y += ranges.h
+generic-y += tables.h
diff --git a/include/asm-generic/tables.h b/include/asm-generic/tables.h
new file mode 100644
index 000000000000..16ef40d145fb
--- /dev/null
+++ b/include/asm-generic/tables.h
@@ -0,0 +1,48 @@
+#ifndef _ASM_GENERIC_TABLES_H_
+#define _ASM_GENERIC_TABLES_H_
+/*
+ * Linux linker tables
+ *
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+#include <asm/section-core.h>
+
+#define SECTION_TBL(section, name, level)	section..tbl.name.level
+
+/* Some toolchains are buggy, let them override */
+#ifndef SECTION_TBL_RO
+# define SECTION_TBL_RO	.rodata
+#endif
+
+#define SECTION_TBL_RO_STR __stringify(SECTION_TBL_RO)
+
+#ifndef set_section_tbl
+# define set_section_tbl(section, name, level, flags)			\
+	 set_section_core(section, tbl, name, level, flags)
+#endif
+
+#ifndef set_section_tbl_any
+# define set_section_tbl_any(section, name, flags)				\
+	 set_section_core(section, tbl, name, any, flags)
+#endif
+
+#ifndef set_section_tbl_type
+# define set_section_tbl_type(section, name, level, flags, type)		\
+	 set_section_core_type(section, tbl, name, level, flags, type)
+#endif
+
+#ifndef push_section_tbl
+# define push_section_tbl(section, name, level, flags)			\
+	 push_section_core(section, tbl, name, level, flags)
+#endif
+
+#ifndef push_section_tbl_any
+# define push_section_tbl_any(section, name, flags)			\
+	 push_section_core(section, tbl, name, any, flags)
+#endif
+
+#endif /* _ASM_GENERIC_TABLES_H_ */
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 71bfd3b3c719..ce1e9a310ada 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -57,6 +57,7 @@
 #include <linux/export.h>
 #include <asm/section-core.h>
 #include <asm/ranges.h>
+#include <asm/tables.h>
 
 /* Align . to a 8 byte boundary equals to maximum function alignment. */
 #define ALIGN_FUNCTION()  . = ALIGN(8)
@@ -207,6 +208,7 @@
 #define DATA_DATA							\
 	*(.data .data.[0-9a-zA-Z_]*)					\
 	*(SORT(.data..rng.*))						\
+	*(SORT(.data..tbl.*))						\
 	*(.ref.data)							\
 	*(.data..shared_aligned) /* percpu related */			\
 	MEM_KEEP(init.data)						\
@@ -277,6 +279,7 @@
 		VMLINUX_SYMBOL(__start_rodata) = .;			\
 		*(.rodata)						\
 		*(SORT(.rodata..rng.*))					\
+		*(SORT(.rodata..tbl.*))					\
 		*(.rodata.*)						\
 		RO_AFTER_INIT_DATA	/* Read only after init */	\
 		KEEP(*(__vermagic))	/* Kernel version magic */	\
@@ -452,6 +455,7 @@
 		ALIGN_FUNCTION();					\
 		*(.text.hot .text)					\
 		*(SORT(.text..rng.*))					\
+		*(SORT(.text..tbl.*))					\
 		*(.text.fixup .text.unlikely)				\
 		*(.ref.text)						\
 	MEM_KEEP(init.text)						\
@@ -556,6 +560,7 @@
 	KEEP(*(SORT(___kentry+*)))					\
 	*(.init.data)							\
 	*(SORT(.init.data..rng.*))					\
+	*(SORT(.init.data..tbl.*))					\
 	MEM_DISCARD(init.data)						\
 	KERNEL_CTORS()							\
 	MCOUNT_REC()							\
@@ -580,6 +585,7 @@
 #define INIT_TEXT							\
 	*(.init.text)							\
 	*(SORT(.init.text..rng.*))					\
+	*(SORT(.init.text..tbl.*))					\
 	*(.text.startup)						\
 	MEM_DISCARD(init.text)
 
diff --git a/include/linux/tables.h b/include/linux/tables.h
new file mode 100644
index 000000000000..cc8fb1dcee47
--- /dev/null
+++ b/include/linux/tables.h
@@ -0,0 +1,612 @@
+#ifndef _LINUX_LINKER_TABLES_H
+#define _LINUX_LINKER_TABLES_H
+/*
+ * Linux linker tables
+ *
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+#include <linux/export.h>
+#include <linux/sections.h>
+#include <asm/tables.h>
+
+#ifndef __ASSEMBLY__
+
+/**
+ * DOC: Introduction
+ *
+ * A linker table is a data structure that is stitched together from items in
+ * multiple object files for the purpose of selective placement into standard
+ * or architecture specific ELF sections. What section is used is utility
+ * specific. Linux has historically implicitly used linker tables, however they
+ * were all built in an adhoc manner which requires linker script modifications
+ * per architecture. The linker table API provides a general facility so that
+ * data structures can be stitched together and placed into Linux ELF sections
+ * by only changing C or asm code in an architecture agnostic form.
+ *
+ * Linker tables help you group together related data and code in an efficient
+ * way. Linker tables can be used to help simplify init sequences, they
+ * enable linker build time selective sorting (disabled options get ignored),
+ * and can optionally also be used to help you avoid code bit-rot due to
+ * overuse of #ifdef.
+ */
+
+/**
+ * DOC: Linker table provenance
+ *
+ * The Linux implementation of linker tables was inspired by the iPXE linker
+ * table's solution (iPXE commit 67a10ef000cb7 "[contrib] Add rom-o-matic to
+ * contrib "[0]).  To see how this code evolved refer to the out of tree
+ * userspace linker-table tree [1].
+ *
+ * Contrary to iPXE's solution which strives to force compilation of
+ * everything using linker tables, Linux's solution allows for developers to be
+ * selective over where one wishes to force compilation, this then is just an
+ * optional feature for the Linux linker table solution. The main advantages
+ * of using linker-tables then are:
+ *
+ *  - Avoiding modifying architecture linker scripts
+ *  - Simplifying initialization code
+ *  - Avoiding the code bit-rot problem
+ *
+ * [0] git://git.ipxe.org/ipxe.git
+ *
+ * [1] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linker-tables.git/
+ */
+
+/**
+ * DOC: Avoids modifying architecture linker scripts
+ *
+ * Linker tables enable you to avoid modifying architecture linker scripts
+ * since it has its has extended each core Linux section with a respective
+ * linker table entry in `include/asm-generic/vmlinux.lds.h`. When you add new
+ * linker table entry you aggregate them `into` the existing linker table core
+ * section.
+ */
+
+/**
+ * DOC: How linker tables simplify initialization code
+ *
+ * Traditionally, we would implement features in C code as follows:
+ *
+ *  foo_init();
+ *
+ * You'd then have a foo.h which would have::
+ *
+ *  #ifndef CONFIG_FOO
+ *  static inline void foo_init(void) { }
+ *  #endif
+ *
+ * With linker tables this is no longer necessary as your init routines would
+ * be implicit, you'd instead call:
+ *
+ *  call_init_fns();
+ *
+ * call_init_fns() would call all functions present in your init table and if
+ * and only if foo.o gets linked in, then its initialisation function will be
+ * called.
+ *
+ * The linker script takes care of assembling the tables for us. All of our
+ * table sections have names of the format `SECTION_NAME..tbl.NAME.N`. Here
+ * `SECTION_NAME` is one of the standard sections in::
+ *
+ *   include/asm-generic/section-core.h
+ *
+ * and `NAME` designates the specific use case for the linker table, the table.
+ * `N` is a digit used to help sort entries in the section. `N=` (empty string)
+ * is reserved for the symbol indicating `table start`, and `N=~` is reserved
+ * for the symbol indicating `table end`. In order for the call_init_fns() to
+ * work behind the scenes the custom linker script would need to define the
+ * beginning of the table, the end of the table, and in between it should use
+ * ``SORT()`` to give order to the section. Typically this would require custom
+ * linker script modifications however since linker table are already defined
+ * in ``include/asm-generic/vmlinux.lds.h`` as documented above each new linker
+ * table definition added in C code folds into the respective core Linux
+ * section linker table.
+ *
+ * This is also done to support all architectures.  All that is needed then is
+ * to ensure a respective common linker table entry is added to the shared
+ * ``include/asm-generic/vmlinux.lds.h``.  There should be a respective::
+ *
+ *  *(SORT(.foo..tbl.*))
+ *
+ * entry for each type of supported section there. If your `SECTION_NAME`
+ * is not yet supported, consider adding support for it.
+ *
+ * Linker tables support ordering entries, it does this using a digit which
+ * is eventually added as a postfix to a section entry name, we refer to this
+ * as the linker table ``order-level``. If order is not important to your
+ * linker table entry you can use the special ``SECTION_ORDER_ANY``. After
+ * ``order-level``, the next contributing factor to order is the order of the
+ * code in the C file, and the order of the objects in the Makefile. Using an
+ * ``order-level`` then should not really be needed in most cases, its use
+ * however enables to compartamentalize code into tables where ordering through
+ * C file or through the Makefile would otherwise be very difficult or if one
+ * wanted to enable very specific initialization semantics.
+ *
+ * As an example, suppose that we want to create a "frobnicator"
+ * feature framework, and allow for several independent modules to
+ * provide frobnicating services. Then we would create a frob.h
+ * header file containing e.g.::
+ *
+ *	struct frobnicator {
+ *		const char *name;
+ *		void (*frob) (void);
+ *	};
+ *
+ *	DECLARE_LINKTABLE(struct frobnicator, frobnicator_fns);
+ *
+ * Any module providing frobnicating services would look something
+ * like::
+ *
+ *	#include "frob.h"
+ *
+ *	static void my_frob(void) {
+ *		... Do my frobnicating
+ *	}
+ *
+ *	LINKTABLE_INIT_DATA(frobnicator_fns, all) my_frobnicator = {
+ *		.name = "my_frob",
+ *		.frob = my_frob,
+ *	};
+ *
+ * The central frobnicator code, say in frob.c, would use the frobnicating
+ * modules as follows::
+ *
+ *	#include "frob.h"
+ *
+ *	void frob_all(void) {
+ *		struct frobnicator *f;
+ *
+ *		LINKTABLE_FOR_EACH(f, frobnicator_fns) {
+ *			pr_info("Calling frobnicator %s\n", frob->name);
+ *			f->frob();
+ *		}
+ *	}
+ */
+
+/**
+ * DOC: Linker table module support
+ *
+ * Modules can use linker tables, however the linker table definition
+ * must be built-in to the kernel. That is, the code that implements
+ * ``DEFINE_LINKTABLE*()`` must be built-in, and modular code cannot add
+ * more items in to the table, unless ``kernel/module.c`` find_module_sections()
+ * and module-common.lds.S are updated accordingly with a respective
+ * module notifier to account for updates. This restriction may be enhanced
+ * in the future.
+ */
+
+/**
+ * DOC: Linker table helpers
+ *
+ * These are helpers for linker tables.
+ */
+
+/**
+ * LINKTABLE_START - get address of start of linker table
+ *
+ * @name: name of the linker table
+ *
+ * This gives you the start address of the linker table.
+ * This should give you the address of the first entry.
+ *
+ */
+#define LINKTABLE_START(name)	LINUX_SECTION_START(name)
+
+/**
+ * LINKTABLE_END - get address of end of the linker table
+ *
+ * @name: name of the linker table
+ *
+ * This gives you the end address of the linker table.
+ * This will match the start address if the linker table
+ * is empty.
+ */
+#define LINKTABLE_END(name)	LINUX_SECTION_END(name)
+
+/**
+ * LINKTABLE_SIZE - get number of entries in the linker table
+ *
+ * @name: name of the linker table
+ *
+ * This gives you the number of entries in the linker table.
+ * Example usage:
+ *
+ *   unsigned int num_frobs = LINKTABLE_SIZE(frobnicator_fns);
+ */
+#define LINKTABLE_SIZE(name)					\
+	((LINKTABLE_END(name)) - (LINKTABLE_START(name)))
+
+/**
+ * LINKTABLE_EMPTY - check if linker table has no entries
+ *
+ * @name: name of linker table
+ *
+ * Returns true if the linker table is emtpy.
+ *
+ *   bool is_empty = LINKTABLE_EMPTY(frobnicator_fns);
+ */
+#define LINKTABLE_EMPTY(name)	(LINKTABLE_SIZE(name) = 0)
+
+/**
+ * LINKTABLE_ADDR_WITHIN - returns true if address is in the linker table
+ *
+ * @name: name of the linker table
+ * @addr: address to query for
+ *
+ * Returns true if the address is part of the linker table.
+ */
+#define LINKTABLE_ADDR_WITHIN(name, addr)				\
+	 (addr >= (unsigned long) LINKTABLE_START(name) &&		\
+          addr < (unsigned long) LINKTABLE_END(name))
+
+/**
+ * LINKTABLE_ALIGNMENT - get the alignment of the linker table
+ *
+ * @name: name of linker table
+ *
+ * Gives you the alignment for the linker table.
+ */
+#define LINKTABLE_ALIGNMENT(name)	LINUX_SECTION_ALIGNMENT(name)
+
+/**
+ * DOC: Constructing linker tables
+ *
+ * Linker tables constructors are used to build an entry into a linker table.
+ * Linker table constructors exist for each type of supported section.
+ *
+ * You have weak and regular type of link table entry constructors.
+ */
+
+/**
+ * DOC: Weak linker tables constructors
+ *
+ * The weak attribute is desirable if you want an entry you can replace at
+ * link time. A very special use case for linker tables is the first entry.
+ * A weak attribute is used for the first entry to ensure that this entry's
+ * address matches the end address of the table when the linker table is
+ * emtpy, but will also point to the first real entry of the table once not
+ * empty. When the first entry is linked in, it takes place of the first entry.
+ */
+
+/**
+ * LINKTABLE_WEAK - Constructs a weak linker table entry for data
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Constructs a weak linker table for data.
+ */
+#define LINKTABLE_WEAK(name, level)					\
+	      __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".data..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_TEXT_WEAK - Constructs a weak linker table entry for execution
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Constructs a weak linker table for code execution. These will be
+ * read-only.
+ */
+#define LINKTABLE_TEXT_WEAK(name, level)				\
+	const __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".text..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_RO_WEAK - Constructs a weak read-only linker table entry
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Constructs a weak linker table which only requires read-only access.
+ */
+#define LINKTABLE_RO_WEAK(name, level)					\
+	const __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(SECTION_TBL_RO_STR "..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_INIT_WEAK - Constructs a weak linker table entry for init code
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Constructs a weak linker table for execution. use at init.
+ */
+#define LINKTABLE_INIT_WEAK(name, level)				\
+	const __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".init.text..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_INIT_DATA_WEAK - Constructs a weak linker table entry for initdata
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Constructs a weak linker table for data during init.
+ */
+#define LINKTABLE_INIT_DATA_WEAK(name, level)				\
+	      __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".init.data..tbl." #name "." #level)))
+
+/**
+ * DOC: Regular linker linker table constructors
+ *
+ * Regular constructors are expected to be used for valid linker table entries.
+ * Valid uses of weak entries other than the beginning and is currently
+ * untested but should in theory work.
+ */
+
+/**
+ * LINKTABLE - Declares a data linker table entry
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Declares a data linker table entry. These are read-write.
+ */
+#define LINKTABLE(name, level)						\
+	      __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".data..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_TEXT - Declares a linker table entry for execution
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Declares a linker table to be used for execution.
+ */
+#define LINKTABLE_TEXT(name, level)					\
+	const __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".text..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_RO - Declares a read-only linker table entry.
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Declares a linker table which only requires read-only access. Contrary
+ * to LINKTABLE_RO_WEAK() which uses SECTION_RODATA this helper uses the
+ * section SECTION_TBL_RO here due to possible toolchains bug on some
+ * architectures, for instance the c6x architicture stuffs non-weak data
+ * into different sections other than the one intended.
+ */
+#define LINKTABLE_RO(name, level)					\
+	const __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(SECTION_TBL_RO_STR "..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_INIT - Declares a linker table entry to be used on init.
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Declares a linker table entry for execution use during init.
+ */
+#define LINKTABLE_INIT(name, level)					\
+	const __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".init.text..tbl." #name "." #level)))
+
+/**
+ * LINKTABLE_INIT_DATA - Declares a linker table entry to be used on init data.
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Declares a linker table entry for data during init.
+ */
+#define LINKTABLE_INIT_DATA(name, level)				\
+	      __typeof__(LINKTABLE_START(name)[0])			\
+	      __attribute__((used,					\
+			     __aligned__(LINKTABLE_ALIGNMENT(name)),	\
+			     section(".init.data..tbl." #name "." #level)))
+
+/**
+ * DOC: Declaring Linker tables
+ *
+ * Declarers are used to help code access the linker tables. Typically
+ * header files for subsystems would declare the linker tables to enable
+ * easy access to add new entries, and to iterate over the list of table.
+ * There are only two declarers needed given that the section association
+ * is done by the definition of the linker table using ``DEFINE_LINKTABLE*()``
+ * helpers.
+ */
+
+
+/**
+ * DECLARE_LINKTABLE - Declares a data linker table entry
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Declares a data linker table entry.
+ */
+#define DECLARE_LINKTABLE(type, name)					\
+	DECLARE_LINUX_SECTION(type, name)
+
+/**
+ * DECLARE_LINKTABLE_RO - Declares a read-only linker table entry
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Declares a read-only linker table entry.
+ */
+#define DECLARE_LINKTABLE_RO(type, name)				\
+	DECLARE_LINUX_SECTION_RO(type, name)
+
+/**
+ * DOC: Defining Linker tables
+ *
+ * Linker tables are defined in the code that takes ownership over
+ * the linker table. This is typically done in the same code that is in
+ * charge of iterating over the linker table as well.
+ */
+
+/**
+ * DEFINE_LINKTABLE - Defines a linker table for data
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Defines a linker table which used for data.
+ */
+#define DEFINE_LINKTABLE(type, name)					\
+	DECLARE_LINKTABLE(type, name);					\
+	LINKTABLE_WEAK(name,) LINKTABLE_START(name)[0] = {};		\
+	LINKTABLE(name, ~) LINKTABLE_END(name)[0] = {}
+
+/**
+ * DEFINE_LINKTABLE_TEXT - Declares linker table entry for exectuion
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Declares a linker table entry for execution.
+ */
+#define DEFINE_LINKTABLE_TEXT(type, name)				\
+	DECLARE_LINKTABLE_RO(type, name);				\
+	LINKTABLE_TEXT_WEAK(name,) LINKTABLE_START(name)[0] = {};	\
+	LINKTABLE_TEXT(name, ~) LINKTABLE_END(name)[0] = {}
+
+/**
+ * DEFINE_LINKTABLE_RO - Defines a read-only linker table
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Defines a linker table which we know only requires read-only access.
+ */
+#define DEFINE_LINKTABLE_RO(type, name)					\
+	DECLARE_LINKTABLE_RO(type, name);				\
+	LINKTABLE_RO_WEAK(name,) LINKTABLE_START(name)[0] = {};		\
+	LINKTABLE_RO(name, ~) LINKTABLE_END(name)[0] = {}
+
+/**
+ * DEFINE_LINKTABLE_INIT - Defines an init time linker table for execution
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Defines a linker table. If you are adding a new type you should
+ * enable ``CONFIG_DEBUG_SECTION_MISMATCH`` and ensure routines that make
+ * use of the linker tables get a respective __ref tag.
+ */
+#define DEFINE_LINKTABLE_INIT(type, name)				\
+	DECLARE_LINKTABLE_RO(type, name);				\
+	LINKTABLE_INIT_WEAK(name,) LINKTABLE_START(name)[0] = {};	\
+	LINKTABLE_INIT(name, ~) LINKTABLE_END(name)[0] = {}
+
+/**
+ * DEFINE_LINKTABLE_INIT_DATA - Defines an init time linker table for data
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Defines a linker table for init data. If you are adding a new type you
+ * should enable ``CONFIG_DEBUG_SECTION_MISMATCH`` and ensure routines that
+ * make use of the linker tables get a respective __ref tag.
+ */
+#define DEFINE_LINKTABLE_INIT_DATA(type, name)				\
+	DECLARE_LINKTABLE(type, name);					\
+	LINKTABLE_INIT_DATA_WEAK(name,) LINKTABLE_START(name)[0] = {};	\
+	LINKTABLE_INIT_DATA(name, ~) LINKTABLE_END(name)[0] = {}
+
+/**
+ * DOC: Iterating over Linker tables
+ *
+ * To make use of the linker tables you want to be able to iterate over
+ * them. This section documents the different iterators available.
+ */
+
+/**
+ * LINKTABLE_FOR_EACH - iterate through all entries within a linker table
+ *
+ * @pointer: entry pointer
+ * @tbl: linker table
+ *
+ * Example usage::
+ *
+ *   struct frobnicator *frob;
+ *
+ *   LINKTABLE_FOR_EACH(frob, frobnicator_fns) {
+ *     ...
+ *   }
+ */
+
+#define LINKTABLE_FOR_EACH(pointer, tbl)				\
+	for (pointer = LINKTABLE_START(tbl);				\
+	     pointer < LINKTABLE_END(tbl);				\
+	     pointer++)
+
+/**
+ * LINKTABLE_RUN_ALL - iterate and run through all entries on a linker table
+ *
+ * @tbl: linker table
+ * @func: structure name for the function name we want to call.
+ * @args...: arguments to pass to func
+ *
+ * Example usage::
+ *
+ *   LINKTABLE_RUN_ALL(frobnicator_fns, some_run,);
+ */
+#define LINKTABLE_RUN_ALL(tbl, func, args...)				\
+do {									\
+	size_t i;							\
+	for (i = 0; i < LINKTABLE_SIZE(tbl); i++)			\
+		(LINKTABLE_START(tbl)[i]).func (args);			\
+} while (0)
+
+/**
+ * LINKTABLE_RUN_ERR - run each linker table entry func and return error if any
+ *
+ * @tbl: linker table
+ * @func: structure name for the function name we want to call.
+ * @args...: arguments to pass to func
+ *
+ * Example usage::
+ *
+ *   unsigned int err = LINKTABLE_RUN_ERR(frobnicator_fns, some_run,);
+ */
+#define LINKTABLE_RUN_ERR(tbl, func, args...)				\
+({									\
+	size_t i;							\
+	int err = 0;							\
+	for (i = 0; !err && i < LINKTABLE_SIZE(tbl); i++)		\
+		err = (LINKTABLE_START(tbl)[i]).func (args);		\
+		err;							\
+})
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _LINUX_LINKER_TABLES_H */
-- 
2.10.1

