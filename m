From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:32:55 +0000
Subject: [PATCH v4 06/16] ranges.h: add helpers to build and identify Linux section ranges
Message-Id: <1471642385-5629-7-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, acme@redhat.com, ak@linux.intel.com, andriy.shevchenko@linux.intel.com, mcb30@ip

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

Section ranges are on one of the types of custom sections
types used in Linux. This provides a series of helpers for
defining them and using them. Most importantly this also
enables us to avoid modifying the linker script when we
add a new section range.

It turns out a lot of custom sections are actually section ranges,
and these are typically spelled out in their architecture specific
asm/sections.h file -- we anable architectures to override what asm
is used for section ranges but start by default trusting the
asm-generic version all around.

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
 Documentation/sections/index.rst   |   1 +
 Documentation/sections/ranges.rst  |  49 ++++++++++++++
 MAINTAINERS                        |  10 +++
 arch/alpha/include/asm/Kbuild      |   1 +
 arch/arc/include/asm/Kbuild        |   1 +
 arch/arm/include/asm/Kbuild        |   1 +
 arch/arm64/include/asm/Kbuild      |   1 +
 arch/avr32/include/asm/Kbuild      |   1 +
 arch/blackfin/include/asm/Kbuild   |   1 +
 arch/c6x/include/asm/Kbuild        |   1 +
 arch/cris/include/asm/Kbuild       |   1 +
 arch/frv/include/asm/Kbuild        |   1 +
 arch/h8300/include/asm/Kbuild      |   1 +
 arch/hexagon/include/asm/Kbuild    |   1 +
 arch/ia64/include/asm/Kbuild       |   1 +
 arch/m32r/include/asm/Kbuild       |   1 +
 arch/m68k/include/asm/Kbuild       |   1 +
 arch/metag/include/asm/Kbuild      |   1 +
 arch/microblaze/include/asm/Kbuild |   1 +
 arch/mips/include/asm/Kbuild       |   1 +
 arch/mn10300/include/asm/Kbuild    |   1 +
 arch/nios2/include/asm/Kbuild      |   1 +
 arch/openrisc/include/asm/Kbuild   |   1 +
 arch/parisc/include/asm/Kbuild     |   1 +
 arch/powerpc/include/asm/Kbuild    |   1 +
 arch/s390/include/asm/Kbuild       |   1 +
 arch/score/include/asm/Kbuild      |   1 +
 arch/sh/include/asm/Kbuild         |   1 +
 arch/sparc/include/asm/Kbuild      |   1 +
 arch/tile/include/asm/Kbuild       |   1 +
 arch/um/include/asm/Kbuild         |   1 +
 arch/unicore32/include/asm/Kbuild  |   1 +
 arch/x86/include/asm/Kbuild        |   1 +
 arch/x86/tools/relocs.c            |   2 +
 arch/xtensa/include/asm/Kbuild     |   1 +
 include/asm-generic/ranges.h       |  89 ++++++++++++++++++++++++++
 include/asm-generic/vmlinux.lds.h  |  12 +++-
 include/linux/ranges.h             | 128 +++++++++++++++++++++++++++++++++++++
 38 files changed, 320 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/sections/ranges.rst
 create mode 100644 include/asm-generic/ranges.h
 create mode 100644 include/linux/ranges.h

diff --git a/Documentation/sections/index.rst b/Documentation/sections/index.rst
index d411e9b22eb3..6dd93ddd5dbe 100644
--- a/Documentation/sections/index.rst
+++ b/Documentation/sections/index.rst
@@ -9,3 +9,4 @@ used throughout the kernel to help declare and define them.
    :maxdepth: 4
 
    section-core
