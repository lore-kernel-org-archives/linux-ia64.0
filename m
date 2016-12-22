From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 22 Dec 2016 02:37:59 +0000
Subject: [PATCH v5 03/14] ranges.h: add helpers to build and identify Linux section ranges
Message-Id: <20161222023811.21246-4-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <20161222023811.21246-1-mcgrof@kernel.org>
In-Reply-To: <20161222023811.21246-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

Section ranges are on one of the types of custom sections
types used in Linux. This provides a series of helpers for
defining them and using them. Most importantly this also
enables us to avoid modifying the linker script when we
add a new section range.

It turns out a lot of custom sections are actually section ranges,
and these are typically spelled out in their architecture specific
asm/sections.h file -- we enable architectures to override what asm
is used for section ranges but start by default trusting the
asm-generic version all around.

Although typically you will not want to have section ranges ordered
we must use SORT() on vmlinux.lds.S for section ranges to enable us
to extend a section range without modifying the linker script. To
accomplish this we use a special order string for the first element
of a section range -- the empty string "" (refer to __SECTION_RANGE_BEGIN()),
then "~" for the last element (refer to __SECTION_RANGE_BEGIN()). If
you use the "any" order for elements in between and use SORT() you end
up keeping any added element in betweeen and a reference to the
beginning and end of the section range without requiring custom linker
script modifications. Specific order annotations are also supported
to help construct synthetic functions, a demo for which will be provided
later.

v5:

o Use ..rng.* instead of .rng.* as suggested by Nicholas Piggin.
  This is the typical way to avoid clash with compiler generated
  section.

o Replace section macros with section names

o Extend commit log to justify SORT() and explain why and how we use
  specific special strings for the beginning, end elements of a section
  range and the "any" order for elements in between.

o Drop SECTION_RNG_ALL() -- we no longer need this on linker scripts

o To make this easier to read, as per Nicholas Piggin, add our own
  SECTION_RANGE_START(), SECTION_RANGE_END(). After reviewing the
  changes affected by this it seemed clearer and better then to also
  use our own specific SECTION_RANGE_SIZE(), and SECTION_RANGE_EMPTY(),
  and SECTION_RANGE_ALIGNMENT() as well.

