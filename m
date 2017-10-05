From: Bjorn Helgaas <helgaas@kernel.org>
Date: Thu, 05 Oct 2017 20:38:49 +0000
Subject: [PATCH 2/4] PCI: Remove redundant pci_dev, pci_bus, resource declarations
Message-Id: <20171005203849.18300.20999.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Jesper Nilsson <jesper.nilsson@axis.com>, linux-am33-list@redhat.com, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, x86@kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-xtensa@linux-xtensa.org, Mikael Starvik <starvik@axis.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Thomas Gleixner <tglx@linutronix.de>, Richard Henderson <rth@twiddle.net>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

From: Bjorn Helgaas <bhelgaas@google.com>

<linux/pci.h> defines struct pci_bus and struct pci_dev and includes the
struct resource definition before including <asm/pci.h>.  Nobody includes
<asm/pci.h> directly, so they don't need their own declarations.

Remove the redundant struct pci_dev, pci_bus, resource declarations.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/alpha/include/asm/pci.h    |    3 ---
 arch/cris/include/asm/pci.h     |    2 --
 arch/frv/include/asm/pci.h      |    2 --
 arch/ia64/include/asm/pci.h     |    2 --
 arch/mips/include/asm/pci.h     |    2 --
 arch/mn10300/include/asm/pci.h  |    2 --
 arch/parisc/include/asm/pci.h   |    7 -------
 arch/powerpc/include/asm/pci.h  |    2 --
 arch/sh/include/asm/pci.h       |    2 --
 arch/sparc/include/asm/pci_32.h |    2 --
 arch/xtensa/include/asm/pci.h   |    2 --
 11 files changed, 28 deletions(-)

diff --git a/arch/alpha/include/asm/pci.h b/arch/alpha/include/asm/pci.h
index 777be3114fda..0a10ff93b174 100644
--- a/arch/alpha/include/asm/pci.h
+++ b/arch/alpha/include/asm/pci.h
@@ -12,9 +12,6 @@
  * The following structure is used to manage multiple PCI busses.
  */
 
-struct pci_dev;
-struct pci_bus;
-struct resource;
 struct pci_iommu_arena;
 struct page;
 
diff --git a/arch/cris/include/asm/pci.h b/arch/cris/include/asm/pci.h
index c6ac59d9f815..8ea640560a46 100644
--- a/arch/cris/include/asm/pci.h
+++ b/arch/cris/include/asm/pci.h
@@ -32,8 +32,6 @@ int pcibios_set_irq_routing(struct pci_dev *dev, int pin, int irq);
 #include <linux/string.h>
 #include <asm/io.h>
 
-struct pci_dev;
-
 /* The PCI address space does equal the physical memory
  * address space.  The networking and block device layers use
  * this boolean for bounce buffer decisions.
diff --git a/arch/frv/include/asm/pci.h b/arch/frv/include/asm/pci.h
index a6957014e74e..895af9d558ba 100644
--- a/arch/frv/include/asm/pci.h
+++ b/arch/frv/include/asm/pci.h
@@ -17,8 +17,6 @@
 #include <linux/scatterlist.h>
 #include <asm-generic/pci.h>
 
-struct pci_dev;
-
 #define pcibios_assign_all_busses()	0
 
 #ifdef CONFIG_MMU
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 6459f2d46200..8c4b37f6be3d 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -31,8 +31,6 @@ struct pci_vector_struct {
 
 void pcibios_config_init(void);
 
-struct pci_dev;
-
 /*
  * PCI_DMA_BUS_IS_PHYS should be set to 1 if there is _necessarily_ a direct
  * correspondence between device bus addresses and CPU physical addresses.
diff --git a/arch/mips/include/asm/pci.h b/arch/mips/include/asm/pci.h
index 0f8528c34753..2339f42f047a 100644
--- a/arch/mips/include/asm/pci.h
+++ b/arch/mips/include/asm/pci.h
@@ -121,8 +121,6 @@ extern unsigned long PCIBIOS_MIN_MEM;
 #include <linux/string.h>
 #include <asm/io.h>
 
-struct pci_dev;
-
 /*
  * The PCI address space does equal the physical memory address space.
  * The networking and block device layers use this boolean for bounce
diff --git a/arch/mn10300/include/asm/pci.h b/arch/mn10300/include/asm/pci.h
index bdacb618d6af..5b75a1b2c4f6 100644
--- a/arch/mn10300/include/asm/pci.h
+++ b/arch/mn10300/include/asm/pci.h
@@ -57,8 +57,6 @@ extern void unit_pci_init(void);
 #include <linux/string.h>
 #include <asm/io.h>
 
-struct pci_dev;
-
 /* The PCI address space does equal the physical memory
  * address space.  The networking and block device layers use
  * this boolean for bounce buffer decisions.
diff --git a/arch/parisc/include/asm/pci.h b/arch/parisc/include/asm/pci.h
index b5730f83b941..8cc009e26a28 100644
--- a/arch/parisc/include/asm/pci.h
+++ b/arch/parisc/include/asm/pci.h
@@ -86,13 +86,6 @@ struct pci_hba_data {
 #define PCI_F_EXTEND		0UL
 #endif /* !CONFIG_64BIT */
 
