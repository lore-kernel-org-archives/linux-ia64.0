From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 03 Apr 2015 09:26:03 +0000
Subject: [PATCH v9 29/30] PCI: Remove pci_bus_assign_domain_nr()
Message-Id: <1428053164-28277-31-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now we save the domain number in pci_host_bridge,
we could remove pci_bus_assign_domain_nr() and
clean the domain member in pci_bus. Also move
pci_host_assign_domain_nr() to drivers/pci/host-bridge.c
for simplicity.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/host-bridge.c |   63 ++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/pci.c         |   67 ---------------------------------------------
 drivers/pci/pci.h         |   13 ---------
 drivers/pci/probe.c       |   11 ++-----
 include/linux/pci.h       |    3 --
 5 files changed, 66 insertions(+), 91 deletions(-)

diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
index 04c69c5..f193136 100644
--- a/drivers/pci/host-bridge.c
+++ b/drivers/pci/host-bridge.c
@@ -11,6 +11,8 @@
 static LIST_HEAD(pci_host_bridge_list);
 static DEFINE_MUTEX(pci_host_mutex);
 
+static void pci_host_assign_domain_nr(struct pci_host_bridge *host);
+
 static void pci_release_host_bridge_dev(struct device *dev)
 {
 	struct pci_host_bridge *bridge = to_pci_host_bridge(dev);
@@ -159,8 +161,69 @@ int pci_domain_nr(struct pci_bus *bus)
 	return host->domain;
 }
 EXPORT_SYMBOL(pci_domain_nr);
+
+static atomic_t __domain_nr = ATOMIC_INIT(-1);
+
+int pci_get_new_domain_nr(void)
+{
+	return atomic_inc_return(&__domain_nr);
+}
+
+#ifdef CONFIG_PCI_DOMAINS_GENERIC
+static int pci_assign_domain_nr(struct device *dev)
+{
+	static int use_dt_domains = -1;
+	int domain = of_get_pci_domain_nr(dev->of_node);
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
+		dev_err(dev, "Node %s has inconsistent \"linux,pci-domain\" property in DT\n",
+			dev->of_node->full_name);
+		domain = -1;
+	}
+
+	return domain;
+}
+#endif
 #endif
 
+static void pci_host_assign_domain_nr(struct pci_host_bridge *host)
+{
+#ifdef CONFIG_PCI_DOMAINS_GENERIC
+	host->domain = pci_assign_domain_nr(host->dev.parent);
+#endif
+}
+
 void pci_set_host_bridge_release(struct pci_host_bridge *bridge,
 				 void (*release_fn)(struct pci_host_bridge *),
 				 void *release_data)
diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 8a2f12c..044801c 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4515,73 +4515,6 @@ static void pci_no_domains(void)
 #endif
 }
 
