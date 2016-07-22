From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:41 +0000
Subject: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@linux-foun

A linker table is a data structure that is stitched together from items
in multiple object files. Linux has historically implicitly used linker
tables for ages, however they were all built in an adhoc manner which
requires linker script modifications, per architecture. This adds a
general linker table solution so that a new linker table can be
implemented by changing C code only. The Linux linker table was
originally based on Michael Brown's iPXE's linker table solution but
has been significantly modified to fit Linux's use in its integration.

The same philosophy is borrowed, extended and further simplified:

Linker tables enable an extremely light weight linker build time
solution for feature ordering and selection, this can help to both
simplify init sequences in a generic fashion and helps avoiding code
bit-rotting when desirable.

Bit rotting avoidance is enabled by *granting the option* to force
compilation of code and only enable linking object code in when
specific features have been enabled. It accomplishes this by using
linker sections, the lightweight feature ordering of code is enabled
by taking advantage of the old binutils ld SORT() on features
specific sections.

Contrary to iPXE's solution, which strives to force compilation
of all features, Linux' solution strives to encourage usage of linker
tables to force compilation of code *only on designated code*. Linker
tables can be used without requiring one to force code compilation
of features that use it though, to take advantage of the simplification
of init sequences.

Linux code that uses linker tables *and* wishes to always require
compilation but selectively linking must use new kbuild target object
that helps accomplishes this, table-y. Linux code that uses linker
tables but does not want to require forcing compilation can use the
good 'ol obj-y targets.

Used commit 67a10ef000cb7 from iPXE upstream [0] as the starting point
for development and evaluation of Linux's integration, further changes
made and evaluation of different linker table options for Linux are
available on the linker-table userspace tree [1].

[0] git://git.ipxe.org/ipxe.git
[1] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linker-tables.git/

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
 Documentation/DocBook/Makefile           |   2 +-
 Documentation/DocBook/linker-tables.tmpl | 166 +++++++++
 Documentation/kbuild/makefiles.txt       |  19 +
 arch/alpha/include/asm/tables.h          |   6 +
 arch/arc/include/asm/tables.h            |   6 +
 arch/arm/include/asm/tables.h            |   6 +
 arch/arm64/include/asm/tables.h          |   6 +
 arch/avr32/include/asm/tables.h          |   6 +
 arch/blackfin/include/asm/tables.h       |   6 +
 arch/c6x/include/asm/tables.h            |   6 +
 arch/cris/include/asm/tables.h           |   6 +
 arch/frv/include/asm/tables.h            |   6 +
 arch/h8300/include/asm/tables.h          |   6 +
 arch/hexagon/include/asm/tables.h        |   6 +
 arch/ia64/include/asm/tables.h           |   6 +
 arch/m32r/include/asm/tables.h           |   6 +
 arch/m68k/include/asm/tables.h           |   6 +
 arch/metag/include/asm/tables.h          |   6 +
 arch/microblaze/include/asm/tables.h     |   6 +
 arch/mips/include/asm/tables.h           |   6 +
 arch/mn10300/include/asm/tables.h        |   6 +
 arch/nios2/include/asm/tables.h          |   6 +
 arch/openrisc/include/asm/tables.h       |   6 +
 arch/parisc/include/asm/tables.h         |   6 +
 arch/powerpc/include/asm/tables.h        |   6 +
 arch/s390/include/asm/tables.h           |   6 +
 arch/score/include/asm/tables.h          |   6 +
 arch/sh/include/asm/tables.h             |   6 +
 arch/sparc/include/asm/tables.h          |   6 +
 arch/tile/include/asm/tables.h           |   6 +
 arch/um/include/asm/tables.h             |   6 +
 arch/unicore32/include/asm/tables.h      |   6 +
 arch/x86/include/asm/tables.h            |   6 +
 arch/x86/tools/relocs.c                  |   3 +
 arch/xtensa/include/asm/tables.h         |   6 +
 include/asm-generic/tables.h             |  70 ++++
 include/asm-generic/vmlinux.lds.h        |   9 +-
 include/linux/tables.h                   | 597 +++++++++++++++++++++++++++++++
 scripts/Makefile.build                   |   4 +-
 scripts/Makefile.clean                   |   1 +
 scripts/Makefile.lib                     |  12 +
 tools/include/linux/sections.h           |  13 +
 42 files changed, 1078 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/DocBook/linker-tables.tmpl
 create mode 100644 arch/alpha/include/asm/tables.h
 create mode 100644 arch/arc/include/asm/tables.h
 create mode 100644 arch/arm/include/asm/tables.h
 create mode 100644 arch/arm64/include/asm/tables.h
 create mode 100644 arch/avr32/include/asm/tables.h
 create mode 100644 arch/blackfin/include/asm/tables.h
 create mode 100644 arch/c6x/include/asm/tables.h
 create mode 100644 arch/cris/include/asm/tables.h
 create mode 100644 arch/frv/include/asm/tables.h
 create mode 100644 arch/h8300/include/asm/tables.h
 create mode 100644 arch/hexagon/include/asm/tables.h
 create mode 100644 arch/ia64/include/asm/tables.h
 create mode 100644 arch/m32r/include/asm/tables.h
 create mode 100644 arch/m68k/include/asm/tables.h
 create mode 100644 arch/metag/include/asm/tables.h
 create mode 100644 arch/microblaze/include/asm/tables.h
 create mode 100644 arch/mips/include/asm/tables.h
 create mode 100644 arch/mn10300/include/asm/tables.h
 create mode 100644 arch/nios2/include/asm/tables.h
 create mode 100644 arch/openrisc/include/asm/tables.h
 create mode 100644 arch/parisc/include/asm/tables.h
 create mode 100644 arch/powerpc/include/asm/tables.h
 create mode 100644 arch/s390/include/asm/tables.h
 create mode 100644 arch/score/include/asm/tables.h
 create mode 100644 arch/sh/include/asm/tables.h
 create mode 100644 arch/sparc/include/asm/tables.h
 create mode 100644 arch/tile/include/asm/tables.h
 create mode 100644 arch/um/include/asm/tables.h
 create mode 100644 arch/unicore32/include/asm/tables.h
 create mode 100644 arch/x86/include/asm/tables.h
 create mode 100644 arch/xtensa/include/asm/tables.h
 create mode 100644 include/asm-generic/tables.h
 create mode 100644 include/linux/tables.h
 create mode 100644 tools/include/linux/sections.h