-/*
-** KLUGE: linux/pci.h include asm/pci.h BEFORE declaring struct pci_bus
-** (This eliminates some of the warnings).
-*/
-struct pci_bus;
-struct pci_dev;
-
 /*
  * If the PCI device's view of memory is the same as the CPU's view of memory,
  * PCI_DMA_BUS_IS_PHYS is true.  The networking and block device layers use
diff --git a/arch/powerpc/include/asm/pci.h b/arch/powerpc/include/asm/pci.h
index c8975dac535f..8dc32eacc97c 100644
--- a/arch/powerpc/include/asm/pci.h
+++ b/arch/powerpc/include/asm/pci.h
@@ -28,8 +28,6 @@
 #define PCIBIOS_MIN_IO		0x1000
 #define PCIBIOS_MIN_MEM		0x10000000
 
-struct pci_dev;
-
 /* Values for the `which' argument to sys_pciconfig_iobase syscall.  */
 #define IOBASE_BRIDGE_NUMBER	0
 #define IOBASE_MEMORY		1
diff --git a/arch/sh/include/asm/pci.h b/arch/sh/include/asm/pci.h
index 063c8003b169..6c2d68e08a57 100644
--- a/arch/sh/include/asm/pci.h
+++ b/arch/sh/include/asm/pci.h
@@ -63,8 +63,6 @@ extern int pci_is_66mhz_capable(struct pci_channel *hose,
 
 extern unsigned long PCIBIOS_MIN_IO, PCIBIOS_MIN_MEM;
 
-struct pci_dev;
-
 #define HAVE_PCI_MMAP
 #define ARCH_GENERIC_PCI_MMAP_RESOURCE
 
diff --git a/arch/sparc/include/asm/pci_32.h b/arch/sparc/include/asm/pci_32.h
index b7c092df3134..8b0e26232c78 100644
--- a/arch/sparc/include/asm/pci_32.h
+++ b/arch/sparc/include/asm/pci_32.h
@@ -20,8 +20,6 @@
  */
 #define PCI_DMA_BUS_IS_PHYS	(0)
 
-struct pci_dev;
-
 #endif /* __KERNEL__ */
 
 #ifndef CONFIG_LEON_PCI
diff --git a/arch/xtensa/include/asm/pci.h b/arch/xtensa/include/asm/pci.h
index e4f366a488d3..5c83798e3b2e 100644
--- a/arch/xtensa/include/asm/pci.h
+++ b/arch/xtensa/include/asm/pci.h
@@ -37,8 +37,6 @@ extern struct pci_controller* pcibios_alloc_controller(void);
 #include <linux/string.h>
 #include <asm/io.h>
 
-struct pci_dev;
-
 /* The PCI address space does equal the physical memory address space.
  * The networking and block device layers use this boolean for bounce buffer
  * decisions.

