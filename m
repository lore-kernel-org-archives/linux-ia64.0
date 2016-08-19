From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:32:53 +0000
Subject: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <1471642385-5629-5-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, acme@redhat.com, ak@linux.intel.com, andriy.shevchenko@linux.intel.com, mcb30@ip

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

Linux makes extensive use of custom ELF header sections,
documentation for these are well scatterred. Unify this
documentation in a central place and provide helpers to
build custom Linux sections.

This also generalizes sections code to enable avoiding
modifying the linker scripts when we want to add new
custom Linux sections. In order to make this generally
useful we need to ensure all architectures can make use of
core section helpers but that they can also override should
this be needed. Instead of relying on section.h this adds
a sections-core.h since this will be targetted to be safe
to be used on asm code, linker scripts and C code.

v4:

o Port to shiny new sphinx documentation format

o fix a unicore32 build, turns out this actually fixes unicore32
  defconfig builds which were failing for a long while. unicore32
  does not seem to grok well the type passed on a section declaration,
  this ignores it.

o Use VMLINUX_SYMBOL() in more user symbols (extern C code), not doing
  this was causing final linker issues with blackfin -- this is
  a CONFIG_HAVE_UNDERSCORE_SYMBOL_PREFIX=y architecture. The other one
  being metatag. metatag is not supported on 0-day so I cannot confirm
  compilation there.

o Added SECTION_CORE() for C code, used later by __LINUX_RANGE()

o Since SECTION_CORE() is defined for linker script and C code, share
  the same helper and just use a __stringify() for the C code as is done
  for the other C helpers.

o move generic sections to asm-generic/section-core.h instead.
  PowerPC compilation blows up if asm/jump_labels.h gets
  section.h included, fixing this is not in any way easy.
  The list of issues are endless. Moving new data to a new
  simple file resolves this.

o since things are now in asm-generic/section-core.h the
  guard changes on asm-generic/sections.h and each architecture
  sections.h are no longer needed

o Give generic sections some maintainer love, that change is
  Acked-by Arnd Bergmann, Josh and hpa.

o A few checkpatch.pl style fixes

o As suggested by James Hogan use generic-y to copy generic
  header files on architectures that do not have a sections.h
  instead of writing a simple file only to include the generic one.

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
 Documentation/index.rst                   |   1 +
 Documentation/sections/conf.py            |   4 +
 Documentation/sections/index.rst          |  11 +
 Documentation/sections/section-core.rst   | 153 ++++++++++++++
 MAINTAINERS                               |  14 ++
 arch/alpha/include/asm/Kbuild             |   1 +
 arch/arc/include/asm/Kbuild               |   1 +
 arch/arm/include/asm/Kbuild               |   1 +
 arch/arm64/include/asm/Kbuild             |   1 +
 arch/avr32/include/asm/Kbuild             |   1 +
 arch/blackfin/include/asm/Kbuild          |   1 +
 arch/c6x/include/asm/Kbuild               |   1 +
 arch/cris/include/asm/Kbuild              |   1 +
 arch/frv/include/asm/Kbuild               |   1 +
 arch/h8300/include/asm/Kbuild             |   1 +
 arch/hexagon/include/asm/Kbuild           |   1 +
 arch/ia64/include/asm/Kbuild              |   1 +
 arch/m32r/include/asm/Kbuild              |   1 +
 arch/m68k/include/asm/Kbuild              |   1 +
 arch/metag/include/asm/Kbuild             |   1 +
 arch/microblaze/include/asm/Kbuild        |   1 +
 arch/mips/include/asm/Kbuild              |   1 +
 arch/mn10300/include/asm/Kbuild           |   1 +
 arch/nios2/include/asm/Kbuild             |   1 +
 arch/openrisc/include/asm/Kbuild          |   1 +
 arch/parisc/include/asm/Kbuild            |   1 +
 arch/powerpc/include/asm/Kbuild           |   1 +
 arch/s390/include/asm/Kbuild              |   1 +
 arch/score/include/asm/Kbuild             |   1 +
 arch/sh/include/asm/Kbuild                |   1 +
 arch/sparc/include/asm/Kbuild             |   1 +
 arch/tile/include/asm/Kbuild              |   1 +
 arch/um/include/asm/Kbuild                |   1 +
 arch/unicore32/include/asm/section-core.h |  19 ++
 arch/x86/include/asm/Kbuild               |   1 +
 arch/xtensa/include/asm/Kbuild            |   1 +
 include/asm-generic/section-core.h        | 341 ++++++++++++++++++++++++++++++
 include/asm-generic/sections.h            |   2 +
 include/asm-generic/vmlinux.lds.h         |  27 +--
 include/linux/sections.h                  | 111 ++++++++++
 40 files changed, 700 insertions(+), 13 deletions(-)
 create mode 100644 Documentation/sections/conf.py
 create mode 100644 Documentation/sections/index.rst
 create mode 100644 Documentation/sections/section-core.rst
 create mode 100644 arch/unicore32/include/asm/section-core.h
 create mode 100644 include/asm-generic/section-core.h
 create mode 100644 include/linux/sections.h

