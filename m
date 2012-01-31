From: Yinghai Lu <yinghai@kernel.org>
Date: Tue, 31 Jan 2012 07:42:44 +0000
Subject: [PATCH 06/14] PCI, ia64: Register busn_res for root buses
Message-Id: <1327995772-11388-7-git-send-email-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1327995772-11388-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <1327995772-11388-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@virtuousgeek.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/pci/pci.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index f82f5d4..936b2f1 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -331,6 +331,7 @@ pci_acpi_scan_root(struct acpi_pci_root *root)
 	struct acpi_device *device = root->device;
 	int domain = root->segment;
 	int bus = root->secondary.start;
+	int busmax = root->secondary.end;
 	struct pci_controller *controller;
 	unsigned int windows = 0;
 	struct pci_root_info info;
@@ -384,6 +385,7 @@ pci_acpi_scan_root(struct acpi_pci_root *root)
 		return NULL;
 	}
 
+	pci_bus_insert_busn_res(pbus, busnum, busmax);
 	pbus->subordinate = pci_scan_child_bus(pbus);
 	return pbus;
 
-- 
1.7.7

