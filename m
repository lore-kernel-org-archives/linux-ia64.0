From: Jiang Liu <liuj97@gmail.com>
Date: Sat, 25 May 2013 13:48:33 +0000
Subject: [PATCH v3, part1 05/10] PCI, IA64: minor code clean up
Message-Id: <1369489718-25869-6-git-send-email-jiang.liu@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1369489718-25869-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369489718-25869-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, Myron Stowe <myron.stowe@redhat.com>, Yijing Wang <wangyijing@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

pci_scan_root_bus() already set bus->sysdata, so no need to explicitly
set it again in function sn_pci_controller_fixup();

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/ia64/sn/kernel/io_init.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 238e2c5..e2c7733 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -326,16 +326,7 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, controller,
 				&resources);
  	if (bus = NULL)
- 		goto error_return; /* error, or bus already scanned */
-
-	bus->sysdata = controller;
-
-	return;
-
-error_return:
-
-	kfree(controller);
-	return;
+		kfree(controller);
 }
 
 /*
-- 
1.8.1.2