diff --git a/Documentation/index.rst b/Documentation/index.rst
index a15f81855b39..10c9b867e326 100644
--- a/Documentation/index.rst
+++ b/Documentation/index.rst
@@ -14,6 +14,7 @@ Contents:
    kernel-documentation
    media/index
    gpu/index
+   sections/index
 
 Indices and tables
 =========
diff --git a/Documentation/sections/conf.py b/Documentation/sections/conf.py
new file mode 100644
index 000000000000..faa1c57595e1
--- /dev/null
+++ b/Documentation/sections/conf.py
@@ -0,0 +1,4 @@
+# -*- coding: utf-8; mode: python -*-
+
+project = 'Linux Kernel ELF sections'
+html_search_language = 'en'
diff --git a/Documentation/sections/index.rst b/Documentation/sections/index.rst
new file mode 100644
index 000000000000..d411e9b22eb3
--- /dev/null
+++ b/Documentation/sections/index.rst
@@ -0,0 +1,11 @@
+============+Linux Kernel ELF sections
+============+
+This book documents the Linux kernel's use of ELF sections, as well as helpers
+used throughout the kernel to help declare and define them.
+
+.. toctree::
+   :maxdepth: 4
+
+   section-core
diff --git a/Documentation/sections/section-core.rst b/Documentation/sections/section-core.rst
new file mode 100644
index 000000000000..ecf4228bc4f8
--- /dev/null
+++ b/Documentation/sections/section-core.rst
@@ -0,0 +1,153 @@
+===============
+Core Linux kernel ELF sections
+===============
+
+About
+==+
+This book documents the different standard and custom ELF sections used
+on the Linux kernel, which we refer to as the ``core Linux sections``. We
+start off by documenting the standard ELF sections used by Linux and move
+on to the basic custom ELF sections, followed by a set of helpers. Each
+section documented describes the goal of the section, and addresses
+concurrency considerations when applicable.
+
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: Custom linker script
+
+Standard ELF section use in Linux
+================+
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: Standard ELF section use in Linux
+
+SECTION_RODATA
+--------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_RODATA
+
+SECTION_RODATA
+--------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_TEXT
+
+SECTION_DATA
+------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_DATA
+
+Linux .init\* sections
+===========
+
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: Linux init sections
+
+SECTION_INIT_DATA
+-----------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_INIT_DATA
+
+SECTION_INIT_RODATA
+-------------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_INIT_RODATA
+
+SECTION_INIT_CALL
+-----------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_INIT_CALL
+
+Linux .exit\* sections
+===========
+
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: Linux exit sections
+
+SECTION_EXIT
+------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_EXIT
+
+SECTION_EXIT_DATA
+-----------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_EXIT_DATA
+
+SECTION_EXIT_CALL
+-----------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_EXIT_CALL
+
+Linux .ref\* sections
+==========+
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: Linux references to init sections
+
+SECTION_REF
+-----------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_REF
+
+SECTION_REF_DATA
+----------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_REF_DATA
+
+SECTION_REF_RODATA
+------------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_REF_RODATA
+
+Linux section ordering
+===========
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: Linux section ordering
+
+SECTION_ORDER_ANY
+-----------------
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: SECTION_ORDER_ANY
+
+Generic Linux kernel section helpers
+==================
+
+Introduction
+-------------
+.. kernel-doc:: include/linux/sections.h
+   :doc: Introduction
+
+LINUX_SECTION_ALIGNMENT
+-----------------------
+.. kernel-doc:: include/linux/sections.h
+   :functions: LINUX_SECTION_ALIGNMENT
+
+LINUX_SECTION_SIZE
+------------------
+.. kernel-doc:: include/linux/sections.h
+   :functions: LINUX_SECTION_SIZE
+
+LINUX_SECTION_EMPTY
+-------------------
+.. kernel-doc:: include/linux/sections.h
+   :functions: LINUX_SECTION_EMPTY
+
+LINUX_SECTION_START
+-------------------
+.. kernel-doc:: include/linux/sections.h
+   :functions: LINUX_SECTION_START
+
+LINUX_SECTION_END
+-----------------
+.. kernel-doc:: include/linux/sections.h
+   :functions: LINUX_SECTION_END
+
+DECLARE_LINUX_SECTION
+---------------------
+.. kernel-doc:: include/linux/sections.h
+   :functions: DECLARE_LINUX_SECTION
+
+DECLARE_LINUX_SECTION_RO
+------------------------
+.. kernel-doc:: include/linux/sections.h
+   :functions: DECLARE_LINUX_SECTION_RO
diff --git a/MAINTAINERS b/MAINTAINERS
index 5aec01883020..689c12075842 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5217,6 +5217,20 @@ S:	Supported
 F:	drivers/base/power/domain*.c
 F:	include/linux/pm_domain.h
 
