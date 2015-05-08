From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 08 May 2015 07:22:59 +0000
Subject: [PATCH Part3 v11 9/9] PCI: Remove pci_bus_assign_domain_nr()
Message-Id: <1431069779-29346-10-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-arm-kernel@lists.infradead.org, Liviu Dudau <liviu@dudau.co.uk>, x86@kernel.org, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, dja@axtens.net, Arnd Bergmann <arnd@arndb.de>, Yijing Wang <wangyijing@huawei.com>

Now we save the domain number in pci_host_bridge,
we could remove pci_bus_assign_domain_nr() and
clean the domain member in pci_bus.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci.c   |    5 -----
 drivers/pci/pci.h   |    9 ---------
 drivers/pci/probe.c |   11 +++--------
 include/linux/pci.h |    3 ---
 4 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 2e2f429..a3cb571 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4558,11 +4558,6 @@ static int pci_assign_domain_nr(struct device *dev)
 
 	return domain;
 }
-
-void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
-{
-	bus->domain_nr = pci_assign_domain_nr(parent);
-}
 #endif
 #endif
 
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index c2e1a6b..d8a4238 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -325,14 +325,5 @@ static inline int pci_dev_specific_reset(struct pci_dev *dev, int probe)
 
 struct pci_host_bridge *pci_find_host_bridge(struct pci_bus *bus);
 
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent);
-#else
-static inline void pci_bus_assign_domain_nr(struct pci_bus *bus,
-					struct device *parent)
-{
-}
-#endif
-
 void pci_host_assign_domain_nr(struct pci_host_bridge *host, int domain);
 #endif /* DRIVERS_PCI_H */
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index e4ef791..be60074 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -481,7 +481,7 @@ void pci_read_bridge_bases(struct pci_bus *child)
 	}
 }
 
-static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
+static struct pci_bus *pci_alloc_bus(void)
 {
 	struct pci_bus *b;
 
@@ -496,10 +496,6 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
 	INIT_LIST_HEAD(&b->resources);
 	b->max_bus_speed = PCI_SPEED_UNKNOWN;
 	b->cur_bus_speed = PCI_SPEED_UNKNOWN;
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-	if (parent)
-		b->domain_nr = parent->domain_nr;
-#endif
 	return b;
 }
 
@@ -670,7 +666,7 @@ static struct pci_bus *pci_alloc_child_bus(struct pci_bus *parent,
 	/*
 	 * Allocate a new bus, and inherit stuff from the parent..
 	 */
-	child = pci_alloc_bus(parent);
+	child = pci_alloc_bus();
 	if (!child)
 		return NULL;
 
@@ -1936,7 +1932,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 		goto unregister_host;
 	}
 
-	b = pci_alloc_bus(NULL);
+	b = pci_alloc_bus();
 	if (!b)
 		goto unregister_host;
 
@@ -1944,7 +1940,6 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 	b->sysdata = sysdata;
 	b->ops = ops;
 	b->number = b->busn_res.start = bus;
-	pci_bus_assign_domain_nr(b, parent);
 
 	b->bridge = get_device(&bridge->dev);
 	device_enable_async_suspend(b->bridge);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 13ed681..f010042 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -460,9 +460,6 @@ struct pci_bus {
 	unsigned char	primary;	/* number of primary bridge */
 	unsigned char	max_bus_speed;	/* enum pci_bus_speed */
 	unsigned char	cur_bus_speed;	/* enum pci_bus_speed */
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-	int		domain_nr;
-#endif
 
 	char		name[48];
 
-- 
1.7.1

