From: Jiang Liu <liuj97@gmail.com>
Date: Tue, 26 Feb 2013 15:25:47 +0000
Subject: [PATCH v8 07/13] PCI, IA64: implement pcibios_{add|remove}_bus() hooks
Message-Id: <1361892353-14786-8-git-send-email-jiang.liu@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1361892353-14786-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1361892353-14786-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, "Rafael J . Wysocki" <rjw@sisk.pl>
Cc: Jiang Liu <jiang.liu@huawei.com>, Yinghai Lu <yinghai@kernel.org>, Yijing Wang <wangyijing@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Myron Stowe <myron.stowe@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Implement pcibios_{add|remove}_bus() hooks for IA64 platforms.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/ia64/pci/pci.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 00e59c7..e60aeb7 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -15,6 +15,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
+#include <linux/pci-acpi.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
@@ -463,6 +464,16 @@ pcibios_fixup_bus (struct pci_bus *b)
 	platform_pci_fixup_bus(b);
 }
 
+void pcibios_add_bus(struct pci_bus *bus)
+{
+	acpi_pci_add_bus(bus);
+}
+
+void pcibios_remove_bus(struct pci_bus *bus)
+{
+	acpi_pci_remove_bus(bus);
+}
+
 void pcibios_set_master (struct pci_dev *dev)
 {
 	/* No special bus mastering setup handling */
-- 
1.7.9.5