+GENERIC SECTIONS
+M:	"Luis R. Rodriguez" <mcgrof@kernel.org>
+M:	Josh Poimboeuf <jpoimboe@redhat.com>
+M:	"H. Peter Anvin" <hpa@zytor.com>
+L:	linux-arch@vger.kernel.org
+L:	linux-kernel@vger.kernel.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git for-arnd
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux-next.git for-arnd
+S:	Supported
+F:	include/asm-generic/section-core.h
+F:	include/asm-generic/sections.h
+F:	include/asm-generic/vmlinux.lds.h
+F:	Documentation/sections/section-core.rst
+
 GENERIC UIO DRIVER FOR PCI DEVICES
 M:	"Michael S. Tsirkin" <mst@redhat.com>
 L:	kvm@vger.kernel.org
diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index bf8475ce85ee..5422827f1585 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -10,3 +10,4 @@ generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
+generic-y += section-core.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 0b10ef2a4372..9a0929576de1 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -50,3 +50,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 0745538b26d3..47923635be16 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -39,3 +39,4 @@ generic-y += termios.h
 generic-y += timex.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
+generic-y += section-core.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index f43d2c44c765..42d00806e4fb 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -52,3 +52,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 241b9b9729d8..f2c3b656a0e7 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -22,3 +22,4 @@ generic-y += trace_clock.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index 91d49c0a3118..7de674411bed 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -48,3 +48,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index 64465e7e2245..38127ce747be 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -62,3 +62,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 1778805f6380..385cd88a9d9e 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -45,3 +45,4 @@ generic-y += types.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 1fa084cf1a43..46d7c599d9b8 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -8,3 +8,4 @@ generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 373cb23301e3..1ec04ec1c82b 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -75,3 +75,4 @@ generic-y += unaligned.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index db8ddabc6bd2..37d7bfae7619 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -60,3 +60,4 @@ generic-y += unaligned.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 502a91d8dbbd..672c6d5da18c 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -9,3 +9,4 @@ generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += vtime.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 860e440611c9..6111e1523750 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index eb85bd9c6180..eef72c464c9b 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -35,3 +35,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 29acb89daaaa..50ebd5a30d16 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -56,3 +56,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index b0ae88c9fed9..c6c2cf6edc98 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += preempt.h
 generic-y += syscalls.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 9740066cc631..12f7c5984c03 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -20,3 +20,4 @@ generic-y += trace_clock.h
 generic-y += user.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 1c8dd0f5cd5d..f8145bc85835 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -10,3 +10,4 @@ generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index d63330e88379..c9c7cb82b00f 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -63,3 +63,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 2832f031fb11..86175e701869 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -71,3 +71,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index f9b3a81aefcd..6f43f33f0e0f 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -29,3 +29,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index ab9f4e0ed4cf..b49fab7bab2f 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -7,3 +7,4 @@ generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += vtime.h
