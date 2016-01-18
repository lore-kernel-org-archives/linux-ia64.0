From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Date: Mon, 18 Jan 2016 16:47:59 +0000
Subject: [PATCH v9 0/6] arm64, numa: Add numa support for arm64 platforms
Message-Id: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, Will.Deacon@arm.com, catalin.marinas@arm.com, grant.likely@linaro.org, leif.lindholm@linaro.org, rfranz@cavium.com, ard.biesheuvel@linaro.org, msalter@redhat.com, robh+dt@kernel.org, steve.capper@linaro.org, hanjun.guo@linaro.org, al.stone@linaro.org, arnd@arndb.de, pawel.moll@arm.com, mark.rutland@arm.com, ijc+devicetree@hellion.org.uk, galak@codeaurora.org, rjw@rjwysocki.net, lenb@kernel.org, marc.zyngier@arm.com, lorenzo.pieralisi@arm.com, bhelgaas@google.com, tony.luck@intel.com, fenghua.yu@intel.com, james.hoga
Cc: gpkulkarni@gmail.com

v9:	- Added cleanup patch to reuse and avoid redefinition of cpumask_of_pcibus
	  as suggested from Will Deacon and Bjorn Helgaas.
	- Including patch to Make pci-host-generic driver numa aware.
	- Incorporated comment from Shannon Zhao.

v8:
	- Incorporated review comments of Mark Rutland and Will Deacon.
	- Added pci helper function and macro for numa.

v7:
	- managing numa memory mapping using memblock.
	- Incorporated review comments of Mark Rutland.

v6:
	- defined and implemented the numa dt binding using
	node property proximity and device node distance-map.
	- renamed dt_numa to of_numa

v5:
        - created base verion of numa.c which creates dummy numa without using dt
          on single socket platforms. Then added patches for dt support.
        - Incorporated review comments from Hanjun Guo.

v4:
done changes as per Arnd review comments.

v3:
Added changes to support numa on arm64 based platforms.
Tested these patches on cavium's multinode(2 node topology) platform.
In this patchset, defined and implemented dt bindings for numa mapping
for core and memory using device node property arm,associativity.

v2:
Defined and implemented numa map for memory, cores to node and
proximity distance matrix of nodes.

v1:
Initial patchset to support numa on arm64 platforms.

Note:
        1. This patchset is tested for numa with dt on
           thunderx single socket and dual socket boards.
        2. Numa DT booting needs the dt memory nodes, which are deleted in current efi-stub,
        hence to try numa with dt, you need to rebase with ard's patchset.
        http://git.linaro.org/people/ard.biesheuvel/linux-arm.git/shortlog/refs/heads/arm64-uefi-early-fdt-handling
	3. PATCH 6 is not tested for other architectures.

Ganapatrao Kulkarni (6):
  arm64, numa: adding numa support for arm64 platforms.
  Documentation, dt, arm64/arm: dt bindings for numa.
  arm64/arm, numa, dt: adding numa dt binding implementation for arm64
    platforms.
  arm64, dt, thunderx: Add initial dts for Cavium Thunderx in 2 node
    topology.
  PCI: generic: Make pci-host-generic driver numa aware
  topology, cleanup: Avoid redefinition of cpumask_of_pcibus in asm
    header files.

 Documentation/devicetree/bindings/arm/numa.txt  | 272 ++++++++
 arch/arm64/Kconfig                              |  35 +
 arch/arm64/boot/dts/cavium/Makefile             |   2 +-
 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts  |  83 +++
 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi | 806 ++++++++++++++++++++++++
 arch/arm64/include/asm/mmzone.h                 |  18 +
 arch/arm64/include/asm/numa.h                   |  50 ++
 arch/arm64/include/asm/topology.h               |   7 +
 arch/arm64/kernel/Makefile                      |   1 +
 arch/arm64/kernel/of_numa.c                     | 257 ++++++++
 arch/arm64/kernel/pci.c                         |   8 +
 arch/arm64/kernel/setup.c                       |   4 +
 arch/arm64/kernel/smp.c                         |   4 +
 arch/arm64/mm/Makefile                          |   1 +
 arch/arm64/mm/init.c                            |  31 +-
 arch/arm64/mm/mmu.c                             |   1 +
 arch/arm64/mm/numa.c                            | 395 ++++++++++++
 arch/ia64/include/asm/topology.h                |   4 -
 arch/metag/include/asm/topology.h               |   3 -
 arch/powerpc/include/asm/topology.h             |   4 -
 arch/s390/include/asm/pci.h                     |   2 +-
 arch/s390/include/asm/topology.h                |   1 +
 arch/sh/include/asm/topology.h                  |   3 -
 arch/x86/include/asm/pci.h                      |   2 +-
 arch/x86/include/asm/topology.h                 |   1 +
 drivers/pci/host/pci-host-generic.c             |   9 +-
 include/asm-generic/topology.h                  |   4 +-
 27 files changed, 1981 insertions(+), 27 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/numa.txt
 create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts
 create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi
 create mode 100644 arch/arm64/include/asm/mmzone.h
 create mode 100644 arch/arm64/include/asm/numa.h
 create mode 100644 arch/arm64/kernel/of_numa.c
 create mode 100644 arch/arm64/mm/numa.c

-- 
1.8.1.4