+   ranges
diff --git a/Documentation/sections/ranges.rst b/Documentation/sections/ranges.rst
new file mode 100644
index 000000000000..1293dcb3ab38
--- /dev/null
+++ b/Documentation/sections/ranges.rst
@@ -0,0 +1,49 @@
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
+SECTION_ADDR_IN_RANGE
+---------------------
+.. kernel-doc:: include/linux/ranges.h
+   :functions: SECTION_ADDR_IN_RANGE
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
diff --git a/MAINTAINERS b/MAINTAINERS
index 689c12075842..1a217751aa8a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5217,6 +5217,16 @@ S:	Supported
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
index 9a0929576de1..e5295413fdf8 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -51,3 +51,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 47923635be16..8e52300e1eed 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -40,3 +40,4 @@ generic-y += timex.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 42d00806e4fb..5ff184574976 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -53,3 +53,4 @@ generic-y += user.h
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
index 7de674411bed..35b7752e65c0 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -49,3 +49,4 @@ generic-y += user.h
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
index eef72c464c9b..d465f51c2088 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -36,3 +36,4 @@ generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 50ebd5a30d16..c869b1ebd583 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -57,3 +57,4 @@ generic-y += vga.h
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
index 12f7c5984c03..ed225600c8a4 100644
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
index 6f43f33f0e0f..1a263a7158e2 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -30,3 +30,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index b49fab7bab2f..065c6e84fb67 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -8,3 +8,4 @@ generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += vtime.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 89e74b59f32d..3e8b95927cb5 100644
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
index d51b84d6b4b7..79664d10e63b 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -23,3 +23,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index 7b8a652e43ae..951fa4be571d 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -42,3 +42,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index e9849834d55e..99be54949b99 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -28,3 +28,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 256c45b3ae34..6c35905fe371 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -64,3 +64,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += ranges.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index f6914a57bc16..f790756fdb48 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -17,3 +17,4 @@ generic-y += early_ioremap.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/arch/x86/tools/relocs.c b/arch/x86/tools/relocs.c
index 0c2fae8d929d..c215db049920 100644
--- a/arch/x86/tools/relocs.c
+++ b/arch/x86/tools/relocs.c
@@ -68,6 +68,8 @@ static const char * const sym_regex_kernel[S_NSYMTYPES] = {
 	"__end_rodata|"
 	"__initramfs_start|"
 	"(jiffies|jiffies_64)|"
+	".rodata.rng.*|"
+	".init.text.rng.*|"
 #if ELF_BITS = 64
 	"__per_cpu_load|"
 	"init_per_cpu__.*|"
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 81ca6816bd72..221b6b652500 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -32,3 +32,4 @@ generic-y += trace_clock.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += section-core.h
+generic-y += ranges.h
diff --git a/include/asm-generic/ranges.h b/include/asm-generic/ranges.h
new file mode 100644
index 000000000000..74cd941aa2f8
--- /dev/null
+++ b/include/asm-generic/ranges.h
@@ -0,0 +1,89 @@
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
+#define SECTION_RNG(section, name)					\
+	SECTION_CORE(section, rng, name,				\
+		     SECTION_ORDER_ANY)
+
+#define SECTION_RNG_LEVEL(section, name, level)				\
+	SECTION_CORE(section, rng, name, level)
+
+#define SECTION_RNG_ALL(section)					\
+	SECTION_CORE_ALL(section,rng)
+
+#ifndef set_section_rng
+# define set_section_rng(section, name, flags)				\
+	 set_section_core(section, rng, name,				\
+			  SECTION_ORDER_ANY, flags)
+#endif
+
+#ifndef set_section_rng_type
+# define set_section_rng_type(section, name, flags, type)		\
+	 set_section_core_type(section, rng, name,			\
+			       SECTION_ORDER_ANY, flags, type)
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
+			   SECTION_ORDER_ANY, flags)
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
+	__attribute__((__section__(SECTION_RNG(section, name))))
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
+	__attribute__((__section__(SECTION_RNG_LEVEL(section, name, level))))
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _ASM_GENERIC_RANGES_H_ */
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 731087276a32..ad843555e6a4 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -56,6 +56,7 @@
 
 #include <linux/export.h>
 #include <asm/section-core.h>
