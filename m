From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 16 Sep 2019 15:49:04 +0000
Subject: [GIT PULL] ia64 changes for v5.4
Message-Id: <20190916154903.GA18169@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit e21a712a9685488f5ce80495b37b9fdbe96c230d:

  Linux 5.3-rc3 (2019-08-04 18:40:12 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-ia64_for_5.4

for you to fetch changes up to 0d3d343560bad8e1b7879fe94251cfe731a2dd13:

  genirq: remove the is_affinity_mask_valid hook (2019-08-16 14:32:26 -0700)

----------------------------------------------------------------
ia64 for v5.4 - big change here is removal of support for SGI Altix

----------------------------------------------------------------
Christoph Hellwig (32):
      ia64: annotate a switch fallthrough in ia64_do_signal
      ia64: annotate switch fallthroughs in ia64_handle_unaligned
      ia64/kprobes: remove the unused ia64_get_bsp_cfm function
      kernel: only define task_struct_whitelist conditionally
      char: remove the SGI snsc driver
      char: remove the SGI tiocx/mbcs driver
      char/agp: remove the sgi-agp driver
      ide: remove the sgiioc4 driver
      PCI/hotplug: remove the sgi_hotplug driver
      tty/serial: remove the sn_console driver
      tty/serial: remove the ioc4_serial driver
      tty/serial: remove the ioc3_serial driver
      char/mspec: remove SGI SN2 support
      misc/sgi-xp: remove SGI SN2 support
      qla1280: remove SGI SN2 support
      qla2xxx: remove SGI SN2 support
      drivers: remove the SGI SN2 IOC3 base support
      drivers: remove the SGI SN2 IOC4 base support
      ia64: remove support for the SGI SN2 platform
      ia64: remove now unused machvec indirections
      ia64: remove the hpsim platform
      ia64: remove CONFIG_PCI ifdefs
      ia64: remove CONFIG_ACPI ifdefs
      ia64: remove the zx1 swiotlb machvec
      ia64: remove the SGI UV simulator support
      ia64: remove the unused sn_coherency_id symbol
      ia64: rework iommu probing
      ia64: move the ROOT_DEV setup to common code
      ia64: move the screen_info setup to common code
      ia64: remove support for machvecs
      ia64: remove CONFIG_SWIOTLB ifdefs
      genirq: remove the is_affinity_mask_valid hook

chenzefeng (1):
      ia64:unwind: fix double free for mod->arch.init_unw_table

 Documentation/admin-guide/kernel-parameters.txt |    2 +-
 Documentation/driver-api/sgi-ioc4.rst           |   49 -
 MAINTAINERS                                     |    6 -
 arch/ia64/Kconfig                               |  141 +-
 arch/ia64/Kconfig.debug                         |    2 +-
 arch/ia64/Makefile                              |   36 +-
 arch/ia64/configs/bigsur_defconfig              |    1 -
 arch/ia64/configs/generic_defconfig             |    8 -
 arch/ia64/configs/gensparse_defconfig           |   10 -
 arch/ia64/configs/sim_defconfig                 |   52 -
 arch/ia64/configs/tiger_defconfig               |    1 -
 arch/ia64/configs/zx1_defconfig                 |    1 -
 arch/ia64/dig/Makefile                          |   15 -
 arch/ia64/dig/machvec.c                         |    3 -
 arch/ia64/dig/machvec_vtd.c                     |    3 -
 arch/ia64/dig/setup.c                           |   71 -
 arch/ia64/hp/common/Makefile                    |    4 +-
 arch/ia64/hp/common/hwsw_iommu.c                |   60 -
 arch/ia64/hp/common/sba_iommu.c                 |  105 +-
 arch/ia64/hp/sim/Kconfig                        |   23 -
 arch/ia64/hp/sim/Makefile                       |   17 -
 arch/ia64/hp/sim/boot/Makefile                  |   37 -
 arch/ia64/hp/sim/boot/boot_head.S               |  165 --
 arch/ia64/hp/sim/boot/bootloader.c              |  175 --
 arch/ia64/hp/sim/boot/bootloader.lds            |   67 -
 arch/ia64/hp/sim/boot/fw-emu.c                  |  374 ---
 arch/ia64/hp/sim/boot/ssc.h                     |   36 -
 arch/ia64/hp/sim/hpsim.S                        |   11 -
 arch/ia64/hp/sim/hpsim_console.c                |   77 -
 arch/ia64/hp/sim/hpsim_irq.c                    |   76 -
 arch/ia64/hp/sim/hpsim_machvec.c                |    3 -
 arch/ia64/hp/sim/hpsim_setup.c                  |   41 -
 arch/ia64/hp/sim/hpsim_ssc.h                    |   37 -
 arch/ia64/hp/sim/simeth.c                       |  510 ----
 arch/ia64/hp/sim/simscsi.c                      |  373 ---
 arch/ia64/hp/sim/simserial.c                    |  521 ----
 arch/ia64/hp/zx1/Makefile                       |    9 -
 arch/ia64/hp/zx1/hpzx1_machvec.c                |    3 -
 arch/ia64/hp/zx1/hpzx1_swiotlb_machvec.c        |    3 -
 arch/ia64/include/asm/acpi.h                    |   28 +-
 arch/ia64/include/asm/dma-mapping.h             |    8 +-
 arch/ia64/include/asm/dma.h                     |    6 +-
 arch/ia64/include/asm/hpsim.h                   |   17 -
 arch/ia64/include/asm/hw_irq.h                  |   27 +-
 arch/ia64/include/asm/io.h                      |  222 +-
 arch/ia64/include/asm/iommu.h                   |    1 -
 arch/ia64/include/asm/iosapic.h                 |   12 -
 arch/ia64/include/asm/irq.h                     |    3 -
 arch/ia64/include/asm/machvec.h                 |  347 ---
 arch/ia64/include/asm/machvec_dig.h             |   17 -
 arch/ia64/include/asm/machvec_dig_vtd.h         |   19 -
 arch/ia64/include/asm/machvec_hpsim.h           |   19 -
 arch/ia64/include/asm/machvec_hpzx1.h           |   19 -
 arch/ia64/include/asm/machvec_hpzx1_swiotlb.h   |   20 -
 arch/ia64/include/asm/machvec_init.h            |   35 -
 arch/ia64/include/asm/machvec_sn2.h             |  114 -
 arch/ia64/include/asm/machvec_uv.h              |   26 -
 arch/ia64/include/asm/mmiowb.h                  |   12 +-
 arch/ia64/include/asm/mmzone.h                  |   13 +-
 arch/ia64/include/asm/pci.h                     |    9 +-
 arch/ia64/include/asm/processor.h               |    2 -
 arch/ia64/include/asm/sn/acpi.h                 |   15 -
 arch/ia64/include/asm/sn/addrs.h                |  299 --
 arch/ia64/include/asm/sn/arch.h                 |   86 -
 arch/ia64/include/asm/sn/bte.h                  |  236 --
 arch/ia64/include/asm/sn/clksupport.h           |   28 -
 arch/ia64/include/asm/sn/geo.h                  |  132 -
 arch/ia64/include/asm/sn/intr.h                 |   53 -
 arch/ia64/include/asm/sn/io.h                   |  274 --
 arch/ia64/include/asm/sn/ioc3.h                 |  242 --
 arch/ia64/include/asm/sn/klconfig.h             |  246 --
 arch/ia64/include/asm/sn/l1.h                   |   51 -
 arch/ia64/include/asm/sn/leds.h                 |   33 -
 arch/ia64/include/asm/sn/module.h               |  127 -
 arch/ia64/include/asm/sn/mspec.h                |   59 -
 arch/ia64/include/asm/sn/nodepda.h              |   82 -
 arch/ia64/include/asm/sn/pcibr_provider.h       |  150 -
 arch/ia64/include/asm/sn/pcibus_provider_defs.h |   68 -
 arch/ia64/include/asm/sn/pcidev.h               |   85 -
 arch/ia64/include/asm/sn/pda.h                  |   68 -
 arch/ia64/include/asm/sn/pic.h                  |  261 --
 arch/ia64/include/asm/sn/rw_mmr.h               |   28 -
 arch/ia64/include/asm/sn/shub_mmr.h             |  502 ----
 arch/ia64/include/asm/sn/shubio.h               | 3358 -----------------------
 arch/ia64/include/asm/sn/simulator.h            |   25 -
 arch/ia64/include/asm/sn/sn2/sn_hwperf.h        |  242 --
 arch/ia64/include/asm/sn/sn_cpuid.h             |  132 -
 arch/ia64/include/asm/sn/sn_feature_sets.h      |   58 -
 arch/ia64/include/asm/sn/sn_sal.h               | 1111 +-------
 arch/ia64/include/asm/sn/tioca.h                |  596 ----
 arch/ia64/include/asm/sn/tioca_provider.h       |  207 --
 arch/ia64/include/asm/sn/tioce.h                |  760 -----
 arch/ia64/include/asm/sn/tioce_provider.h       |   63 -
 arch/ia64/include/asm/sn/tiocp.h                |  257 --
 arch/ia64/include/asm/sn/tiocx.h                |   72 -
 arch/ia64/include/asm/sn/types.h                |   26 -
 arch/ia64/include/asm/switch_to.h               |    1 -
 arch/ia64/include/asm/tlb.h                     |    1 -
 arch/ia64/include/asm/uv/uv.h                   |   23 +-
 arch/ia64/kernel/Makefile                       |    9 +-
 arch/ia64/kernel/acpi.c                         |   81 +-
 arch/ia64/kernel/dma-mapping.c                  |   14 -
 arch/ia64/kernel/iosapic.c                      |    8 +-
 arch/ia64/kernel/irq.c                          |   23 -
 arch/ia64/kernel/irq_ia64.c                     |   11 +-
 arch/ia64/kernel/kprobes.c                      |   26 -
 arch/ia64/kernel/machine_kexec.c                |    1 -
 arch/ia64/kernel/machvec.c                      |   77 -
 arch/ia64/kernel/mca.c                          |   29 +-
 arch/ia64/kernel/mca_drv.c                      |    1 -
 arch/ia64/kernel/module.c                       |    8 +-
 arch/ia64/kernel/msi_ia64.c                     |   21 +-
 arch/ia64/kernel/pci-dma.c                      |   22 -
 arch/ia64/kernel/sal.c                          |    9 +-
 arch/ia64/kernel/setup.c                        |   96 +-
 arch/ia64/kernel/signal.c                       |   10 +-
 arch/ia64/kernel/smp.c                          |    9 +-
 arch/ia64/kernel/smpboot.c                      |    9 +-
 arch/ia64/kernel/sys_ia64.c                     |   18 -
 arch/ia64/kernel/time.c                         |    3 -
 arch/ia64/kernel/topology.c                     |    4 -
 arch/ia64/kernel/unaligned.c                    |    6 +-
 arch/ia64/kernel/uncached.c                     |    6 +-
 arch/ia64/kernel/vmlinux.lds.S                  |   10 -
 arch/ia64/lib/io.c                              |  114 -
 arch/ia64/mm/discontig.c                        |    3 +-
 arch/ia64/mm/init.c                             |   19 +-
 arch/ia64/mm/tlb.c                              |    6 +-
 arch/ia64/pci/fixup.c                           |    6 +-
 arch/ia64/pci/pci.c                             |   14 +-
 arch/ia64/sn/Makefile                           |   12 -
 arch/ia64/sn/include/ioerror.h                  |   81 -
 arch/ia64/sn/include/tio.h                      |   41 -
 arch/ia64/sn/include/xtalk/hubdev.h             |   91 -
 arch/ia64/sn/include/xtalk/xbow.h               |  301 --
 arch/ia64/sn/include/xtalk/xwidgetdev.h         |   70 -
 arch/ia64/sn/kernel/Makefile                    |   18 -
 arch/ia64/sn/kernel/bte.c                       |  475 ----
 arch/ia64/sn/kernel/bte_error.c                 |  255 --
 arch/ia64/sn/kernel/huberror.c                  |  220 --
 arch/ia64/sn/kernel/idle.c                      |   30 -
 arch/ia64/sn/kernel/io_acpi_init.c              |  513 ----
 arch/ia64/sn/kernel/io_common.c                 |  561 ----
 arch/ia64/sn/kernel/io_init.c                   |  308 ---
 arch/ia64/sn/kernel/iomv.c                      |   82 -
 arch/ia64/sn/kernel/irq.c                       |  489 ----
 arch/ia64/sn/kernel/klconflib.c                 |  107 -
 arch/ia64/sn/kernel/machvec.c                   |   11 -
 arch/ia64/sn/kernel/mca.c                       |  144 -
 arch/ia64/sn/kernel/msi_sn.c                    |  238 --
 arch/ia64/sn/kernel/pio_phys.S                  |   71 -
 arch/ia64/sn/kernel/setup.c                     |  786 ------
 arch/ia64/sn/kernel/sn2/Makefile                |   13 -
 arch/ia64/sn/kernel/sn2/cache.c                 |   41 -
 arch/ia64/sn/kernel/sn2/io.c                    |  101 -
 arch/ia64/sn/kernel/sn2/prominfo_proc.c         |  207 --
 arch/ia64/sn/kernel/sn2/ptc_deadlock.S          |   92 -
 arch/ia64/sn/kernel/sn2/sn2_smp.c               |  577 ----
 arch/ia64/sn/kernel/sn2/sn_hwperf.c             | 1004 -------
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c            |   69 -
 arch/ia64/sn/kernel/sn2/timer.c                 |   61 -
 arch/ia64/sn/kernel/sn2/timer_interrupt.c       |   60 -
 arch/ia64/sn/kernel/tiocx.c                     |  569 ----
 arch/ia64/sn/pci/Makefile                       |   10 -
 arch/ia64/sn/pci/pci_dma.c                      |  446 ---
 arch/ia64/sn/pci/pcibr/Makefile                 |   13 -
 arch/ia64/sn/pci/pcibr/pcibr_ate.c              |  177 --
 arch/ia64/sn/pci/pcibr/pcibr_dma.c              |  413 ---
 arch/ia64/sn/pci/pcibr/pcibr_provider.c         |  265 --
 arch/ia64/sn/pci/pcibr/pcibr_reg.c              |  285 --
 arch/ia64/sn/pci/tioca_provider.c               |  677 -----
 arch/ia64/sn/pci/tioce_provider.c               | 1062 -------
 arch/ia64/uv/kernel/Makefile                    |    1 -
 arch/ia64/uv/kernel/machvec.c                   |   11 -
 arch/ia64/uv/kernel/setup.c                     |   74 +-
 arch/mips/configs/bigsur_defconfig              |    1 -
 arch/mips/configs/ip32_defconfig                |    1 -
 arch/mips/configs/markeins_defconfig            |    1 -
 arch/mips/configs/rm200_defconfig               |    1 -
 arch/mips/configs/sb1250_swarm_defconfig        |    1 -
 drivers/Kconfig                                 |    2 -
 drivers/Makefile                                |    1 -
 drivers/acpi/Kconfig                            |    2 +-
 drivers/char/Kconfig                            |   22 -
 drivers/char/Makefile                           |    2 -
 drivers/char/agp/Kconfig                        |   11 +-
 drivers/char/agp/Makefile                       |    1 -
 drivers/char/agp/sgi-agp.c                      |  338 ---
 drivers/char/mbcs.c                             |  831 ------
 drivers/char/mbcs.h                             |  553 ----
 drivers/char/mspec.c                            |  155 +-
 drivers/char/snsc.c                             |  469 ----
 drivers/char/snsc.h                             |   92 -
 drivers/char/snsc_event.c                       |  303 --
 drivers/ide/Kconfig                             |    9 -
 drivers/ide/Makefile                            |    1 -
 drivers/ide/sgiioc4.c                           |  630 -----
 drivers/iommu/Kconfig                           |    2 +-
 drivers/misc/Kconfig                            |   17 +-
 drivers/misc/Makefile                           |    1 -
 drivers/misc/ioc4.c                             |  498 ----
 drivers/misc/sgi-xp/Makefile                    |   13 +-
 drivers/misc/sgi-xp/xp.h                        |   19 -
 drivers/misc/sgi-xp/xp_main.c                   |    8 +-
 drivers/misc/sgi-xp/xp_nofault.S                |   35 -
 drivers/misc/sgi-xp/xp_sn2.c                    |  190 --
 drivers/misc/sgi-xp/xp_uv.c                     |    9 +-
 drivers/misc/sgi-xp/xpc.h                       |  273 --
 drivers/misc/sgi-xp/xpc_main.c                  |   31 +-
 drivers/misc/sgi-xp/xpc_partition.c             |    5 -
 drivers/misc/sgi-xp/xpc_sn2.c                   | 2459 -----------------
 drivers/misc/sgi-xp/xpc_uv.c                    |   16 +-
 drivers/misc/sgi-xp/xpnet.c                     |    2 +-
 drivers/pci/hotplug/Kconfig                     |    9 -
 drivers/pci/hotplug/Makefile                    |    1 -
 drivers/pci/hotplug/sgi_hotplug.c               |  700 -----
 drivers/scsi/qla1280.c                          |   37 -
 drivers/scsi/qla1280.h                          |    3 -
 drivers/scsi/qla2xxx/qla_init.c                 |   14 -
 drivers/sn/Kconfig                              |   22 -
 drivers/sn/Makefile                             |    7 -
 drivers/sn/ioc3.c                               |  844 ------
 drivers/tty/serial/Kconfig                      |   27 -
 drivers/tty/serial/Makefile                     |    3 -
 drivers/tty/serial/ioc3_serial.c                | 2195 ---------------
 drivers/tty/serial/ioc4_serial.c                | 2955 --------------------
 drivers/tty/serial/sn_console.c                 | 1036 -------
 include/linux/ioc4.h                            |  184 --
 include/linux/pci_ids.h                         |    1 -
 kernel/fork.c                                   |    2 +
 kernel/irq/proc.c                               |   14 -
 231 files changed, 349 insertions(+), 40676 deletions(-)
 delete mode 100644 Documentation/driver-api/sgi-ioc4.rst
 delete mode 100644 arch/ia64/configs/sim_defconfig
 delete mode 100644 arch/ia64/dig/Makefile
 delete mode 100644 arch/ia64/dig/machvec.c
 delete mode 100644 arch/ia64/dig/machvec_vtd.c
 delete mode 100644 arch/ia64/dig/setup.c
 delete mode 100644 arch/ia64/hp/common/hwsw_iommu.c
 delete mode 100644 arch/ia64/hp/sim/Kconfig
 delete mode 100644 arch/ia64/hp/sim/Makefile
 delete mode 100644 arch/ia64/hp/sim/boot/Makefile
 delete mode 100644 arch/ia64/hp/sim/boot/boot_head.S
 delete mode 100644 arch/ia64/hp/sim/boot/bootloader.c
 delete mode 100644 arch/ia64/hp/sim/boot/bootloader.lds
 delete mode 100644 arch/ia64/hp/sim/boot/fw-emu.c
 delete mode 100644 arch/ia64/hp/sim/boot/ssc.h
 delete mode 100644 arch/ia64/hp/sim/hpsim.S
 delete mode 100644 arch/ia64/hp/sim/hpsim_console.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_irq.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_machvec.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_setup.c
 delete mode 100644 arch/ia64/hp/sim/hpsim_ssc.h
 delete mode 100644 arch/ia64/hp/sim/simeth.c
 delete mode 100644 arch/ia64/hp/sim/simscsi.c
 delete mode 100644 arch/ia64/hp/sim/simserial.c
 delete mode 100644 arch/ia64/hp/zx1/Makefile
 delete mode 100644 arch/ia64/hp/zx1/hpzx1_machvec.c
 delete mode 100644 arch/ia64/hp/zx1/hpzx1_swiotlb_machvec.c
 delete mode 100644 arch/ia64/include/asm/hpsim.h
 delete mode 100644 arch/ia64/include/asm/machvec.h
 delete mode 100644 arch/ia64/include/asm/machvec_dig.h
 delete mode 100644 arch/ia64/include/asm/machvec_dig_vtd.h
 delete mode 100644 arch/ia64/include/asm/machvec_hpsim.h
 delete mode 100644 arch/ia64/include/asm/machvec_hpzx1.h
 delete mode 100644 arch/ia64/include/asm/machvec_hpzx1_swiotlb.h
 delete mode 100644 arch/ia64/include/asm/machvec_init.h
 delete mode 100644 arch/ia64/include/asm/machvec_sn2.h
 delete mode 100644 arch/ia64/include/asm/machvec_uv.h
 delete mode 100644 arch/ia64/include/asm/sn/acpi.h
 delete mode 100644 arch/ia64/include/asm/sn/addrs.h
 delete mode 100644 arch/ia64/include/asm/sn/arch.h
 delete mode 100644 arch/ia64/include/asm/sn/bte.h
 delete mode 100644 arch/ia64/include/asm/sn/clksupport.h
 delete mode 100644 arch/ia64/include/asm/sn/geo.h
 delete mode 100644 arch/ia64/include/asm/sn/io.h
 delete mode 100644 arch/ia64/include/asm/sn/ioc3.h
 delete mode 100644 arch/ia64/include/asm/sn/klconfig.h
 delete mode 100644 arch/ia64/include/asm/sn/l1.h
 delete mode 100644 arch/ia64/include/asm/sn/leds.h
 delete mode 100644 arch/ia64/include/asm/sn/module.h
 delete mode 100644 arch/ia64/include/asm/sn/mspec.h
 delete mode 100644 arch/ia64/include/asm/sn/nodepda.h
 delete mode 100644 arch/ia64/include/asm/sn/pcibr_provider.h
 delete mode 100644 arch/ia64/include/asm/sn/pcibus_provider_defs.h
 delete mode 100644 arch/ia64/include/asm/sn/pcidev.h
 delete mode 100644 arch/ia64/include/asm/sn/pda.h
 delete mode 100644 arch/ia64/include/asm/sn/pic.h
 delete mode 100644 arch/ia64/include/asm/sn/rw_mmr.h
 delete mode 100644 arch/ia64/include/asm/sn/shub_mmr.h
 delete mode 100644 arch/ia64/include/asm/sn/shubio.h
 delete mode 100644 arch/ia64/include/asm/sn/simulator.h
 delete mode 100644 arch/ia64/include/asm/sn/sn2/sn_hwperf.h
 delete mode 100644 arch/ia64/include/asm/sn/sn_cpuid.h
 delete mode 100644 arch/ia64/include/asm/sn/sn_feature_sets.h
 delete mode 100644 arch/ia64/include/asm/sn/tioca.h
 delete mode 100644 arch/ia64/include/asm/sn/tioca_provider.h
 delete mode 100644 arch/ia64/include/asm/sn/tioce.h
 delete mode 100644 arch/ia64/include/asm/sn/tioce_provider.h
 delete mode 100644 arch/ia64/include/asm/sn/tiocp.h
 delete mode 100644 arch/ia64/include/asm/sn/tiocx.h
 delete mode 100644 arch/ia64/include/asm/sn/types.h
 delete mode 100644 arch/ia64/kernel/machvec.c
 delete mode 100644 arch/ia64/sn/Makefile
 delete mode 100644 arch/ia64/sn/include/ioerror.h
 delete mode 100644 arch/ia64/sn/include/tio.h
 delete mode 100644 arch/ia64/sn/include/xtalk/hubdev.h
 delete mode 100644 arch/ia64/sn/include/xtalk/xbow.h
 delete mode 100644 arch/ia64/sn/include/xtalk/xwidgetdev.h
 delete mode 100644 arch/ia64/sn/kernel/Makefile
 delete mode 100644 arch/ia64/sn/kernel/bte.c
 delete mode 100644 arch/ia64/sn/kernel/bte_error.c
 delete mode 100644 arch/ia64/sn/kernel/huberror.c
 delete mode 100644 arch/ia64/sn/kernel/idle.c
 delete mode 100644 arch/ia64/sn/kernel/io_acpi_init.c
 delete mode 100644 arch/ia64/sn/kernel/io_common.c
 delete mode 100644 arch/ia64/sn/kernel/io_init.c
 delete mode 100644 arch/ia64/sn/kernel/iomv.c
 delete mode 100644 arch/ia64/sn/kernel/irq.c
 delete mode 100644 arch/ia64/sn/kernel/klconflib.c
 delete mode 100644 arch/ia64/sn/kernel/machvec.c
 delete mode 100644 arch/ia64/sn/kernel/mca.c
 delete mode 100644 arch/ia64/sn/kernel/msi_sn.c
 delete mode 100644 arch/ia64/sn/kernel/pio_phys.S
 delete mode 100644 arch/ia64/sn/kernel/setup.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/Makefile
 delete mode 100644 arch/ia64/sn/kernel/sn2/cache.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/io.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/prominfo_proc.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/ptc_deadlock.S
 delete mode 100644 arch/ia64/sn/kernel/sn2/sn2_smp.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/sn_hwperf.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/sn_proc_fs.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/timer.c
 delete mode 100644 arch/ia64/sn/kernel/sn2/timer_interrupt.c
 delete mode 100644 arch/ia64/sn/kernel/tiocx.c
 delete mode 100644 arch/ia64/sn/pci/Makefile
 delete mode 100644 arch/ia64/sn/pci/pci_dma.c
 delete mode 100644 arch/ia64/sn/pci/pcibr/Makefile
 delete mode 100644 arch/ia64/sn/pci/pcibr/pcibr_ate.c
 delete mode 100644 arch/ia64/sn/pci/pcibr/pcibr_dma.c
 delete mode 100644 arch/ia64/sn/pci/pcibr/pcibr_provider.c
 delete mode 100644 arch/ia64/sn/pci/pcibr/pcibr_reg.c
 delete mode 100644 arch/ia64/sn/pci/tioca_provider.c
 delete mode 100644 arch/ia64/sn/pci/tioce_provider.c
 delete mode 100644 arch/ia64/uv/kernel/machvec.c
 delete mode 100644 drivers/char/agp/sgi-agp.c
 delete mode 100644 drivers/char/mbcs.c
 delete mode 100644 drivers/char/mbcs.h
 delete mode 100644 drivers/char/snsc.c
 delete mode 100644 drivers/char/snsc.h
 delete mode 100644 drivers/char/snsc_event.c
 delete mode 100644 drivers/ide/sgiioc4.c
 delete mode 100644 drivers/misc/ioc4.c
 delete mode 100644 drivers/misc/sgi-xp/xp_nofault.S
 delete mode 100644 drivers/misc/sgi-xp/xp_sn2.c
 delete mode 100644 drivers/misc/sgi-xp/xpc_sn2.c
 delete mode 100644 drivers/pci/hotplug/sgi_hotplug.c
 delete mode 100644 drivers/sn/Kconfig
 delete mode 100644 drivers/sn/Makefile
 delete mode 100644 drivers/sn/ioc3.c
 delete mode 100644 drivers/tty/serial/ioc3_serial.c
 delete mode 100644 drivers/tty/serial/ioc4_serial.c
 delete mode 100644 drivers/tty/serial/sn_console.c
 delete mode 100644 include/linux/ioc4.h
