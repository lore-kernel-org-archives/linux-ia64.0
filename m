From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Mon, 09 Jan 2017 14:58:18 +0000
Subject: [PATCH v6 00/14] linux: generalize sections, ranges and linker tables
Message-Id: <20170109145833.11502-1-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161222023811.21246-1-mcgrof@kernel.org>
In-Reply-To: <20161222023811.21246-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

This v6 addresses Andy Shevchenko's feedback from the v5 series [0] to use
lowercase on a few of the tables.h macros. No other changes have been done to
this series. As I had mentioned on the last cover-letter the v5 series had
gone through a lot of testing both compile and run time, with the linktable
test driver forced-enabled as a debug measure to try to capture errors as
many architectures as possible:

    alpha      arc        arcv2       arm       arm64       blackfin    c6x                                                                                                     
    cris       crisv32    frv         h8300     hexagon     i386        ia64                                                                                                    
    m32r       m68k       m68k_nommu  metag     microblaze  mips_22     mips_24                                                                                                 
    mips_25    mn10300    nios2       openrisc  parisc      parisc64    powerpc                                                                                                 
    s390       score      sh          sparc32   sparc64     tile        um                                                                                                      
    unicore32  x86_64     xtensa                                                                                                                                                

The only architecture that was not tested was avr32 and that is because
linux-next fails to compile on it. I'd like to greatly thank Guenter Roeck for
his help with testing.

The debug patch which force enables the test driver is not submitted for
upstream inclusion but is kept as part of the public tree for those curious,
its the last patch [1]. This tree is based on linux-next tag next-20170109.

[0] https://lkml.kernel.org/r/20161222023811.21246-1-mcgrof@kernel.org
[1] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linux-next.git/log/?h 170109-linker-tables-v6