diff --git a/Documentation/DocBook/Makefile b/Documentation/DocBook/Makefile
index 1b2ac4731418..b78365cc3cd1 100644
--- a/Documentation/DocBook/Makefile
+++ b/Documentation/DocBook/Makefile
@@ -18,7 +18,7 @@ DOCBOOKS := z8530book.xml device-drivers.xml \
 	    alsa-driver-api.xml writing-an-alsa-driver.xml \
 	    tracepoint.xml media_api.xml w1.xml \
 	    writing_musb_glue_layer.xml crypto-API.xml iio.xml \
-	    sections.xml
+	    sections.xml linker-tables.xml
 
 include Documentation/DocBook/media/Makefile
 
diff --git a/Documentation/DocBook/linker-tables.tmpl b/Documentation/DocBook/linker-tables.tmpl
new file mode 100644
index 000000000000..fba90c61eee1
--- /dev/null
+++ b/Documentation/DocBook/linker-tables.tmpl
@@ -0,0 +1,166 @@
+<?xml version="1.0" encoding="UTF-8"?>
+<!DOCTYPE set PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN"
+	"http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd" []>
+<set>
+  <setinfo>
+    <title>Linux linker tables</title>
+    <subtitle>
+      Explains Linux' linker tables work.
+    </subtitle>
+
+    <copyright>
+      <year>2015-2016</year>
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
+        This book documents the Linux' use of linker tables, how you can
+        use them and how they work.
+      </para>
+    </abstract>
+  </setinfo>
+  <book id="linux-linux-tables">
+    <bookinfo>
+      <title>Linux linker tables</title>
+
+      <abstract>
+!Pinclude/linux/tables.h Introduction
+      </abstract>
+    </bookinfo>
+
+      <chapter>
+      <title>About Linker tables</title>
+
+	<sect1>
+	<title>Linker table provenance and userspace testing</title>
+!Pinclude/linux/tables.h Linker table provenance and userspace testing
+	</sect1>
+
+	<sect1>
+	<title>The code bit-rot problem</title>
+!Pinclude/linux/tables.h The code bit-rot problem
+	</sect1>
+
+	<sect1>
+	<title>Avoiding the code bit-rot problem when desirable</title>
+!Pinclude/linux/tables.h Avoiding the code bit-rot problem when desirable
+	</sect1>
+      </chapter>
+
+      <chapter>
+      <title>Using linker tables in Linux</title>
+
+	<sect1>
+      <title>Using target table-y and table-n</title>
+!Pinclude/linux/tables.h Using target table-y and table-n
+	</sect1>
+
+	<sect1>
+	<title>Opting out of forcing compilation</title>
+!Pinclude/linux/tables.h Opting out of forcing compilation
+	</sect1>
+
+	<sect1>
+	<title>How linker tables simplify inits</title>
+!Pinclude/linux/tables.h How linker tables simplify inits
+	</sect1>
+
+      </chapter>
+
+      <chapter>
+      <title>Linker table helpers</title>
+!Pinclude/linux/tables.h Linker table helpers
+!Finclude/linux/tables.h LINKTABLE_ADDR_WITHIN
+      </chapter>
+
+      <chapter>
+      <title>Constructing Linker tables</title>
+!Pinclude/linux/tables.h Constructing linker tables
+
+	<sect1>
+	<title>Weak linker tables constructors</title>
+!Pinclude/linux/tables.h Weak linker tables constructors
+!Finclude/linux/tables.h LINKTABLE_WEAK
+!Finclude/linux/tables.h LINKTABLE_TEXT_WEAK
+!Finclude/linux/tables.h LINKTABLE_DATA_WEAK
+!Finclude/linux/tables.h LINKTABLE_RO_WEAK
+!Finclude/linux/tables.h LINKTABLE_INIT_WEAK
+!Finclude/linux/tables.h LINKTABLE_INIT_DATA_WEAK
+	</sect1>
+
+	<sect1>
+	<title>Regular linker linker table constructors</title>
+!Pinclude/linux/tables.h Regular linker linker table constructors
+!Finclude/linux/tables.h LINKTABLE_TEXT
+!Finclude/linux/tables.h LINKTABLE_DATA
+!Finclude/linux/tables.h LINKTABLE_RO
+!Finclude/linux/tables.h LINKTABLE_INIT
+!Finclude/linux/tables.h LINKTABLE_INIT_DATA
+	</sect1>
+      </chapter>
+
+      <chapter>
+      <title>Declaring Linker tables</title>
+!Pinclude/linux/tables.h Declaring Linker tables
+!Finclude/linux/tables.h DECLARE_LINKTABLE_TEXT
+!Finclude/linux/tables.h DECLARE_LINKTABLE_DATA
+!Finclude/linux/tables.h DECLARE_LINKTABLE_RO
+!Finclude/linux/tables.h DECLARE_LINKTABLE_INIT
+!Finclude/linux/tables.h DECLARE_LINKTABLE_INIT_DATA
+      </chapter>
+
+      <chapter>
+      <title>Defining Linker tables</title>
+!Pinclude/linux/tables.h Defining Linker tables
+!Finclude/linux/tables.h DEFINE_LINKTABLE_TEXT
+!Finclude/linux/tables.h DEFINE_LINKTABLE_DATA
+!Finclude/linux/tables.h DEFINE_LINKTABLE_RO
+!Finclude/linux/tables.h DEFINE_LINKTABLE_INIT
+!Finclude/linux/tables.h DEFINE_LINKTABLE_INIT_DATA
+      </chapter>
+
+      <chapter>
+      <title>Iterating over Linker tables</title>
+!Pinclude/linux/tables.h Iterating over Linker tables
+!Finclude/linux/tables.h LINKTABLE_FOR_EACH
+!Finclude/linux/tables.h LINKTABLE_RUN_ALL
+!Finclude/linux/tables.h LINKTABLE_RUN_ERR
+      </chapter>
+
+  </book>
+</set>
diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 385a5ef41c17..c63751312810 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -1089,6 +1089,25 @@ When kbuild executes, the following steps are followed (roughly):
 	In this example, extra-y is used to list object files that
 	shall be built, but shall not be linked as part of built-in.o.
 