+generic-y += section-core.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 20f196b82a6e..89e74b59f32d 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -8,3 +8,4 @@ generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index a05218ff3fe4..f089a264cd38 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -14,3 +14,4 @@ generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += serial.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 751c3373a92c..7b0356dca562 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -39,3 +39,4 @@ generic-y += termios.h
 generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index cfc918067f80..d51b84d6b4b7 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -22,3 +22,4 @@ generic-y += serial.h
 generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
+generic-y += section-core.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index ba35c41c71ff..7b8a652e43ae 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -41,3 +41,4 @@ generic-y += termios.h
 generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index 904f3ebf4220..e9849834d55e 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -27,3 +27,4 @@ generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/arch/unicore32/include/asm/section-core.h b/arch/unicore32/include/asm/section-core.h
new file mode 100644
index 000000000000..ebffeed8835d
--- /dev/null
+++ b/arch/unicore32/include/asm/section-core.h
@@ -0,0 +1,19 @@
+#ifndef __UNICORE_SECTION_CORE_ASM_H__
+#define __UNICORE_SECTION_CORE_ASM_H__
+/*
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+
+/* Unicore32 has known to not work properly with the type set, so ignore it */
+
+#define __set_section_core_type(___section, ___core, ___name,		\
+				___level, ___flags, ___type)		\
+	.section ___section.___core.___name.___level, ___flags
+
+#include <asm-generic/section-core.h>
+
+#endif /* __UNICORE_SECTION_CORE_ASM_H__ */
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 2cfed174e3c9..f6914a57bc16 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -16,3 +16,4 @@ generic-y += dma-contiguous.h
 generic-y += early_ioremap.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += section-core.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 28cf4c5d65ef..81ca6816bd72 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -31,3 +31,4 @@ generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += section-core.h
