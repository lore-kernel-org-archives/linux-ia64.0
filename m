From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 20 Jan 2014 17:25:36 +0000
Subject: [GIT PULL] ia64 - drop the unmaintained/broken Xen code
Message-Id: <52dd5c102220811c45@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 374b105797c3d4f29c685f3be535c35f5689b30e:

  Linux 3.13-rc3 (2013-12-06 09:34:04 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-rm_xen

for you to fetch changes up to d52eefb47d4eb6fe40d4c92bc711dd34a8ce1747:

  ia64/xen: Remove Xen support for ia64 (2013-12-10 16:11:07 -0800)

----------------------------------------------------------------
Nobody has been maintaining xen in ia64 for a long time.
Rip it all out so people do not waste time making updates
to broken/dead code.

----------------------------------------------------------------
Boris Ostrovsky (1):
      ia64/xen: Remove Xen support for ia64

 arch/ia64/Kconfig                         |   12 -
 arch/ia64/Makefile                        |    2 -
 arch/ia64/configs/xen_domu_defconfig      |  199 -----
 arch/ia64/include/asm/acpi.h              |    2 -
 arch/ia64/include/asm/machvec.h           |    2 -
 arch/ia64/include/asm/machvec_xen.h       |   22 -
 arch/ia64/include/asm/meminit.h           |    1 -
 arch/ia64/include/asm/paravirt.h          |    1 -
 arch/ia64/include/asm/pvclock-abi.h       |    2 +-
 arch/ia64/include/asm/sync_bitops.h       |   51 --
 arch/ia64/include/asm/xen/events.h        |   41 --
 arch/ia64/include/asm/xen/hypercall.h     |  265 -------
 arch/ia64/include/asm/xen/hypervisor.h    |   61 --
 arch/ia64/include/asm/xen/inst.h          |  486 ------------
 arch/ia64/include/asm/xen/interface.h     |  363 ---------
 arch/ia64/include/asm/xen/irq.h           |   44 --
 arch/ia64/include/asm/xen/minstate.h      |  143 ----
 arch/ia64/include/asm/xen/page-coherent.h |   38 -
 arch/ia64/include/asm/xen/page.h          |   65 --
 arch/ia64/include/asm/xen/patchlist.h     |   38 -
 arch/ia64/include/asm/xen/privop.h        |  135 ----
 arch/ia64/include/asm/xen/xcom_hcall.h    |   51 --
 arch/ia64/include/asm/xen/xencomm.h       |   42 --
 arch/ia64/include/uapi/asm/break.h        |    9 -
 arch/ia64/kernel/acpi.c                   |    3 -
 arch/ia64/kernel/asm-offsets.c            |   32 -
 arch/ia64/kernel/head.S                   |    3 -
 arch/ia64/kernel/nr-irqs.c                |    4 -
 arch/ia64/kernel/paravirt_inst.h          |    3 -
 arch/ia64/kernel/paravirt_patchlist.h     |    4 -
 arch/ia64/kernel/vmlinux.lds.S            |    6 -
 arch/ia64/xen/Kconfig                     |   25 -
 arch/ia64/xen/Makefile                    |   37 -
 arch/ia64/xen/gate-data.S                 |    3 -
 arch/ia64/xen/grant-table.c               |   94 ---
 arch/ia64/xen/hypercall.S                 |   88 ---
 arch/ia64/xen/hypervisor.c                |   97 ---
 arch/ia64/xen/irq_xen.c                   |  443 -----------
 arch/ia64/xen/irq_xen.h                   |   34 -
 arch/ia64/xen/machvec.c                   |    4 -
 arch/ia64/xen/suspend.c                   |   59 --
 arch/ia64/xen/time.c                      |  257 -------
 arch/ia64/xen/time.h                      |   24 -
 arch/ia64/xen/xcom_hcall.c                |  441 -----------
 arch/ia64/xen/xen_pv_ops.c                | 1141 -----------------------------
 arch/ia64/xen/xencomm.c                   |  106 ---
 arch/ia64/xen/xenivt.S                    |   52 --
 arch/ia64/xen/xensetup.S                  |   80 --
 include/xen/interface/callback.h          |    2 +-
 include/xen/interface/io/protocols.h      |    3 -
 50 files changed, 2 insertions(+), 5118 deletions(-)
 delete mode 100644 arch/ia64/configs/xen_domu_defconfig
 delete mode 100644 arch/ia64/include/asm/machvec_xen.h
 delete mode 100644 arch/ia64/include/asm/sync_bitops.h
 delete mode 100644 arch/ia64/include/asm/xen/events.h
 delete mode 100644 arch/ia64/include/asm/xen/hypercall.h
 delete mode 100644 arch/ia64/include/asm/xen/hypervisor.h
 delete mode 100644 arch/ia64/include/asm/xen/inst.h
 delete mode 100644 arch/ia64/include/asm/xen/interface.h
 delete mode 100644 arch/ia64/include/asm/xen/irq.h
 delete mode 100644 arch/ia64/include/asm/xen/minstate.h
 delete mode 100644 arch/ia64/include/asm/xen/page-coherent.h
 delete mode 100644 arch/ia64/include/asm/xen/page.h
 delete mode 100644 arch/ia64/include/asm/xen/patchlist.h
 delete mode 100644 arch/ia64/include/asm/xen/privop.h
 delete mode 100644 arch/ia64/include/asm/xen/xcom_hcall.h
 delete mode 100644 arch/ia64/include/asm/xen/xencomm.h
 delete mode 100644 arch/ia64/xen/Kconfig
 delete mode 100644 arch/ia64/xen/Makefile
 delete mode 100644 arch/ia64/xen/gate-data.S
 delete mode 100644 arch/ia64/xen/grant-table.c
 delete mode 100644 arch/ia64/xen/hypercall.S
 delete mode 100644 arch/ia64/xen/hypervisor.c
 delete mode 100644 arch/ia64/xen/irq_xen.c
 delete mode 100644 arch/ia64/xen/irq_xen.h
 delete mode 100644 arch/ia64/xen/machvec.c
 delete mode 100644 arch/ia64/xen/suspend.c
 delete mode 100644 arch/ia64/xen/time.c
 delete mode 100644 arch/ia64/xen/time.h
 delete mode 100644 arch/ia64/xen/xcom_hcall.c
 delete mode 100644 arch/ia64/xen/xen_pv_ops.c
 delete mode 100644 arch/ia64/xen/xencomm.c
 delete mode 100644 arch/ia64/xen/xenivt.S
 delete mode 100644 arch/ia64/xen/xensetup.S
