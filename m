From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 22 Dec 2016 02:37:56 +0000
Subject: [PATCH v5 00/14] linux: generalize sections, ranges and linker tables
Message-Id: <20161222023811.21246-1-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel

Posting this for *after* the merge window.

This v5 addresses feedback from the last v4 series [0] about 4 months ago.
The first RFC series was posted just 1 year ago, last December 15 [1], its
been a long way coming. The largest amount of feedback from the v4 series came
from Nicholas Piggin, I've also made a few more minor changes and enhancements.

Because I have gone on different conferences talking about this work I've
jotted down in a white-paper form what this is all about and I've used it as
basis for a huge brush up on the documentation. I have not included the
paper into the tree as I think the documentation now stands for itself. The
paper may be useful for those wanted a huge verbose explanation to things
with much more in depth analysis and review of history [2].

I've split up the linker table patches in two groups to make it easier to
review, the first set (this) is for the kernel work, the second set is for the
tools/ userspace sandbox. If you would like to review all the changes in git
form you can yank them off of my linux-next 20161221-linker-tables-v5 branch on
kernel.org [3], please however note that the last patch on that tree was *not*
submitted upstream, it was used to force test 0-day and also Guenter's testbed
to force-enable and run the tests. You can disregard that patch unless you also
want to force test things :)

The biggest changes since v4 series worth noting:

  o Ended up using two dots (..) to separate the new sections to avoid conflicts
    with compiler generated sections, so we have: .text..rng.*, .data..tbl.*,
    etc.

  o Remove all the macro magic for section names. We now expect you to
    spell out each section manually. So no more SECTION_TEXT, for instance,
    for instance, we use just naked .text.

  o Adds a section linker table selftest driver. I have a debug out of tree
    patch used which was applied when testing which force enables the driver
    to be built in. This has been successfully run time tested against the
    following architectures:

    alpha      arc        arcv2       arm       arm64       blackfin    c6x
    cris       crisv32    frv         h8300     hexagon     i386        ia64
    m32r       m68k       m68k_nommu  metag     microblaze  mips_22     mips_24
    mips_25    mn10300    nios2       openrisc  parisc      parisc64    powerpc
    s390       score      sh          sparc32   sparc64     tile        um
    unicore32  x86_64     xtensa

    The only architecture that was not tested was avr32 and that is because
    linux-next fails to compile on it. I'd like to greatly thank Guenter Roeck
    for his help with testing.

  o A documentation revamp, to align what I hard originally written in the
    v4 series more in alignment with the the ELF specifications. Also properly
    document mark_rodata_ro().

  o Recruited Josh Poimboeuf and hpa as co-mainters of the general section
    stuff. For section ranges and linker tables it will be both me and hpa
    reviewing things. At Plumbers I spoke with Arnd and he would prefer changes
    to go in through each respective tree that needs each change, so no new
    tree is created. We'll just review and Ack/nack changes.

Happy holidays, and may the force be with you all...

Oh and lastly, a quick summary of the gains of having an API for all this.

First the obvious gains:

  o Allows us to just use plain C code to add new program specific
    ELF sections
  o Makes it less error prone to add new sections

Then the not so obvious immediate gains:

  o Helps simplify initialization code
  o Helps optionally avoid code bit-rot (see commit "kbuild: enable option to
    force compile force-obj-y and force-lib-y)
  o Enables link time ordering which can help make an extremely lightweight
    dependency annotations explicit (for this refer to the tools/linker-tables/
    example where I've demo'd simplfying Xen PV init code, which has caused
    tons of regressions over time due to the lack of explicit dependency
    annotations due to the sloppy Xen PV entry path; this is not going away
    any time soon)

Not so obvious long term gains:

  o Run time ordering customization are still possible (this is really long
    term but we already have one precedent in the kernel that does memmove()
    on entries on a section per some dependency heuristic.)
  o May help prevent use of dead code by either free'ing / nop'ing, no exec
    or whatever sections which we know should definitely not run.
  o Can easily increase the levels of initialization in the kernel without
    much changes (refer to tools/linker-tables/ for an example init with
    linker tables). I've seen a few cases where we've already run out of space
    to get init right in a few subsystems. This not only allows this but also
    allows subsystems to define their own custom levels of init if they wanted
    for their own things.
  o Synthetic functions: enables custom C / asm functions which could help
    add new functionality (see synth_init_or() on tools/linker-tables/drivers/synth/main.c)
    I've been hinted this can help with RAID6 support
  o Self modifying consts (see ps_shr() on tools/linker-tables/drivers/synth/main.c)

[0] https://lkml.kernel.org/r/1471642454-5679-1-git-send-email-mcgrof@kernel.org
[1] https://lkml.kernel.org/r/1450217797-19295-1-git-send-email-mcgrof@do-not-panic.com
[2] http://drvbp1.linux-foundation.org/~mcgrof/papers/2016/12/21/linker-tables-20161221.pdf
[3] https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linux-next.git/log/?h 161221-linker-tables-v5

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
2.10.1

