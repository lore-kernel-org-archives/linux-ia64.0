From: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Date: Tue, 02 Feb 2016 10:21:15 +0000
Subject: [PATCH v10 0/8] arm64, numa: Add numa support for arm64 platforms
Message-Id: <1454407763-1017-1-git-send-email-gkulkarni@caviumnetworks.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, Will.Deacon@arm.com, catalin.marinas@arm.com, robh+dt@kernel.org, mark.rutland@arm.com, grant.likely@linaro.org, leif.lindholm@linaro.org, rfranz@cavium.com, ard.biesheuvel@linaro.org, msalter@redhat.com, steve.capper@linaro.org, hanjun.guo@linaro.org, al.stone@linaro.org, arnd@arndb.de, pawel.moll@arm.com, ijc+devicetree@hellion.org.uk, galak@codeaurora.org, rjw@rjwysocki.net, lenb@kernel.org, marc.zyngier@arm.com, lorenzo.pieralisi@arm.com, bhelgaas@google.com, tony.luck@intel.com, fenghua.yu@intel.com, james.hog
Cc: gpkulkarni@gmail.com

v10:
	- Incorporated review comments from Rob Herring.
	- Moved numa binding and implementation to devicetree core.
	- Added cleanup patch to remove redundant NODE_DATA macro from asm header files
	- Include numa balancing support for arm64 patch in this series.
	- Fix tile build issue reported by the kbuild robot(patch 7)

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
	3. PATCH[7,8] are not tested for other architectures.

Ganapatrao Kulkarni (8):
  arm64, numa: adding numa support for arm64 platforms.
  Documentation, dt, numa: dt bindings for numa.
  dt, numa: adding numa dt binding implementation.
  arm64, numa : Enable numa dt for arm64 platforms.
  arm64, dt, thunderx: Add initial dts for Cavium Thunderx in 2 node
    topology.
  arm64, mm, numa: Adding numa balancing support for arm64.
  topology, cleanup: Avoid redefinition of cpumask_of_pcibus in asm
    header files.
  numa, mm, cleanup: remove redundant NODE_DATA macro from asm header
    files.

 Documentation/devicetree/bindings/numa.txt      | 272 ++++++++
 arch/arm64/Kconfig                              |  26 +
 arch/arm64/boot/dts/cavium/Makefile             |   2 +-
 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts  |  83 +++
 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi | 806 ++++++++++++++++++++++++
 arch/arm64/include/asm/mmzone.h                 |  10 +
 arch/arm64/include/asm/numa.h                   |  45 ++
 arch/arm64/include/asm/pgtable.h                |  18 +
 arch/arm64/include/asm/topology.h               |   7 +
 arch/arm64/kernel/pci.c                         |  10 +
 arch/arm64/kernel/setup.c                       |   4 +
 arch/arm64/kernel/smp.c                         |   4 +
 arch/arm64/mm/Makefile                          |   1 +
 arch/arm64/mm/init.c                            |  34 +-
 arch/arm64/mm/mmu.c                             |   1 +
 arch/arm64/mm/numa.c                            | 404 ++++++++++++
 arch/ia64/include/asm/topology.h                |   4 -
 arch/m32r/include/asm/mmzone.h                  |   4 +-
 arch/metag/include/asm/mmzone.h                 |   4 +-
 arch/metag/include/asm/topology.h               |   3 -
 arch/powerpc/include/asm/mmzone.h               |   8 +-
 arch/powerpc/include/asm/topology.h             |   4 -
 arch/s390/include/asm/mmzone.h                  |   6 +-
 arch/s390/include/asm/pci.h                     |   2 +-
 arch/s390/include/asm/topology.h                |   1 +
 arch/sh/include/asm/mmzone.h                    |   4 +-
 arch/sh/include/asm/topology.h                  |   3 -
 arch/sparc/include/asm/mmzone.h                 |   6 +-
 arch/tile/include/asm/pci.h                     |   2 -
 arch/tile/include/asm/topology.h                |   3 +
 arch/x86/include/asm/mmzone.h                   |   3 +-
 arch/x86/include/asm/mmzone_32.h                |   5 -
 arch/x86/include/asm/mmzone_64.h                |  17 -
 arch/x86/include/asm/pci.h                      |   2 +-
 arch/x86/include/asm/topology.h                 |   1 +
 drivers/of/Kconfig                              |  11 +
 drivers/of/Makefile                             |   1 +
 drivers/of/of_numa.c                            | 207 ++++++
 include/asm-generic/mmzone.h                    |  24 +
 include/asm-generic/topology.h                  |   4 +-
 include/linux/of.h                              |   4 +
 41 files changed, 1986 insertions(+), 74 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/numa.txt
 create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts
 create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi
 create mode 100644 arch/arm64/include/asm/mmzone.h
 create mode 100644 arch/arm64/include/asm/numa.h
 create mode 100644 arch/arm64/mm/numa.c
 delete mode 100644 arch/x86/include/asm/mmzone_64.h
 create mode 100644 drivers/of/of_numa.c
 create mode 100644 include/asm-generic/mmzone.h

-- 
1.8.1.4

