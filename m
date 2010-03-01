From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Mar 2010 18:11:12 +0000
Subject: [git pull] ia64 changes
Message-Id: <4b8c0340666f0cbe@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.  The lone non-ia64 file touched
(drivers/input/input-compat.h) just has some ia64 specific #ifdef code
removed like this:

diff --git a/drivers/input/input-compat.h b/drivers/input/input-compat.h
index 47cd9ea..4d8ea32 100644
--- a/drivers/input/input-compat.h
+++ b/drivers/input/input-compat.h
@@ -21,8 +21,6 @@
    you why the ifdefs are needed? Think about it again. -AK */
 #ifdef CONFIG_X86_64
 #  define INPUT_COMPAT_TEST is_compat_task()
-#elif defined(CONFIG_IA64)
-#  define INPUT_COMPAT_TEST IS_IA32_PROCESS(task_pt_regs(current))
 #elif defined(CONFIG_S390)
 #  define INPUT_COMPAT_TEST test_thread_flag(TIF_31BIT)
 #elif defined(CONFIG_MIPS)

Thanks!

-Tony

 arch/ia64/Kconfig                     |   17 -
 arch/ia64/Makefile                    |    1 -
 arch/ia64/configs/bigsur_defconfig    |    2 -
 arch/ia64/configs/generic_defconfig   |    2 -
 arch/ia64/configs/gensparse_defconfig |    2 -
 arch/ia64/configs/sim_defconfig       |    2 -
 arch/ia64/configs/tiger_defconfig     |    1 -
 arch/ia64/configs/xen_domu_defconfig  |    2 -
 arch/ia64/configs/zx1_defconfig       |    2 -
 arch/ia64/ia32/Makefile               |   11 -
 arch/ia64/ia32/audit.c                |   42 -
 arch/ia64/ia32/binfmt_elf32.c         |  245 ---
 arch/ia64/ia32/elfcore32.h            |  148 --
 arch/ia64/ia32/ia32_entry.S           |  468 ------
 arch/ia64/ia32/ia32_ldt.c             |  146 --
 arch/ia64/ia32/ia32_signal.c          | 1010 ------------
 arch/ia64/ia32/ia32_support.c         |  253 ---
 arch/ia64/ia32/ia32_traps.c           |  156 --
 arch/ia64/ia32/ia32priv.h             |  532 -------
 arch/ia64/ia32/sys_ia32.c             | 2765 ---------------------------------
 arch/ia64/include/asm/acpi.h          |   25 +
 arch/ia64/include/asm/ia32.h          |   40 -
 arch/ia64/include/asm/processor.h     |   46 -
 arch/ia64/include/asm/scatterlist.h   |   24 +-
 arch/ia64/include/asm/syscall.h       |   81 -
 arch/ia64/include/asm/system.h        |   11 +-
 arch/ia64/include/asm/unistd.h        |   14 -
 arch/ia64/kernel/Makefile             |    6 +-
 arch/ia64/kernel/acpi.c               |   33 +-
 arch/ia64/kernel/audit.c              |   21 -
 arch/ia64/kernel/entry.S              |   39 -
 arch/ia64/kernel/ivt.S                |  114 --
 arch/ia64/kernel/perfmon.c            |    4 +-
 arch/ia64/kernel/process.c            |   59 +-
 arch/ia64/kernel/ptrace.c             |   14 +-
 arch/ia64/kernel/setup.c              |    5 -
 arch/ia64/kernel/signal.c             |   54 +-
 arch/ia64/kernel/smpboot.c            |    5 -
 arch/ia64/kernel/traps.c              |    9 -
 arch/ia64/mm/init.c                   |    5 -
 arch/ia64/uv/kernel/setup.c           |    2 +-
 arch/ia64/xen/hypercall.S             |    5 -
 arch/ia64/xen/xen_pv_ops.c            |   16 -
 drivers/input/input-compat.h          |    2 -
 44 files changed, 56 insertions(+), 6385 deletions(-)
 delete mode 100644 arch/ia64/ia32/Makefile
 delete mode 100644 arch/ia64/ia32/audit.c
 delete mode 100644 arch/ia64/ia32/binfmt_elf32.c
 delete mode 100644 arch/ia64/ia32/elfcore32.h
 delete mode 100644 arch/ia64/ia32/ia32_entry.S
 delete mode 100644 arch/ia64/ia32/ia32_ldt.c
 delete mode 100644 arch/ia64/ia32/ia32_signal.c
 delete mode 100644 arch/ia64/ia32/ia32_support.c
 delete mode 100644 arch/ia64/ia32/ia32_traps.c
 delete mode 100644 arch/ia64/ia32/ia32priv.h
 delete mode 100644 arch/ia64/ia32/sys_ia32.c
 delete mode 100644 arch/ia64/include/asm/ia32.h

Alex Chiang (2):
      [IA64] Only build arch/ia64/kernel/acpi.o when CONFIG_ACPI
      [IA64] build arch/ia64/kernel/acpi-ext.o when CONFIG_ACPI

FUJITA Tomonori (1):
      [IA64] use asm-generic/scatterlist.h

Frans Pop (1):
      [IA64] remove trailing space in messages

Roel Kluin (1):
      [IA64] wrong attribute of HUB chip written in uv_setup()

Tony Luck (1):
      [IA64] Remove COMPAT_IA32 support

