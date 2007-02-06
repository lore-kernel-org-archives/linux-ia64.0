From: akpm@linux-foundation.org
Date: Tue, 06 Feb 2007 00:20:03 +0000
Subject: [patch 08/13] ia64: Enable SWIOTLB only when needed
Message-Id: <200702060021.l160L6kF004204@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Jan Beulich" <jbeulich@novell.com>

Don't force CONFIG_SWIOTLB on when not actually needed (i.e. HP_ZX1 and
SGI_SN2).

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Andi Kleen <ak@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/Kconfig |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff -puN arch/ia64/Kconfig~ia64-enable-swiotlb-only-when-needed arch/ia64/Kconfig
--- a/arch/ia64/Kconfig~ia64-enable-swiotlb-only-when-needed
+++ a/arch/ia64/Kconfig
@@ -28,7 +28,6 @@ config MMU
 
 config SWIOTLB
        bool
-       default y
 
 config RWSEM_XCHGADD_ALGORITHM
 	bool
@@ -88,6 +87,7 @@ config IA64_GENERIC
 	select PCI
 	select NUMA
 	select ACPI_NUMA
+	select SWIOTLB
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
@@ -104,6 +104,7 @@ config IA64_GENERIC
 
 config IA64_DIG
 	bool "DIG-compliant"
+	select SWIOTLB
 
 config IA64_HP_ZX1
 	bool "HP-zx1/sx1000"
@@ -113,6 +114,7 @@ config IA64_HP_ZX1
 
 config IA64_HP_ZX1_SWIOTLB
 	bool "HP-zx1/sx1000 with software I/O TLB"
+	select SWIOTLB
 	help
 	  Build a kernel that runs on HP zx1 and sx1000 systems even when they
 	  have broken PCI devices which cannot DMA to full 32 bits.  Apart
@@ -131,6 +133,7 @@ config IA64_SGI_SN2
 
 config IA64_HP_SIM
 	bool "Ski-simulator"
+	select SWIOTLB
 
 endchoice
 
_