o We were using LINUX_SECTION_START() and LINUX_SECTION_END() in some places
  but in some other places VMLINUX_SYMBOL(name), VMLINUX_SYMBOL(name##__end).
  Since we are adding SECTION_RANGE_START() and SECTION_RANGE_END() just
  use those consistently.

o Move the linker table *(SORT(.data.rng.*)) to be present before
  the recently added *(.data.[0-9a-zA-Z_]*) to ensure we keep sort order
  on the section range.

o Adds the "Linux section ordering" documentation, as its much more
  relevant after this patch, in particular when treating the "any"
  order level.

o Fix powerpc .text use: -- it does not use TEXT_TEXT so we must
  add our *(SORT(.text.rng.*)) to its linker script manually.

v4:

o tons of documentation love
o fix arch/x86/tools/relocs.c typo - which caused compilation issues
  on old toolchains
o port to new shiny sphinx documentation
o sprinkle a few more needed VMLINUX_SYMBOL() - fixes
  compilation on blackfin
o name changes as suggested by Boris:
- %s/SECTION_TYPE_RANGES/rng/g
- %s/SECTION_TYPE/SECTION_CORE/g
- %s/section_type_asmtype/section_core_type/g
- %s/section_type/section_core/g
- %s/section_rng/set_section_rng/g
- rebrand DECLARE_SECTION_RNG() as DEFINE_SECTION_RANGE() - this is
  the asm version of the respective C version, this will have a
  userspace C demo added later.
o move __LINUX_RANGE() and __LINUX_RANGE_ORDER() - fixes builds
  on sparc
o adds section ranges to linker script
o rename SECTION_RANGE_ALL()
o use default alignment, fixes builds on powerpc and arm for both
  __LINUX_RANGE() and __LINUX_RANGE_ORDER()
o expand documentation to document modules support
o add maintainers
o use generic-y

v3: new in this series, uses copyleft-next

Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 Documentation/sections/index.rst        |   1 +
 Documentation/sections/ranges.rst       |  74 +++++++++++++
 Documentation/sections/section-core.rst |   5 +
 MAINTAINERS                             |  10 ++
 arch/alpha/include/asm/Kbuild           |   1 +
 arch/arc/include/asm/Kbuild             |   1 +
 arch/arm/include/asm/Kbuild             |   1 +
 arch/arm64/include/asm/Kbuild           |   1 +
 arch/avr32/include/asm/Kbuild           |   1 +
 arch/blackfin/include/asm/Kbuild        |   1 +
 arch/c6x/include/asm/Kbuild             |   1 +
 arch/cris/include/asm/Kbuild            |   1 +
 arch/frv/include/asm/Kbuild             |   1 +
 arch/h8300/include/asm/Kbuild           |   1 +
 arch/hexagon/include/asm/Kbuild         |   1 +
 arch/ia64/include/asm/Kbuild            |   1 +
 arch/m32r/include/asm/Kbuild            |   1 +
 arch/m68k/include/asm/Kbuild            |   1 +
 arch/metag/include/asm/Kbuild           |   1 +
 arch/microblaze/include/asm/Kbuild      |   1 +
 arch/mips/include/asm/Kbuild            |   1 +
 arch/mn10300/include/asm/Kbuild         |   1 +
 arch/nios2/include/asm/Kbuild           |   1 +
 arch/openrisc/include/asm/Kbuild        |   1 +
 arch/parisc/include/asm/Kbuild          |   1 +
 arch/powerpc/include/asm/Kbuild         |   1 +
 arch/powerpc/kernel/vmlinux.lds.S       |   1 +
 arch/s390/include/asm/Kbuild            |   1 +
 arch/score/include/asm/Kbuild           |   1 +
 arch/sh/include/asm/Kbuild              |   1 +
 arch/sparc/include/asm/Kbuild           |   1 +
 arch/tile/include/asm/Kbuild            |   1 +
 arch/um/include/asm/Kbuild              |   1 +
 arch/unicore32/include/asm/Kbuild       |   1 +
 arch/x86/include/asm/Kbuild             |   1 +
 arch/x86/tools/relocs.c                 |   2 +
 arch/xtensa/include/asm/Kbuild          |   1 +
 include/asm-generic/ranges.h            |  93 ++++++++++++++++
 include/asm-generic/section-core.h      |  41 +++++++
 include/asm-generic/vmlinux.lds.h       |  12 ++-
 include/linux/ranges.h                  | 183 ++++++++++++++++++++++++++++++++
 41 files changed, 451 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/sections/ranges.rst
 create mode 100644 include/asm-generic/ranges.h
 create mode 100644 include/linux/ranges.h

diff --git a/Documentation/sections/index.rst b/Documentation/sections/index.rst
index f37511ef05e7..4a1df389fa91 100644
--- a/Documentation/sections/index.rst
+++ b/Documentation/sections/index.rst
@@ -15,3 +15,4 @@ common a set of Linux helpers for ELF sections are also documented.
 
    background
    section-core
+   ranges
diff --git a/Documentation/sections/ranges.rst b/Documentation/sections/ranges.rst
new file mode 100644
index 000000000000..d9d3af4e52cb
--- /dev/null
+++ b/Documentation/sections/ranges.rst
@@ -0,0 +1,74 @@
+==========
+Linux section ranges
+==========
+
+This documents Linux' use of section ranges, how you can use
+them and how they work.
+
+About section ranges
+==========
+
+Introduction
+------------
+.. kernel-doc:: include/linux/ranges.h
+   :doc: Introduction
+
+Section range module support
+----------------------------
+.. kernel-doc:: include/linux/ranges.h
+   :doc: Section range module support
+
+Section range helpers
+==========+.. kernel-doc:: include/linux/ranges.h
+   :doc: Section range helpers
+
+SECTION_RANGE_START
+-------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: SECTION_RANGE_START
+
+SECTION_RANGE_END
+-----------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: SECTION_RANGE_END
+
+SECTION_RANGE_SIZE
+------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: SECTION_RANGE_SIZE
+
+SECTION_RANGE_EMPTY
+-------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: SECTION_RANGE_EMPTY
+
+SECTION_RANGE_ADDR_WITHIN
+-------------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: SECTION_RANGE_ADDR_WITHIN
+
+SECTION_RANGE_ALIGNMENT
+-------------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: SECTION_RANGE_ALIGNMENT
+
+DECLARE_SECTION_RANGE
+---------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: DECLARE_SECTION_RANGE
+
+DEFINE_SECTION_RANGE
+--------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: DEFINE_SECTION_RANGE
+
+__LINUX_RANGE
+-------------
+.. kernel-doc:: include/asm-generic/ranges.h
+   :functions: __LINUX_RANGE
+
+__LINUX_RANGE_ORDER
+-------------------
+.. kernel-doc:: include/asm-generic/ranges.h
+   :functions: __LINUX_RANGE_ORDER
diff --git a/Documentation/sections/section-core.rst b/Documentation/sections/section-core.rst
index ac5815a0d9b3..1f613a6c7b78 100644
--- a/Documentation/sections/section-core.rst
+++ b/Documentation/sections/section-core.rst
@@ -114,6 +114,11 @@ Linux .ref\* sections
 .. kernel-doc:: include/asm-generic/section-core.h
    :doc: .ref.rodata
 
+Linux section ordering
+===========
+.. kernel-doc:: include/asm-generic/section-core.h
+   :doc: Linux section ordering
+
 Generic Linux kernel section helpers
 ==================
 
diff --git a/MAINTAINERS b/MAINTAINERS
index 308826f5094b..93bebccad674 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5422,6 +5422,16 @@ S:	Supported
 F:	drivers/base/power/domain*.c
 F:	include/linux/pm_domain.h
 
+GENERIC SECTION RANGES
+M:	"Luis R. Rodriguez" <mcgrof@kernel.org>
+M:	"H. Peter Anvin" <hpa@zytor.com>
+L:	linux-arch@vger.kernel.org
+L:	linux-kernel@vger.kernel.org
+S:	Supported
+F:	include/asm-generic/ranges.h
+F:	include/linux/ranges.h
+F:	Documentation/sections/ranges.rst
+
 GENERIC SECTIONS
 M:	"Luis R. Rodriguez" <mcgrof@kernel.org>
 M:	Josh Poimboeuf <jpoimboe@redhat.com>
diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index 5422827f1585..e44c896b91c4 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 7b2cb3dea5fc..a374b7f83888 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -52,3 +52,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 9b69a22a9ae1..0d47f98ccbc0 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -42,3 +42,4 @@ generic-y += unaligned.h
 generated-y += mach-types.h
 generated-y += unistd-nr.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 00ace5e826f1..e9939cbd9067 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -46,3 +46,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index f2c3b656a0e7..edc176348d7c 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -23,3 +23,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index bf20541bcf21..3428415b1996 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -48,3 +48,4 @@ generic-y += user.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index 38127ce747be..cede2a950fbf 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -63,3 +63,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 385cd88a9d9e..fb8bb4112773 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -46,3 +46,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 46d7c599d9b8..5191fec655d7 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -9,3 +9,4 @@ generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 1ec04ec1c82b..7929a992566c 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -76,3 +76,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 37d7bfae7619..af17ee334788 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -61,3 +61,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 672c6d5da18c..d8f226b35a0a 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -10,3 +10,4 @@ generic-y += trace_clock.h
 generic-y += vtime.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 6111e1523750..1c6504d29312 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -12,3 +12,4 @@ generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index 1277b45bf4f9..006e2863ad37 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -35,3 +35,4 @@ generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index b1011375cd7a..4a8471434a3e 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -56,3 +56,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index c6c2cf6edc98..63c083a1f8da 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -12,3 +12,4 @@ generic-y += syscalls.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index a67d3177f3ca..288e21b64170 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -21,3 +21,4 @@ generic-y += user.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index f8145bc85835..656af7b69940 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index c9c7cb82b00f..c55880659d67 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -64,3 +64,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 86175e701869..7d6a704b808c 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -72,3 +72,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index 18a9d4c5ead7..f11d1249738f 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -29,3 +29,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 4322d9746cdb..60d8349241a7 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -9,3 +9,4 @@ generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += vtime.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
index 7394b770ae1f..fcfc9d102348 100644
--- a/arch/powerpc/kernel/vmlinux.lds.S
+++ b/arch/powerpc/kernel/vmlinux.lds.S
@@ -107,6 +107,7 @@ SECTIONS
 #endif
 		/* careful! __ftr_alt_* sections need to be close to .text */
 		*(.text .fixup __ftr_alt_* .ref.text)
+		*(SORT(.text.rng.*))
 		SCHED_TEXT
 		CPUIDLE_TEXT
 		LOCK_TEXT
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 63a1c2924b91..c1b85a361e5d 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -9,3 +9,4 @@ generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index f089a264cd38..f0cdb2cbca4d 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -15,3 +15,4 @@ generic-y += xor.h
 generic-y += serial.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 7b0356dca562..c9bb7932a3d1 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -40,3 +40,4 @@ generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index 438f86573dc5..28280887ac79 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -22,3 +22,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index fb6b831c1fba..33f7069763ae 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -41,3 +41,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index 580bd5ff828f..b952dcb3e216 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -27,3 +27,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 8578702d4998..93abbfdab543 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -61,3 +61,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += ranges.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index af975f21eeee..f672f2fc181d 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -13,3 +13,4 @@ generic-y += early_ioremap.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/x86/tools/relocs.c b/arch/x86/tools/relocs.c
index 73eb7fd4aec4..f96fa2ddf7c9 100644
--- a/arch/x86/tools/relocs.c
+++ b/arch/x86/tools/relocs.c
@@ -68,6 +68,8 @@ static const char * const sym_regex_kernel[S_NSYMTYPES] = {
 	"__end_rodata|"
 	"__initramfs_start|"
 	"(jiffies|jiffies_64)|"
+	".rodata..rng.*|"
+	".init.text..rng.*|"
 #if ELF_BITS = 64
 	"__per_cpu_load|"
 	"init_per_cpu__.*|"
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 7879c31e66a7..2b7fe48c0225 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -33,3 +33,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/include/asm-generic/ranges.h b/include/asm-generic/ranges.h
new file mode 100644
index 000000000000..75c196864f45
--- /dev/null
+++ b/include/asm-generic/ranges.h
@@ -0,0 +1,93 @@
+#ifndef _ASM_GENERIC_RANGES_H_
+#define _ASM_GENERIC_RANGES_H_
+/*
+ * Copyright (C) 2016 Luis R. Rodriguez <mcgrof@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of copyleft-next (version 0.3.1 or later) as published
+ * at http://copyleft-next.org/.
+ */
+#include <asm/section-core.h>
+
+#ifndef set_section_rng
+# define set_section_rng(section, name, flags)				\
+	 set_section_core(section, rng, name,				\
+			  any, flags)
+#endif
+
+#ifndef set_section_rng_type
+# define set_section_rng_type(section, name, flags, type)		\
+	 set_section_core_type(section, rng, name,			\
+			       any, flags, type)
+#endif
+
+#ifndef set_section_rng_level
+# define set_section_rng_level(section, name, level, flags)		\
+	 set_section_core(section, rng, name, level, flags)
+#endif
+
+#ifndef push_section_rng
+# define push_section_rng(section, name, flags)				\
+	 push_section_core(section, rng, name,				\
+			   any, flags)
+#endif
+
+#ifndef push_section_rng_level
+# define push_section_rng_level(section, name, level, flags)		\
+	 push_section_core(section, rng, name,				\
+			   level, flags)
+#endif
+
+#ifndef __ASSEMBLY__
+/**
+ * __LINUX_RANGE - short hand association into a section range
+ *
+ * @section: ELF section name to place section range into
+ * @name: section range name
+ *
+ * This helper can be used by subsystems to define their own subsystem
+ * specific helpers to easily associate a piece of code being defined to a
+ * section range.
+ */
+#define __LINUX_RANGE(section, name)					\
+	__attribute__((__section__(#section "..rng.name.any")))
+
+/**
+ * __LINUX_RANGE_ORDER - short hand association into a section range of order
+ *
+ * @section: ELF section name to place section range into
+ * @name: section range name
+ * @level: order level, a number. The order level gets tucked into the
+ *	section as a postfix string. Order levels are sorted using
+ * 	binutils SORT(), the number is sorted as a string, as such be
+ * 	sure to fill with zeroes any empty digits. For instance if you are
+ * 	using 3 levels of digits for order levels, use 001 for the first entry,
+ * 	0002 for the second, 999 for the last entry. You can use however many
+ * 	digits you need.
+ *
+ * This helper can be used by subsystems to define their own subsystem specific
+ * helpers to easily associate a piece of code being defined to a section range
+ * with an associated specific order level. The order level provides the
+ * ability for explicit user ordering of code. Sorting takes place at link
+ * time, after compilation.
+ */
+#define __LINUX_RANGE_ORDER(section, name, level)			\
+	__attribute__((__section__(#section "..rng.name." #level)))
+
+#endif /* __ASSEMBLY__ */
+
+#ifdef __ASSEMBLER__
+
+#ifndef DEFINE_SECTION_RANGE
+#define DEFINE_SECTION_RANGE(section, name)				\
+  push_section_rng_level(section, name,,) ;				\
+  .globl name ;								\
+name: ;									\
+  .popsection								\
+									\
+  push_section_rng_level(section, name, ~,) ;				\
+  .popsection
+#endif
+#endif /* __ASSEMBLER__ */
+
+#endif /* _ASM_GENERIC_RANGES_H_ */
diff --git a/include/asm-generic/section-core.h b/include/asm-generic/section-core.h
index bb16befc4251..65fb076765f8 100644
--- a/include/asm-generic/section-core.h
+++ b/include/asm-generic/section-core.h
@@ -183,6 +183,47 @@
  * or data structures part of the init sections.
  */
 
+/**
+ * DOC: Linux section ordering
+ *
+ * Linux may use binutils linker-script 'SORT()' on sections to sort Linux
+ * sections alpha numerically. Linux has historically used 'SORT()' in
+ * ``include/asm-generic/vmlinux.lds.h``, its a well established practice. If
+ * 'SORT()' is used on a section one can provide ordering using a postfix on
+ * each section entry added. For instance if a linker script uses::
+ *
+ *    SORT(.foo.*)
+ *
+ * one can then add entries with explicit ordering using numeric postfixes for
+ * each entry, we refer to these as 'order levels'. Since 'SORT()' sorts alpha
+ * numerically a specific series set of digits must be agreed a-priori which
+ * would give also an idea of the max expected number of entries added to a
+ * section. For instance, if you expect a maximum of 999 entries you can use
+ * 3 digits for a section order level. If you wanted an entry to be ordered
+ * first you could use the postfix '000', if you wanted an entry to follow this
+ * you could use '001', and so on. We could for instance have::
+ *
+ *    .foo.000
+ *    .foo.001
+ *    .foo.002
+ *
+ * Often times one may want the option to specify no order is required for
+ * certain elements added to a section which does use 'SORT()' on the linker
+ * script. You can use any arbitrary string value to to specify no order is
+ * used, so long as its used consistantly. For instance, one possibility is to
+ * use the 'any' postfix.  All entries on the section would then have no
+ * specific ordering::
+ *
+ *    .foo.any
+ *    .foo.any
+ *    .foo.any
+ *
+ * To help establish a convention we reserve the special name 'any' for this
+ * purpose. Developers can use and expect the 'any' postfix string on sections
+ * as a helper to annotate section ordering at link time is not relevant
+ * for entries on a section.
+ */
+
 /* Can be used on foo.S for instance */
 #ifndef __set_section_core_type
 # define __set_section_core_type(___section, ___core, ___name,		\
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 483f60c451f9..71bfd3b3c719 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -56,6 +56,7 @@
 
 #include <linux/export.h>
 #include <asm/section-core.h>
+#include <asm/ranges.h>
 
 /* Align . to a 8 byte boundary equals to maximum function alignment. */
 #define ALIGN_FUNCTION()  . = ALIGN(8)
@@ -205,6 +206,7 @@
  */
 #define DATA_DATA							\
 	*(.data .data.[0-9a-zA-Z_]*)					\
+	*(SORT(.data..rng.*))						\
 	*(.ref.data)							\
 	*(.data..shared_aligned) /* percpu related */			\
 	MEM_KEEP(init.data)						\
@@ -273,7 +275,9 @@
 	. = ALIGN((align));						\
 	.rodata           : AT(ADDR(.rodata) - LOAD_OFFSET) {		\
 		VMLINUX_SYMBOL(__start_rodata) = .;			\
-		*(.rodata) *(.rodata.*)					\
+		*(.rodata)						\
+		*(SORT(.rodata..rng.*))					\
+		*(.rodata.*)						\
 		RO_AFTER_INIT_DATA	/* Read only after init */	\
 		KEEP(*(__vermagic))	/* Kernel version magic */	\
 		. = ALIGN(8);						\
@@ -446,7 +450,9 @@
  * conflicting section names, and must pull in .text.[0-9a-zA-Z_]* */
 #define TEXT_TEXT							\
 		ALIGN_FUNCTION();					\
-		*(.text.hot .text .text.fixup .text.unlikely)		\
+		*(.text.hot .text)					\
+		*(SORT(.text..rng.*))					\
+		*(.text.fixup .text.unlikely)				\
 		*(.ref.text)						\
 	MEM_KEEP(init.text)						\
 	MEM_KEEP(exit.text)						\
@@ -549,6 +555,7 @@
 #define INIT_DATA							\
 	KEEP(*(SORT(___kentry+*)))					\
 	*(.init.data)							\
+	*(SORT(.init.data..rng.*))					\
 	MEM_DISCARD(init.data)						\
 	KERNEL_CTORS()							\
 	MCOUNT_REC()							\
@@ -572,6 +579,7 @@
 
 #define INIT_TEXT							\
 	*(.init.text)							\
+	*(SORT(.init.text..rng.*))					\
 	*(.text.startup)						\
 	MEM_DISCARD(init.text)
 
diff --git a/include/linux/ranges.h b/include/linux/ranges.h
new file mode 100644
index 000000000000..1e64674f6d7d
--- /dev/null
+++ b/include/linux/ranges.h
@@ -0,0 +1,183 @@
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
+#include <linux/sections.h>
+#include <asm/ranges.h>
+
+#ifndef __ASSEMBLY__
+
+/**
+ * DOC: Introduction
+ *
+ * A section ranges consists of explicitly annotated series executable code
+ * stitched together for the purpose of selective placement into standard or
+ * architecture specific ELF sections. What ELF section is used is utility
+ * specific. Linux has historically implicitly used section ranges, however
+ * they were all built in an adhoc manner and typically required linker script
+ * modifications per architecture. The section range API allows adding new
+ * bundles of stiched executable code into custom ELF sections by only
+ * modifying C or asm code in an architecture agnostic form.
+ *
+ * This documents the set of helpers available to declare, and define section
+ * ranges and associate each section range to a specific Linux ELF section.
+ */
+
+/**
+ * DOC: Section range module support
+ *
+ * Modules can use section ranges, however the section range definition must be
+ * built-in to the kernel. That is, the code that implements
+ * DEFINE_SECTION_RANGE() must be built-in, and modular code cannot add more
+ * items in to the section range (with __LINUX_RANGE() or
+ * __LINUX_RANGE_ORDER()), unless kernel/module.c find_module_sections() and
+ * module-common.lds.S are updated accordingly with a respective module
+ * notifier to account for updates. This restriction may be enhanced in the
+ * future.
+ */
+
+/**
+ * DOC: Section range helpers
+ *
+ * These are helpers for section ranges.
+ */
+
+/**
+ * SECTION_RANGE_START - get address of start of section range
+ *
+ * @name: name of the section range
+ *
+ * This gives you the start address of the section range.
+ * This should give you the address of the first entry.
+ *
+ */
+#define SECTION_RANGE_START(name)	LINUX_SECTION_START(name)
+
+/**
+ * SECTION_RANGE_END - get address of end of the section range
+ *
+ * @name: name of the section range
+ *
+ * This gives you the end address of the linker table.
+ * This will match the start address if the linker table
+ * is empty.
+ */
+#define SECTION_RANGE_END(name)		LINUX_SECTION_END(name)
+
+/**
+ * SECTION_RANGE_SIZE - get number of entries in the section range
+ *
+ * @name: name of the section range
+ *
+ * This gives you the number of entries in the section range.
+ * Example usage:
+ *
+ *   unsigned int num_ents = LINKTABLE_SIZE(some_fns);
+ */
+#define SECTION_RANGE_SIZE(name)					\
+	((SECTION_RANGE_END(name)) - (SECTION_RANGE_START(name)))
+
+/**
+ * SECTION_RANGE_EMPTY - check if section range has no entries
+ *
+ * @name: name of the section range
+ *
+ * Returns true if the section range is emtpy.
+ *
+ *   bool is_empty = LINKTABLE_EMPTY(some_fns);
+ */
+#define SECTION_RANGE_EMPTY(name)	(SECTION_RANGE_SIZE(name) = 0)
+
+/**
+ * SECTION_RANGE_ADDR_WITHIN - returns true if address is in the section range
+ *
+ * @name: name of the section range
+ * @addr: address to query for
+ *
+ * Returns true if the address is in the section range.
+ */
+#define SECTION_RANGE_ADDR_WITHIN(name, addr)				\
+	 (addr >= (unsigned long) SECTION_RANGE_START(name) &&		\
+          addr < (unsigned long) SECTION_RANGE_END(name))
+
+/**
+ * SECTION_RANGE_ALIGNMENT - get the alignment of the section range
+ *
+ * @name: name of linker table
+ *
+ * Gives you the alignment for the section range.
+ */
+#define SECTION_RANGE_ALIGNMENT(name)	LINUX_SECTION_ALIGNMENT(name)
+
+/**
+ * DECLARE_SECTION_RANGE - Declares a section range
+ *
+ * @name: section range name
+ *
+ * Declares a section range to help code access the range. Typically if
+ * a subsystems needs code to have direct access to the section range the
+ * subsystem's header file would declare the section range. Care should be
+ * taken to only declare the section range in a header file if access to it
+ * is truly needed outside of the code defining it. You typically would
+ * rather instead provide helpers which access the section range with special
+ * code on behalf of the caller.
+ */
+#define DECLARE_SECTION_RANGE(name)					\
+	DECLARE_LINUX_SECTION_RO(char, name)
+
+/**
+ * __SECTION_RANGE_BEGIN - Constructs the beginning of a section range
+ *
+ * @name: section range name
+ * @__section: ELF section to place section range into
+ *
+ * Constructs the beginning of a section range. You will typically not need
+ * to use this directly.
+ */
+#define __SECTION_RANGE_BEGIN(name, __section)				\
+	const __typeof__(SECTION_RANGE_START(name)[0])			\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(SECTION_RANGE_ALIGNMENT(name)),\
+			     section(#__section "..rng.name.")))
+
+/**
+ * __SECTION_RANGE_END - Constructs the end of a section range
+ *
+ * @name: section range name
+ * @__section: ELF section to place section range into
+ *
+ * Constructs the end of a section range. You will typically not need
+ * to use this directly.
+ */
+#define __SECTION_RANGE_END(name, __section)				\
+	const __typeof__(SECTION_RANGE_START(name)[0])			\
+	      __attribute__((used,					\
+			     __aligned__(SECTION_RANGE_ALIGNMENT(name)),\
+			     section(#__section "..rng.name.~")))
+
+/**
+ * DEFINE_SECTION_RANGE - Defines a section range
+ *
+ * @name: section range name
+ * @section: ELF section name to place section range into
+ *
+ * Defines a section range, used for executable code. Section ranges are
+ * defined in the code that takes ownership and makes use of the section
+ * range.
+ */
+#define DEFINE_SECTION_RANGE(name, section)				\
+	DECLARE_LINUX_SECTION_RO(char, name);				\
+	__SECTION_RANGE_BEGIN(name, section) SECTION_RANGE_START(name)[0] = {};\
+	__SECTION_RANGE_END(name, section) SECTION_RANGE_END(name)[0] = {}
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _LINUX_RANGES_H */
-- 
2.10.1

