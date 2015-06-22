From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 22 Jun 2015 16:59:30 +0000
Subject: [GIT PULL] ia64: remove paravirt code
Message-Id: <55883ef2696a3f04@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit c65b99f046843d2455aa231747b5a07a999a9f3d:

  Linux 4.1-rc6 (2015-05-31 19:01:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-paravirt

for you to fetch changes up to e55645ec5725a33eac9d6133f3bce381af1e993d:

  ia64: remove paravirt code (2015-06-10 14:26:32 -0700)

----------------------------------------------------------------
Nobody cares about paravirtualization on ia64 anymore

----------------------------------------------------------------
Luis R. Rodriguez (1):
      ia64: remove paravirt code

 arch/ia64/Kconfig                         |  23 -
 arch/ia64/include/asm/hw_irq.h            |   8 -
 arch/ia64/include/asm/intrinsics.h        |  13 -
 arch/ia64/include/asm/iosapic.h           |   4 -
 arch/ia64/include/asm/module.h            |   6 -
 arch/ia64/include/asm/native/inst.h       | 103 +---
 arch/ia64/include/asm/native/pvchk_inst.h | 271 ---------
 arch/ia64/include/asm/paravirt.h          | 321 -----------
 arch/ia64/include/asm/paravirt_patch.h    | 143 -----
 arch/ia64/include/asm/paravirt_privop.h   | 479 ----------------
 arch/ia64/kernel/Makefile                 |  34 +-
 arch/ia64/kernel/efi.c                    |   1 -
 arch/ia64/kernel/entry.S                  |  41 +-
 arch/ia64/kernel/fsys.S                   |  18 +-
 arch/ia64/kernel/gate.S                   |   9 +-
 arch/ia64/kernel/gate.lds.S               |  17 +-
 arch/ia64/kernel/head.S                   |  42 --
 arch/ia64/kernel/ivt.S                    |   4 +-
 arch/ia64/kernel/minstate.h               |   2 +-
 arch/ia64/kernel/module.c                 |  32 --
 arch/ia64/kernel/paravirt.c               | 902 ------------------------------
 arch/ia64/kernel/paravirt_inst.h          |  28 -
 arch/ia64/kernel/paravirt_patch.c         | 514 -----------------
 arch/ia64/kernel/paravirt_patchlist.c     |  81 ---
 arch/ia64/kernel/paravirt_patchlist.h     |  24 -
 arch/ia64/kernel/paravirtentry.S          | 121 ----
 arch/ia64/kernel/patch.c                  |  38 +-
 arch/ia64/kernel/setup.c                  |  12 -
 arch/ia64/kernel/smpboot.c                |   2 -
 arch/ia64/kernel/time.c                   |  29 -
 arch/ia64/kernel/vmlinux.lds.S            |  21 -
 arch/ia64/mm/init.c                       |   9 +-
 arch/ia64/scripts/pvcheck.sed             |  33 --
 33 files changed, 68 insertions(+), 3317 deletions(-)
 delete mode 100644 arch/ia64/include/asm/native/pvchk_inst.h
 delete mode 100644 arch/ia64/include/asm/paravirt.h
 delete mode 100644 arch/ia64/include/asm/paravirt_patch.h
 delete mode 100644 arch/ia64/include/asm/paravirt_privop.h
 delete mode 100644 arch/ia64/kernel/paravirt.c
 delete mode 100644 arch/ia64/kernel/paravirt_inst.h
 delete mode 100644 arch/ia64/kernel/paravirt_patch.c
 delete mode 100644 arch/ia64/kernel/paravirt_patchlist.c
 delete mode 100644 arch/ia64/kernel/paravirt_patchlist.h
 delete mode 100644 arch/ia64/kernel/paravirtentry.S
 delete mode 100644 arch/ia64/scripts/pvcheck.sed
--
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
