From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 21 Jan 2015 00:30:03 +0000
Subject: [PATCH v2 08/30] PCI: Introduce pci_host_assign_domain_nr() to assign domain
Message-Id: <1421800225-26230-9-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421800225-26230-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Introduce pci_host_assign_domain_nr() to assign domain
number for pci_host_bridge. Later we will remove
pci_bus_assign_domain_nr().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci.c   |   14 +++++++++++---
 include/linux/pci.h |    4 ++++
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index c419554..3e10772 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4443,10 +4443,10 @@ int pci_get_new_domain_nr(void)
 }
 
 #ifdef CONFIG_PCI_DOMAINS_GENERIC
-void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
+static int pci_assign_domain_nr(struct device *dev)
 {
 	static int use_dt_domains = -1;
-	int domain = of_get_pci_domain_nr(parent->of_node);
+	int domain = of_get_pci_domain_nr(dev->of_node);
 
 	/*
 	 * Check DT domain and use_dt_domains values.
@@ -4484,8 +4484,16 @@ void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
 			parent->of_node->full_name);
 		domain = -1;
 	}
+}
 
-	bus->domain_nr = domain;
+void pci_host_assign_domain_nr(struct pci_host_bridge *host)
+{
+	host->domain = pci_assign_domain_nr(host->dev.parent);
+}
+
+void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
+{
+	bus->domain_nr = pci_assign_domain_nr(parent);
 }
 #endif
 #endif
diff --git a/include/linux/pci.h b/include/linux/pci.h
index c771508..1b9c799 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1316,11 +1316,15 @@ static inline int pci_domain_nr(struct pci_bus *bus)
 	return bus->domain_nr;
 }
 void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent);
+void pci_host_assign_domain_nr(struct pci_host_bridge *host);
 #else
 static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
 					struct device *parent)
 {
 }
+static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
+{
+}
 #endif
 
 /* some architectures require additional setup to direct VGA traffic */
-- 
1.7.1