+    table-y table-m and table-
+
+	To avoid code bit-rot you may wish to avoid using #ifdefs on your
+	code. Bit-rot is possible if certain features may not be enabled
+	on certain build environments. The table-y, specifies targets which you
+	always wish to force compilation on, but wish to only enable linking in
+	if the feature is enabled, these are features taking advantage of
+	Linux's linker tables. For details on how to implement a feature using
+	linker tablesrefer to include/linux/tables.h. Use of table-m is not
+	yet supported.
+
+	Example:
+		table-$(CONFIG-FEATURE_FOO) += foo.o
+
+	An alternative to using table-y, is to use extra-y followed by the
+	respective obj-y:
+
+		extra-y += foo.o
+		obj-$(CONFIG-FEATURE_FOO) += foo.o
 
 --- 6.7 Commands useful for building a boot image
 
diff --git a/arch/alpha/include/asm/tables.h b/arch/alpha/include/asm/tables.h
new file mode 100644
index 000000000000..e53ee883330c
--- /dev/null
+++ b/arch/alpha/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ALPHA_TABLES_H
+#define _ASM_ALPHA_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_ALPHA_TABLES_H */
diff --git a/arch/arc/include/asm/tables.h b/arch/arc/include/asm/tables.h
new file mode 100644
index 000000000000..a02e790bcb14
--- /dev/null
+++ b/arch/arc/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ARC_TABLES_H
+#define _ASM_ARC_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_ARC_TABLES_H */
diff --git a/arch/arm/include/asm/tables.h b/arch/arm/include/asm/tables.h
new file mode 100644
index 000000000000..96c1147fb766
--- /dev/null
+++ b/arch/arm/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ARM_TABLES_H
+#define _ASM_ARM_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_ARM_TABLES_H */
diff --git a/arch/arm64/include/asm/tables.h b/arch/arm64/include/asm/tables.h
new file mode 100644
index 000000000000..d84a554ec6da
--- /dev/null
+++ b/arch/arm64/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_ARM64_TABLES_H
+#define _ASM_ARM64_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_ARM64_TABLES_H */
diff --git a/arch/avr32/include/asm/tables.h b/arch/avr32/include/asm/tables.h
new file mode 100644
index 000000000000..7ef914761c38
--- /dev/null
+++ b/arch/avr32/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_AVR32_TABLES_H
+#define _ASM_AVR32_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_AVR32_TABLES_H */
diff --git a/arch/blackfin/include/asm/tables.h b/arch/blackfin/include/asm/tables.h
new file mode 100644
index 000000000000..6e7445818a9c
--- /dev/null
+++ b/arch/blackfin/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_BLACKFIN_TABLES_H
+#define _ASM_BLACKFIN_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_BLACKFIN_TABLES_H */
diff --git a/arch/c6x/include/asm/tables.h b/arch/c6x/include/asm/tables.h
new file mode 100644
index 000000000000..209642925772
--- /dev/null
+++ b/arch/c6x/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_C6X_TABLES_H
+#define _ASM_C6X_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_C6X_TABLES_H */
diff --git a/arch/cris/include/asm/tables.h b/arch/cris/include/asm/tables.h
new file mode 100644
index 000000000000..17c0f04e7c27
--- /dev/null
+++ b/arch/cris/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_CRIS_TABLES_H
+#define _ASM_CRIS_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_CRIS_TABLES_H */
diff --git a/arch/frv/include/asm/tables.h b/arch/frv/include/asm/tables.h
new file mode 100644
index 000000000000..7a6c1f263a07
--- /dev/null
+++ b/arch/frv/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_FRV_TABLES_H
+#define _ASM_FRV_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_FRV_TABLES_H */
diff --git a/arch/h8300/include/asm/tables.h b/arch/h8300/include/asm/tables.h
new file mode 100644
index 000000000000..fc4297961bb7
--- /dev/null
+++ b/arch/h8300/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_H8300_TABLES_H
+#define _ASM_H8300_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_H8300_TABLES_H */
diff --git a/arch/hexagon/include/asm/tables.h b/arch/hexagon/include/asm/tables.h
new file mode 100644
index 000000000000..73475cc63c77
--- /dev/null
+++ b/arch/hexagon/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_HEXAGON_TABLES_H
+#define _ASM_HEXAGON_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_HEXAGON_TABLES_H */
diff --git a/arch/ia64/include/asm/tables.h b/arch/ia64/include/asm/tables.h
new file mode 100644
index 000000000000..4d7084cf0bd4
--- /dev/null
+++ b/arch/ia64/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_IA64_TABLES_H
+#define _ASM_IA64_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_IA64_TABLES_H */
diff --git a/arch/m32r/include/asm/tables.h b/arch/m32r/include/asm/tables.h
new file mode 100644
index 000000000000..6708322deba8
--- /dev/null
+++ b/arch/m32r/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_M32R_TABLES_H
+#define _ASM_M32R_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_M32R_TABLES_H */
diff --git a/arch/m68k/include/asm/tables.h b/arch/m68k/include/asm/tables.h
new file mode 100644
index 000000000000..1f6def4822ff
--- /dev/null
+++ b/arch/m68k/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_M68K_TABLES_H
+#define _ASM_M68K_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_M68K_TABLES_H */
diff --git a/arch/metag/include/asm/tables.h b/arch/metag/include/asm/tables.h
new file mode 100644
index 000000000000..594ee23ab968
--- /dev/null
+++ b/arch/metag/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_METAG_TABLES_H
+#define _ASM_METAG_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_METAG_TABLES_H */
diff --git a/arch/microblaze/include/asm/tables.h b/arch/microblaze/include/asm/tables.h
new file mode 100644
index 000000000000..f84bbfbdd63c
--- /dev/null
+++ b/arch/microblaze/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MICROBLAZE_TABLES_H
+#define _ASM_MICROBLAZE_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_MICROBLAZE_TABLES_H */
diff --git a/arch/mips/include/asm/tables.h b/arch/mips/include/asm/tables.h
new file mode 100644
index 000000000000..db5d62983667
--- /dev/null
+++ b/arch/mips/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MIPS_TABLES_H
+#define _ASM_MIPS_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_MIPS_TABLES_H */
diff --git a/arch/mn10300/include/asm/tables.h b/arch/mn10300/include/asm/tables.h
new file mode 100644
index 000000000000..b6d19fb66119
--- /dev/null
+++ b/arch/mn10300/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_MN10300_TABLES_H
+#define _ASM_MN10300_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_MN10300_TABLES_H */
diff --git a/arch/nios2/include/asm/tables.h b/arch/nios2/include/asm/tables.h
new file mode 100644
index 000000000000..5dce7fc56bf7
--- /dev/null
+++ b/arch/nios2/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_NIOS2_TABLES_H
+#define _ASM_NIOS2_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_NIOS2_TABLES_H */
diff --git a/arch/openrisc/include/asm/tables.h b/arch/openrisc/include/asm/tables.h
new file mode 100644
index 000000000000..1b052c3b1816
--- /dev/null
+++ b/arch/openrisc/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_OPENRISC_TABLES_H
+#define _ASM_OPENRISC_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_OPENRISC_TABLES_H */
diff --git a/arch/parisc/include/asm/tables.h b/arch/parisc/include/asm/tables.h
new file mode 100644
index 000000000000..da60f2d9588d
--- /dev/null
+++ b/arch/parisc/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_PARISC_TABLES_H
+#define _ASM_PARISC_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_PARISC_TABLES_H */
diff --git a/arch/powerpc/include/asm/tables.h b/arch/powerpc/include/asm/tables.h
new file mode 100644
index 000000000000..1615f2edc4fc
--- /dev/null
+++ b/arch/powerpc/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_POWERPC_TABLES_H
+#define _ASM_POWERPC_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_POWERPC_TABLES_H */
diff --git a/arch/s390/include/asm/tables.h b/arch/s390/include/asm/tables.h
new file mode 100644
index 000000000000..c9615ed026b2
--- /dev/null
+++ b/arch/s390/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_S390_TABLES_H
+#define _ASM_S390_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_S390_TABLES_H */
diff --git a/arch/score/include/asm/tables.h b/arch/score/include/asm/tables.h
new file mode 100644
index 000000000000..7694b5bfca91
--- /dev/null
+++ b/arch/score/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SCORE_TABLES_H
+#define _ASM_SCORE_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_SCORE_TABLES_H */
diff --git a/arch/sh/include/asm/tables.h b/arch/sh/include/asm/tables.h
new file mode 100644
index 000000000000..7db4ffee4d7e
--- /dev/null
+++ b/arch/sh/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SH_TABLES_H
+#define _ASM_SH_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_SH_TABLES_H */
diff --git a/arch/sparc/include/asm/tables.h b/arch/sparc/include/asm/tables.h
new file mode 100644
index 000000000000..c540236bd9f5
--- /dev/null
+++ b/arch/sparc/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_SPARC_TABLES_H
+#define _ASM_SPARC_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_SPARC_TABLES_H */
diff --git a/arch/tile/include/asm/tables.h b/arch/tile/include/asm/tables.h
new file mode 100644
index 000000000000..33168b49a295
--- /dev/null
+++ b/arch/tile/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_TILE_TABLES_H
+#define _ASM_TILE_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_TILE_TABLES_H */
diff --git a/arch/um/include/asm/tables.h b/arch/um/include/asm/tables.h
new file mode 100644
index 000000000000..ed093477c617
--- /dev/null
+++ b/arch/um/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_UM_TABLES_H
+#define _ASM_UM_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_UM_TABLES_H */
diff --git a/arch/unicore32/include/asm/tables.h b/arch/unicore32/include/asm/tables.h
new file mode 100644
index 000000000000..6edc65c625f5
--- /dev/null
+++ b/arch/unicore32/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_UNICORE32_TABLES_H
+#define _ASM_UNICORE32_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_UNICORE32_TABLES_H */
diff --git a/arch/x86/include/asm/tables.h b/arch/x86/include/asm/tables.h
new file mode 100644
index 000000000000..5828e3a73a61
--- /dev/null
+++ b/arch/x86/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_X86_TABLES_H
+#define _ASM_X86_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_X86_TABLES_H */
diff --git a/arch/x86/tools/relocs.c b/arch/x86/tools/relocs.c
index 0c2fae8d929d..07b335c67139 100644
--- a/arch/x86/tools/relocs.c
+++ b/arch/x86/tools/relocs.c
@@ -1,4 +1,5 @@
 /* This is included from relocs_32/64.c */
