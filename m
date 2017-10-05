From: Bjorn Helgaas <helgaas@kernel.org>
Date: Thu, 05 Oct 2017 20:38:56 +0000
Subject: [PATCH 3/4] PCI: Remove unused declarations
Message-Id: <20171005203856.18300.62381.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Jesper Nilsson <jesper.nilsson@axis.com>, linux-am33-list@redhat.com, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, x86@kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-xtensa@linux-xtensa.org, Mikael Starvik <starvik@axis.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Thomas Gleixner <tglx@linutronix.de>, Richard Henderson <rth@twiddle.net>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

From: Bjorn Helgaas <bhelgaas@google.com>

Remove these unused declarations:

  pcibios_config_init()              # never defined anywhere
  pcibios_scan_root()                # only defined by x86
  pcibios_get_irq_routing_table()    # only defined by x86
  pcibios_set_irq_routing()          # only defined by x86

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/cris/include/asm/pci.h             |    6 ------
 arch/ia64/include/asm/pci.h             |    2 --
 arch/mn10300/unit-asb2305/pci-asb2305.h |    3 ---
 arch/x86/include/asm/pci.h              |    1 -
 4 files changed, 12 deletions(-)

diff --git a/arch/cris/include/asm/pci.h b/arch/cris/include/asm/pci.h
index 8ea640560a46..141337bf16bc 100644
--- a/arch/cris/include/asm/pci.h
+++ b/arch/cris/include/asm/pci.h
@@ -16,12 +16,6 @@
 
 #define PCIBIOS_MIN_CARDBUS_IO	0x4000
 
-void pcibios_config_init(void);
-struct pci_bus * pcibios_scan_root(int bus);
-
-struct irq_routing_table *pcibios_get_irq_routing_table(void);
-int pcibios_set_irq_routing(struct pci_dev *dev, int pin, int irq);
-
 /* Dynamic DMA mapping stuff.
  * i386 has everything mapped statically.
  */
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 8c4b37f6be3d..915531ede6a5 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -29,8 +29,6 @@ struct pci_vector_struct {
 #define PCIBIOS_MIN_IO		0x1000
 #define PCIBIOS_MIN_MEM		0x10000000
 
-void pcibios_config_init(void);
-
 /*
  * PCI_DMA_BUS_IS_PHYS should be set to 1 if there is _necessarily_ a direct
  * correspondence between device bus addresses and CPU physical addresses.
diff --git a/arch/mn10300/unit-asb2305/pci-asb2305.h b/arch/mn10300/unit-asb2305/pci-asb2305.h
index 96c484b12226..0667f613b023 100644
--- a/arch/mn10300/unit-asb2305/pci-asb2305.h
+++ b/arch/mn10300/unit-asb2305/pci-asb2305.h
@@ -30,9 +30,6 @@ extern void pcibios_resource_survey(void);
 
 extern struct pci_ops *pci_root_ops;
 
-extern struct irq_routing_table *pcibios_get_irq_routing_table(void);
-extern int pcibios_set_irq_routing(struct pci_dev *dev, int pin, int irq);
-
 /* pci-irq.c */
 
 struct irq_info {
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 645019085bb8..53873a875c01 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -88,7 +88,6 @@ extern unsigned long pci_mem_start;
 #define PCIBIOS_MIN_CARDBUS_IO	0x4000
 
 extern int pcibios_enabled;
-void pcibios_config_init(void);
 void pcibios_scan_root(int bus);
 
 struct irq_routing_table *pcibios_get_irq_routing_table(void);

