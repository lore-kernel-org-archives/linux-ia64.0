From: Bjorn Helgaas <helgaas@kernel.org>
Date: Thu, 05 Oct 2017 20:39:06 +0000
Subject: [PATCH 4/4] alpha/PCI: Make pdev_save_srm_config() static
Message-Id: <20171005203906.18300.63272.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20171005201939.18300.25690.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Howells <dhowells@redhat.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Jesper Nilsson <jesper.nilsson@axis.com>, linux-am33-list@redhat.com, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, Helge Deller <deller@gmx.de>, x86@kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-xtensa@linux-xtensa.org, Mikael Starvik <starvik@axis.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Thomas Gleixner <tglx@linutronix.de>, Richard Henderson <rth@twiddle.net>, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

From: Bjorn Helgaas <bhelgaas@google.com>

pdev_save_srm_config() and struct pdev_srm_saved_conf are only used in
arch/alpha/kernel/pci.c, so make them static there.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/alpha/kernel/pci.c      |   11 ++++++++++-
 arch/alpha/kernel/pci_impl.h |    8 --------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
index 564114eb85e1..16b67621a0d5 100644
--- a/arch/alpha/kernel/pci.c
+++ b/arch/alpha/kernel/pci.c
@@ -196,9 +196,16 @@ pcibios_init(void)
 subsys_initcall(pcibios_init);
 
 #ifdef ALPHA_RESTORE_SRM_SETUP
+/* Store PCI device configuration left by SRM here. */
+struct pdev_srm_saved_conf
+{
+	struct pdev_srm_saved_conf *next;
+	struct pci_dev *dev;
+};
+
 static struct pdev_srm_saved_conf *srm_saved_configs;
 
-void pdev_save_srm_config(struct pci_dev *dev)
+static void pdev_save_srm_config(struct pci_dev *dev)
 {
 	struct pdev_srm_saved_conf *tmp;
 	static int printed = 0;
@@ -238,6 +245,8 @@ pci_restore_srm_config(void)
 		pci_restore_state(tmp->dev);
 	}
 }
+#else
+#define pdev_save_srm_config(dev)	do {} while (0)
 #endif
 
 void pcibios_fixup_bus(struct pci_bus *bus)
diff --git a/arch/alpha/kernel/pci_impl.h b/arch/alpha/kernel/pci_impl.h
index 2b0ac429f5eb..65adea0d3d78 100644
--- a/arch/alpha/kernel/pci_impl.h
+++ b/arch/alpha/kernel/pci_impl.h
@@ -156,16 +156,8 @@ struct pci_iommu_arena
 #endif
 
 #ifdef ALPHA_RESTORE_SRM_SETUP
-/* Store PCI device configuration left by SRM here. */
-struct pdev_srm_saved_conf
-{
-	struct pdev_srm_saved_conf *next;
-	struct pci_dev *dev;
-};
-
 extern void pci_restore_srm_config(void);
 #else
-#define pdev_save_srm_config(dev)	do {} while (0)
 #define pci_restore_srm_config()	do {} while (0)
 #endif
 