+#include <linux/sections.h>
 
 #define ElfW(type)		_ElfW(ELF_BITS, type)
 #define _ElfW(bits, type)	__ElfW(bits, type)
@@ -68,6 +69,8 @@ static const char * const sym_regex_kernel[S_NSYMTYPES] = {
 	"__end_rodata|"
 	"__initramfs_start|"
 	"(jiffies|jiffies_64)|"
+	SECTION_TBL_ALL_STR(SECTION_RODATA) "|"
+	SECTION_TBL_ALL_STR(SECTION_INIT) "|"
 #if ELF_BITS = 64
 	"__per_cpu_load|"
 	"init_per_cpu__.*|"
diff --git a/arch/xtensa/include/asm/tables.h b/arch/xtensa/include/asm/tables.h
new file mode 100644
index 000000000000..af78c7cd8e47
--- /dev/null
+++ b/arch/xtensa/include/asm/tables.h
@@ -0,0 +1,6 @@
+#ifndef _ASM_XTENSA_TABLES_H
+#define _ASM_XTENSA_TABLES_H
+
+#include <asm-generic/tables.h>
+
+#endif /* _ASM_XTENSA_TABLES_H */
diff --git a/include/asm-generic/tables.h b/include/asm-generic/tables.h
new file mode 100644
index 000000000000..5cf655590a19
--- /dev/null
+++ b/include/asm-generic/tables.h
@@ -0,0 +1,70 @@
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
+
+#ifdef __KERNEL__
+# include <asm/sections.h>
+#endif /* __KERNEL__ */
+
+#define SECTION_TYPE_TABLES	tbl
+
+#define SECTION_TBL(section, name, level)				\
+	SECTION_TYPE(section, SECTION_TYPE_TABLES, name, level)
+
+#define SECTION_TBL_ALL(section)					\
+	SECTION_TYPE_ALL(section,SECTION_TYPE_TABLES)
+
+#ifndef section_tbl
+# define section_tbl(section, name, level, flags)			\
+	 section_type(section, SECTION_TYPE_TABLES, name,		\
+		     level, flags)
+#endif
+
+#ifndef section_tbl_any
+# define section_tbl_any(section, name, flags)				\
+	 section_type(section, SECTION_TYPE_TABLES, name,		\
+		     SECTION_ORDER_ANY, flags)
+#endif
+
+#ifndef section_tbl_asmtype
+# define section_tbl_asmtype(section, name, level, flags, asmtype)	\
+	 section_type_asmtype(section, SECTION_TYPE_TABLES, name,	\
+			     level, flags, asmtype)
+#endif
+
+#ifndef push_section_tbl
+# define push_section_tbl(section, name, level, flags)			\
+	 push_section_type(section, SECTION_TYPE_TABLES, name,		\
+			  level, flags)
+#endif
+
+#ifndef push_section_tbl_any
+# define push_section_tbl_any(section, name, flags)			\
+	 push_section_type(section, SECTION_TYPE_TABLES, name,		\
+			  SECTION_ORDER_ANY, flags)
+#endif
+
+#if defined(__ASSEMBLER__) || defined(__ASSEMBLY__)
+
+# ifndef DECLARE_SECTION_TBL
+#  define DECLARE_SECTION_TBL(section, name)				\
+  push_section_tbl(section, name,,) ;					\
+  .globl name ;								\
+name: ;									\
+  .popsection								\
+									\
+  push_section_tbl(section, name, ~,) ;					\
+  .popsection
+# endif
+
+#endif /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
+
+#endif /* _ASM_GENERIC_TABLES_H_ */
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 0042f30ff34b..b3a9cd7bc947 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -56,6 +56,7 @@
 
 #include <linux/export.h>
 #include <asm/sections.h>
+#include <asm/tables.h>
 
 /* Align . to a 8 byte boundary equals to maximum function alignment. */
 #define ALIGN_FUNCTION()  . = ALIGN(8)
@@ -200,6 +201,7 @@
 /* .data section */
 #define DATA_DATA							\
 	*(SECTION_DATA)							\
+	*(SORT(SECTION_TBL_ALL(SECTION_DATA)))				\
 	*(SECTION_REF_DATA)						\
 	*(.data..shared_aligned) /* percpu related */			\
 	MEM_KEEP(init.data)						\
@@ -265,7 +267,9 @@
 	. = ALIGN((align));						\
 	SECTION_RODATA    : AT(ADDR(SECTION_RODATA) - LOAD_OFFSET) {	\
 		VMLINUX_SYMBOL(__start_rodata) = .;			\
-		*(SECTION_RODATA) *(SECTION_ALL(SECTION_RODATA))	\
+		*(SECTION_RODATA)					\
+		*(SORT(SECTION_TBL_ALL(SECTION_RODATA)))		\
+		*(SECTION_ALL(SECTION_RODATA))				\
 		RO_AFTER_INIT_DATA	/* Read only after init */	\
 		*(__vermagic)		/* Kernel version magic */	\
 		. = ALIGN(8);						\
@@ -434,6 +438,7 @@
 #define TEXT_TEXT							\
 		ALIGN_FUNCTION();					\
 		*(.text.hot SECTION_TEXT .text.fixup .text.unlikely)	\
+		*(SORT(SECTION_TBL_ALL(SECTION_TEXT)))			\
 		*(SECTION_REF)						\
 	MEM_KEEP(init.text)						\
 	MEM_KEEP(exit.text)						\
@@ -529,6 +534,7 @@
 /* init and exit section handling */
 #define INIT_DATA							\
 	*(SECTION_INIT_DATA)						\
+	*(SORT(SECTION_TBL_ALL(SECTION_INIT_DATA)))			\
 	MEM_DISCARD(init.data)						\
 	KERNEL_CTORS()							\
 	MCOUNT_REC()							\
@@ -551,6 +557,7 @@
 
 #define INIT_TEXT							\
 	*(SECTION_INIT)							\
+	*(SORT(SECTION_TBL_ALL(SECTION_INIT)))				\
 	*(.text.startup)						\
 	MEM_DISCARD(init.text)
 
diff --git a/include/linux/tables.h b/include/linux/tables.h
new file mode 100644
index 000000000000..89d46f4c5739
--- /dev/null
+++ b/include/linux/tables.h
@@ -0,0 +1,597 @@
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
+#include <linux/sections.h>
+#ifdef __KERNEL__
+# include <asm/tables.h>
+#endif /* __KERNEL__ */
+
+#ifndef __ASSEMBLY__
+
+/**
+ * DOC: Introduction
+ *
+ * A linker table is a data structure that is stitched together from items
+ * in multiple object files. Linux has historically implicitly used linker
+ * tables for ages, however they were all built in an adhoc manner which
+ * requires linker script modifications, per architecture. This linker table
+ * solution provides a general linker table facility so that a new linker table
+ * can be implemented by changing C code only.
+ *
+ * Linker tables help you simplify init sequences by using ELF sections, linker
+ * build time selective sorting (disabled options get ignored), and can
+ * optionally also be used to help you avoid code bit-rot due to #ifdery
+ * collateral.
+ */
+
+/**
+ * DOC: Linker table provenance and userspace testing
+ *
+ * The Linux implementation of linker tables is derivative of iPXE linker
+ * table's solution (iPXE commit 67a10ef000cb7 [0]).  To see how this code
+ * evolved or to extend and test and use this code in userspace refer to the
+ * userspace linker-table tree [1].  This repository can be used for ease of
+ * testing of extensions and sampling of changes prior to inclusion into Linux,
+ * it is intended to be kept up to date to match Linux's solution. Contrary to
+ * iPXE's solution, which strives to force compilation of everything using
+ * linker tables, Linux's solution allows for developers to be selective over
+ * where one wishes to force compilation, this then is just an optional feature
+ * for the Linux linker table solution.
+ *
+ * [0] git://git.ipxe.org/ipxe.git
+ *
+ * [1] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linker-tables.git/
+ */
+
+/**
+ * DOC: The code bit-rot problem
+ *
+ * Overuse of C #ifdefs can be problematic for certain types of code.  Linux
+ * provides a rich array of features, but all these features take up valuable
+ * space in a kernel image. The traditional solution to this problem has been
+ * for each feature to have its own Kconfig entry and for the respective code
+ * to be wrapped around #ifdefs, allowing the feature to be compiled in only
+ * if desired.
+ *
+ * The problem with this is that over time it becomes very difficult and time
+ * consuming to compile, let alone test, all possible versions of Linux. Code
+ * that is not typically used tends to suffer from bit-rot over time. It can
+ * become difficult to predict which combinations of compile-time options will
+ * result in code that can compile and link correctly.
+ */
+
+/**
+ * DOC: Avoiding the code bit-rot problem when desirable
+ *
+ * To solve the code bit-rot problem linker tables can be used on Linux, it
+ * enables you to always force compiling of select features that one wishes to
+ * avoid bit-rot while still enabling you to disable linking feature code into
+ * the final kernel image if the features have been disabled via Kconfig.
+ * Linux's linker tables allows for developers to be selective over where one
+ * wishes to take advantage of the optional feature of forcing compilation and
+ * only linking in enabled features.
+ *
+ * To use linker tables and to optionally take advantage of avoiding code
+ * bit-rot, feature code should be implemented in separate C files, and should
+ * be designed to always be compiled -- they should not be guarded with a C
+ * code #ifdef CONFIG_FOO statements, consideration must also be taken for
+ * sub-features which depend on the main CONFIG_FOO option, as they will be
+ * disabled if they depend on CONFIG_FOO and therefore not compiled. To force
+ * compilation and only link when features are needed a new optional target
+ * table-y can be used on Makefiles, documented below.
+ *
+ * Currently only built-in features are supported, modular support is not
+ * yet supported, however you can make use of sub-features for modules
+ * if they are independent and can simply be linked into modules.
+ */
+
+/**
+ * DOC: Using target table-y and table-n
+ *
+ * Let's assume we want to always force compilation of feature FOO in the
+ * kernel but avoid linking it. When you enable the FOO feature via Kconfig
+ * you'd end up with:
+ *
+ *	#define CONFIG_FOO 1
+ *
+ * You typically would then just use this on your Makefile to selectively
+ * compile and link the feature:
+ *
+ *	obj-$(CONFIG_FOO) += foo.o
+ *
+ * You could instead optionally use the new linker table object:
+ *
+ *	table-$(CONFIG_FOO) += foo.o
+ *
+ * Alternatively, this would be the equivalent of listing:
+ *
+ *	extra += foo.o
+ *	obj-$(CONFIG_FOO) += foo.o
+ *
+ * Both are mechanisms which can be used to take advantage of forcing
+ * compilation with linker tables, however making use of table-$(CONFIG_FOO)
+ * is encouraged as it helps with annotating linker tables clearly where
+ * compilation is forced.
+ */
+
+/**
+ * DOC: Opting out of forcing compilation
+ *
+ * If you want to opt-out of forcing compilation you would use the typical
+ * obj-$(CONFIG_FOO) += foo.o and foo.o will only be compiled and linked
+ * in when enabled. Using both table-$(CONFIG_FOO) and obj-($CONFIG_FOO)
+ * will result with the feature on your binary only if you've enabled
+ * CONFIG_FOO, however using table-$(CONFIG_FOO) will always force compilation,
+ * this is why avoiding code bit-rot is an optional fature for Linux linker
+ * tables.
+ */
+
+/**
+ * DOC: How linker tables simplify inits
+ *
+ * Traditionally, we would implement features in C code as follows:
+ *
+ *	foo_init();
+ *
+ * You'd then have a foo.h which would have:
+ *
+ *	#ifdef CONFIG_FOO
+ *	#else
+ *	static inline void foo(void) { }
+ *	#endif
+ *
+ * With linker tables this is no longer necessary as your init routines would
+ * be implicit, you'd instead call:
+ *
+ *	call_init_fns();
+ *
+ * call_init_fns() would call all functions present in your init table and if
+ * and only if foo.o gets linked in, then its initialisation function will be
+ * called, whether you use obj-$(CONFIG_FOO) or table-$(CONFIG_FOO).
+ *
+ * The linker script takes care of assembling the tables for us. All of our
+ * table sections have names of the format SECTION_NAME*.tbl.NAME.N. Here
+ * SECTION_NAME is one of the standard sections in include/linux/sections.h,
+ * and NAME designates the specific use case for the linker table, the table.
+ * N is a digit decimal number used to impose an "order level" upon the tables
+ * if required. NN= (empty string) is reserved for the symbol indicating "table
+ * start", and N=~ is reserved for the symbol indicating "table end". In order
+ * for the call_init_fns() to work behind the scenes the custom linker script
+ * would need to define the beginning of the table, the end of the table, and
+ * in between it should use SORT() to give order-level effect. Now, typically
+ * such type of requirements would require custom linker script modifications
+ * but Linux's linker tables builds on top of already existing standard Linux
+ * ELF sections, each with different purposes. This lets you build and add
+ * new tables without needing custom linker script modifications. This is
+ * also done to support all architectures. All that is needed then is to
+ * ensure a respective common linker table entry is added to the shared
+ * include/asm-generic/vmlinux.lds.h. There should be a respective:
+ *
+ *	*(SORT(SECTION_TBL_ALL(SECTION_NAME)))
+ *
+ * entry for each type of supported section there. If your SECTION_NAME
+ * is not yet supported, consider adding support for it.
+ *
+ * The order-level is really only a helper, if only one order level is
+ * used, the next contributing factor to order is the order of the code
+ * in the C file, and the order of the objects in the Makefile. Using
+ * an order level then should not really be needed in most cases, its
+ * use however enables to compartamentalize code into tables where ordering
+ * through C file or through the Makefile would otherwise be very difficult
+ * or if one wanted to enable very specific initialization semantics.
+ *
+ * As an example, suppose that we want to create a "frobnicator"
+ * feature framework, and allow for several independent modules to
+ * provide frobnicating services. Then we would create a frob.h
+ * header file containing e.g.
+ *
+ *	struct frobnicator {
+ *		const char *name;
+ *		void (*frob) (void);
+ *	};
+ *
+ *	DECLARE_LINKTABLE(struct frobnicator, frobnicator_fns);
+ *
+ * Any module providing frobnicating services would look something
+ * like
+ *
+ *	#include "frob.h"
+ *	static void my_frob(void) {
+ *		... Do my frobnicating
+ *	}
+ *	LINKTABLE_INIT_DATA(frobnicator_fns, all) my_frobnicator = {
+ *		.name = "my_frob",
+ *		.frob = my_frob,
+ *	};
+ *
+ * The central frobnicator code (frob.c) would use the frobnicating
+ * modules as follows
+ *
+ *	#include "frob.h"
+ *
+ *	void frob_all(void) {
+ *		struct frob *frob;
+ *
+ *		LINKTABLE_FOR_EACH(frob, frobnicator_fns) {
+ *			pr_info("Calling frobnicator \"%s\"\n", frob->name);
+ *			frob->frob();
+ *		}
+ *	}
+ */
+
+/**
+ * DOC: Linker table helpers
+ *
+ * These are helpers for linker tables.
+ */
+
+/**
+ * LINKTABLE_ADDR_WITHIN - returns true if address is in range
+ *
+ * @tbl: linker table
+ * @addr: address to query for
+ *
+ * Returns true if the address is part of the linker table.
+ */
+#define LINKTABLE_ADDR_WITHIN(tbl, addr)				\
+	 (addr >= (unsigned long) LINUX_SECTION_START(tbl) &&		\
+          addr < (unsigned long) LINUX_SECTION_END(tbl))
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
+	      __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_DATA, name, level))))
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
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_TEXT, name, level))))
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
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_RODATA, name, level))))
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
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_INIT, name, level))))
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
+	      __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_INIT_DATA, name, level))))
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
+	      __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_DATA, name, level))))
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
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_TEXT, name, level))))
+
+/**
+ * LINKTABLE_RO - Declares a read-only linker table entry.
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Declares a linker table which only requires read-only access.
+ */
+#define LINKTABLE_RO(name, level)					\
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_RODATA, name, level))))
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
+	const __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     __aligned__(LINUX_SECTION_ALIGN_FUNC),	\
+			     section(SECTION_TBL(SECTION_INIT, name, level))))
+
+/**
+ * LINKTABLE_INIT_DATA - Declares a linker table entry to be used on init data.
+ *
+ * @name: linker table name
+ * @level: order level
+ *
+ * Declares a linker table entry for data during init.
+ */
+#define LINKTABLE_INIT_DATA(name, level)					\
+	      __typeof__(name[0])					\
+	      __attribute__((used,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_TBL(SECTION_INIT_DATA, name, level))))
+
+/**
+ * DOC: Declaring Linker tables
+ *
+ * Declarers are used to help code access the linker tables. Typically
+ * header files for subsystems would declare the linker tables to enable
+ * easy access to add new entries, and to iterate over the list of table.
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
+	LINKTABLE_WEAK(name, ) VMLINUX_SYMBOL(name)[0] = {};		\
+	LINKTABLE(name, ~) VMLINUX_SYMBOL(name##__end)[0] = {};
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
+	LINKTABLE_TEXT_WEAK(name, ) VMLINUX_SYMBOL(name)[0] = {};	\
+	LINKTABLE_TEXT(name, ~) VMLINUX_SYMBOL(name##__end)[0] = {};
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
+	LINKTABLE_RO_WEAK(name, ) VMLINUX_SYMBOL(name)[0] = {};		\
+	LINKTABLE_RO(name, ~) VMLINUX_SYMBOL(name##__end)[0] = {};
+
+/**
+ * DEFINE_LINKTABLE_INIT - Defines an init time linker table for execution
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Defines a linker table. If you are adding a new type you should
+ * enable CONFIG_DEBUG_SECTION_MISMATCH and ensure routines that make
+ * use of the linker tables get a respective __ref tag.
+ */
+#define DEFINE_LINKTABLE_INIT(type, name)				\
+	DECLARE_LINKTABLE(type, name);					\
+	LINKTABLE_INIT_WEAK(name, ) VMLINUX_SYMBOL(name)[0] = {};	\
+	LINKTABLE_INIT(name, ~) VMLINUX_SYMBOL(name##__end)[0] = {};
+
+/**
+ * DEFINE_LINKTABLE_INIT_DATA - Defines an init time linker table for data
+ *
+ * @type: data type
+ * @name: table name
+ *
+ * Defines a linker table for init data. If you are adding a new type you
+ * should enable CONFIG_DEBUG_SECTION_MISMATCH and ensure routines that make
+ * use of the linker tables get a respective __ref tag.
+ */
+#define DEFINE_LINKTABLE_INIT_DATA(type, name)				\
+	DECLARE_LINKTABLE(type, name);					\
+	LINKTABLE_INIT_DATA_WEAK(name, ) VMLINUX_SYMBOL(name)[0] = {};	\
+	LINKTABLE_INIT_DATA(name, ~) VMLINUX_SYMBOL(name##__end)[0] = {};
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
+ * Example usage:
+ *
+ *   struct frobnicator *frob;
+ *
+ *   LINKTABLE_FOR_EACH(frob, frobnicator_fns) {
+ *     ...
+ *   }
+ */
+
+#define LINKTABLE_FOR_EACH(pointer, tbl)				\
+	for (pointer = LINUX_SECTION_START(tbl);			\
+	     pointer < LINUX_SECTION_END(tbl);				\
+	     pointer++)
+
+/**
+ * LINKTABLE_RUN_ALL - iterate and run through all entries on a linker table
+ *
+ * @tbl: linker table
+ * @func: structure name for the function name we want to call.
+ * @args...: arguments to pass to func
+ *
+ * Example usage:
+ *
+ *   LINKTABLE_RUN_ALL(frobnicator_fns, some_run,);
+ */
+#define LINKTABLE_RUN_ALL(tbl, func, args...)				\
+do {									\
+	size_t i;							\
+	for (i = 0; i < LINUX_SECTION_SIZE(tbl); i++)			\
+		(tbl[i]).func (args);					\
+} while (0);
+
+/**
+ * LINKTABLE_RUN_ERR - run each linker table entry func and return error if any
+ *
+ * @tbl: linker table
+ * @func: structure name for the function name we want to call.
+ * @args...: arguments to pass to func
+ *
+ * Example usage:
+ *
+ *   unsigned int err = LINKTABLE_RUN_ERR(frobnicator_fns, some_run,);
+ */
+#define LINKTABLE_RUN_ERR(tbl, func, args...)				\
+({									\
+	size_t i;							\
+	int err = 0;							\
+	for (i = 0; !err && i < LINUX_SECTION_SIZE(tbl); i++)		\
+		err = (tbl[i]).func (args);				\
+		err; \
+})
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _LINUX_LINKER_TABLES_H */
diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 11602e5efb3b..002857fe8d0d 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -91,7 +91,7 @@ modorder-target := $(obj)/modules.order
 
 # We keep a list of all modules in $(MODVERDIR)
 
-__build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target) $(extra-y)) \
+__build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target) $(extra-y) $(table-y)) \
 	 $(if $(KBUILD_MODULES),$(obj-m) $(modorder-target)) \
 	 $(subdir-ym) $(always)
 	@:
