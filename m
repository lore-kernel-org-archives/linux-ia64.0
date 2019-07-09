From: Rob Herring <robh@kernel.org>
Date: Tue, 09 Jul 2019 17:02:45 +0000
Subject: Re: [PATCH v1 01/22] docs: Documentation/*.txt: rename all ReST files to *.rst
Message-Id: <20190709170245.GA7073@bogus>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1560891322.git.mchehab+samsung@kernel.org>
 <6b6b6db8d6de9b66223dd6d4b43eb60ead4c71d7.1560891322.git.mchehab+samsung@kernel.org>
In-Reply-To: <6b6b6db8d6de9b66223dd6d4b43eb60ead4c71d7.1560891322.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: linux-wireless@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, kvm@vger.kernel.org, linux-sh@vger.kernel.org, linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org, platform-driver-x86@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, x86@kernel.org, iommu@lists.linux-foundation.org, devicetree@vger.kernel.org, linux-watchdog@vger.kernel.org, Mauro Carvalho Chehab <mchehab@infradead.org>, linux-block@vger.kernel.org, linux-gpio@vger.kernel.org, openipmi-developer@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, Linux Doc Mailing List <linux-doc@vger.kernel.org>, linux-kernel@vger.kernel.org, linux-securit

On Tue, Jun 18, 2019 at 06:05:25PM -0300, Mauro Carvalho Chehab wrote:
> Those files are actually at ReST format. Ok, currently, they
> don't belong to any place yet at the organized book series,
> but we don't want patches to break them as ReST files. So,
> rename them and add a :orphan: in order to shut up warning
> messages like those:
> 
> ...
>     Documentation/svga.rst: WARNING: document isn't included in any toctree
>     Documentation/switchtec.rst: WARNING: document isn't included in any toctree
> ...
> 
> Later patches will move them to a better place and remove the
> :orphan: markup.
> 
> Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> ---
> 
> I had to remove the long list of maintainers got by
> getpatch.pl, as it was too long. I opted to keep only the
> mailing lists.
> 
>  Documentation/ABI/removed/sysfs-class-rfkill  |  2 +-
>  Documentation/ABI/stable/sysfs-class-rfkill   |  2 +-
>  Documentation/ABI/stable/sysfs-devices-node   |  2 +-
>  Documentation/ABI/testing/procfs-diskstats    |  2 +-
>  Documentation/ABI/testing/sysfs-block         |  2 +-
>  .../ABI/testing/sysfs-class-switchtec         |  2 +-
>  .../ABI/testing/sysfs-devices-system-cpu      |  4 +-
>  .../{DMA-API-HOWTO.txt => DMA-API-HOWTO.rst}  |  2 +
>  Documentation/{DMA-API.txt => DMA-API.rst}    |  8 ++-
>  .../{DMA-ISA-LPC.txt => DMA-ISA-LPC.rst}      |  4 +-
>  ...{DMA-attributes.txt => DMA-attributes.rst} |  2 +
>  Documentation/{IPMI.txt => IPMI.rst}          |  2 +
>  .../{IRQ-affinity.txt => IRQ-affinity.rst}    |  2 +
>  .../{IRQ-domain.txt => IRQ-domain.rst}        |  2 +
>  Documentation/{IRQ.txt => IRQ.rst}            |  2 +
>  .../{Intel-IOMMU.txt => Intel-IOMMU.rst}      |  2 +
>  Documentation/PCI/pci.rst                     |  8 +--
>  Documentation/{SAK.txt => SAK.rst}            |  3 +-
>  Documentation/{SM501.txt => SM501.rst}        |  2 +
>  Documentation/admin-guide/hw-vuln/l1tf.rst    |  2 +-
>  .../admin-guide/kernel-parameters.txt         |  4 +-
>  .../{atomic_bitops.txt => atomic_bitops.rst}  |  3 +-
>  Documentation/block/biodoc.txt                |  2 +-
>  .../{bt8xxgpio.txt => bt8xxgpio.rst}          |  3 +-
>  Documentation/{btmrvl.txt => btmrvl.rst}      |  2 +
>  ...-mapping.txt => bus-virt-phys-mapping.rst} | 54 +++++++++---------
>  ...g-warn-once.txt => clearing-warn-once.rst} |  2 +
>  Documentation/{cpu-load.txt => cpu-load.rst}  |  2 +
>  .../{cputopology.txt => cputopology.rst}      |  2 +
>  Documentation/{crc32.txt => crc32.rst}        |  2 +
>  Documentation/{dcdbas.txt => dcdbas.rst}      |  2 +
>  ...ging-modules.txt => debugging-modules.rst} |  2 +
>  ...hci1394.txt => debugging-via-ohci1394.rst} |  2 +
>  Documentation/{dell_rbu.txt => dell_rbu.rst}  |  3 +-
>  Documentation/device-mapper/statistics.rst    |  4 +-
>  .../devicetree/bindings/phy/phy-bindings.txt  |  2 +-

Acked-by: Rob Herring <robh@kernel.org>

>  Documentation/{digsig.txt => digsig.rst}      |  2 +
>  Documentation/driver-api/usb/dma.rst          |  6 +-
>  Documentation/driver-model/device.rst         |  2 +-
>  Documentation/{efi-stub.txt => efi-stub.rst}  |  2 +
>  Documentation/{eisa.txt => eisa.rst}          |  2 +
>  Documentation/fb/vesafb.rst                   |  2 +-
>  Documentation/filesystems/sysfs.txt           |  2 +-
>  ...ex-requeue-pi.txt => futex-requeue-pi.rst} |  2 +
>  .../{gcc-plugins.txt => gcc-plugins.rst}      |  2 +
>  Documentation/gpu/drm-mm.rst                  |  2 +-
>  Documentation/{highuid.txt => highuid.rst}    |  4 +-
>  .../{hw_random.txt => hw_random.rst}          |  2 +
>  .../{hwspinlock.txt => hwspinlock.rst}        |  2 +
>  Documentation/ia64/irq-redir.rst              |  2 +-
>  .../{intel_txt.txt => intel_txt.rst}          |  2 +
>  .../{io-mapping.txt => io-mapping.rst}        |  2 +
>  .../{io_ordering.txt => io_ordering.rst}      |  2 +
>  Documentation/{iostats.txt => iostats.rst}    |  2 +
>  ...flags-tracing.txt => irqflags-tracing.rst} |  3 +-
>  Documentation/{isa.txt => isa.rst}            |  2 +
>  Documentation/{isapnp.txt => isapnp.rst}      |  2 +
>  ...hreads.txt => kernel-per-CPU-kthreads.rst} |  4 +-
>  Documentation/{kobject.txt => kobject.rst}    |  6 +-
>  Documentation/{kprobes.txt => kprobes.rst}    |  3 +-
>  Documentation/{kref.txt => kref.rst}          |  2 +
>  Documentation/laptops/thinkpad-acpi.rst       |  6 +-
>  Documentation/{ldm.txt => ldm.rst}            |  5 +-
>  Documentation/locking/rt-mutex.rst            |  2 +-
>  ...kup-watchdogs.txt => lockup-watchdogs.rst} |  2 +
>  Documentation/{lsm.txt => lsm.rst}            |  2 +
>  Documentation/{lzo.txt => lzo.rst}            |  2 +
>  Documentation/{mailbox.txt => mailbox.rst}    |  2 +
>  Documentation/memory-barriers.txt             |  6 +-
>  ...hameleon-bus.txt => men-chameleon-bus.rst} |  2 +
>  Documentation/networking/scaling.rst          |  4 +-
>  .../{nommu-mmap.txt => nommu-mmap.rst}        |  2 +
>  Documentation/{ntb.txt => ntb.rst}            |  2 +
>  Documentation/{numastat.txt => numastat.rst}  |  3 +-
>  Documentation/{padata.txt => padata.rst}      |  2 +
>  ...port-lowlevel.txt => parport-lowlevel.rst} |  2 +
>  ...-semaphore.txt => percpu-rw-semaphore.rst} |  2 +
>  Documentation/{phy.txt => phy.rst}            |  2 +
>  Documentation/{pi-futex.txt => pi-futex.rst}  |  2 +
>  Documentation/{pnp.txt => pnp.rst}            | 13 +++--
>  ...reempt-locking.txt => preempt-locking.rst} |  4 +-
>  Documentation/{pwm.txt => pwm.rst}            |  2 +
>  Documentation/{rbtree.txt => rbtree.rst}      | 54 +++++++++---------
>  .../{remoteproc.txt => remoteproc.rst}        |  4 +-
>  Documentation/{rfkill.txt => rfkill.rst}      |  2 +
>  ...ust-futex-ABI.txt => robust-futex-ABI.rst} |  2 +
>  ...{robust-futexes.txt => robust-futexes.rst} |  2 +
>  Documentation/{rpmsg.txt => rpmsg.rst}        |  2 +
>  Documentation/{rtc.txt => rtc.rst}            |  8 ++-
>  Documentation/s390/vfio-ccw.rst               |  6 +-
>  Documentation/{sgi-ioc4.txt => sgi-ioc4.rst}  |  2 +
>  Documentation/{siphash.txt => siphash.rst}    |  2 +
>  .../{smsc_ece1099.txt => smsc_ece1099.rst}    |  2 +
>  .../{speculation.txt => speculation.rst}      |  2 +
>  .../{static-keys.txt => static-keys.rst}      |  2 +
>  Documentation/{svga.txt => svga.rst}          |  2 +
>  .../{switchtec.txt => switchtec.rst}          |  4 +-
>  .../{sync_file.txt => sync_file.rst}          |  2 +
>  Documentation/sysctl/kernel.txt               |  4 +-
>  Documentation/sysctl/vm.txt                   |  2 +-
>  Documentation/{tee.txt => tee.rst}            |  2 +
>  .../{this_cpu_ops.txt => this_cpu_ops.rst}    |  2 +
>  Documentation/trace/kprobetrace.rst           |  2 +-
>  .../translations/ko_KR/memory-barriers.txt    |  6 +-
>  Documentation/translations/zh_CN/IRQ.txt      |  4 +-
>  .../translations/zh_CN/filesystems/sysfs.txt  |  2 +-
>  .../translations/zh_CN/io_ordering.txt        |  4 +-
>  ...access.txt => unaligned-memory-access.rst} |  2 +
>  ...ed-device.txt => vfio-mediated-device.rst} |  4 +-
>  Documentation/{vfio.txt => vfio.rst}          |  2 +
>  .../{video-output.txt => video-output.rst}    |  3 +-
>  Documentation/watchdog/hpwdt.rst              |  2 +-
>  Documentation/x86/topology.rst                |  2 +-
>  Documentation/{xillybus.txt => xillybus.rst}  |  2 +
>  Documentation/{xz.txt => xz.rst}              |  2 +
>  Documentation/{zorro.txt => zorro.rst}        |  7 ++-
>  MAINTAINERS                                   | 56 +++++++++----------
>  arch/Kconfig                                  |  4 +-
>  arch/arm/Kconfig                              |  2 +-
>  arch/ia64/hp/common/sba_iommu.c               | 12 ++--
>  arch/ia64/sn/pci/pci_dma.c                    |  4 +-
>  arch/parisc/Kconfig                           |  2 +-
>  arch/parisc/kernel/pci-dma.c                  |  2 +-
>  arch/sh/Kconfig                               |  2 +-
>  arch/sparc/Kconfig                            |  2 +-
>  arch/unicore32/include/asm/io.h               |  2 +-
>  arch/x86/Kconfig                              |  4 +-
>  arch/x86/include/asm/dma-mapping.h            |  4 +-
>  arch/x86/kernel/amd_gart_64.c                 |  2 +-
>  block/partitions/Kconfig                      |  2 +-
>  drivers/base/core.c                           |  2 +-
>  drivers/char/Kconfig                          |  4 +-
>  drivers/char/hw_random/core.c                 |  2 +-
>  drivers/char/ipmi/Kconfig                     |  2 +-
>  drivers/char/ipmi/ipmi_si_hotmod.c            |  2 +-
>  drivers/char/ipmi/ipmi_si_intf.c              |  2 +-
>  drivers/dma-buf/Kconfig                       |  2 +-
>  drivers/gpio/Kconfig                          |  2 +-
>  drivers/parisc/sba_iommu.c                    | 16 +++---
>  drivers/pci/switch/Kconfig                    |  2 +-
>  drivers/platform/x86/Kconfig                  |  4 +-
>  drivers/platform/x86/dcdbas.c                 |  2 +-
>  drivers/platform/x86/dell_rbu.c               |  2 +-
>  drivers/pnp/isapnp/Kconfig                    |  2 +-
>  drivers/vfio/Kconfig                          |  2 +-
>  drivers/vfio/mdev/Kconfig                     |  2 +-
>  include/asm-generic/bitops/atomic.h           |  2 +-
>  include/linux/dma-mapping.h                   |  2 +-
>  include/linux/hw_random.h                     |  2 +-
>  include/linux/io-mapping.h                    |  2 +-
>  include/linux/jump_label.h                    |  2 +-
>  include/linux/kobject.h                       |  2 +-
>  include/linux/kobject_ns.h                    |  2 +-
>  include/linux/rbtree.h                        |  2 +-
>  include/linux/rbtree_augmented.h              |  2 +-
>  include/media/videobuf-dma-sg.h               |  2 +-
>  init/Kconfig                                  |  2 +-
>  kernel/dma/debug.c                            |  2 +-
>  kernel/padata.c                               |  2 +-
>  lib/Kconfig                                   |  2 +-
>  lib/Kconfig.debug                             |  2 +-
>  lib/crc32.c                                   |  2 +-
>  lib/kobject.c                                 |  4 +-
>  lib/lzo/lzo1x_decompress_safe.c               |  2 +-
>  lib/xz/Kconfig                                |  2 +-
>  mm/Kconfig                                    |  2 +-
>  mm/nommu.c                                    |  2 +-
>  samples/kprobes/kprobe_example.c              |  2 +-
>  samples/kprobes/kretprobe_example.c           |  2 +-
>  scripts/gcc-plugins/Kconfig                   |  2 +-
>  security/Kconfig                              |  2 +-
>  tools/include/linux/rbtree.h                  |  2 +-
>  tools/include/linux/rbtree_augmented.h        |  2 +-
>  173 files changed, 397 insertions(+), 242 deletions(-)
>  rename Documentation/{DMA-API-HOWTO.txt => DMA-API-HOWTO.rst} (99%)
>  rename Documentation/{DMA-API.txt => DMA-API.rst} (99%)
>  rename Documentation/{DMA-ISA-LPC.txt => DMA-ISA-LPC.rst} (98%)
>  rename Documentation/{DMA-attributes.txt => DMA-attributes.rst} (99%)
>  rename Documentation/{IPMI.txt => IPMI.rst} (99%)
>  rename Documentation/{IRQ-affinity.txt => IRQ-affinity.rst} (99%)
>  rename Documentation/{IRQ-domain.txt => IRQ-domain.rst} (99%)
>  rename Documentation/{IRQ.txt => IRQ.rst} (99%)
>  rename Documentation/{Intel-IOMMU.txt => Intel-IOMMU.rst} (99%)
>  rename Documentation/{SAK.txt => SAK.rst} (99%)
>  rename Documentation/{SM501.txt => SM501.rst} (99%)
>  rename Documentation/{atomic_bitops.txt => atomic_bitops.rst} (99%)
>  rename Documentation/{bt8xxgpio.txt => bt8xxgpio.rst} (99%)
>  rename Documentation/{btmrvl.txt => btmrvl.rst} (99%)
>  rename Documentation/{bus-virt-phys-mapping.txt => bus-virt-phys-mapping.rst} (93%)
>  rename Documentation/{clearing-warn-once.txt => clearing-warn-once.rst} (96%)
>  rename Documentation/{cpu-load.txt => cpu-load.rst} (99%)
>  rename Documentation/{cputopology.txt => cputopology.rst} (99%)
>  rename Documentation/{crc32.txt => crc32.rst} (99%)
>  rename Documentation/{dcdbas.txt => dcdbas.rst} (99%)
>  rename Documentation/{debugging-modules.txt => debugging-modules.rst} (98%)
>  rename Documentation/{debugging-via-ohci1394.txt => debugging-via-ohci1394.rst} (99%)
>  rename Documentation/{dell_rbu.txt => dell_rbu.rst} (99%)
>  rename Documentation/{digsig.txt => digsig.rst} (99%)
>  rename Documentation/{efi-stub.txt => efi-stub.rst} (99%)
>  rename Documentation/{eisa.txt => eisa.rst} (99%)
>  rename Documentation/{futex-requeue-pi.txt => futex-requeue-pi.rst} (99%)
>  rename Documentation/{gcc-plugins.txt => gcc-plugins.rst} (99%)
>  rename Documentation/{highuid.txt => highuid.rst} (99%)
>  rename Documentation/{hw_random.txt => hw_random.rst} (99%)
>  rename Documentation/{hwspinlock.txt => hwspinlock.rst} (99%)
>  rename Documentation/{intel_txt.txt => intel_txt.rst} (99%)
>  rename Documentation/{io-mapping.txt => io-mapping.rst} (99%)
>  rename Documentation/{io_ordering.txt => io_ordering.rst} (99%)
>  rename Documentation/{iostats.txt => iostats.rst} (99%)
>  rename Documentation/{irqflags-tracing.txt => irqflags-tracing.rst} (99%)
>  rename Documentation/{isa.txt => isa.rst} (99%)
>  rename Documentation/{isapnp.txt => isapnp.rst} (98%)
>  rename Documentation/{kernel-per-CPU-kthreads.txt => kernel-per-CPU-kthreads.rst} (99%)
>  rename Documentation/{kobject.txt => kobject.rst} (99%)
>  rename Documentation/{kprobes.txt => kprobes.rst} (99%)
>  rename Documentation/{kref.txt => kref.rst} (99%)
>  rename Documentation/{ldm.txt => ldm.rst} (98%)
>  rename Documentation/{lockup-watchdogs.txt => lockup-watchdogs.rst} (99%)
>  rename Documentation/{lsm.txt => lsm.rst} (99%)
>  rename Documentation/{lzo.txt => lzo.rst} (99%)
>  rename Documentation/{mailbox.txt => mailbox.rst} (99%)
>  rename Documentation/{men-chameleon-bus.txt => men-chameleon-bus.rst} (99%)
>  rename Documentation/{nommu-mmap.txt => nommu-mmap.rst} (99%)
>  rename Documentation/{ntb.txt => ntb.rst} (99%)
>  rename Documentation/{numastat.txt => numastat.rst} (99%)
>  rename Documentation/{padata.txt => padata.rst} (99%)
>  rename Documentation/{parport-lowlevel.txt => parport-lowlevel.rst} (99%)
>  rename Documentation/{percpu-rw-semaphore.txt => percpu-rw-semaphore.rst} (99%)
>  rename Documentation/{phy.txt => phy.rst} (99%)
>  rename Documentation/{pi-futex.txt => pi-futex.rst} (99%)
>  rename Documentation/{pnp.txt => pnp.rst} (98%)
>  rename Documentation/{preempt-locking.txt => preempt-locking.rst} (99%)
>  rename Documentation/{pwm.txt => pwm.rst} (99%)
>  rename Documentation/{rbtree.txt => rbtree.rst} (94%)
>  rename Documentation/{remoteproc.txt => remoteproc.rst} (99%)
>  rename Documentation/{rfkill.txt => rfkill.rst} (99%)
>  rename Documentation/{robust-futex-ABI.txt => robust-futex-ABI.rst} (99%)
>  rename Documentation/{robust-futexes.txt => robust-futexes.rst} (99%)
>  rename Documentation/{rpmsg.txt => rpmsg.rst} (99%)
>  rename Documentation/{rtc.txt => rtc.rst} (99%)
>  rename Documentation/{sgi-ioc4.txt => sgi-ioc4.rst} (99%)
>  rename Documentation/{siphash.txt => siphash.rst} (99%)
>  rename Documentation/{smsc_ece1099.txt => smsc_ece1099.rst} (99%)
>  rename Documentation/{speculation.txt => speculation.rst} (99%)
>  rename Documentation/{static-keys.txt => static-keys.rst} (99%)
>  rename Documentation/{svga.txt => svga.rst} (99%)
>  rename Documentation/{switchtec.txt => switchtec.rst} (98%)
>  rename Documentation/{sync_file.txt => sync_file.rst} (99%)
>  rename Documentation/{tee.txt => tee.rst} (99%)
>  rename Documentation/{this_cpu_ops.txt => this_cpu_ops.rst} (99%)
>  rename Documentation/{unaligned-memory-access.txt => unaligned-memory-access.rst} (99%)
>  rename Documentation/{vfio-mediated-device.txt => vfio-mediated-device.rst} (99%)
>  rename Documentation/{vfio.txt => vfio.rst} (99%)
>  rename Documentation/{video-output.txt => video-output.rst} (99%)
>  rename Documentation/{xillybus.txt => xillybus.rst} (99%)
>  rename Documentation/{xz.txt => xz.rst} (99%)
>  rename Documentation/{zorro.txt => zorro.rst} (99%)
