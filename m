From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 21 Jan 2015 00:30:25 +0000
Subject: [PATCH v2 30/30] PCI: Remove pci_bus_assign_domain_nr()
Message-Id: <1421800225-26230-31-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421800225-26230-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Now we save the domain number in pci_host_bridge,
we could remove pci_bus_assign_domain_nr() and
clean the domain member in pci_bus.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci.c   |    5 -----
 drivers/pci/probe.c |   12 ++++--------
 include/linux/pci.h |    3 ---
 3 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 0af5ef1..7ad1e59 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4521,11 +4521,6 @@ void pci_host_assign_domain_nr(struct pci_host_bridge *host)
 {
 	host->domain = pci_assign_domain_nr(host->dev.parent);
 }
-
-void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
-{
-	bus->domain_nr = pci_assign_domain_nr(parent);
-}
 #endif
 #endif
 
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 70e28d9..dabf4ca 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -480,7 +480,7 @@ void pci_read_bridge_bases(struct pci_bus *child)
 	}
 }
 
-static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
+static struct pci_bus *pci_alloc_bus(void)
 {
 	struct pci_bus *b;
 
@@ -495,10 +495,7 @@ static struct pci_bus *pci_alloc_bus(struct pci_bus *parent)
 	INIT_LIST_HEAD(&b->resources);
 	b->max_bus_speed = PCI_SPEED_UNKNOWN;
 	b->cur_bus_speed = PCI_SPEED_UNKNOWN;
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-	if (parent)
-		b->domain_nr = parent->domain_nr;
-#endif
+
 	return b;
 }
 
@@ -645,7 +642,7 @@ static struct pci_bus *pci_alloc_child_bus(struct pci_bus *parent,
 	/*
 	 * Allocate a new bus, and inherit stuff from the parent..
 	 */
-	child = pci_alloc_bus(parent);
+	child = pci_alloc_bus();
 	if (!child)
 		return NULL;
 
@@ -1865,14 +1862,13 @@ static struct pci_bus *pci_create_root_bus(
 	char *fmt;
 
 	parent = bridge->dev.parent;
-	b = pci_alloc_bus(NULL);
+	b = pci_alloc_bus();
 	if (!b)
 		return NULL;
 
 	b->sysdata = dev_get_drvdata(&bridge->dev);
 	b->ops = ops;
 	b->number = b->busn_res.start = bridge->busnum;
-	pci_bus_assign_domain_nr(b, parent);
 
 	bridge->bus = b;
 	b->bridge = get_device(&bridge->dev);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 57e7e00..90fb71a 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -471,9 +471,6 @@ struct pci_bus {
 	unsigned char	primary;	/* number of primary bridge */
 	unsigned char	max_bus_speed;	/* enum pci_bus_speed */
 	unsigned char	cur_bus_speed;	/* enum pci_bus_speed */
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
-	int		domain_nr;
-#endif
 
 	char		name[48];
 
-- 
1.7.1

