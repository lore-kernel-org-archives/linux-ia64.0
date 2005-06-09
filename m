From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 09 Jun 2005 12:53:28 +0000
Subject: [PATCH 04/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42A83BC8.2010500@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com>
In-Reply-To: <42A8386F.2060100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org
Cc: Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

[This is 4 of 10 patches, "iochk-04-register_bridge.patch"]

- Since there could be a (PCI-)bus-error, some kind of error
   cannot detected on the device but on its hosting bridge.
   So, it is also required to check the bridge's register.

   In other words, to check a bus-error correctly, we need to
   check both end of the bus, device and its host bridge.

OK, but often bridges are shared by multiple devices, right?
So we need care to handle it... Yes, see next (5 of 10).

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---

  arch/ia64/lib/iomap_check.c |   19 ++++++++++++++++++-
  include/asm-ia64/io.h       |    1 +
  2 files changed, 19 insertions(+), 1 deletion(-)

Index: linux-2.6.11.11/arch/ia64/lib/iomap_check.c
=================================--- linux-2.6.11.11.orig/arch/ia64/lib/iomap_check.c
+++ linux-2.6.11.11/arch/ia64/lib/iomap_check.c
@@ -14,6 +14,7 @@ int  iochk_read(iocookie *cookie);
  struct list_head iochk_devices;
  DEFINE_SPINLOCK(iochk_lock);	/* all works are excluded on this lock */

+static struct pci_dev *search_host_bridge(struct pci_dev *dev);
  static int have_error(struct pci_dev *dev);

  void iochk_init(void)
@@ -29,6 +30,7 @@ void iochk_clear(iocookie *cookie, struc
  	INIT_LIST_HEAD(&(cookie->list));

  	cookie->dev = dev;
+	cookie->host = search_host_bridge(dev);

  	spin_lock_irqsave(&iochk_lock, flag);
  	list_add(&cookie->list, &iochk_devices);
@@ -43,7 +45,8 @@ int iochk_read(iocookie *cookie)
  	int ret = 0;

  	spin_lock_irqsave(&iochk_lock, flag);
-	if( cookie->error || have_error(cookie->dev) )
+	if( cookie->error || have_error(cookie->dev)
+		|| (cookie->host && have_error(cookie->host)) )
  		ret = 1;
  	list_del(&cookie->list);
  	spin_unlock_irqrestore(&iochk_lock, flag);
@@ -51,6 +54,20 @@ int iochk_read(iocookie *cookie)
  	return ret;
  }

+struct pci_dev *search_host_bridge(struct pci_dev *dev)
+{
+	struct pci_bus *pbus;
+
+	/* there is no bridge */
+	if (!dev->bus->self) return NULL;
+
+	/* find root bus bridge */
+	for (pbus = dev->bus; pbus->parent && pbus->parent->self;
+		pbus = pbus->parent);
+
+	return pbus->self;
+}
+
  static int have_error(struct pci_dev *dev)
  {
  	u16 status;
Index: linux-2.6.11.11/include/asm-ia64/io.h
=================================--- linux-2.6.11.11.orig/include/asm-ia64/io.h
+++ linux-2.6.11.11/include/asm-ia64/io.h
@@ -78,6 +78,7 @@ extern unsigned int num_io_spaces;
  struct __iocookie {
  	struct list_head	list;
  	struct pci_dev		*dev;	/* targeting device */
+	struct pci_dev		*host;	/* hosting bridge */
  	unsigned long		error;	/* error flag */
  };
  typedef struct __iocookie iocookie;

