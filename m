From: Joe Perches <joe@perches.com>
Date: Fri, 17 Feb 2017 07:11:13 +0000
Subject: [PATCH 00/35] treewide trivial patches converting pr_warning to pr_warn
Message-Id: <cover.1487314666.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Shishkin <alexander.shishkin@linux.intel.com>, Karol Herbst <karolherbst@gmail.com>, Pekka Paalanen <ppaalanen@gmail.com>, Richard Weinberger <richard@nod.at>, Fabio Estevam <fabio.estevam@nxp.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, tboot-devel@lists.sourceforge.net, nouveau@lists.freedesktop.org, oprofile-list@lists.sf.net, sfi-devel@simplefirmware.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, drbd-dev@lists.linbit.com, virtualization@lists.linux-foundation.org, linux-crypto@vger.kernel.org, linux-ide@vger.kernel.org, gigaset307x-common@lists.sourceforge.net, linux-media@vger.kernel.org, linux-omap@vger.kernel.org, linux-mtd@lists.infradead.org, devicetree@vger.kernel.org, acpi4asus-user@lists.sourceforge.net, platform-driver-x86@vger.kernel.org, linux-scsi@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, netdev@vger.kernel.org, linux-input@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org

There are ~4300 uses of pr_warn and ~250 uses of the older
pr_warning in the kernel source tree.

Make the use of pr_warn consistent across all kernel files.

This excludes all files in tools/ as there is a separate
define pr_warning for that directory tree and pr_warn is
not used in tools/.

Done with 'sed s/\bpr_warning\b/pr_warn/' and some emacsing.

Miscellanea:

o Coalesce formats and realign arguments

Some files not compiled - no cross-compilers