@@ -326,7 +326,7 @@ $(obj)/%.o: $(src)/%.S $(objtool_obj) FORCE
 	$(call if_changed_rule,as_o_S)
 
 targets += $(real-objs-y) $(real-objs-m) $(lib-y)
-targets += $(extra-y) $(MAKECMDGOALS) $(always)
+targets += $(extra-y) $(table-y) $(MAKECMDGOALS) $(always)
 
 # Linker scripts preprocessor (.lds.S -> .lds)
 # ---------------------------------------------------------------------------
diff --git a/scripts/Makefile.clean b/scripts/Makefile.clean
index 50616ea25131..bdc29810dae5 100644
--- a/scripts/Makefile.clean
+++ b/scripts/Makefile.clean
@@ -36,6 +36,7 @@ subdir-ymn	:= $(addprefix $(obj)/,$(subdir-ymn))
 # directory
 
 __clean-files	:= $(extra-y) $(extra-m) $(extra-)       \
+		   $(table-y) $(table-m) $(table-)       \
 		   $(always) $(targets) $(clean-files)   \
 		   $(host-progs)                         \
 		   $(hostprogs-y) $(hostprogs-m) $(hostprogs-) \
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 0a07f9014944..494f215ebaa4 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -12,6 +12,16 @@ export KBUILD_SUBDIR_CCFLAGS := $(KBUILD_SUBDIR_CCFLAGS) $(subdir-ccflags-y)
 # Figure out what we need to build from the various variables
 # ===================================== 
