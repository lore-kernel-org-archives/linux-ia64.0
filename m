From: Yinghai Lu <yinghai@kernel.org>
Date: Wed, 29 Feb 2012 23:07:25 +0000
Subject: [PATCH 26/39] PCI, ia64: Register busn_res for root buses
Message-Id: <1330556858-11768-27-git-send-email-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1330556858-11768-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <1330556858-11768-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@virtuousgeek.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, David Miller <davem@davemloft.net>, x86 <x86@kernel.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Dominik Brodowski <linux@dominikbrodowski.net>, linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

-v2: according to Bjorn, use root->secondary directly.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/pci/pci.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index d1ce320..6c7c4ae 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -352,6 +352,8 @@ pci_acpi_scan_root(struct acpi_pci_root *root)
 #endif
 
 	INIT_LIST_HEAD(&info.resources);
+	/* insert busn resource at first */
+	pci_add_resource(&info.resources, &root->secondary);
 	acpi_walk_resources(device->handle, METHOD_NAME__CRS, count_window,
 			&windows);
 	if (windows) {
-- 
1.7.7

