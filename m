From: Joe Perches <joe@perches.com>
Date: Wed, 05 Jul 2017 20:02:09 +0000
Subject: [PATCH 00/18] treewide: Move storage class before return type
Message-Id: <cover.1499284835.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, kvm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-m68k@lists.linux-m68k.org, linux-efi@vger.kernel.org, linux-s390@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-usb@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-omap@vger.kernel.org, alsa-devel@alsa-project.org
Cc: linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-sh@vger.kernel.org

Move the inline/asmlinkage keywords before the return types
Add a checkpatch test for this too.

Joe Perches (18):
  checkpatch: improve the STORAGE_CLASS test
  ARM: KVM: Move asmlinkage before type
  ARM: HP Jornada 7XX: Move inline before return type
  CRIS: gpio: Move inline before return type
  FRV: tlbflush: Move asmlinkage before return type
  ia64: Move inline before return type
  ia64: sn: pci: Move inline before type
  m68k: coldfire: Move inline before return type
  MIPS: SMP: Move asmlinkage before return type
  sh: Move inline before return type
  x86/efi: Move asmlinkage before return type
  drivers: s390: Move static and inline before return type
  drivers: tty: serial: Move inline before return type
  USB: serial: safe_serial: Move __inline__ before return type
  video: fbdev: intelfb: Move inline before return type
  video: fbdev: omap: Move inline before return type
  ARM: samsung: usb-ohci: Move inline before return type
  ALSA: opl4: Move inline before return type

 arch/arm/include/asm/kvm_hyp.h                 |  8 ++++----
 arch/arm/mach-sa1100/jornada720_ssp.c          |  2 +-
 arch/cris/arch-v10/drivers/gpio.c              |  4 ++--
 arch/frv/include/asm/tlbflush.h                |  8 ++++----
 arch/ia64/kernel/mca.c                         |  2 +-
 arch/ia64/sn/pci/pcibr/pcibr_ate.c             |  2 +-
 arch/ia64/sn/pci/tioce_provider.c              |  4 ++--
 arch/m68k/coldfire/intc-simr.c                 |  4 ++--
 arch/mips/include/asm/smp.h                    |  2 +-
 arch/sh/mm/cache-sh5.c                         |  2 +-
 arch/x86/include/asm/efi.h                     |  4 ++--
 drivers/s390/net/ctcm_main.c                   |  2 +-
 drivers/s390/net/qeth_l3_main.c                |  2 +-
 drivers/tty/serial/ioc3_serial.c               |  4 ++--
 drivers/tty/serial/ioc4_serial.c               |  4 ++--
 drivers/usb/serial/safe_serial.c               |  2 +-
 drivers/video/fbdev/intelfb/intelfbdrv.c       |  2 +-
 drivers/video/fbdev/omap/lcdc.c                |  6 +++---
 include/linux/platform_data/usb-ohci-s3c2410.h |  2 +-
 scripts/checkpatch.pl                          | 12 ++++++++++--
 sound/drivers/opl4/opl4_lib.c                  |  2 +-
 21 files changed, 44 insertions(+), 36 deletions(-)

-- 
2.10.0.rc2.1.g053435c