diff --git a/include/asm-generic/section-core.h b/include/asm-generic/section-core.h
new file mode 100644
index 000000000000..2ab57e2c4117
--- /dev/null
+++ b/include/asm-generic/section-core.h
@@ -0,0 +1,341 @@
+#ifndef _ASM_GENERIC_SECTION_CORE_H_
+#define _ASM_GENERIC_SECTION_CORE_H_
+/*
+ * Linux section core definitions
+ *
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+
+/**
+ * DOC: Custom linker script
+ *
+ * The Linux vmlinux binary uses a custom linker script on each architecture
+ * which it uses to strategically place standard ELF sections and also adds
+ * custom specialized ELF sections. Each architecture defines its own custom
+ * linker defined in arch/$(ARCH)/kernel/vmlinux.lds.S -- these in turn
+ * include and use definitions in include/asm-generic/vmlinux.lds.h as well
+ * as some helpers documented in this chaper.
+ */
+
+/**
+ * DOC: Standard ELF section use in Linux
+ *
+ * Linux makes use of the standard ELF sections, this sections documents
+ * these.
+ */
+
+/**
+ * DOC: SECTION_RODATA
+ *
+ * Macro name for code which must be protected from write access, read only
+ * data.
+ */
+#define SECTION_RODATA			.rodata
+
+/**
+ * DOC: SECTION_TEXT
+ *
+ * Macro name used to annotate code (functions) used during regular
+ * kernel run time. This is combined with `SECTION_RODATA`, only this
+ * section also allows for execution.
+ *
+ */
+#define SECTION_TEXT			.text
+
+/**
+ * DOC: SECTION_DATA
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
+ * DOC: SECTION_INIT
+ *
+ * Macro name used to annotate code (functions) used only during boot or driver
+ * initialization.
+ *
+ */
+#define SECTION_INIT			.init.text
+
+/**
+ * DOC: SECTION_INIT_DATA
+ *
+ * Macro name used to annotate data structures used only during boot or driver
+ * initialization.
+ */
+#define SECTION_INIT_DATA		.init.data
+
+/**
+ * DOC: SECTION_INIT_RODATA
+ *
+ * Macro name used to annotate read-only code (functions) used only during boot
+ * or driver initialization.
+ */
+#define SECTION_INIT_RODATA		.init.rodata
+
+/**
+ * DOC: SECTION_INIT_CALL
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
+ * DOC: SECTION_EXIT
+ *
+ * Macro name used to annotate code (functions) used only during module
+ * unload.
+ */
+#define SECTION_EXIT			.exit.text
+
+/**
+ * DOC: SECTION_EXIT_DATA
+ *
+ * Macro name used to annotate data structures used only during module
+ * unload.
+ */
+#define SECTION_EXIT_DATA		.exit.data
+
+/**
+ * DOC: SECTION_EXIT_CALL
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
+ * sectioned code is valid. For more details refer to ``include/linux/init.h``
+ * ``__ref``, ``__refdata``, and ``__refconst`` documentation.
+ */
+
+/**
+ * DOC: SECTION_REF
+ *
+ * Macro name used to annotate that code (functions) declared with this section
+ * has been vetteed as valid for its reference or use of other code (functions)
+ * or data structures which are part of the init sections.
+ */
+#define SECTION_REF			.ref.text
+
+/**
+ * DOC: SECTION_REF_DATA
+ *
+ * Macro name used to annotate data structures declared with this section have
+ * been vetteed for its reference or use of other code (functions) or data
+ * structures part of the init sections.
+ */
+#define SECTION_REF_DATA		.ref.data
+
+/**
+ * DOC: SECTION_REF_RODATA
+ *
+ * Macro name used to annotate const code (functions) const data structures
+ * which has been vetteed for its reference or use of other code (functions)
+ * or data structures part of the init sections.
+ */
+#define SECTION_REF_RODATA		.ref.rodata
+
+/**
+ * DOC: Linux section ordering
+ *
+ * Linux may use binutils linker-script 'SORT()' on sections to sort Linux
+ * sections. Linux has used 'SORT()' in ``include/asm-generic/vmlinux.lds.h``
+ * for years.
+ */
+
+/**
+ * DOC: SECTION_ORDER_ANY
+ *
+ * Macro name which can be used as helper to annotate custom section
+ * ordering at link time is not relevant for specific sections.
+ */
+#define SECTION_ORDER_ANY	any
+
+/*
+ * These section _ALL() helpers are for use on linker scripts and helpers
+ */
+#define SECTION_ALL(__section)						\
+	__section##.*
+
+#define __SECTION_CORE(__section, __core, __name, __level)		\
+	__section.__core.__name.__level
+
+#define SECTION_CORE_ALL(__section, __core)				\
+	__section##.##__core##.*
+
+/* Can be used on foo.S for instance */
+#ifndef __set_section_core_type
+# define __set_section_core_type(___section, ___core, ___name,		\
+				 ___level, ___flags, ___type)		\
+	.section ___section.___core.___name.___level, ___flags, ___type
+#endif
+
+#ifndef __set_section_core
+# define __set_section_core(___section, ___core, ___name, ___level, ___flags) \
+	.section ___section.___core.___name.___level, ___flags
+#endif
+
+#ifndef __push_section_core
+# define __push_section_core(__section, __core, __name, __level, __flags) \
+	.pushsection __section.__core.__name.__level, __flags
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
+#  ifndef SECTION_CORE
+#   define SECTION_CORE(__section, __core, __name, __level)		\
+	__SECTION_CORE(__section,__core,__name,__level)
+#  endif
+
+# else
+
+#  ifndef SECTION_CORE
+#   define SECTION_CORE(__section, __core, __name, __level)		\
+	push_section_core(__section, __core, __name, __level,)
+#  endif
+
+#  ifndef push_section_core
+#   define push_section_core(__section, __core, __name, __level, __flags) \
+	 __push_section_core(__section, __core, __name,			  \
+			     __level, __stringify(__flags))
+#  endif
+
+#  ifndef set_section_core
+#   define set_section_core(__section, __core, __name,			\
+			    __level, __flags)				\
+	__set_section_core(__section, __core, __name,			\
+			   __level, __stringify(__flags))
+#  endif
+
+#  ifndef set_section_core_type
+#   define set_section_core_type(__section, __core, __name,		\
+				 __level, __flags, __type)		\
+	__set_section_core_type(__section, __core, __name, __level,	\
+				__stringify(__flags), __type)
+#  endif
+
+# endif /* LINKER_SCRIPT */
+#else /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
+
+# ifndef SECTION_CORE
+#  define SECTION_CORE(__section, __core, __name, __level)		\
+	__stringify(__SECTION_CORE(__section,__core,__name,__level))
+# endif
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
+# ifndef set_section_core
+#  define set_section_core(__section, __core, __name, __level, __flags)	\
+	__stringify(__set_section_core_type(__section, __core, __name,	\
+					    __level, __stringify(__flags))) \
+	ASM_CMD_SEP
+# endif
+
+/*
+ * Some architectures (arm, and avr32 are two examples on kprobes) seem
+ * currently explicitly specify the type [0] -- this can be any of the
+ * optional constants on ELF:
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
+# ifndef set_section_core_type
+#  define set_section_core_type(__section, __core, __name, __level,	\
+				__flags, __type)			\
+	__stringify(__set_section_core_type(__section, __core,		\
+					    __name, __level,		\
+					    __stringify(__flags),	\
+					    __type))			\
+	ASM_CMD_SEP
+# endif
+
+# ifndef push_section_core
+#  define push_section_core(__section, __core, __name,			\
+			    __level, __flags)				\
+	__stringify(__push_section_core(__section, __core,		\
+					__name,	__level,		\
+					__stringify(__flags)))		\
+	ASM_CMD_SEP
+# endif
+
+#endif /* defined(__ASSEMBLER__) || defined(__ASSEMBLY__) */
+#endif /* _ASM_GENERIC_SECTION_CORE_H_ */
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index af0254c09424..298252df3c81 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_GENERIC_SECTIONS_H_
 #define _ASM_GENERIC_SECTIONS_H_
 
