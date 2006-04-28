From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 28 Apr 2006 02:50:43 +0000
Subject: [PATCH] Make PCI Express support selectable
Message-Id: <44518303.2030500@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

When I tried to use PCI Express Hotplug driver on my ia64 box, I
noticed that "PCI Express support" is not even selectable on ia64.
The attached patch make PCI Express support selectable.

Thanks,
Kenji Kaneshige


This patch makes PCI Express support selectable.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6.17-rc3/arch/ia64/Kconfig
=================================--- linux-2.6.17-rc3.orig/arch/ia64/Kconfig	2006-04-28 11:11:04.000000000 +0900
+++ linux-2.6.17-rc3/arch/ia64/Kconfig	2006-04-28 11:13:19.000000000 +0900
@@ -447,6 +447,8 @@
 	bool
 	default PCI
 
+source "drivers/pci/pcie/Kconfig"
+
 source "drivers/pci/Kconfig"
 
 source "drivers/pci/hotplug/Kconfig"
