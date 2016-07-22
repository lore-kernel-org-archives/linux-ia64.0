From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 22 Jul 2016 21:24:34 +0000
Subject: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@linux-foun

This RFC v3 builds off the last RFC v2 series [0] for adding linker tables.
The largest amount of work here was to take Russell King's feedback on
using linker table for kprobes text not being appropriate -- and providing
another lightweight API for simple section ranges: read-only stitched pieces
of executable code. This required also generalizing common building blocks
for both linker tables and section ranges, these building blocks are defined
now in include/linux/sections.h and asm-generic/section.h. The other last thing
decided was to not support sub-sections. In the hunt for this I could think of
anything that really required this, and if it was needed it did not seem
impossible to port over to avoid its use. Please let me know if there are valid
uses cases for sub-sections.

Other significant effort here was to provide a set of common assembly helpers
which could be used across architectures, this starts off some of this work
for generic helpers which carve out and define custom Linux sections.

Lastly, this now also goes with two ports which required module support when
using linker tables: jump labels, and dynamic debug support. A few
extensions have been made to the original series in order to provide
support for that.

Since kprobes actually had both a linker table and a section range the
patch that dealt with kprobes is now split off in two patches, one
that deals with its linker table and another for its section ranges.

More elaborate uses for linker tables are possible, I'll hold off on any
of this type of work until at least the basic building blocks are fleshed
out. To review how this work came about, and more elaborate uses being
evaluated check out the userspace linker-tables mockup solution [1].
Hopefully most of the possible bikeshedding was already dealt with through
that tree. Thanks to hpa for tons of feedback.

Should you need it, the code here is also available on my linux-next
20160722-linker-table-v3-try2 branch on kernel.org [2]. Lastly, ranges and
table development go under copyleft-next, Rusty recently asked for code
to go in prior to the license tag being added denoting this license as
GPL-compatible [3] -- I had noted in the patch submission which annotated
copyleft-next's compatibility to GPLv2 that copyleft-next is the license
of choice for ongoing kernel development on my end [4]. If this is
objectionable I'm happy to change it to GPLv2 however I'd like a reason
provided as I've gone through all possible channels to ensure this is kosher,
including vetting by 3 attorneys now, 2 at SUSE.

This all goes tested by 0-day... however since I found an issue with linker
tables and blackfin this series remains as RFC -- I'll try to debug the
issue with Steven Miao. The issue with blackfin is using a config that
enables CONFIG_FW_LOADER=y and CONFIG_DYNAMIC_DEBUG=y [5] we end up with
the following at final link time:

  LD      init/built-in.o
lib/built-in.o: In function `dynamic_debug_init':
lib/dynamic_debug.c:(.init.text+0x156): undefined reference to `__verbose__end'
lib/dynamic_debug.c:(.init.text+0x15a): undefined reference to `__verbose__end'
lib/dynamic_debug.c:(.init.text+0x160): undefined reference to `__verbose'
lib/dynamic_debug.c:(.init.text+0x164): undefined reference to `__verbose'
lib/dynamic_debug.c:(.init.text+0x214): undefined reference to `__verbose__end'
lib/dynamic_debug.c:(.init.text+0x218): undefined reference to `__verbose__end'
lib/dynamic_debug.c:(.init.text+0x252): undefined reference to `__verbose__end'
lib/dynamic_debug.c:(.init.text+0x258): undefined reference to `__verbose'
lib/dynamic_debug.c:(.init.text+0x25c): undefined reference to `__verbose__end'
lib/dynamic_debug.c:(.init.text+0x260): undefined reference to `__verbose'
drivers/built-in.o: In function `release_firmware':
(.text+0x22dc2): undefined reference to `builtin_fw'
drivers/built-in.o: In function `release_firmware':
(.text+0x22dc6): undefined reference to `builtin_fw__end'
drivers/built-in.o: In function `release_firmware':
(.text+0x22dca): undefined reference to `builtin_fw'
drivers/built-in.o: In function `release_firmware':
(.text+0x22dce): undefined reference to `builtin_fw__end'
drivers/built-in.o: In function `fw_get_builtin_firmware':
drivers/base/firmware_class.c:(.text+0x23008): undefined reference to `builtin_fw'
drivers/base/firmware_class.c:(.text+0x2300c): undefined reference to `builtin_fw__end'
drivers/base/firmware_class.c:(.text+0x23010): undefined reference to `builtin_fw'
drivers/base/firmware_class.c:(.text+0x23014): undefined reference to `builtin_fw__end'
Makefile:957: recipe for target 'vmlinux' failed
make: *** [vmlinux] Error 1