-#ifdef CONFIG_PCI_DOMAINS
-static atomic_t __domain_nr = ATOMIC_INIT(-1);
-
-int pci_get_new_domain_nr(void)
-{
-	return atomic_inc_return(&__domain_nr);
-}
-
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-static int pci_assign_domain_nr(struct device *dev)
-{
-	static int use_dt_domains = -1;
-	int domain = of_get_pci_domain_nr(dev->of_node);
-
-	/*
-	 * Check DT domain and use_dt_domains values.
-	 *
-	 * If DT domain property is valid (domain >= 0) and
-	 * use_dt_domains != 0, the DT assignment is valid since this means
-	 * we have not previously allocated a domain number by using
-	 * pci_get_new_domain_nr(); we should also update use_dt_domains to
-	 * 1, to indicate that we have just assigned a domain number from
-	 * DT.
-	 *
-	 * If DT domain property value is not valid (ie domain < 0), and we
-	 * have not previously assigned a domain number from DT
-	 * (use_dt_domains != 1) we should assign a domain number by
-	 * using the:
-	 *
-	 * pci_get_new_domain_nr()
-	 *
-	 * API and update the use_dt_domains value to keep track of method we
-	 * are using to assign domain numbers (use_dt_domains = 0).
-	 *
-	 * All other combinations imply we have a platform that is trying
-	 * to mix domain numbers obtained from DT and pci_get_new_domain_nr(),
-	 * which is a recipe for domain mishandling and it is prevented by
-	 * invalidating the domain value (domain = -1) and printing a
-	 * corresponding error.
-	 */
-	if (domain >= 0 && use_dt_domains) {
-		use_dt_domains = 1;
-	} else if (domain < 0 && use_dt_domains != 1) {
-		use_dt_domains = 0;
-		domain = pci_get_new_domain_nr();
-	} else {
-		dev_err(dev, "Node %s has inconsistent \"linux,pci-domain\" property in DT\n",
-			dev->of_node->full_name);
-		domain = -1;
-	}
-
-	return domain;
-}
-
-void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
-{
-	bus->domain_nr = pci_assign_domain_nr(parent);
-}
-
-void pci_host_assign_domain_nr(struct pci_host_bridge *host)
-{
-	host->domain = pci_assign_domain_nr(host->dev.parent);
-}
-
-#endif
-#endif
-
 /**
  * pci_ext_cfg_avail - can we access extended PCI config space?
  *
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index ef10cc1..a6e4d8f 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -321,19 +321,6 @@ static inline int pci_dev_specific_reset(struct pci_dev *dev, int probe)
 }
 #endif
 
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent);
-void pci_host_assign_domain_nr(struct pci_host_bridge *host);
-#else
-static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
-					struct device *parent)
-{
-}
-static inline void pci_host_assign_domain_nr(struct pci_host_bridge *host)
-{
-}
-#endif
-
 struct pci_host_bridge *pci_create_host_bridge(
 		struct device *parent, int domain, int bus, void *sysdata,
 		struct list_head *resources, struct pci_host_bridge_ops *ops);
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index cb0237f..53e4887 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -480,7 +480,7 @@ void pci_read_bridge_bases(struct pci_bus *child)
 	}
 }
 
-static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
+static struct pci_bus *pci_alloc_bus(void)
 {
 	struct pci_bus *b;
 
@@ -495,10 +495,6 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
 	INIT_LIST_HEAD(&b->resources);
 	b->max_bus_speed = PCI_SPEED_UNKNOWN;
 	b->cur_bus_speed = PCI_SPEED_UNKNOWN;
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-	if (parent)
-		b->domain_nr = parent->domain_nr;
-#endif
 	return b;
 }
 
@@ -645,7 +641,7 @@ static struct pci_bus *pci_alloc_child_bus(struct pci_bus *parent,
 	/*
 	 * Allocate a new bus, and inherit stuff from the parent..
 	 */
-	child = pci_alloc_bus(parent);
+	child = pci_alloc_bus();
 	if (!child)
 		return NULL;
 
@@ -1865,7 +1861,7 @@ static struct pci_bus *pci_create_root_bus(
 	char *fmt;
 
 	parent = bridge->dev.parent;
-	b = pci_alloc_bus(NULL);
+	b = pci_alloc_bus();
 	if (!b)
 		return NULL;
 
@@ -1873,7 +1869,6 @@ static struct pci_bus *pci_create_root_bus(
 	b->ops = ops;
 	b->number = b->busn_res.start  		pci_host_first_busnr(bridge);
-	pci_bus_assign_domain_nr(b, parent);
 
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index c2c6675..7ef205c 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -469,9 +469,6 @@ struct pci_bus {
 	unsigned char	primary;	/* number of primary bridge */
 	unsigned char	max_bus_speed;	/* enum pci_bus_speed */
 	unsigned char	cur_bus_speed;	/* enum pci_bus_speed */
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-	int		domain_nr;
-#endif
 
 	char		name[48];
 
-- 
1.7.1