+# Linker tables objects always wish to be built to avoid bit-rot in
+# code, but only linked in *iff* they were enabled. We accomplish this
+# using pegging linker table objects into extra-y, which forces
+# compilation and then using the respective table-y and table-m as
+# as hints for things we do want enabled. Objects which we want to
+# avoid linking in will be in table-, not table-y and table-m.
+extra-y += $(table-)
+obj-m += $(table-m)
+obj-y += $(table-y)
+
 # When an object is listed to be built compiled-in and modular,
 # only build the compiled-in version
 
@@ -72,6 +82,8 @@ real-objs-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)
 # Add subdir path
 
 extra-y		:= $(addprefix $(obj)/,$(extra-y))
+table-y		:= $(addprefix $(obj)/,$(table-y))
+table-m		:= $(addprefix $(obj)/,$(table-m))
 always		:= $(addprefix $(obj)/,$(always))
 targets		:= $(addprefix $(obj)/,$(targets))
 modorder	:= $(addprefix $(obj)/,$(modorder))
diff --git a/tools/include/linux/sections.h b/tools/include/linux/sections.h
new file mode 100644
index 000000000000..cc6f07f11583
--- /dev/null
+++ b/tools/include/linux/sections.h
@@ -0,0 +1,13 @@
+#ifndef _TOOLS_LINUX_SECTIONS_H_
+
+/* Mostly a copy of what we need only */
+
+#define SECTION_INIT			.init.text
+#define SECTION_RODATA			.rodata
+
+#define ___SECTION_TBL_STR(section, name)				\
+	#section ".tbl." #name
+#define SECTION_TBL_ALL_STR(section)					\
+	___SECTION_TBL_STR(section, *)
+
+#endif /* _TOOLS_LINUX_SECTIONS_H_ */
-- 
2.8.4