To reproduce then:

wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
chmod +x ~/bin/make.cross
wget http://drvbp1.linux-foundation.org/~mcgrof/2016/07/22/blackfin-fw-dyndbg.config -o .config
make.cross ARCH=blackfin

[0] https://lkml.kernel.org/r/1455889559-9428-1-git-send-email-mcgrof@kernel.org
[1] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linker-tables.git/
[2] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linux-next.git/log/?h 160722-linker-table-v3-try2
[3] https://lkml.kernel.org/r/87y44zhbiu.fsf@rustcorp.com.au
[4] https://lkml.kernel.org/r/1467327207-14916-1-git-send-email-mcgrof@kernel.org
[5] http://drvbp1.linux-foundation.org/~mcgrof/2016/07/22/blackfin-fw-dyndbg.config


Luis R. Rodriguez (13):
  x86: remove LTO_REFERENCE_INITCALL()
  dell-smo8800: include uaccess.h
  scripts/module-common.lds: enable generation
  sections.h: guard against asm and linker script
  sections.h: add sections header to collect all section info
  ranges.h: add helpers to build and identify Linux section ranges
  tables.h: add linker table support
  firmware/Makefile: force recompilation if makefile changes
  firmware: port built-in section to linker table
  jump_label: port __jump_table to linker tables
  dynamic_debug: port to use linker tables
  kprobes: port .kprobes.text to section range
  kprobes: port blacklist kprobes to linker table

 .gitignore                                         |   2 +
 Documentation/DocBook/Makefile                     |   3 +-
 Documentation/DocBook/linker-tables.tmpl           | 166 ++++++
 Documentation/DocBook/sections.tmpl                | 112 ++++
 Documentation/kbuild/makefiles.txt                 |  19 +
 Makefile                                           |   6 +-
 arch/alpha/include/asm/ranges.h                    |   6 +
 arch/alpha/include/asm/sections.h                  |   6 +
 arch/alpha/include/asm/tables.h                    |   6 +
 arch/arc/include/asm/ranges.h                      |   6 +
 arch/arc/include/asm/tables.h                      |   6 +
 arch/arc/kernel/vmlinux.lds.S                      |   1 -
 arch/arm/include/asm/jump_label.h                  |   6 +-
 arch/arm/include/asm/ranges.h                      |   6 +
 arch/arm/include/asm/sections.h                    |   2 +
 arch/arm/include/asm/tables.h                      |   6 +
 arch/arm/kernel/entry-armv.S                       |   3 +-
 arch/arm/kernel/vmlinux-xip.lds.S                  |   1 -
 arch/arm/kernel/vmlinux.lds.S                      |   1 -
 arch/arm64/include/asm/jump_label.h                |   6 +-
 arch/arm64/include/asm/ranges.h                    |   6 +
 arch/arm64/include/asm/sections.h                  |   6 +
 arch/arm64/include/asm/tables.h                    |   6 +
 arch/avr32/include/asm/ranges.h                    |   6 +
 arch/avr32/include/asm/sections.h                  |   6 +
 arch/avr32/include/asm/tables.h                    |   6 +
 arch/avr32/kernel/entry-avr32b.S                   |   5 +-
 arch/avr32/kernel/vmlinux.lds.S                    |   1 -
 arch/blackfin/include/asm/ranges.h                 |   6 +
 arch/blackfin/include/asm/sections.h               |   4 +
 arch/blackfin/include/asm/tables.h                 |   6 +
 arch/blackfin/kernel/vmlinux.lds.S                 |   1 -
 arch/c6x/include/asm/ranges.h                      |   6 +
 arch/c6x/include/asm/tables.h                      |   6 +
 arch/c6x/kernel/vmlinux.lds.S                      |   1 -
 arch/cris/include/asm/ranges.h                     |   6 +
 arch/cris/include/asm/sections.h                   |   6 +
 arch/cris/include/asm/tables.h                     |   6 +
 arch/frv/include/asm/ranges.h                      |   6 +
 arch/frv/include/asm/tables.h                      |   6 +
 arch/h8300/include/asm/ranges.h                    |   6 +
 arch/h8300/include/asm/sections.h                  |   6 +
 arch/h8300/include/asm/tables.h                    |   6 +
 arch/hexagon/include/asm/ranges.h                  |   6 +
 arch/hexagon/include/asm/sections.h                |   6 +
 arch/hexagon/include/asm/tables.h                  |   6 +
 arch/hexagon/kernel/vmlinux.lds.S                  |   1 -
 arch/ia64/include/asm/ranges.h                     |   6 +
 arch/ia64/include/asm/sections.h                   |   7 +-
 arch/ia64/include/asm/tables.h                     |   6 +
 arch/ia64/kernel/jprobes.S                         |   3 +-
 arch/ia64/kernel/vmlinux.lds.S                     |   1 -
 arch/ia64/lib/flush.S                              |   5 +-
 arch/m32r/include/asm/ranges.h                     |   6 +
 arch/m32r/include/asm/sections.h                   |   6 +
 arch/m32r/include/asm/tables.h                     |   6 +
 arch/m68k/include/asm/ranges.h                     |   6 +
 arch/m68k/include/asm/sections.h                   |   6 +
 arch/m68k/include/asm/tables.h                     |   6 +
 arch/metag/include/asm/ranges.h                    |   6 +
 arch/metag/include/asm/sections.h                  |   6 +
 arch/metag/include/asm/tables.h                    |   6 +
 arch/metag/kernel/vmlinux.lds.S                    |   1 -
 arch/microblaze/include/asm/ranges.h               |   6 +
 arch/microblaze/include/asm/tables.h               |   6 +
 arch/microblaze/kernel/vmlinux.lds.S               |   1 -
 arch/mips/include/asm/jump_label.h                 |   6 +-
 arch/mips/include/asm/ranges.h                     |   6 +
 arch/mips/include/asm/sections.h                   |   6 +
 arch/mips/include/asm/tables.h                     |   6 +
 arch/mips/kernel/vmlinux.lds.S                     |   1 -
 arch/mn10300/include/asm/ranges.h                  |   6 +
 arch/mn10300/include/asm/sections.h                |   6 +
 arch/mn10300/include/asm/tables.h                  |   6 +
 arch/mn10300/kernel/vmlinux.lds.S                  |   1 -
 arch/nios2/include/asm/ranges.h                    |   6 +
 arch/nios2/include/asm/sections.h                  |   6 +
 arch/nios2/include/asm/tables.h                    |   6 +
 arch/nios2/kernel/vmlinux.lds.S                    |   1 -
 arch/openrisc/include/asm/ranges.h                 |   6 +
 arch/openrisc/include/asm/sections.h               |   6 +
 arch/openrisc/include/asm/tables.h                 |   6 +
 arch/openrisc/kernel/vmlinux.lds.S                 |   1 -
 arch/parisc/include/asm/ranges.h                   |   6 +
 arch/parisc/include/asm/tables.h                   |   6 +
 arch/parisc/kernel/vmlinux.lds.S                   |   1 -
 arch/powerpc/include/asm/jump_label.h              |   8 +-
 arch/powerpc/include/asm/ppc_asm.h                 |   7 +-
 arch/powerpc/include/asm/ranges.h                  |   6 +
 arch/powerpc/include/asm/sections.h                |  11 +-
 arch/powerpc/include/asm/tables.h                  |   6 +
 arch/powerpc/kernel/vmlinux.lds.S                  |   1 -
 arch/s390/include/asm/jump_label.h                 |   6 +-
 arch/s390/include/asm/ranges.h                     |   6 +
 arch/s390/include/asm/tables.h                     |   6 +
 arch/s390/kernel/entry.S                           |   5 +-
 arch/s390/kernel/kprobes.c                         |   6 +-
 arch/s390/kernel/mcount.S                          |   2 +-
 arch/s390/kernel/vmlinux.lds.S                     |   1 -
 arch/score/include/asm/ranges.h                    |   6 +
 arch/score/include/asm/sections.h                  |   6 +
 arch/score/include/asm/tables.h                    |   6 +
 arch/score/kernel/vmlinux.lds.S                    |   1 -
 arch/sh/include/asm/ranges.h                       |   6 +
 arch/sh/include/asm/sections.h                     |   2 +
 arch/sh/include/asm/tables.h                       |   6 +
 arch/sh/kernel/vmlinux.lds.S                       |   1 -
 arch/sparc/include/asm/jump_label.h                |   6 +-
 arch/sparc/include/asm/ranges.h                    |   6 +
 arch/sparc/include/asm/sections.h                  |   4 +
 arch/sparc/include/asm/tables.h                    |   6 +
 arch/sparc/kernel/vmlinux.lds.S                    |   1 -
 arch/sparc/mm/ultra.S                              |   3 +-
 arch/tile/include/asm/ranges.h                     |   6 +
 arch/tile/include/asm/sections.h                   |   4 +
 arch/tile/include/asm/tables.h                     |   6 +
 arch/tile/kernel/vmlinux.lds.S                     |   1 -
 arch/um/include/asm/ranges.h                       |   6 +
 arch/um/include/asm/tables.h                       |   6 +
 arch/unicore32/include/asm/ranges.h                |   6 +
 arch/unicore32/include/asm/sections.h              |   6 +
 arch/unicore32/include/asm/tables.h                |   6 +
 arch/x86/include/asm/jump_label.h                  |  10 +-
 arch/x86/include/asm/ranges.h                      |   6 +
 arch/x86/include/asm/sections.h                    |  23 +-
 arch/x86/include/asm/tables.h                      |   6 +
 arch/x86/include/asm/uaccess.h                     |  18 +-
 arch/x86/kernel/cpu/microcode/core.c               |   8 +-
 arch/x86/kernel/kprobes/core.c                     |  11 +-
 arch/x86/kernel/vmlinux.lds.S                      |   1 -
 arch/x86/tools/relocs.c                            |   3 +
 arch/xtensa/include/asm/ranges.h                   |   6 +
 arch/xtensa/include/asm/sections.h                 |   6 +
 arch/xtensa/include/asm/tables.h                   |   6 +
 drivers/base/firmware_class.c                      |  12 +-
 drivers/platform/x86/dell-smo8800.c                |   1 +
 firmware/Makefile                                  |   7 +-
 include/asm-generic/ranges.h                       |  70 +++
 include/asm-generic/sections.h                     | 306 ++++++++++-
 include/asm-generic/tables.h                       |  70 +++
 include/asm-generic/vmlinux.lds.h                  |  66 +--
 include/linux/compiler.h                           |   2 +-
 include/linux/dynamic_debug.h                      |   5 +-
 include/linux/init.h                               |  20 +-
 include/linux/jump_label.h                         |  10 +-
 include/linux/kprobes.h                            |   8 +-
 include/linux/ranges.h                             |  54 ++
 include/linux/sections.h                           | 123 +++++
 include/linux/tables.h                             | 597 +++++++++++++++++++++
 kernel/jump_label.c                                |  17 +-
 kernel/kprobes.c                                   |  17 +-
 lib/dynamic_debug.c                                |  13 +-
 scripts/Makefile                                   |   1 +
 scripts/Makefile.build                             |   4 +-
 scripts/Makefile.clean                             |   1 +
 scripts/Makefile.lib                               |  12 +
 scripts/Makefile.modpost                           |   2 +-
 scripts/mod/Makefile                               |   2 +
 scripts/mod/modpost.c                              |   8 +-
 scripts/{module-common.lds => module-common.lds.S} |   6 +
 scripts/recordmcount.c                             |   7 +-
 scripts/recordmcount.pl                            |   2 +-
 tools/include/linux/sections.h                     |  13 +
 tools/objtool/special.c                            |   8 +-
 164 files changed, 2241 insertions(+), 205 deletions(-)
 create mode 100644 Documentation/DocBook/linker-tables.tmpl
 create mode 100644 Documentation/DocBook/sections.tmpl
 create mode 100644 arch/alpha/include/asm/ranges.h
 create mode 100644 arch/alpha/include/asm/sections.h
 create mode 100644 arch/alpha/include/asm/tables.h
 create mode 100644 arch/arc/include/asm/ranges.h
 create mode 100644 arch/arc/include/asm/tables.h
 create mode 100644 arch/arm/include/asm/ranges.h
 create mode 100644 arch/arm/include/asm/tables.h
 create mode 100644 arch/arm64/include/asm/ranges.h
 create mode 100644 arch/arm64/include/asm/sections.h
 create mode 100644 arch/arm64/include/asm/tables.h
 create mode 100644 arch/avr32/include/asm/ranges.h
 create mode 100644 arch/avr32/include/asm/sections.h
 create mode 100644 arch/avr32/include/asm/tables.h
 create mode 100644 arch/blackfin/include/asm/ranges.h
 create mode 100644 arch/blackfin/include/asm/tables.h
 create mode 100644 arch/c6x/include/asm/ranges.h
 create mode 100644 arch/c6x/include/asm/tables.h
 create mode 100644 arch/cris/include/asm/ranges.h
 create mode 100644 arch/cris/include/asm/sections.h
 create mode 100644 arch/cris/include/asm/tables.h
 create mode 100644 arch/frv/include/asm/ranges.h
 create mode 100644 arch/frv/include/asm/tables.h
 create mode 100644 arch/h8300/include/asm/ranges.h
 create mode 100644 arch/h8300/include/asm/sections.h
 create mode 100644 arch/h8300/include/asm/tables.h
 create mode 100644 arch/hexagon/include/asm/ranges.h
 create mode 100644 arch/hexagon/include/asm/sections.h
 create mode 100644 arch/hexagon/include/asm/tables.h
 create mode 100644 arch/ia64/include/asm/ranges.h
 create mode 100644 arch/ia64/include/asm/tables.h
 create mode 100644 arch/m32r/include/asm/ranges.h
 create mode 100644 arch/m32r/include/asm/sections.h
 create mode 100644 arch/m32r/include/asm/tables.h
 create mode 100644 arch/m68k/include/asm/ranges.h
 create mode 100644 arch/m68k/include/asm/sections.h
 create mode 100644 arch/m68k/include/asm/tables.h
 create mode 100644 arch/metag/include/asm/ranges.h
 create mode 100644 arch/metag/include/asm/sections.h
 create mode 100644 arch/metag/include/asm/tables.h
 create mode 100644 arch/microblaze/include/asm/ranges.h
 create mode 100644 arch/microblaze/include/asm/tables.h
 create mode 100644 arch/mips/include/asm/ranges.h
 create mode 100644 arch/mips/include/asm/sections.h
 create mode 100644 arch/mips/include/asm/tables.h
 create mode 100644 arch/mn10300/include/asm/ranges.h
 create mode 100644 arch/mn10300/include/asm/sections.h
 create mode 100644 arch/mn10300/include/asm/tables.h
 create mode 100644 arch/nios2/include/asm/ranges.h
 create mode 100644 arch/nios2/include/asm/sections.h
 create mode 100644 arch/nios2/include/asm/tables.h
 create mode 100644 arch/openrisc/include/asm/ranges.h
 create mode 100644 arch/openrisc/include/asm/sections.h
 create mode 100644 arch/openrisc/include/asm/tables.h
 create mode 100644 arch/parisc/include/asm/ranges.h
 create mode 100644 arch/parisc/include/asm/tables.h
 create mode 100644 arch/powerpc/include/asm/ranges.h
 create mode 100644 arch/powerpc/include/asm/tables.h
 create mode 100644 arch/s390/include/asm/ranges.h
 create mode 100644 arch/s390/include/asm/tables.h
 create mode 100644 arch/score/include/asm/ranges.h
 create mode 100644 arch/score/include/asm/sections.h
 create mode 100644 arch/score/include/asm/tables.h
 create mode 100644 arch/sh/include/asm/ranges.h
 create mode 100644 arch/sh/include/asm/tables.h
 create mode 100644 arch/sparc/include/asm/ranges.h
 create mode 100644 arch/sparc/include/asm/tables.h
 create mode 100644 arch/tile/include/asm/ranges.h
 create mode 100644 arch/tile/include/asm/tables.h
 create mode 100644 arch/um/include/asm/ranges.h
 create mode 100644 arch/um/include/asm/tables.h
 create mode 100644 arch/unicore32/include/asm/ranges.h
 create mode 100644 arch/unicore32/include/asm/sections.h
 create mode 100644 arch/unicore32/include/asm/tables.h
 create mode 100644 arch/x86/include/asm/ranges.h
 create mode 100644 arch/x86/include/asm/tables.h
 create mode 100644 arch/xtensa/include/asm/ranges.h
 create mode 100644 arch/xtensa/include/asm/sections.h
 create mode 100644 arch/xtensa/include/asm/tables.h
 create mode 100644 include/asm-generic/ranges.h
 create mode 100644 include/asm-generic/tables.h
 create mode 100644 include/linux/ranges.h
 create mode 100644 include/linux/sections.h
 create mode 100644 include/linux/tables.h
 rename scripts/{module-common.lds => module-common.lds.S} (80%)
 create mode 100644 tools/include/linux/sections.h

-- 
2.8.4