Luis R. Rodriguez (14):
  generic-sections: add section core helpers
  xtensa: skip adding literal when SORT() is used
  ranges.h: add helpers to build and identify Linux section ranges
  tables.h: add linker table support
  kbuild: enable option to force compile force-obj-y and force-lib-y
  firmware/Makefile: force recompilation if makefile changes
  firmware: port built-in section to linker table
  jump_label: move guard #endif down where it belongs
  jump_label: port __jump_table to linker tables
  dynamic_debug: port to use linker tables
  kprobes: move kprobe declarations to asm-generic/kprobes.h
  kprobes: port .kprobes.text to section range
  kprobes: port blacklist kprobes to linker table
  lib: add linker tables test driver

 Documentation/index.rst                   |   1 +
 Documentation/kbuild/makefiles.txt        |  36 ++
 Documentation/sections/background.rst     | 105 ++++
 Documentation/sections/conf.py            |   4 +
 Documentation/sections/index.rst          |  19 +
 Documentation/sections/linker-tables.rst  | 227 +++++++++
 Documentation/sections/ranges.rst         |  74 +++
 Documentation/sections/section-core.rst   | 153 ++++++
 MAINTAINERS                               |  32 ++
 arch/alpha/include/asm/Kbuild             |   4 +
 arch/arc/include/asm/Kbuild               |   3 +
 arch/arc/include/asm/kprobes.h            |   6 +-
 arch/arc/kernel/vmlinux.lds.S             |   1 -
 arch/arm/include/asm/Kbuild               |   3 +
 arch/arm/include/asm/jump_label.h         |   6 +-
 arch/arm/include/asm/kprobes.h            |   4 +
 arch/arm/kernel/entry-armv.S              |   3 +-
 arch/arm/kernel/vmlinux-xip.lds.S         |   1 -
 arch/arm/kernel/vmlinux.lds.S             |   1 -
 arch/arm/probes/decode.h                  |   1 +
 arch/arm64/include/asm/Kbuild             |   3 +
 arch/arm64/include/asm/jump_label.h       |   6 +-
 arch/arm64/include/asm/kprobes.h          |   4 +
 arch/arm64/kernel/armv8_deprecated.c      |   1 +
 arch/arm64/kernel/insn.c                  |   1 +
 arch/arm64/kernel/probes/decode-insn.h    |   2 +
 arch/arm64/kernel/probes/kprobes.c        |   4 +-
 arch/arm64/kernel/vmlinux.lds.S           |   1 -
 arch/avr32/include/asm/Kbuild             |   3 +
 arch/avr32/include/asm/kprobes.h          |   7 +-
 arch/avr32/kernel/entry-avr32b.S          |  13 +-
 arch/avr32/kernel/vmlinux.lds.S           |   1 -
 arch/blackfin/include/asm/Kbuild          |   4 +
 arch/blackfin/kernel/vmlinux.lds.S        |   1 -
 arch/c6x/include/asm/Kbuild               |   3 +
 arch/c6x/include/asm/tables.h             |  26 +
 arch/c6x/kernel/vmlinux.lds.S             |   1 -
 arch/cris/include/asm/Kbuild              |   4 +
 arch/frv/include/asm/Kbuild               |   4 +
 arch/h8300/include/asm/Kbuild             |   4 +
 arch/hexagon/include/asm/Kbuild           |   4 +
 arch/hexagon/kernel/vmlinux.lds.S         |   1 -
 arch/ia64/include/asm/Kbuild              |   3 +
 arch/ia64/include/asm/kprobes.h           |  12 +-
 arch/ia64/kernel/jprobes.S                |   3 +-
 arch/ia64/kernel/vmlinux.lds.S            |   1 -
 arch/ia64/lib/flush.S                     |   6 +-
 arch/m32r/include/asm/Kbuild              |   4 +
 arch/m68k/include/asm/Kbuild              |   4 +
 arch/metag/include/asm/Kbuild             |   4 +
 arch/metag/kernel/vmlinux.lds.S           |   1 -
 arch/microblaze/include/asm/Kbuild        |   4 +
 arch/microblaze/kernel/vmlinux.lds.S      |   1 -
 arch/mips/include/asm/Kbuild              |   3 +
 arch/mips/include/asm/jump_label.h        |   6 +-
 arch/mips/include/asm/kprobes.h           |   6 +-
 arch/mips/kernel/vmlinux.lds.S            |   1 -
 arch/mn10300/include/asm/Kbuild           |   3 +
 arch/mn10300/include/asm/kprobes.h        |   7 +-
 arch/mn10300/kernel/vmlinux.lds.S         |   1 -
 arch/nios2/include/asm/Kbuild             |   4 +
 arch/nios2/kernel/vmlinux.lds.S           |   1 -
 arch/openrisc/include/asm/Kbuild          |   4 +
 arch/openrisc/kernel/vmlinux.lds.S        |   1 -
 arch/parisc/include/asm/Kbuild            |   4 +
 arch/parisc/kernel/vmlinux.lds.S          |   1 -
 arch/powerpc/include/asm/Kbuild           |   3 +
 arch/powerpc/include/asm/jump_label.h     |   8 +-
 arch/powerpc/include/asm/kprobes.h        |   3 +
 arch/powerpc/include/asm/ppc_asm.h        |   3 +-
 arch/powerpc/kernel/vmlinux.lds.S         |   3 +-
 arch/s390/include/asm/Kbuild              |   3 +
 arch/s390/include/asm/jump_label.h        |   6 +-
 arch/s390/include/asm/kprobes.h           |   7 +-
 arch/s390/kernel/entry.S                  |   5 +-
 arch/s390/kernel/kprobes.c                |   6 +-
 arch/s390/kernel/mcount.S                 |   3 +-
 arch/s390/kernel/vmlinux.lds.S            |   1 -
 arch/score/include/asm/Kbuild             |   4 +
 arch/score/kernel/vmlinux.lds.S           |   1 -
 arch/sh/include/asm/Kbuild                |   3 +
 arch/sh/include/asm/kprobes.h             |   5 +-
 arch/sh/kernel/vmlinux.lds.S              |   1 -
 arch/sparc/include/asm/Kbuild             |   3 +
 arch/sparc/include/asm/jump_label.h       |   6 +-
 arch/sparc/include/asm/kprobes.h          |  10 +-
 arch/sparc/kernel/vmlinux.lds.S           |   1 -
 arch/sparc/mm/ultra.S                     |   3 +-
 arch/tile/include/asm/Kbuild              |   3 +
 arch/tile/include/asm/jump_label.h        |   5 +-
 arch/tile/include/asm/kprobes.h           |   6 +-
 arch/tile/kernel/vmlinux.lds.S            |   1 -
 arch/um/include/asm/Kbuild                |   4 +
 arch/unicore32/include/asm/Kbuild         |   3 +
 arch/unicore32/include/asm/section-core.h |  19 +
 arch/x86/include/asm/Kbuild               |   3 +
 arch/x86/include/asm/asm.h                |   4 +-
 arch/x86/include/asm/jump_label.h         |  10 +-
 arch/x86/include/asm/kprobes.h            |   9 +-
 arch/x86/kernel/cpu/microcode/core.c      |   8 +-
 arch/x86/kernel/kprobes/core.c            |  11 +-
 arch/x86/kernel/vmlinux.lds.S             |   1 -
 arch/x86/tools/relocs.c                   |   4 +
 arch/xtensa/include/asm/Kbuild            |   4 +
 arch/xtensa/kernel/Makefile               |   8 +-
 drivers/base/firmware_class.c             |  12 +-
 firmware/Makefile                         |   6 +-
 include/asm-generic/kprobes.h             |  26 +
 include/asm-generic/ranges.h              |  93 ++++
 include/asm-generic/section-core.h        | 348 +++++++++++++
 include/asm-generic/sections.h            |   4 +-
 include/asm-generic/tables.h              |  48 ++
 include/asm-generic/vmlinux.lds.h         |  47 +-
 include/linux/compiler.h                  |   8 -
 include/linux/dynamic_debug.h             |   5 +-
 include/linux/init.h                      |  89 +++-
 include/linux/jump_label.h                |   8 +-
 include/linux/kprobes.h                   |  24 +-
 include/linux/ranges.h                    | 183 +++++++
 include/linux/sections.h                  |  87 ++++
 include/linux/tables.h                    | 683 +++++++++++++++++++++++++
 init/Kconfig                              |  22 +
 kernel/jump_label.c                       |  17 +-
 kernel/kprobes.c                          |  17 +-
 lib/Kconfig.debug                         |   6 +
 lib/Makefile                              |   1 +
 lib/dynamic_debug.c                       |  13 +-
 lib/test_linktables/Makefile              |  13 +
 lib/test_linktables/test-linktables-00.c  |  27 +
 lib/test_linktables/test-linktables-01.c  |  27 +
 lib/test_linktables/test-linktables-02.c  |  27 +
 lib/test_linktables/test-linktables-03.c  |  27 +
 lib/test_linktables/test-linktables-04.c  |  27 +
 lib/test_linktables/test-linktables.c     | 801 ++++++++++++++++++++++++++++++
 lib/test_linktables/test-linktables.h     |  48 ++
 scripts/Makefile.build                    |   7 +-
 scripts/Makefile.clean                    |   2 +
 scripts/Makefile.lib                      |  11 +
 scripts/mod/modpost.c                     |   2 +-
 scripts/module-common.lds                 |   2 +
 scripts/recordmcount.c                    |   2 +-
 scripts/recordmcount.pl                   |   2 +-
 tools/objtool/special.c                   |   2 +-
 143 files changed, 3632 insertions(+), 200 deletions(-)
 create mode 100644 Documentation/sections/background.rst
 create mode 100644 Documentation/sections/conf.py
 create mode 100644 Documentation/sections/index.rst
 create mode 100644 Documentation/sections/linker-tables.rst
 create mode 100644 Documentation/sections/ranges.rst
 create mode 100644 Documentation/sections/section-core.rst
 create mode 100644 arch/c6x/include/asm/tables.h
 create mode 100644 arch/unicore32/include/asm/section-core.h
 create mode 100644 include/asm-generic/kprobes.h
 create mode 100644 include/asm-generic/ranges.h
 create mode 100644 include/asm-generic/section-core.h
 create mode 100644 include/asm-generic/tables.h
 create mode 100644 include/linux/ranges.h
 create mode 100644 include/linux/sections.h
 create mode 100644 include/linux/tables.h
 create mode 100644 lib/test_linktables/Makefile
 create mode 100644 lib/test_linktables/test-linktables-00.c
 create mode 100644 lib/test_linktables/test-linktables-01.c
 create mode 100644 lib/test_linktables/test-linktables-02.c
 create mode 100644 lib/test_linktables/test-linktables-03.c
 create mode 100644 lib/test_linktables/test-linktables-04.c
 create mode 100644 lib/test_linktables/test-linktables.c
 create mode 100644 lib/test_linktables/test-linktables.h

-- 
2.11.0

