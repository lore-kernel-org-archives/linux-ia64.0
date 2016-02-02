From: Robert Richter <robert.richter@caviumnetworks.com>
Date: Tue, 02 Feb 2016 11:26:42 +0000
Subject: Re: [PATCH v10 0/8] arm64, numa: Add numa support for arm64 platforms
Message-Id: <20160202112642.GE24726@rric.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454407763-1017-1-git-send-email-gkulkarni@caviumnetworks.com>
In-Reply-To: <1454407763-1017-1-git-send-email-gkulkarni@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Cc: mark.rutland@arm.com, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-pci@vger.kernel.org, Will.Deacon@arm.com, hpa@zytor.com, catalin.marinas@arm.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, lorenzo.pieralisi@arm.com, pawel.moll@arm.com, al.stone@linaro.org, Prasun.Kapoor@caviumnetworks.com, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, rfranz@cavium.com, lenb@kernel.org, devicetree@vger.kernel.org, james.hogan@imgtec.com, steve.capper@linaro.org, arnd@arndb.de, ijc+devicetree@hellion.org.uk, marc.zyngier@arm.com, leif.lindholm@linaro.org, grant.likely@linaro.org, robh+dt@kernel.org, bhelgaas@google.com, tglx@linutronix.de, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, tony.luck@intel.com, ard.biesheuvel@linaro.org, rjw@rjwysocki.net, linux-kernel@vger.kernel.org, fenghua.yu@intel.com, benh@kernel.crashing.org, han

On 02.02.16 15:39:15, Ganapatrao Kulkarni wrote:

> Ganapatrao Kulkarni (8):
>   arm64, numa: adding numa support for arm64 platforms.
>   Documentation, dt, numa: dt bindings for numa.
>   dt, numa: adding numa dt binding implementation.
>   arm64, numa : Enable numa dt for arm64 platforms.
>   arm64, dt, thunderx: Add initial dts for Cavium Thunderx in 2 node
>     topology.
>   arm64, mm, numa: Adding numa balancing support for arm64.
>   topology, cleanup: Avoid redefinition of cpumask_of_pcibus in asm
>     header files.
>   numa, mm, cleanup: remove redundant NODE_DATA macro from asm header
>     files.

I have tested the whole series on single and dual node systems for
devicetree and acpi (with Hanjun's acpi numa v3 patches ported on
top).

Tested-by: Robert Richter <rrichter@cavium.com>

-Robert

> 
>  Documentation/devicetree/bindings/numa.txt      | 272 ++++++++
>  arch/arm64/Kconfig                              |  26 +
>  arch/arm64/boot/dts/cavium/Makefile             |   2 +-
>  arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts  |  83 +++
>  arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi | 806 ++++++++++++++++++++++++
>  arch/arm64/include/asm/mmzone.h                 |  10 +
>  arch/arm64/include/asm/numa.h                   |  45 ++
>  arch/arm64/include/asm/pgtable.h                |  18 +
>  arch/arm64/include/asm/topology.h               |   7 +
>  arch/arm64/kernel/pci.c                         |  10 +
>  arch/arm64/kernel/setup.c                       |   4 +
>  arch/arm64/kernel/smp.c                         |   4 +
>  arch/arm64/mm/Makefile                          |   1 +
>  arch/arm64/mm/init.c                            |  34 +-
>  arch/arm64/mm/mmu.c                             |   1 +
>  arch/arm64/mm/numa.c                            | 404 ++++++++++++
>  arch/ia64/include/asm/topology.h                |   4 -
>  arch/m32r/include/asm/mmzone.h                  |   4 +-
>  arch/metag/include/asm/mmzone.h                 |   4 +-
>  arch/metag/include/asm/topology.h               |   3 -
>  arch/powerpc/include/asm/mmzone.h               |   8 +-
>  arch/powerpc/include/asm/topology.h             |   4 -
>  arch/s390/include/asm/mmzone.h                  |   6 +-
>  arch/s390/include/asm/pci.h                     |   2 +-
>  arch/s390/include/asm/topology.h                |   1 +
>  arch/sh/include/asm/mmzone.h                    |   4 +-
>  arch/sh/include/asm/topology.h                  |   3 -
>  arch/sparc/include/asm/mmzone.h                 |   6 +-
>  arch/tile/include/asm/pci.h                     |   2 -
>  arch/tile/include/asm/topology.h                |   3 +
>  arch/x86/include/asm/mmzone.h                   |   3 +-
>  arch/x86/include/asm/mmzone_32.h                |   5 -
>  arch/x86/include/asm/mmzone_64.h                |  17 -
>  arch/x86/include/asm/pci.h                      |   2 +-
>  arch/x86/include/asm/topology.h                 |   1 +
>  drivers/of/Kconfig                              |  11 +
>  drivers/of/Makefile                             |   1 +
>  drivers/of/of_numa.c                            | 207 ++++++
>  include/asm-generic/mmzone.h                    |  24 +
>  include/asm-generic/topology.h                  |   4 +-
>  include/linux/of.h                              |   4 +
>  41 files changed, 1986 insertions(+), 74 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/numa.txt
>  create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts
>  create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi
>  create mode 100644 arch/arm64/include/asm/mmzone.h
>  create mode 100644 arch/arm64/include/asm/numa.h
>  create mode 100644 arch/arm64/mm/numa.c
>  delete mode 100644 arch/x86/include/asm/mmzone_64.h
>  create mode 100644 drivers/of/of_numa.c
>  create mode 100644 include/asm-generic/mmzone.h
> 
> -- 
> 1.8.1.4
> 