+#include <asm/section-core.h>
+
 /* References to section boundaries */
 
 #include <linux/compiler.h>
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 24563970ff7b..731087276a32 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -55,6 +55,7 @@
 #endif
 
 #include <linux/export.h>
+#include <asm/section-core.h>
 
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
index 000000000000..f21c6ee88ded
--- /dev/null
+++ b/include/linux/sections.h
@@ -0,0 +1,111 @@
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
+#include <asm/section-core.h>
+#include <linux/export.h>
+
+#ifndef __ASSEMBLY__
+
+/**
+ * DOC: Introduction
+ *
+ * Linux defines a set of common helpers which can be used to against its use
+ * of standard or custom Linux sections, this section is dedicated to these
+ * helpers.
+ */
+
+/**
+ * LINUX_SECTION_ALIGNMENT - get section alignment
+ *
+ * @name: section name
+ *
+ * Gives you the alignment for the section.
+ */
+#define LINUX_SECTION_ALIGNMENT(name)	__alignof__(*VMLINUX_SYMBOL(name))
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
+#define LINUX_SECTION_SIZE(name)					\
+	((VMLINUX_SYMBOL(name##__end)) - (VMLINUX_SYMBOL(name)))
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
+#define LINUX_SECTION_START(name)	VMLINUX_SYMBOL(name)
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
+#define LINUX_SECTION_END(name)	VMLINUX_SYMBOL(name##__end)
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
+	 extern type VMLINUX_SYMBOL(name)[], \
+		     VMLINUX_SYMBOL(name##__end)[]
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
+	 extern const type VMLINUX_SYMBOL(name)[],			\
+			   VMLINUX_SYMBOL(name##__end)[]
+
+#define __SECTION_TYPE(section, type, name, level)			\
+	#section "." #type "." #name "." #level
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _LINUX_SECTIONS_H */
-- 
2.9.2