+#include <asm/ranges.h>
 
 /* Align . to a 8 byte boundary equals to maximum function alignment. */
 #define ALIGN_FUNCTION()  . = ALIGN(8)
@@ -200,6 +201,7 @@
 /* .data section */
 #define DATA_DATA							\
 	*(SECTION_DATA)							\
+	*(SORT(SECTION_RNG_ALL(SECTION_DATA)))				\
 	*(SECTION_REF_DATA)						\
 	*(.data..shared_aligned) /* percpu related */			\
 	MEM_KEEP(init.data)						\
@@ -265,7 +267,9 @@
 	. = ALIGN((align));						\
 	SECTION_RODATA    : AT(ADDR(SECTION_RODATA) - LOAD_OFFSET) {	\
 		VMLINUX_SYMBOL(__start_rodata) = .;			\
-		*(SECTION_RODATA) *(SECTION_ALL(SECTION_RODATA))	\
+		*(SECTION_RODATA)					\
+		*(SORT(SECTION_RNG_ALL(SECTION_RODATA)))		\
+		*(SECTION_ALL(SECTION_RODATA))				\
 		RO_AFTER_INIT_DATA	/* Read only after init */	\
 		*(__vermagic)		/* Kernel version magic */	\
 		. = ALIGN(8);						\
@@ -433,7 +437,9 @@
  * during second ld run in second ld pass when generating System.map */
 #define TEXT_TEXT							\
 		ALIGN_FUNCTION();					\
-		*(.text.hot SECTION_TEXT .text.fixup .text.unlikely)	\
+		*(.text.hot SECTION_TEXT)				\
+		*(SORT(SECTION_RNG_ALL(SECTION_TEXT)))			\
+		*(.text.fixup .text.unlikely)				\
 		*(SECTION_REF)						\
 	MEM_KEEP(init.text)						\
 	MEM_KEEP(exit.text)						\
@@ -529,6 +535,7 @@
 /* init and exit section handling */
 #define INIT_DATA							\
 	*(SECTION_INIT_DATA)						\
+	*(SORT(SECTION_RNG_ALL(SECTION_INIT_DATA)))			\
 	MEM_DISCARD(init.data)						\
 	KERNEL_CTORS()							\
 	MCOUNT_REC()							\
@@ -551,6 +558,7 @@
 
 #define INIT_TEXT							\
 	*(SECTION_INIT)							\
+	*(SORT(SECTION_RNG_ALL(SECTION_INIT)))				\
 	*(.text.startup)						\
 	MEM_DISCARD(init.text)
 
diff --git a/include/linux/ranges.h b/include/linux/ranges.h
new file mode 100644
index 000000000000..30b2182bd484
--- /dev/null
+++ b/include/linux/ranges.h
@@ -0,0 +1,128 @@
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
+	const __typeof__(VMLINUX_SYMBOL(name)[0])			\
+	      __attribute__((used,					\
+			     weak,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_RNG_LEVEL(__section, name,))))
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
+	const __typeof__(VMLINUX_SYMBOL(name)[0])			\
+	      __attribute__((used,					\
+			     __aligned__(LINUX_SECTION_ALIGNMENT(name)),\
+			     section(SECTION_RNG_LEVEL(__section, name, ~))))
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
+	__SECTION_RANGE_BEGIN(name, section) VMLINUX_SYMBOL(name)[0] = {};\
+	__SECTION_RANGE_END(name, section) VMLINUX_SYMBOL(name##__end)[0] = {}
+
+/**
+ * SECTION_ADDR_IN_RANGE - returns true if address is in range
+ *
+ * @name: section range name
+ * @addr: address to query for
+ *
+ * Returns true if the address is in the section range.
+ */
+#define SECTION_ADDR_IN_RANGE(name, addr)				\
+	 (addr >= (unsigned long) LINUX_SECTION_START(name) &&		\
+	  addr <  (unsigned long) LINUX_SECTION_END(name))
+
+#endif /* __ASSEMBLY__ */
+
+#endif /* _LINUX_RANGES_H */
-- 
2.9.2

