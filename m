From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 16 Jan 2015 01:44:06 +0000
Subject: [PATCH 08/28] PCI: Introduce pci_host_assign_domain_nr() to assign domain
Message-Id: <1421372666-12288-9-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Introduce pci_host_assign_domain_nr() to assign domain
number for pci_host_bridge. Later we will remove
pci_bus_assign_domain_nr().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci.c   |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/pci.h |    4 ++++
 2 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index c419554..8b35e8e 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4443,6 +4443,53 @@ int pci_get_new_domain_nr(void)
 }
 
 #ifdef CONFIG_PCI_DOMAINS_GENERIC
+void pci_host_assign_domain_nr(struct pci_host_bridge *host)
+{
+	static int use_dt_domains = -1;
+	struct device *parent = host->dev.parent;
+	int domain = of_get_pci_domain_nr(parent->of_node);
+
+	/*
+	 * Check DT domain and use_dt_domains values.
+	 *
+	 * If DT domain property is valid (domain >= 0) and
+	 * use_dt_domains != 0, the DT assignment is valid since this means
+	 * we have not previously allocated a domain number by using
+	 * pci_get_new_domain_nr(); we should also update use_dt_domains to
+	 * 1, to indicate that we have just assigned a domain number from
+	 * DT.
+	 *
+	 * If DT domain property value is not valid (ie domain < 0), and we
+	 * have not previously assigned a domain number from DT
+	 * (use_dt_domains != 1) we should assign a domain number by
+	 * using the:
+	 *
+	 * pci_get_new_domain_nr()
+	 *
+	 * API and update the use_dt_domains value to keep track of method we
+	 * are using to assign domain numbers (use_dt_domains = 0).
+	 *
+	 * All other combinations imply we have a platform that is trying
+	 * to mix domain numbers obtained from DT and pci_get_new_domain_nr(),
+	 * which is a recipe for domain mishandling and it is prevented by
+	 * invalidating the domain value (domain = -1) and printing a
+	 * corresponding error.
+	 */
+	if (domain >= 0 && use_dt_domains) {
+		use_dt_domains = 1;
+	} else if (domain < 0 && use_dt_domains != 1) {
+		use_dt_domains = 0;
+		domain = pci_get_new_domain_nr();
+	} else {
+		dev_err(parent, "Node %s has inconsistent \"linux,pci-domain\" property in DT\n",
+			parent->of_node->full_name);
+		domain = -1;
+	}
+
+	host->domain_nr = domain;
+}
+
+
 void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
 {
 	static int use_dt_domains = -1;
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

