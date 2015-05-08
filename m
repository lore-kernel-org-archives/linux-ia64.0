From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 08 May 2015 07:22:53 +0000
Subject: [PATCH Part3 v11 3/9] PCI: Remove declaration for pci_get_new_domain_nr()
Message-Id: <1431069779-29346-4-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-arm-kernel@lists.infradead.org, Liviu Dudau <liviu@dudau.co.uk>, x86@kernel.org, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, dja@axtens.net, Arnd Bergmann <arnd@arndb.de>, Yijing Wang <wangyijing@huawei.com>

pci_get_new_domain_nr() is only used in drivers/pci/pci.c,
remove the declaration in include/linux/pci.h.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci.c   |    4 ++--
 include/linux/pci.h |    3 ---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index acc4b6e..7bf27e8 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -4498,14 +4498,14 @@ static void pci_no_domains(void)
 }
 
 #ifdef CONFIG_PCI_DOMAINS
+#ifdef CONFIG_PCI_DOMAINS_GENERIC
 static atomic_t __domain_nr = ATOMIC_INIT(-1);
 
-int pci_get_new_domain_nr(void)
+static int pci_get_new_domain_nr(void)
 {
 	return atomic_inc_return(&__domain_nr);
 }
 
-#ifdef CONFIG_PCI_DOMAINS_GENERIC
 void pci_bus_assign_domain_nr(struct pci_bus *bus, struct device *parent)
 {
 	static int use_dt_domains = -1;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 5ff35cb..636c0a9 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1314,12 +1314,10 @@ void pci_cfg_access_unlock(struct pci_dev *dev);
  */
 #ifdef CONFIG_PCI_DOMAINS
 extern int pci_domains_supported;
-int pci_get_new_domain_nr(void);
 #else
 enum { pci_domains_supported = 0 };
 static inline int pci_domain_nr(struct pci_bus *bus) { return 0; }
 static inline int pci_proc_domain(struct pci_bus *bus) { return 0; }
-static inline int pci_get_new_domain_nr(void) { return -ENOSYS; }
 #endif /* CONFIG_PCI_DOMAINS */
 
 /*
@@ -1442,7 +1440,6 @@ static inline struct pci_dev *pci_get_bus_and_slot(unsigned int bus,
 
 static inline int pci_domain_nr(struct pci_bus *bus) { return 0; }
 static inline struct pci_dev *pci_dev_get(struct pci_dev *dev) { return NULL; }
-static inline int pci_get_new_domain_nr(void) { return -ENOSYS; }
 
 #define dev_is_pci(d) (false)
 #define dev_is_pf(d) (false)
-- 
1.7.1

