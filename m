From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:32:49 +0000
Subject: [PATCH v4 00/16] linux: generalize sections, ranges and linker tables
Message-Id: <1471642385-5629-1-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, sparclinux@vger.kernel.org, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, xen-devel@lists.xensource.com, msalter@redhat.com, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, fontana@sharpeleven.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, jani.nikula@intel.com, will.deacon@arm.com, rusty@rustcorp.com.au, rostedt@goodmis.org, acme@redhat.com, ak@linux.intel.com, andriy.shevchenko@linux.intel.com, mcb30@ip

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

This v4 addresses feedback from the previous v3 series [0], and also
addresses a huge array of additional tests against many architectures
outside of what 0-day provides. As I mentioned in my last v3 series,
0-day had only found one issue with the series, a blackfin architecture
linker issue with the last series. Guenter Rock was kind enough to give
my series a test spin on his test bed and he found quite a bit of other
oddball issues with obscure architectures, and even on x86 with an old
toolchain. After a lot of work and coordinating with a few maintainers
I'm happy to report all issues found so far through all possible testing
I could do are now fixed, this series also addresses all feedback from
the last series, as such this goes submitted as PATCH form.

In addressing fixing this work on a few architectures some of the previous
patches are further simplified. The kprobes port to linker tables is made
much easier now that I've addressed moving out core kprobe declarations
into asm-generic/kprobes.h. Refer to the patch "kprobes: move kprobe
declarations to asm-generic/kprobes.h". This makes for a much cleaner
solution across architectures.

Boris feedback on making the code bit rot feature optional is addressed
by using a new Kconfig symbol for this, CONFIG_BUILD_AVOID_BITROT,
but given Greg's concerns over lack of clarity over what this was all about
I've ripped that functionality out into its own patch with a bit more
extensive documentation and re-wording. See the patch "kbuild: enable option
to force compile force-obj-y and force-lib-y". I hope makes it clear how
linker tables can help with avoiding code bit rot. I've gone with a new
Kconfig symbol CONFIG_BUILD_AVOID_BITROT given CONFIG_COMPILE_TEST is
not available on UML, this feature is desirable on all architectures.

The documentation is revamped, now that the DocBook format is deprecated
I ported the documention into the trendy hipster Sphinx documentation
format.

AT Boris' request I've adapated the userspace linker table application
forintegration into the kernel under tools/ to make it easier to keep
things in sync, however since this requires a bit of changes to some headers
in tools/ I'll submit that separately.

[0] https://lkml.kernel.org/r/1469222687-1600-1-git-send-email-mcgrof@kernel.org

If you'd like this in git-form, you can get it on the 20160819-linker-table-v4
branch of my linux-next tree on kernel.org, this also includes the series of
the linker table userspace sandbox:

https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linux-next.git/log/?h 160819-linker-table-v4

Please let me know if there are any concerns or questions.

