From: Yann Droneaud <ydroneaud@opteya.com>
Date: Sat, 31 Jan 2015 14:08:19 +0000
Subject: ia64: implicit declaration of functions since change on <linux/dmar.h>
Message-Id: <1422713299.3030.23.camel@opteya.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <jiang.liu@linux.intel.com>, Joerg Roedel <jroedel@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi,

While trying to conduct some regression testing, I've hit the following
build issue for ia64:

  CC      arch/ia64/kernel/pci-dma.o
../arch/ia64/kernel/pci-dma.c: In function 'pci_iommu_init':
../arch/ia64/kernel/pci-dma.c:41:3: error: implicit declaration of function 'intel_iommu_init' [-Werror=implicit-function-declaration]
   intel_iommu_init();
   ^
../arch/ia64/kernel/pci-dma.c: In function 'pci_iommu_alloc':
../arch/ia64/kernel/pci-dma.c:103:2: error: implicit declaration of function 'detect_intel_iommu' [-Werror=implicit-function-declaration]
  detect_intel_iommu();
  ^

It should be noted Kconfig complain with the following:

warning: (IA64) selects PM which has unmet direct dependencies (PM_SLEEP || PM_RUNTIME)
warning: (IA64_DIG_VTD) selects INTEL_IOMMU which has unmet direct dependencies (IOMMU_SUPPORT && PCI_MSI && ACPI && (X86 || IA64_GENERIC))
warning: (IA64) selects PM which has unmet direct dependencies (PM_SLEEP || PM_RUNTIME)
warning: (IA64_DIG_VTD) selects INTEL_IOMMU which has unmet direct dependencies (IOMMU_SUPPORT && PCI_MSI && ACPI && (X86 || IA64_GENERIC))

Bissection report the following commit as the root cause of the broken build:

8594d83261d14754288ef00993f0971131ff08eb is the first bad commit
commit 8594d83261d14754288ef00993f0971131ff08eb
Author: Jiang Liu <jiang.liu@linux.intel.com>
Date:   Fri Jul 11 14:19:32 2014 +0800

    iommu/vt-d: Simplify include/linux/dmar.h
    
    Simplify include/linux/dmar.h a bit based on the fact that
    both CONFIG_INTEL_IOMMU and CONFIG_IRQ_REMAP select CONFIG_DMAR_TABLE.
    
    Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
    Signed-off-by: Joerg Roedel <jroedel@suse.de>

Regards.

-- 
Yann Droneaud
OPTEYA


