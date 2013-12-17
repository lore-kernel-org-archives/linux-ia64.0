From: Mark Salter <msalter@redhat.com>
Date: Tue, 17 Dec 2013 15:48:43 +0000
Subject: [PATCH v2 00/10] Kconfig: cleanup SERIO_I8042 dependencies
Message-Id: <1387295333-24684-1-git-send-email-msalter@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

This patch series removes the messy dependencies from SERIO_I8042
by having it depend on one variable (ARCH_MAY_HAVE_PC_SERIO) and
having architectures which need it select that variable in
arch/*/Kconfig.

New architectures are unlikely to need SERIO_I8042, so this avoids
having an ever growing list of architectures to exclude. If an
architecture without i8042 support isn't excluded through the
dependency list for SERIO_I8042 or through explicit disabling in
a config, it will likely panic on boot with something similar to
this (from arm64):

[   27.426181] [<ffffffc000403b1c>] i8042_flush+0x88/0x10c
[   27.426251] [<ffffffc00084cc2c>] i8042_init+0x58/0xe8
[   27.426320] [<ffffffc000080bec>] do_one_initcall+0xc4/0x14c
[   27.426404] [<ffffffc000820970>] kernel_init_freeable+0x1a4/0x244
[   27.426480] [<ffffffc0005a894c>] kernel_init+0x18/0x148
[   27.426561] Code: d2800c82 f2bf7c02 f2dff7e2 f2ffffe2 (39400042) 
[   27.426789] ---[ end trace ac076843cf0f383e ]---
[   27.426875] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

This is v2 of the patch series. Changes from version 1:

  o Added acks. arm, ia64, and sh are only ones without acks.
  o Moved select of ARCH_MIGHT_HAVE_PC_SERIO to board-specific
    Kconfigs for arm and sh.
    
A tree with these patches is at:

   git://github.com/mosalter/linux.git (serio-i8042-v2 branch)


Mark Salter (10):
  alpha: select ARCH_MIGHT_HAVE_PC_SERIO
  arm: select ARCH_MIGHT_HAVE_PC_SERIO
  ia64: select ARCH_MIGHT_HAVE_PC_SERIO
  mips: select ARCH_MIGHT_HAVE_PC_SERIO
  powerpc: select ARCH_MIGHT_HAVE_PC_SERIO
  sh: select ARCH_MIGHT_HAVE_PC_SERIO for SH_CAYMAN
  sparc: select ARCH_MIGHT_HAVE_PC_SERIO
  unicore32: select ARCH_MIGHT_HAVE_PC_SERIO
  x86: select ARCH_MIGHT_HAVE_PC_SERIO
  Kconfig: cleanup SERIO_I8042 dependencies

 arch/alpha/Kconfig               |  1 +
 arch/arm/mach-footbridge/Kconfig |  1 +
 arch/ia64/Kconfig                |  1 +
 arch/mips/Kconfig                |  1 +
 arch/powerpc/Kconfig             |  1 +
 arch/sh/boards/Kconfig           |  1 +
 arch/sparc/Kconfig               |  1 +
 arch/unicore32/Kconfig           |  1 +
 arch/x86/Kconfig                 |  1 +
 drivers/input/serio/Kconfig      | 11 ++++++++---
 10 files changed, 17 insertions(+), 3 deletions(-)

-- 
1.8.3.1