Joe Perches (35):
  alpha: Convert remaining uses of pr_warning to pr_warn
  ARM: ep93xx: Convert remaining uses of pr_warning to pr_warn
  arm64: Convert remaining uses of pr_warning to pr_warn
  arch/blackfin: Convert remaining uses of pr_warning to pr_warn
  ia64: Convert remaining use of pr_warning to pr_warn
  powerpc: Convert remaining uses of pr_warning to pr_warn
  sh: Convert remaining uses of pr_warning to pr_warn
  sparc: Convert remaining use of pr_warning to pr_warn
  x86: Convert remaining uses of pr_warning to pr_warn
  drivers/acpi: Convert remaining uses of pr_warning to pr_warn
  block/drbd: Convert remaining uses of pr_warning to pr_warn
  gdrom: Convert remaining uses of pr_warning to pr_warn
  drivers/char: Convert remaining use of pr_warning to pr_warn
  clocksource: Convert remaining use of pr_warning to pr_warn
  drivers/crypto: Convert remaining uses of pr_warning to pr_warn
  fmc: Convert remaining use of pr_warning to pr_warn
  drivers/gpu: Convert remaining uses of pr_warning to pr_warn
  drivers/ide: Convert remaining uses of pr_warning to pr_warn
  drivers/input: Convert remaining uses of pr_warning to pr_warn
  drivers/isdn: Convert remaining uses of pr_warning to pr_warn
  drivers/macintosh: Convert remaining uses of pr_warning to pr_warn
  drivers/media: Convert remaining use of pr_warning to pr_warn
  drivers/mfd: Convert remaining uses of pr_warning to pr_warn
  drivers/mtd: Convert remaining uses of pr_warning to pr_warn
  drivers/of: Convert remaining uses of pr_warning to pr_warn
  drivers/oprofile: Convert remaining uses of pr_warning to pr_warn
  drivers/platform: Convert remaining uses of pr_warning to pr_warn
  drivers/rapidio: Convert remaining use of pr_warning to pr_warn
  drivers/scsi: Convert remaining use of pr_warning to pr_warn
  drivers/sh: Convert remaining use of pr_warning to pr_warn
  drivers/tty: Convert remaining uses of pr_warning to pr_warn
  drivers/video: Convert remaining uses of pr_warning to pr_warn
  kernel/trace: Convert remaining uses of pr_warning to pr_warn
  lib: Convert remaining uses of pr_warning to pr_warn
  sound/soc: Convert remaining uses of pr_warning to pr_warn

 arch/alpha/kernel/perf_event.c                     |  4 +-
 arch/arm/mach-ep93xx/core.c                        |  4 +-
 arch/arm64/include/asm/syscall.h                   |  8 ++--
 arch/arm64/kernel/hw_breakpoint.c                  |  8 ++--
 arch/arm64/kernel/smp.c                            |  4 +-
 arch/blackfin/kernel/nmi.c                         |  2 +-
 arch/blackfin/kernel/ptrace.c                      |  2 +-
 arch/blackfin/mach-bf533/boards/stamp.c            |  2 +-
 arch/blackfin/mach-bf537/boards/cm_bf537e.c        |  2 +-
 arch/blackfin/mach-bf537/boards/cm_bf537u.c        |  2 +-
 arch/blackfin/mach-bf537/boards/stamp.c            |  2 +-
 arch/blackfin/mach-bf537/boards/tcm_bf537.c        |  2 +-
 arch/blackfin/mach-bf561/boards/cm_bf561.c         |  2 +-
 arch/blackfin/mach-bf561/boards/ezkit.c            |  2 +-
 arch/blackfin/mm/isram-driver.c                    |  4 +-
 arch/ia64/kernel/setup.c                           |  6 +--
 arch/powerpc/kernel/pci-common.c                   |  4 +-
 arch/powerpc/mm/init_64.c                          |  5 +--
 arch/powerpc/mm/mem.c                              |  3 +-
 arch/powerpc/platforms/512x/mpc512x_shared.c       |  4 +-
 arch/powerpc/platforms/85xx/socrates_fpga_pic.c    |  7 ++--
 arch/powerpc/platforms/86xx/mpc86xx_hpcn.c         |  2 +-
 arch/powerpc/platforms/pasemi/dma_lib.c            |  4 +-
 arch/powerpc/platforms/powernv/opal.c              |  8 ++--
 arch/powerpc/platforms/powernv/pci-ioda.c          | 10 ++---
 arch/powerpc/platforms/ps3/device-init.c           | 14 +++----
 arch/powerpc/platforms/ps3/mm.c                    |  4 +-
 arch/powerpc/platforms/ps3/os-area.c               |  2 +-
 arch/powerpc/platforms/pseries/iommu.c             |  8 ++--
 arch/powerpc/platforms/pseries/setup.c             |  4 +-
 arch/powerpc/sysdev/fsl_pci.c                      |  9 ++---
 arch/powerpc/sysdev/mpic.c                         | 10 ++---
 arch/powerpc/sysdev/xics/icp-native.c              | 10 ++---
 arch/powerpc/sysdev/xics/ics-opal.c                |  4 +-
 arch/powerpc/sysdev/xics/ics-rtas.c                |  4 +-
 arch/powerpc/sysdev/xics/xics-common.c             |  8 ++--
 arch/sh/boards/mach-sdk7786/nmi.c                  |  2 +-
 arch/sh/drivers/pci/fixups-sdk7786.c               |  2 +-
 arch/sh/kernel/io_trapped.c                        |  2 +-
 arch/sh/kernel/setup.c                             |  2 +-
 arch/sh/mm/consistent.c                            |  5 +--
 arch/sparc/kernel/smp_64.c                         |  5 +--
 arch/x86/kernel/amd_gart_64.c                      | 12 ++----
 arch/x86/kernel/apic/apic.c                        | 46 ++++++++++------------
 arch/x86/kernel/apic/apic_noop.c                   |  2 +-
 arch/x86/kernel/setup_percpu.c                     |  4 +-
 arch/x86/kernel/tboot.c                            | 15 ++++---
 arch/x86/kernel/tsc_sync.c                         |  8 ++--
 arch/x86/mm/kmmio.c                                |  8 ++--
 arch/x86/mm/mmio-mod.c                             |  5 +--
 arch/x86/mm/numa.c                                 | 12 +++---
 arch/x86/mm/numa_emulation.c                       |  6 +--
 arch/x86/mm/testmmiotrace.c                        |  5 +--
 arch/x86/oprofile/op_x86_model.h                   |  6 +--
 arch/x86/platform/olpc/olpc-xo15-sci.c             |  2 +-
 arch/x86/platform/sfi/sfi.c                        |  3 +-
 arch/x86/xen/debugfs.c                             |  2 +-
 arch/x86/xen/setup.c                               |  2 +-
 drivers/acpi/apei/apei-base.c                      | 32 +++++++--------
 drivers/acpi/apei/einj.c                           |  4 +-
 drivers/acpi/apei/erst-dbg.c                       |  4 +-
 drivers/acpi/apei/ghes.c                           | 30 +++++++-------
 drivers/acpi/apei/hest.c                           | 10 ++---
 drivers/acpi/resource.c                            |  4 +-
 drivers/block/drbd/drbd_nl.c                       | 13 +++---
 drivers/cdrom/gdrom.c                              |  4 +-
 drivers/char/virtio_console.c                      |  2 +-
 drivers/clocksource/samsung_pwm_timer.c            |  4 +-
 drivers/crypto/n2_core.c                           | 12 +++---
 drivers/fmc/fmc-fakedev.c                          |  2 +-
 drivers/gpu/drm/amd/powerplay/hwmgr/smu7_hwmgr.c   |  2 +-
 drivers/gpu/drm/amd/powerplay/inc/pp_debug.h       |  2 +-
 drivers/gpu/drm/amd/powerplay/smumgr/fiji_smc.c    |  4 +-
 drivers/gpu/drm/amd/powerplay/smumgr/iceland_smc.c | 14 +++----
 .../gpu/drm/amd/powerplay/smumgr/polaris10_smc.c   |  4 +-
 drivers/gpu/drm/amd/powerplay/smumgr/tonga_smc.c   |  4 +-
 drivers/ide/tx4938ide.c                            |  2 +-
 drivers/ide/tx4939ide.c                            |  5 +--
 drivers/input/gameport/gameport.c                  |  4 +-
 drivers/input/joystick/gamecon.c                   |  3 +-
 drivers/input/misc/apanel.c                        |  3 +-
 drivers/input/misc/xen-kbdfront.c                  |  8 ++--
 drivers/input/serio/serio.c                        |  8 ++--
 drivers/isdn/gigaset/interface.c                   |  2 +-
 drivers/isdn/hardware/mISDN/avmfritz.c             | 17 ++++----
 drivers/isdn/hardware/mISDN/hfcmulti.c             |  8 ++--
 drivers/isdn/hardware/mISDN/hfcpci.c               |  4 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c              |  4 +-
 drivers/isdn/hardware/mISDN/mISDNipac.c            |  4 +-
 drivers/isdn/hardware/mISDN/mISDNisar.c            | 10 ++---
 drivers/isdn/hardware/mISDN/netjet.c               |  8 ++--
 drivers/isdn/hardware/mISDN/w6692.c                | 12 +++---
 drivers/isdn/mISDN/hwchannel.c                     |  8 ++--
 drivers/macintosh/windfarm_fcu_controls.c          |  5 +--
 drivers/macintosh/windfarm_lm87_sensor.c           |  4 +-
 drivers/macintosh/windfarm_pm72.c                  | 22 +++++------
 drivers/macintosh/windfarm_rm31.c                  |  6 +--
 drivers/media/platform/sh_vou.c                    |  4 +-
 drivers/mfd/db8500-prcmu.c                         |  2 +-
 drivers/mfd/sta2x11-mfd.c                          |  4 +-
 drivers/mfd/twl4030-power.c                        |  7 +---
 drivers/mtd/chips/cfi_cmdset_0002.c                | 12 ++++--
 drivers/mtd/nand/cmx270_nand.c                     |  4 +-
 drivers/mtd/ofpart.c                               |  4 +-
 drivers/of/fdt.c                                   | 20 +++++-----
 drivers/oprofile/oprofile_perf.c                   |  8 ++--
 drivers/platform/x86/asus-laptop.c                 |  2 +-
 drivers/platform/x86/eeepc-laptop.c                |  2 +-
 drivers/platform/x86/intel_oaktrail.c              | 10 ++---
 drivers/rapidio/rio-sysfs.c                        |  4 +-
 drivers/scsi/a3000.c                               |  2 +-
 drivers/sh/intc/core.c                             |  4 +-
 drivers/tty/hvc/hvcs.c                             |  2 +-
 drivers/tty/tty_io.c                               |  4 +-
 drivers/video/fbdev/aty/radeon_base.c              |  4 +-
 drivers/video/fbdev/core/fbmon.c                   |  4 +-
 drivers/video/fbdev/pxafb.c                        |  7 ++--
 kernel/trace/trace_benchmark.c                     |  4 +-
 lib/cpu_rmap.c                                     |  2 +-
 lib/dma-debug.c                                    |  2 +-
 sound/soc/fsl/imx-audmux.c                         |  6 +--
 sound/soc/samsung/s3c-i2s-v2.c                     |  6 +--
 122 files changed, 367 insertions(+), 397 deletions(-)

-- 
2.10.0.rc2.1.g053435c

