From: mcgrof@kernel.org
Date: Fri, 19 Aug 2016 21:41:08 +0000
Subject: [PATCH v1 0/7] tools: add linker table userspace sandbox
Message-Id: <1471642875-5957-1-git-send-email-mcgrof@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acme@redhat.com, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, ton

From: "Luis R. Rodriguez" <mcgrof@kernel.org>

The original v3 series for linker tables made reference only to
an external repository userspace sandbox application, however
Boris noted it'd be difficult ot keep this in sync with the
kernel so advised to consider integrate with the kernel. I've
taken steps in this direction.

A bit of prepping is done to help make use of the tools/include
and tools/arch/$(ARCH)/include/asm directories. For now the tool
only supports x86_64, however quite a bit of work was done to
help make it work with a cross compiler, and try to make as
architecture agnostic as possible. Adding suppor for another 
architecture should not require much work, mosty just generating
a userspace custom linker script, modifying it for linker tables,
section ranges, and finally testing this with its toolchain.

This is being submitted separately than the patches which adds
linker table support into the kernel. This should be considered
only if that gets merged.

If you'd like this in git-form, you can get it on the 20160819-linker-table-v4  
branch of my linux-next tree on kernel.org, this also includes the series of    
that introduces linker tables into the kernel:
                                                                                
https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linux-next.git/log/?h 160819-linker-table-v4

Please let me know if there are any issue or questions.

