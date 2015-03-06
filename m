From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 06 Mar 2015 09:33:35 +0000
Subject: [PATCH v5 18/29] sparc/PCI: Claim bus resources before pci_bus_add_devices()
Message-Id: <1425634426-437-19-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425634426-437-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Pci_claim_bus_resources() should be called before
pci_bus_add_devices(), or driver may failed to
load, because the resources had not claimed.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/sparc/kernel/pci.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 838fe1e..21f804a 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -678,11 +678,10 @@ struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 	}
 
 	pci_of_scan_bus(pbm, node, bus);
-	pci_bus_add_devices(bus);
 	pci_bus_register_of_sysfs(bus);
 
 	pci_claim_bus_resources(bus);
-
+	pci_bus_add_devices(bus);
 	return bus;
 }
 
-- 
1.7.1