Luis R. Rodriguez (16):
  x86: remove LTO_REFERENCE_INITCALL()
  dell-smo8800: include uaccess.h
  scripts/module-common.lds: enable generation
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

 .gitignore                                         |   2 +
 Documentation/index.rst                            |   1 +
 Documentation/kbuild/makefiles.txt                 |  36 ++
 Documentation/sections/conf.py                     |   4 +
 Documentation/sections/index.rst                   |  13 +
 Documentation/sections/linker-tables.rst           | 202 +++++++
 Documentation/sections/ranges.rst                  |  49 ++
 Documentation/sections/section-core.rst            | 153 +++++
 MAINTAINERS                                        |  37 ++
 Makefile                                           |   6 +-
 arch/alpha/include/asm/Kbuild                      |   4 +
 arch/arc/include/asm/Kbuild                        |   3 +
 arch/arc/include/asm/kprobes.h                     |   6 +-
 arch/arc/kernel/vmlinux.lds.S                      |   1 -
 arch/arm/include/asm/Kbuild                        |   3 +
 arch/arm/include/asm/jump_label.h                  |   6 +-
 arch/arm/include/asm/kprobes.h                     |   4 +
 arch/arm/kernel/entry-armv.S                       |   3 +-
 arch/arm/kernel/vmlinux-xip.lds.S                  |   1 -
 arch/arm/kernel/vmlinux.lds.S                      |   1 -
 arch/arm/probes/decode.h                           |   1 +
 arch/arm64/include/asm/Kbuild                      |   3 +
 arch/arm64/include/asm/jump_label.h                |   6 +-
 arch/arm64/include/asm/kprobes.h                   |   4 +
 arch/arm64/kernel/armv8_deprecated.c               |   1 +
 arch/arm64/kernel/insn.c                           |   1 +
 arch/arm64/kernel/probes/kprobes.c                 |   4 +-
 arch/arm64/kernel/vmlinux.lds.S                    |   1 -
 arch/avr32/include/asm/Kbuild                      |   3 +
 arch/avr32/include/asm/kprobes.h                   |   4 +
 arch/avr32/kernel/entry-avr32b.S                   |  13 +-
 arch/avr32/kernel/vmlinux.lds.S                    |   1 -
 arch/blackfin/include/asm/Kbuild                   |   4 +
 arch/blackfin/kernel/vmlinux.lds.S                 |   1 -
 arch/c6x/include/asm/Kbuild                        |   3 +
 arch/c6x/include/asm/tables.h                      |  26 +
 arch/c6x/kernel/vmlinux.lds.S                      |   1 -
 arch/cris/include/asm/Kbuild                       |   4 +
 arch/frv/include/asm/Kbuild                        |   4 +
 arch/h8300/include/asm/Kbuild                      |   4 +
 arch/hexagon/include/asm/Kbuild                    |   4 +
 arch/hexagon/kernel/vmlinux.lds.S                  |   1 -
 arch/ia64/include/asm/Kbuild                       |   3 +
 arch/ia64/include/asm/kprobes.h                    |   7 +-
 arch/ia64/kernel/jprobes.S                         |   3 +-
 arch/ia64/kernel/vmlinux.lds.S                     |   1 -
 arch/ia64/lib/flush.S                              |   6 +-
 arch/m32r/include/asm/Kbuild                       |   4 +
 arch/m68k/include/asm/Kbuild                       |   4 +
 arch/metag/include/asm/Kbuild                      |   4 +
 arch/metag/kernel/vmlinux.lds.S                    |   1 -
 arch/microblaze/include/asm/Kbuild                 |   4 +
 arch/microblaze/kernel/vmlinux.lds.S               |   1 -
 arch/mips/include/asm/Kbuild                       |   3 +
 arch/mips/include/asm/jump_label.h                 |   6 +-
 arch/mips/include/asm/kprobes.h                    |   6 +-
 arch/mips/kernel/vmlinux.lds.S                     |   1 -
 arch/mn10300/include/asm/Kbuild                    |   3 +
 arch/mn10300/include/asm/kprobes.h                 |   4 +
 arch/mn10300/kernel/vmlinux.lds.S                  |   1 -
 arch/nios2/include/asm/Kbuild                      |   4 +
 arch/nios2/kernel/vmlinux.lds.S                    |   1 -
 arch/openrisc/include/asm/Kbuild                   |   4 +
 arch/openrisc/kernel/vmlinux.lds.S                 |   1 -
 arch/parisc/include/asm/Kbuild                     |   4 +
 arch/parisc/kernel/vmlinux.lds.S                   |   1 -
 arch/powerpc/include/asm/Kbuild                    |   3 +
 arch/powerpc/include/asm/jump_label.h              |   8 +-
 arch/powerpc/include/asm/kprobes.h                 |   6 +
 arch/powerpc/include/asm/ppc_asm.h                 |   7 +-
 arch/powerpc/kernel/vmlinux.lds.S                  |   1 -
 arch/s390/include/asm/Kbuild                       |   3 +
 arch/s390/include/asm/jump_label.h                 |   6 +-
 arch/s390/include/asm/kprobes.h                    |   4 +
 arch/s390/kernel/entry.S                           |   5 +-
 arch/s390/kernel/kprobes.c                         |   6 +-
 arch/s390/kernel/mcount.S                          |   3 +-
 arch/s390/kernel/vmlinux.lds.S                     |   1 -
 arch/score/include/asm/Kbuild                      |   4 +
 arch/score/kernel/vmlinux.lds.S                    |   1 -
 arch/sh/include/asm/Kbuild                         |   3 +
 arch/sh/include/asm/kprobes.h                      |   2 +
 arch/sh/kernel/vmlinux.lds.S                       |   1 -
 arch/sparc/include/asm/Kbuild                      |   3 +
 arch/sparc/include/asm/jump_label.h                |   6 +-
 arch/sparc/include/asm/kprobes.h                   |   5 +
 arch/sparc/kernel/vmlinux.lds.S                    |   1 -
 arch/sparc/mm/ultra.S                              |   3 +-
 arch/tile/include/asm/Kbuild                       |   3 +
 arch/tile/include/asm/kprobes.h                    |   6 +-
 arch/tile/kernel/vmlinux.lds.S                     |   1 -
 arch/um/include/asm/Kbuild                         |   4 +
 arch/unicore32/include/asm/Kbuild                  |   3 +
 arch/unicore32/include/asm/section-core.h          |  19 +
 arch/x86/include/asm/Kbuild                        |   3 +
 arch/x86/include/asm/jump_label.h                  |  10 +-
 arch/x86/include/asm/kprobes.h                     |   6 +
 arch/x86/kernel/cpu/microcode/core.c               |   8 +-
 arch/x86/kernel/kprobes/core.c                     |  11 +-
 arch/x86/kernel/vmlinux.lds.S                      |   1 -
 arch/x86/tools/relocs.c                            |   4 +
 arch/xtensa/include/asm/Kbuild                     |   4 +
 arch/xtensa/kernel/Makefile                        |   8 +-
 drivers/base/firmware_class.c                      |  12 +-
 drivers/platform/x86/dell-smo8800.c                |   1 +
 firmware/Makefile                                  |   6 +-
 include/asm-generic/kprobes.h                      |  26 +
 include/asm-generic/ranges.h                       | 103 ++++
 include/asm-generic/section-core.h                 | 341 +++++++++++
 include/asm-generic/sections.h                     |   4 +-
 include/asm-generic/tables.h                       |  50 ++
 include/asm-generic/vmlinux.lds.h                  |  73 +--
 include/linux/compiler.h                           |   8 -
 include/linux/dynamic_debug.h                      |   5 +-
 include/linux/init.h                               |  20 +-
 include/linux/jump_label.h                         |   8 +-
 include/linux/kprobes.h                            |  24 +-
 include/linux/ranges.h                             | 128 +++++
 include/linux/sections.h                           | 111 ++++
 include/linux/tables.h                             | 638 +++++++++++++++++++++
 init/Kconfig                                       |  22 +
 kernel/jump_label.c                                |  17 +-
 kernel/kprobes.c                                   |  17 +-
 lib/dynamic_debug.c                                |  13 +-
 scripts/Makefile.build                             |   7 +-
 scripts/Makefile.clean                             |   2 +
 scripts/Makefile.lib                               |  11 +
 scripts/Makefile.modpost                           |   2 +-
 scripts/mod/modpost.c                              |   2 +-
 scripts/{module-common.lds => module-common.lds.S} |   6 +
 scripts/recordmcount.c                             |   2 +-
 scripts/recordmcount.pl                            |   2 +-
 tools/objtool/special.c                            |   2 +-
 133 files changed, 2328 insertions(+), 214 deletions(-)
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
 rename scripts/{module-common.lds => module-common.lds.S} (80%)

-- 
2.9.2