Luis R. Rodriguez (7):
  tools: add a userspace tools bug.h
  tools: add a basic tools printk.h
  tools: add init.h for tools
  tools: add __used and enable to override
  tools: expand export.h with VMLINUX_SYMBOL()
  tools: add __section() to compiler.h
  tools: add userspace linker table sandbox

 Documentation/sections/linker-tables.rst           |   4 +-
 MAINTAINERS                                        |   1 +
 include/linux/tables.h                             |   5 +-
 tools/Makefile                                     |   3 +-
 .../arch/x86/include/generated/asm/section-core.h  |   1 +
 tools/arch/x86/include/generated/ranges.h          |   1 +
 tools/arch/x86/include/generated/tables.h          |   1 +
 tools/include/asm-generic/bug.h                    |  24 +
 tools/include/asm-generic/ranges.h                 | 103 ++++
 tools/include/asm-generic/section-core.h           | 341 +++++++++++
 tools/include/asm-generic/tables.h                 |  50 ++
 tools/include/linux/bug.h                          |   6 +
 tools/include/linux/compiler.h                     |   8 +
 tools/include/linux/export.h                       |  22 +
 tools/include/linux/init.h                         |   9 +
 tools/include/linux/kernel.h                       |   3 +
 tools/include/linux/printk.h                       |  14 +
 tools/include/linux/ranges.h                       | 128 ++++
 tools/include/linux/sections.h                     | 111 ++++
 tools/include/linux/string.h                       |   1 +
 tools/include/linux/tables.h                       | 664 +++++++++++++++++++++
 tools/linker-tables/.gitignore                     |   2 +
 tools/linker-tables/Makefile                       | 184 ++++++
 tools/linker-tables/README                         | 114 ++++
 tools/linker-tables/arch/x86/include/asm/asm.h     |  17 +
 tools/linker-tables/arch/x86/include/asm/boot.h    |   1 +
 .../linker-tables/arch/x86/include/asm/bootparam.h |  32 +
 tools/linker-tables/arch/x86/include/asm/kprobes.h |   7 +
 .../linker-tables/arch/x86/include/asm/ps_const.h  |  21 +
 tools/linker-tables/arch/x86/include/asm/ranges.h  |   6 +
 .../arch/x86/include/asm/section-core.h            |   1 +
 tools/linker-tables/arch/x86/include/asm/setup.h   |   6 +
 tools/linker-tables/arch/x86/include/asm/tables.h  |   6 +
 tools/linker-tables/arch/x86/include/asm/x86.h     |   4 +
 .../arch/x86/include/asm/x86_init_fn.h             | 169 ++++++
 tools/linker-tables/arch/x86/kernel/alpha.c        |   9 +
 tools/linker-tables/arch/x86/kernel/alternative.c  |  31 +
 tools/linker-tables/arch/x86/kernel/beta.c         |   9 +
 tools/linker-tables/arch/x86/kernel/head64.c       |  58 ++
 tools/linker-tables/arch/x86/kernel/init.c         |  42 ++
 tools/linker-tables/arch/x86/kernel/kasan.c        |  10 +
 tools/linker-tables/arch/x86/kernel/kprobes.c      |  51 ++
 tools/linker-tables/arch/x86/kernel/vmlinux.lds.S  | 273 +++++++++
 tools/linker-tables/arch/x86/mm/init.c             |  10 +
 tools/linker-tables/arch/x86/xen/init.c            |  13 +
 tools/linker-tables/drivers/acme.c                 |  32 +
 tools/linker-tables/drivers/synth/common.c         |  16 +
 tools/linker-tables/drivers/synth/common.h         |   2 +
 tools/linker-tables/drivers/synth/main.c           |  35 ++
 tools/linker-tables/drivers/synth/or.S             |  39 ++
 tools/linker-tables/drivers/synth/synth.h          |   2 +
 tools/linker-tables/drivers/xen-driver.c           |  11 +
 .../include/asm-generic/arch_init_fn.h             |  50 ++
 tools/linker-tables/include/asm-generic/kprobes.h  |  26 +
 tools/linker-tables/include/linux/bitops.h         |   6 +
 tools/linker-tables/include/linux/init.h           |  40 ++
 tools/linker-tables/include/linux/kasan.h          |   5 +
 tools/linker-tables/include/linux/kprobes.h        |  11 +
 tools/linker-tables/include/linux/module.h         |  14 +
 tools/linker-tables/include/linux/mutex.h          |  17 +
 tools/linker-tables/include/linux/pci.h            |   7 +
 tools/linker-tables/include/linux/ps_const.h       |  46 ++
 tools/linker-tables/include/linux/sched.h          |   9 +
 tools/linker-tables/include/linux/spinlock.h       |  13 +
 tools/linker-tables/include/linux/start_kernel.h   |   1 +
 tools/linker-tables/include/linux/types.h          |  13 +
 tools/linker-tables/include/linux/workqueue.h      |  51 ++
 tools/linker-tables/include/xen/xen.h              |   4 +
 tools/linker-tables/kernel/locking/mutex.c         |  28 +
 tools/linker-tables/kernel/locking/spinlock.c      |  26 +
 tools/linker-tables/kernel/main.c                  |  32 +
 tools/linker-tables/kernel/workqueue.c             |  43 ++
 tools/linker-tables/lib/string.c                   |  26 +
 tools/linker-tables/main.c                         |  20 +
 tools/linker-tables/pci-quirks.c                   |  13 +
 tools/linker-tables/pci.c                          |  29 +
 76 files changed, 3238 insertions(+), 5 deletions(-)
 create mode 100644 tools/arch/x86/include/generated/asm/section-core.h
 create mode 100644 tools/arch/x86/include/generated/ranges.h
 create mode 100644 tools/arch/x86/include/generated/tables.h
 create mode 100644 tools/include/asm-generic/bug.h
 create mode 100644 tools/include/asm-generic/ranges.h
 create mode 100644 tools/include/asm-generic/section-core.h
 create mode 100644 tools/include/asm-generic/tables.h
 create mode 100644 tools/include/linux/bug.h
 create mode 100644 tools/include/linux/init.h
 create mode 100644 tools/include/linux/printk.h
 create mode 100644 tools/include/linux/ranges.h
 create mode 100644 tools/include/linux/sections.h
 create mode 100644 tools/include/linux/tables.h
 create mode 100644 tools/linker-tables/.gitignore
 create mode 100644 tools/linker-tables/Makefile
 create mode 100644 tools/linker-tables/README
 create mode 100644 tools/linker-tables/arch/x86/include/asm/asm.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/boot.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/bootparam.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/kprobes.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/ps_const.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/ranges.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/section-core.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/setup.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/tables.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/x86.h
 create mode 100644 tools/linker-tables/arch/x86/include/asm/x86_init_fn.h
 create mode 100644 tools/linker-tables/arch/x86/kernel/alpha.c
 create mode 100644 tools/linker-tables/arch/x86/kernel/alternative.c
 create mode 100644 tools/linker-tables/arch/x86/kernel/beta.c
 create mode 100644 tools/linker-tables/arch/x86/kernel/head64.c
 create mode 100644 tools/linker-tables/arch/x86/kernel/init.c
 create mode 100644 tools/linker-tables/arch/x86/kernel/kasan.c
 create mode 100644 tools/linker-tables/arch/x86/kernel/kprobes.c
 create mode 100644 tools/linker-tables/arch/x86/kernel/vmlinux.lds.S
 create mode 100644 tools/linker-tables/arch/x86/mm/init.c
 create mode 100644 tools/linker-tables/arch/x86/xen/init.c
 create mode 100644 tools/linker-tables/drivers/acme.c
 create mode 100644 tools/linker-tables/drivers/synth/common.c
 create mode 100644 tools/linker-tables/drivers/synth/common.h
 create mode 100644 tools/linker-tables/drivers/synth/main.c
 create mode 100644 tools/linker-tables/drivers/synth/or.S
 create mode 100644 tools/linker-tables/drivers/synth/synth.h
 create mode 100644 tools/linker-tables/drivers/xen-driver.c
 create mode 100644 tools/linker-tables/include/asm-generic/arch_init_fn.h
 create mode 100644 tools/linker-tables/include/asm-generic/kprobes.h
 create mode 100644 tools/linker-tables/include/linux/bitops.h
 create mode 100644 tools/linker-tables/include/linux/init.h
 create mode 100644 tools/linker-tables/include/linux/kasan.h
 create mode 100644 tools/linker-tables/include/linux/kprobes.h
 create mode 100644 tools/linker-tables/include/linux/module.h
 create mode 100644 tools/linker-tables/include/linux/mutex.h
 create mode 100644 tools/linker-tables/include/linux/pci.h
 create mode 100644 tools/linker-tables/include/linux/ps_const.h
 create mode 100644 tools/linker-tables/include/linux/sched.h
 create mode 100644 tools/linker-tables/include/linux/spinlock.h
 create mode 100644 tools/linker-tables/include/linux/start_kernel.h
 create mode 100644 tools/linker-tables/include/linux/types.h
 create mode 100644 tools/linker-tables/include/linux/workqueue.h
 create mode 100644 tools/linker-tables/include/xen/xen.h
 create mode 100644 tools/linker-tables/kernel/locking/mutex.c
 create mode 100644 tools/linker-tables/kernel/locking/spinlock.c
 create mode 100644 tools/linker-tables/kernel/main.c
 create mode 100644 tools/linker-tables/kernel/workqueue.c
 create mode 100644 tools/linker-tables/lib/string.c
 create mode 100644 tools/linker-tables/main.c
 create mode 100644 tools/linker-tables/pci-quirks.c
 create mode 100644 tools/linker-tables/pci.c

-- 
2.9.2

